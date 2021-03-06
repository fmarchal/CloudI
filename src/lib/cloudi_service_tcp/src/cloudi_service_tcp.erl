%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et nomod:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==Basic CloudI TCP Integration==
%%% This service requires that the service configuration option
%%% "duo_mode" be set to true (its default is false).
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2013-2015, Michael Truog <mjtruog at gmail dot com>
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%% 
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%     * All advertising materials mentioning features or use of this
%%%       software must display the following acknowledgment:
%%%         This product includes software developed by Michael Truog
%%%     * The name of the author may not be used to endorse or promote
%%%       products derived from this software without specific prior
%%%       written permission
%%% 
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
%%% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
%%% DAMAGE.
%%%
%%% @author Michael Truog <mjtruog [at] gmail (dot) com>
%%% @copyright 2013-2015 Michael Truog
%%% @version 1.5.0 {@date} {@time}
%%%------------------------------------------------------------------------

-module(cloudi_service_tcp).
-author('mjtruog [at] gmail (dot) com').

-behaviour(cloudi_service).

%% external interface

%% cloudi_service callbacks
-export([cloudi_service_init/4,
         cloudi_service_handle_request/11,
         cloudi_service_handle_info/3,
         cloudi_service_terminate/3]).

-include_lib("cloudi_core/include/cloudi_logger.hrl").
-include_lib("cloudi_core/include/cloudi_service_children.hrl").

-define(DEFAULT_INTERFACE,             {127,0,0,1}). % ip address
-define(DEFAULT_PORT,                         8080).
-define(DEFAULT_DESTINATION,             undefined). % service name
-define(DEFAULT_DESTINATION_CONNECT,     undefined). % service name
-define(DEFAULT_DESTINATION_DISCONNECT,  undefined). % service name
-define(DEFAULT_BACKLOG,                       128).
-define(DEFAULT_NODELAY,                      true).
-define(DEFAULT_KEEPALIVE,                    true).
-define(DEFAULT_RECV_TIMEOUT,            30 * 1000). % milliseconds
-define(DEFAULT_MAX_CONNECTIONS,              4096).
-define(DEFAULT_PACKET_TYPE,                  line). % inet:setopts/2 packet
-define(DEFAULT_PACKET_BUFFER_RECV_SIZE, undefined).
-define(DEFAULT_PACKET_BUFFER_SEND_SIZE, undefined).
-define(DEFAULT_PACKET_BUFFER_SIZE,      undefined). % Erlang driver buffer

-record(state,
    {
        listener,
        acceptor,
        timeout_recv,
        socket_options,
        interface_formatted,
        port_formatted,
        service,
        destination,
        destination_connect,
        destination_disconnect,
        connection_count = 0,
        connection_max,
        requests = dict:new()
    }).

-record(state_socket,
    {
        socket,
        timeout_recv,
        service,
        dispatcher,
        context,
        destination,
        destination_disconnect,
        request_info
    }).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

%%%------------------------------------------------------------------------
%%% Callback functions from cloudi_service
%%%------------------------------------------------------------------------

cloudi_service_init(Args, _Prefix, _Timeout, Dispatcher) ->
    Defaults = [
        {ip,                       ?DEFAULT_INTERFACE},
        {port,                     ?DEFAULT_PORT},
        {destination,              ?DEFAULT_DESTINATION},
        {destination_connect,      ?DEFAULT_DESTINATION_CONNECT},
        {destination_disconnect,   ?DEFAULT_DESTINATION_DISCONNECT},
        {backlog,                  ?DEFAULT_BACKLOG},
        {nodelay,                  ?DEFAULT_NODELAY},
        {keepalive,                ?DEFAULT_KEEPALIVE},
        {recv_timeout,             ?DEFAULT_RECV_TIMEOUT},
        {max_connections,          ?DEFAULT_MAX_CONNECTIONS},
        {packet_type,              ?DEFAULT_PACKET_TYPE},
        {packet_buffer_recv_size,  ?DEFAULT_PACKET_BUFFER_RECV_SIZE},
        {packet_buffer_send_size,  ?DEFAULT_PACKET_BUFFER_SEND_SIZE},
        {packet_buffer_size,       ?DEFAULT_PACKET_BUFFER_SIZE}],
    [Interface, Port, Destination, DestinationConnect, DestinationDisconnect,
     Backlog, NoDelay, KeepAlive, RecvTimeout, MaxConnections, PacketType,
     BufferRecvSize, BufferSendSize, BufferSize] =
        cloudi_proplists:take_values(Defaults, Args),
    true = is_integer(Port),
    true = is_list(Destination),
    true = (DestinationConnect =:= undefined) orelse
           is_list(DestinationConnect),
    true = (DestinationDisconnect =:= undefined) orelse
           is_list(DestinationDisconnect),
    true = is_integer(Backlog),
    true = is_boolean(NoDelay),
    true = is_boolean(KeepAlive),
    true = is_integer(RecvTimeout) andalso (RecvTimeout > 0),
    true = (is_integer(MaxConnections) andalso (MaxConnections > 0)),
    true = lists:member(PacketType,
                        [raw, 0, 1, 2, 4, asn1, cdr, sunrm, fcgi, tpkt, line]),
    true = (BufferRecvSize =:= undefined) orelse is_integer(BufferRecvSize),
    true = (BufferSendSize =:= undefined) orelse is_integer(BufferSendSize),
    true = (BufferSize =:= undefined) orelse is_integer(BufferSize),
    SocketOptions0 = [binary, {active, false},
                      {nodelay, NoDelay}, {delay_send, false},
                      {keepalive, KeepAlive}, {packet, PacketType}],
    SocketOptions1 = if
        BufferRecvSize =:= undefined ->
            SocketOptions0;
        true ->
            [{recbuf, BufferRecvSize} | SocketOptions0]
    end,
    SocketOptions2 = if
        BufferSendSize =:= undefined ->
            SocketOptions1;
        true ->
            [{sndbuf, BufferSendSize} | SocketOptions1]
    end,
    SocketOptionsN = if
        BufferSize =:= undefined ->
            SocketOptions2;
        true ->
            [{buffer, BufferSize} | SocketOptions2]
    end,
    case gen_tcp:listen(Port, [{ip, Interface}, {backlog, Backlog},
                               {reuseaddr, true} | SocketOptionsN]) of
        {ok, Listener} ->
            case inet:sockname(Listener) of
                {ok, {InterfaceUsed, PortUsed}} ->
                    InterfaceFormatted =
                        cloudi_ip_address:to_binary(InterfaceUsed),
                    PortFormatted = erlang:integer_to_binary(PortUsed),
                    case prim_inet:async_accept(Listener, -1) of
                        {ok, Acceptor} ->
                            Service = cloudi_service:self(Dispatcher),
                            {ok, #state{listener = Listener,
                                        acceptor = Acceptor,
                                        timeout_recv = RecvTimeout,
                                        socket_options = SocketOptionsN,
                                        interface_formatted =
                                            InterfaceFormatted,
                                        port_formatted =
                                            PortFormatted,
                                        service = Service,
                                        destination = Destination,
                                        destination_connect =
                                            DestinationConnect,
                                        destination_disconnect =
                                            DestinationDisconnect,
                                        connection_max = MaxConnections}};
                        {error, _} = Error ->
                            {stop, Error, #state{listener = Listener}}
                    end;
                {error, _} = Error ->
                    {stop, Error, #state{listener = Listener}}
            end;
        {error, _} = Error ->
            {stop, Error, #state{}}
    end.

cloudi_service_handle_request(_Type, _Name, _Pattern, _RequestInfo, _Request,
                              _Timeout, _Priority, _TransId, _Pid,
                              State, _Dispatcher) ->
    {reply, <<>>, State}.

cloudi_service_handle_info({inet_async, Listener, Acceptor, {ok, Socket}},
                           #state{listener = Listener,
                                  acceptor = Acceptor,
                                  connection_count = ConnectionCount,
                                  connection_max = ConnectionMax} = State,
                           _Dispatcher)
    when ConnectionCount >= ConnectionMax ->
    true = inet_db:register_socket(Socket, inet_tcp),
    catch gen_tcp:close(Socket),
    ?LOG_WARN("max_connections (~p) reached!", [ConnectionMax]),
    case prim_inet:async_accept(Listener, -1) of
        {ok, NewAcceptor} ->
            {noreply, State#state{acceptor = NewAcceptor}};
        {error, _} = Error ->
            {stop, Error, State}
    end;

cloudi_service_handle_info({inet_async, Listener, Acceptor, {ok, Socket}},
                           #state{listener = Listener,
                                  acceptor = Acceptor,
                                  timeout_recv = TimeoutRecv,
                                  socket_options = SocketOptions,
                                  interface_formatted =
                                      DestinationAddressFormatted,
                                  port_formatted =
                                      DestinationPortFormatted,
                                  service = Service,
                                  destination = Destination,
                                  destination_connect =
                                      DestinationConnect,
                                  destination_disconnect =
                                      DestinationDisconnect,
                                  connection_count = ConnectionCount} = State,
                           Dispatcher) ->
    true = inet_db:register_socket(Socket, inet_tcp),
    ok = inet:setopts(Socket, SocketOptions),
    NewConnectionCount = case inet:peername(Socket) of
        {ok, {SourceAddress, SourcePort}} ->
            SourceAddressFormatted = cloudi_ip_address:to_binary(SourceAddress),
            SourcePortFormatted = erlang:integer_to_binary(SourcePort),
            RequestInfo = cloudi_service:request_info_key_value_new(
                [{<<"source_address">>, SourceAddressFormatted},
                 {<<"source_port">>, SourcePortFormatted},
                 {<<"destination_address">>, DestinationAddressFormatted},
                 {<<"destination_port">>, DestinationPortFormatted}]),
            SocketPid = proc_lib:spawn_opt(fun() ->
                Context = create_context(Dispatcher),
                socket_loop_init(DestinationConnect,
                                 #state_socket{socket = Socket,
                                               timeout_recv = TimeoutRecv,
                                               service = Service,
                                               dispatcher = Dispatcher,
                                               context = Context,
                                               destination = Destination,
                                               destination_disconnect =
                                                   DestinationDisconnect,
                                               request_info = RequestInfo})
            end, [link]),
            case gen_tcp:controlling_process(Socket, SocketPid) of
                ok = InitSuccess ->
                    SocketPid ! {init, InitSuccess};
                {error, _} = InitError ->
                    SocketPid ! {init, InitError}
            end,
            ConnectionCount + 1;
        {error, Reason} ->
            ?LOG_ERROR("socket accept error: ~p", [Reason]),
            catch gen_tcp:close(Socket),
            ConnectionCount
    end,
    case prim_inet:async_accept(Listener, -1) of
        {ok, NewAcceptor} ->
            {noreply, State#state{acceptor = NewAcceptor,
                                  connection_count = NewConnectionCount}};
        {error, _} = Error ->
            {stop, Error, State#state{connection_count = NewConnectionCount}}
    end;

cloudi_service_handle_info({inet_async, _Listener, _Acceptor, Error},
                           State, _Dispatcher) ->
    {stop, Error, State};

cloudi_service_handle_info(socket_closed,
                           #state{connection_count = ConnectionCount} = State,
                           _Dispatcher) ->
    {noreply, State#state{connection_count = ConnectionCount - 1}};

cloudi_service_handle_info(Request, State, _Dispatcher) ->
    ?LOG_WARN("Unknown info \"~p\"", [Request]),
    {noreply, State}.

cloudi_service_terminate(_Reason, _Timeout,
                         #state{listener = Listener}) ->
    catch gen_tcp:close(Listener),
    ok.

%%%------------------------------------------------------------------------
%%% Private functions
%%%------------------------------------------------------------------------

socket_loop_init(DestinationConnect,
                 #state_socket{socket = Socket,
                               dispatcher = Dispatcher,
                               context = Context,
                               request_info = RequestInfo} = StateSocket) ->
    receive
        {init, ok} ->
            NewStateSocket = if
                is_list(DestinationConnect) ->
                    case send_sync_minimal(Dispatcher, Context,
                                           DestinationConnect, RequestInfo,
                                           <<"CONNECT">>, self()) of
                        {{ok, ResponseInfo, Response}, NewContext} ->
                            socket_response_info_check(Socket, ResponseInfo),
                            socket_send(Response, StateSocket),
                            StateSocket#state_socket{context = NewContext};
                        {{error, timeout}, NewContext} ->
                            socket_send(<<>>, StateSocket),
                            StateSocket#state_socket{context = NewContext}
                    end;
                true ->
                    StateSocket
            end,
            ok = inet:setopts(Socket, [{active, once}]),
            socket_loop(NewStateSocket);
        {init, Error} ->
            socket_loop_terminate(Error, StateSocket)
    end.

socket_loop(#state_socket{socket = Socket,
                          timeout_recv = TimeoutRecv,
                          dispatcher = Dispatcher,
                          context = Context,
                          destination = Destination,
                          request_info = RequestInfo} = StateSocket) ->
    receive
        {tcp, Socket, Request} ->
            NewStateSocket = case send_sync_minimal(Dispatcher, Context,
                                                    Destination, RequestInfo,
                                                    Request, self()) of
                {{ok, ResponseInfo, Response}, NewContext} ->
                    socket_response_info_check(Socket, ResponseInfo),
                    socket_send(Response, StateSocket),
                    StateSocket#state_socket{context = NewContext};
                {{error, timeout}, NewContext} ->
                    socket_send(<<>>, StateSocket),
                    StateSocket#state_socket{context = NewContext}
            end,
            ok = inet:setopts(Socket, [{active, once}]),
            socket_loop(NewStateSocket);
        {tcp_closed, Socket} ->
            socket_loop_terminate(normal, StateSocket)
    after
        TimeoutRecv ->
            socket_loop_terminate(normal, StateSocket)
    end.

socket_loop_terminate(Reason, #state_socket{socket = Socket,
                                            service = Service,
                                            dispatcher = Dispatcher,
                                            context = Context,
                                            destination_disconnect =
                                                DestinationDisconnect,
                                            request_info = RequestInfo}) ->
    if
        is_list(DestinationDisconnect) ->
            send_async_minimal(Dispatcher, Context,
                               DestinationDisconnect,
                               RequestInfo, <<"DISCONNECT">>, self());
        true ->
            ok
    end,
    if
        Reason =:= normal ->
            ?LOG_TRACE("socket ~p closed", [Socket]);
        true ->
            ?LOG_ERROR("socket ~p error: ~p", [Socket, Reason])
    end,
    catch gen_tcp:close(Socket),
    Service ! socket_closed,
    erlang:unlink(Service),
    erlang:exit(Reason).

socket_response_info_check(Socket, ResponseInfo)
    when is_binary(ResponseInfo); is_list(ResponseInfo) ->
    KeyValues = cloudi_service:request_info_key_value_parse(ResponseInfo),
    case cloudi_service:key_value_find(<<"connection">>, KeyValues) of
        {ok, <<"close">>} ->
            self() ! {tcp_closed, Socket},
            ok;
        error ->
            ok
    end;
socket_response_info_check(_, _) ->
    ok.

socket_send(Data, #state_socket{socket = Socket} = StateSocket) ->
    case gen_tcp:send(Socket, Data) of
        ok ->
            ok;
        {error, Reason} ->
            ?LOG_WARN("socket ~p send error: ~p", [Socket, Reason]),
            socket_loop_terminate(normal, StateSocket)
    end.

