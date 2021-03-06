%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et nomod:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==Key2Value==
%%% Maintain 2 associative lookups for 2 separate keys and 1 value.
%%% The interface creates a bidirectional lookup where key1 can store
%%% multiple key2 associations to the same value.
%%% The supplied data structure module must have dict interface functions.
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2011-2014, Michael Truog <mjtruog at gmail dot com>
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
%%% @copyright 2011-2014 Michael Truog
%%% @version 1.3.3 {@date} {@time}
%%%------------------------------------------------------------------------

-module(key2value).
-author('mjtruog [at] gmail (dot) com').

%% external interface
-export([erase/3,
         erase1/2,
         erase2/2,
         fetch1/2,
         fetch2/2,
         find1/2,
         find2/2,
         is_key1/2,
         is_key2/2,
         new/0,
         new/1,
         store/4]).

-record(key2value,
    {
        module :: module(),
        lookup1 :: any(),
        lookup2 :: any()
    }).
-ifdef(ERLANG_OTP_VERSION_16).
-type dict_proxy(_Key, _Value) :: dict().
-else.
-type dict_proxy(Key, Value) :: dict:dict(Key, Value).
-endif.
-type key2value_dict(Key1, Key2, Value) ::
    {key2value,
     dict,
     dict_proxy(Key1, {list(Key2), Value}),
     dict_proxy(Key2, {list(Key1), Value})}.
-type key2value(Key1, Key2, Value) ::
    key2value_dict(Key1, Key2, Value) |
    #key2value{}.
-export_type([key2value/3]).
-type key1() :: any().
-type key2() :: any().
-type value() :: any().

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

-spec erase(K1 :: key1(),
            K2 :: key2(),
            State :: key2value(key1(), key2(), value())) ->
    key2value(key1(), key2(), value()).

erase(K1, K2,
      #key2value{module = Module,
                 lookup1 = Lookup1,
                 lookup2 = Lookup2} = State) ->
    case Module:find(K1, Lookup1) of
        {ok, {[K2], _}} ->
            case Module:find(K2, Lookup2) of
                {ok, {[K1], _}} ->
                    State#key2value{
                        lookup1 = Module:erase(K1, Lookup1),
                        lookup2 = Module:erase(K2, Lookup2)};
                {ok, {L1, V1}} ->
                    State#key2value{
                        lookup1 = Module:erase(K1, Lookup1),
                        lookup2 = Module:store(K2, {lists:delete(K1, L1), V1},
                                               Lookup2)};
                error ->
                    State
            end;
        {ok, {L2, V2}} ->
            case Module:find(K2, Lookup2) of
                {ok, {[K1], _}} ->
                    State#key2value{
                        lookup1 = Module:store(K1, {lists:delete(K2, L2), V2},
                                               Lookup1),
                        lookup2 = Module:erase(K2, Lookup2)};
                {ok, {L1, V1}} ->
                    State#key2value{
                        lookup1 = Module:store(K1, {lists:delete(K2, L2), V2},
                                               Lookup1),
                        lookup2 = Module:store(K2, {lists:delete(K1, L1), V1},
                                               Lookup2)};
                error ->
                    State
            end;
        error ->
            State
    end.

-spec erase1(K :: key1(),
             State :: key2value(key1(), key2(), value())) ->
    key2value(key1(), key2(), value()).

erase1(K,
       #key2value{module = Module,
                  lookup1 = Lookup1} = State) ->
    case Module:find(K, Lookup1) of
        {ok, {L, _}} ->
            lists:foldl(fun(K2, D) ->
                erase(K, K2, D)
            end, State, L);
        error ->
            State
    end.

-spec erase2(K :: key2(),
             State :: key2value(key1(), key2(), value())) ->
    key2value(key1(), key2(), value()).

erase2(K,
       #key2value{module = Module,
                  lookup2 = Lookup2} = State) ->
    case Module:find(K, Lookup2) of
        {ok, {L, _}} ->
            lists:foldl(fun(K1, D) ->
                erase(K1, K, D)
            end, State, L);
        error ->
            State
    end.

-spec fetch1(K :: key1(),
             key2value(key1(), key2(), value())) ->
    {list(), any()}.

fetch1(K,
       #key2value{module = Module,
                  lookup1 = Lookup1}) ->
    Module:fetch(K, Lookup1).

-spec fetch2(K :: key2(),
             key2value(key1(), key2(), value())) ->
    {list(), any()}.

fetch2(K,
       #key2value{module = Module,
                  lookup2 = Lookup2}) ->
    Module:fetch(K, Lookup2).

-spec find1(K :: key1(),
            State :: key2value(key1(), key2(), value())) ->
    {ok, {list(), any()}} |
    error.

find1(K,
      #key2value{module = Module,
                 lookup1 = Lookup1}) ->
    Module:find(K, Lookup1).

-spec find2(K :: key2(),
            State :: key2value(key1(), key2(), value())) ->
    {ok, {list(), any()}} |
    error.

find2(K,
      #key2value{module = Module,
                 lookup2 = Lookup2}) ->
    Module:find(K, Lookup2).

-spec is_key1(K :: key1(),
              key2value(key1(), key2(), value())) ->
    boolean().

is_key1(K,
        #key2value{module = Module,
                   lookup1 = Lookup1}) ->
    Module:is_key(K, Lookup1).

-spec is_key2(K :: key2(),
              key2value(key1(), key2(), value())) ->
    boolean().

is_key2(K,
        #key2value{module = Module,
                   lookup2 = Lookup2}) ->
    Module:is_key(K, Lookup2).

-spec new() ->
    key2value_dict(key1(), key2(), value()).

new() ->
    #key2value{module = dict,
               lookup1 = dict:new(),
               lookup2 = dict:new()}.

-spec new(Module :: atom()) ->
    key2value(key1(), key2(), value()).

new(Module)
    when is_atom(Module) ->
    #key2value{module = Module,
               lookup1 = Module:new(),
               lookup2 = Module:new()}.

-spec store(K1 :: key1(),
            K2 :: key2(),
            V :: value(),
            key2value(key1(), key2(), value())) ->
    key2value(key1(), key2(), value()).

store(K1, K2, V,
      #key2value{module = Module,
                 lookup1 = Lookup1,
                 lookup2 = Lookup2} = State) ->
    K1L = [K1],
    K2L = [K2],
    F1 = fun({L, _}) ->
        {lists:umerge(L, K2L), V}
    end,
    F2 = fun({L, _}) ->
        {lists:umerge(L, K1L), V}
    end,
    State#key2value{module = Module,
                    lookup1 = Module:update(K1, F1, {K2L, V}, Lookup1),
                    lookup2 = Module:update(K2, F2, {K1L, V}, Lookup2)}.

%%%------------------------------------------------------------------------
%%% Private functions
%%%------------------------------------------------------------------------

