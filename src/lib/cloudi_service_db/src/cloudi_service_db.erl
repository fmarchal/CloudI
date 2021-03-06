%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et nomod:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==CloudI Database==
%%% Provide a simple in-memory database.
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

-module(cloudi_service_db).
-author('mjtruog [at] gmail (dot) com').

-behaviour(cloudi_service).

%% external interface
-export([kv_new/5,
         kv_delete/4,
         kv_delete/5,
         kv_get/4,
         kv_get/5,
         kv_put/6]).

%% cloudi_service callbacks
-export([cloudi_service_init/4,
         cloudi_service_handle_request/11,
         cloudi_service_handle_info/3,
         cloudi_service_terminate/3]).

-include_lib("cloudi_core/include/cloudi_logger.hrl").

-define(DEFAULT_TABLE_MODULE,                dict). % dict API
-define(DEFAULT_OUTPUT,                  internal).
-define(DEFAULT_EXTERNAL_FORMAT,    erlang_string).
-define(DEFAULT_USE_KEY_VALUE,               true). % functionality

-record(state,
    {
        tables = cloudi_x_trie:new() :: cloudi_x_trie:cloudi_x_trie(),
        prefix_length :: integer(),
        uuid_generator :: cloudi_x_uuid:state(),
        table_module :: atom(),
        output_type :: internal | external,
        external_format :: cloudi_request:external_format(),
        use_key_value :: boolean()
    }).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

-type agent() :: cloudi:agent().
-type service_name() :: cloudi:service_name().
-type timeout_milliseconds() :: cloudi:timeout_milliseconds().

%%-------------------------------------------------------------------------
%% @doc
%% ===Store a new value in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_new(Agent :: agent(),
             Name :: service_name(),
             Table :: string() | binary(),
             Value :: any(),
             Timeout :: timeout_milliseconds()) ->
    {{ok, Key :: binary(), NewValue :: any()}, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_new(Agent, Name, Table, Value, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {new, Table, Value}, Timeout) of
        {{ok, {ok, _, _} = Success}, NewAgent} ->
            {Success, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Delete all table values in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_delete(Agent :: agent(),
                Name :: service_name(),
                Table :: string() | binary(),
                Timeout :: timeout_milliseconds()) ->
    {ok, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_delete(Agent, Name, Table, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {delete, Table}, Timeout) of
        {{ok, ok}, NewAgent} ->
            {ok, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Delete a value in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_delete(Agent :: agent(),
                Name :: service_name(),
                Table :: string() | binary(),
                Key :: binary(),
                Timeout :: timeout_milliseconds()) ->
    {ok, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_delete(Agent, Name, Table, Key, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {delete, Table, Key}, Timeout) of
        {{ok, ok}, NewAgent} ->
            {ok, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Retrieve all table values in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_get(Agent :: agent(),
             Name :: service_name(),
             Table :: string() | binary(),
             Timeout :: timeout_milliseconds()) ->
    {{ok, list({Key :: binary(),
                Value :: any()})}, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_get(Agent, Name, Table, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {get, Table}, Timeout) of
        {{ok, {ok, _} = Success}, NewAgent} ->
            {Success, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Retrieve a table value in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_get(Agent :: agent(),
             Name :: service_name(),
             Table :: string() | binary(),
             Key :: binary(),
             Timeout :: timeout_milliseconds()) ->
    {{ok, Key :: binary(), Value :: any()}, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_get(Agent, Name, Table, Key, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {get, Table, Key}, Timeout) of
        {{ok, {ok, Value}}, NewAgent} ->
            {{ok, Key, Value}, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Store a table value in the key-value db.===
%% @end
%%-------------------------------------------------------------------------

-spec kv_put(Agent :: agent(),
             Name :: service_name(),
             Table :: string() | binary(),
             Key :: binary(),
             Value :: any(),
             Timeout :: timeout_milliseconds()) ->
    {{ok, Key :: binary(), Value :: any()}, NewAgent :: agent()} |
    {{error, any()}, NewAgent :: agent()}.

kv_put(Agent, Name, Table, Key, Value, Timeout) ->
    case cloudi:send_sync(Agent, Name,
                          {put, Table, Key, Value}, Timeout) of
        {{ok, {ok, NewValue}}, NewAgent} ->
            {{ok, Key, NewValue}, NewAgent};
        {{error, _}, _} = Error ->
            Error
    end.

%%%------------------------------------------------------------------------
%%% Callback functions from cloudi_service
%%%------------------------------------------------------------------------

cloudi_service_init(Args, Prefix, _Timeout, Dispatcher) ->
    Defaults = [
        {table_module,             ?DEFAULT_TABLE_MODULE},
        {output,                   ?DEFAULT_OUTPUT},
        {external_format,          ?DEFAULT_EXTERNAL_FORMAT},
        {use_key_value,            ?DEFAULT_USE_KEY_VALUE}],
    [TableModule, OutputType, ExternalFormat, UseKeyValue] =
        cloudi_proplists:take_values(Defaults, Args),
    true = is_atom(TableModule),
    {file, _} = code:is_loaded(TableModule),
    true = ((OutputType =:= internal) orelse
            (OutputType =:= external)),
    true = ((ExternalFormat =:= erlang_string) orelse
            (ExternalFormat =:= erlang_term) orelse
            (ExternalFormat =:= msgpack)),
    true = is_boolean(UseKeyValue),
    false = lists:member($*, Prefix),
    cloudi_service:subscribe(Dispatcher, "*"), % dynamic database name
    {ok, #state{prefix_length = erlang:length(Prefix),
                table_module = TableModule,
                output_type = OutputType,
                external_format = ExternalFormat,
                use_key_value = UseKeyValue}}.

cloudi_service_handle_request(_Type, Name, _Pattern, _RequestInfo, Request,
                              _Timeout, _Priority, TransId, _Pid,
                              #state{prefix_length = PrefixLength} = State,
                              _Dispatcher) ->
    do_query(lists:nthtail(PrefixLength, Name), Request, TransId, State).

cloudi_service_handle_info(Request, State, _Dispatcher) ->
    ?LOG_WARN("Unknown info \"~p\"", [Request]),
    {noreply, State}.

cloudi_service_terminate(_Reason, _Timeout, #state{}) ->
    ok.

%%%------------------------------------------------------------------------
%%% Private functions
%%%------------------------------------------------------------------------

key_value({Command, Table},
          Database, Request, TransId, State)
    when is_binary(Table) ->
    key_value({Command, erlang:binary_to_list(Table)},
              Database, Request, TransId, State);
key_value({Command, Table, Arg1},
          Database, Request, TransId, State)
    when is_binary(Table) ->
    key_value({Command, erlang:binary_to_list(Table), Arg1},
              Database, Request, TransId, State);
key_value({Command, Table, Arg1, Arg2},
          Database, Request, TransId, State)
    when is_binary(Table) ->
    key_value({Command, erlang:binary_to_list(Table), Arg1, Arg2},
              Database, Request, TransId, State);
key_value({new, [I | _] = Table, Value},
          Database, Request, TransId,
          #state{tables = Tables,
                 table_module = TableModule} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    NewValue = case Value of
        <<0:128, Rest/binary>> ->
            <<TransId:128/binary, Rest/binary>>;
        [undefined | L] ->
            [TransId | L];
        _ when is_tuple(Value), is_atom(element(1, Value)) ->
            case element(1, Value) of
                undefined ->
                    erlang:setelement(1, Value, TransId);
                _ ->
                    case element(2, Value) of
                        undefined ->
                            erlang:setelement(2, Value, TransId);
                        _ ->
                            Value
                    end
            end;
        _ ->
            Value
    end,
    NewTables = cloudi_x_trie:update(TableName, fun(Old) ->
            TableModule:store(TransId, NewValue, Old)
        end, TableModule:store(TransId, NewValue, TableModule:new()), Tables),
    {reply,
     response(Request, {ok, TransId, NewValue}, State),
     State#state{tables = NewTables}};
key_value({delete, [I | _] = Table},
          Database, Request, _TransId,
          #state{tables = Tables} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    NewTables = cloudi_x_trie:erase(TableName, Tables),
    {reply,
     response(Request, ok, State),
     State#state{tables = NewTables}};
key_value({delete, [I | _] = Table, Key},
          Database, Request, _TransId,
          #state{tables = Tables,
                 table_module = TableModule} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    NewTables = cloudi_x_trie:update(TableName, fun(Old) ->
            TableModule:erase(Key, Old)
        end, TableModule:new(), Tables),
    {reply,
     response(Request, ok, State),
     State#state{tables = NewTables}};
key_value({get, [I | _] = Table},
          Database, Request, _TransId,
          #state{tables = Tables,
                 table_module = TableModule} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    case cloudi_x_trie:find(TableName, Tables) of
        {ok, TableValues} ->
            {reply,
             response(Request, {ok, TableModule:to_list(TableValues)}, State),
             State};
        error ->
            {reply,
             response(Request, {ok, []}, State),
             State}
    end;
key_value({get, [I | _] = Table, Key},
          Database, Request, _TransId,
          #state{tables = Tables,
                 table_module = TableModule} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    Response = case cloudi_x_trie:find(TableName, Tables) of
        {ok, TableValues} ->
            case TableModule:find(Key, TableValues) of
                {ok, Value} ->
                    response(Request, {ok, Value}, State);
                error ->
                    response(Request, {ok, undefined}, State)
            end;
        error ->
            response(Request, {ok, undefined}, State)
    end,
    {reply, Response, State};
key_value({put, [I | _] = Table, Key, Value},
          Database, Request, _TransId,
          #state{tables = Tables,
                 table_module = TableModule} = State)
    when is_integer(I) ->
    TableName = Database ++ [$* | Table],
    NewTables = cloudi_x_trie:update(TableName, fun(Old) ->
            TableModule:store(Key, Value, Old)
        end, TableModule:store(Key, Value, TableModule:new()), Tables),
    {reply,
     response(Request, {ok, Value}, State),
     State#state{tables = NewTables}};
key_value(Command,
          _Database, Request, _TransId, State) ->
    {reply,
     response(Request, {error, {invalid_command, Command}}, State),
     State}.

do_query(Database, Request, TransId,
         #state{output_type = Output,
                external_format = ExternalFormat,
                use_key_value = true} = State)
    when (Output =:= external) orelse
         ((Output =:= internal) andalso is_binary(Request)) ->
    key_value(cloudi_request:external_format(Request, ExternalFormat),
              Database, Request, TransId, State);
do_query(Database, Request, TransId,
         #state{use_key_value = true} = State) ->
    key_value(Request,
              Database, Request, TransId, State).
    
response(Request, Response,
         #state{output_type = Output,
                external_format = ExternalFormat})
    when (Output =:= external) orelse
         ((Output =:= internal) andalso is_binary(Request)) ->
    cloudi_response:external_format(Response, ExternalFormat);
response(_, Response, #state{}) ->
    Response.

