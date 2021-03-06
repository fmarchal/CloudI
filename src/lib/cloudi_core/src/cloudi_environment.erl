%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et nomod:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==CloudI Runtime Environment==
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2014, Michael Truog <mjtruog at gmail dot com>
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
%%% @copyright 2014 Michael Truog
%%% @version 1.3.3 {@date} {@time}
%%%------------------------------------------------------------------------

-module(cloudi_environment).
-author('mjtruog [at] gmail (dot) com').

%% external interface
-export([lookup/0,
         transform/1,
         transform/2]).

-type lookup() :: cloudi_x_trie:cloudi_x_trie().
-export_type([lookup/0]).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @doc
%% ===Get an environment variable lookup for cloudi_service:environment_transform().===
%% @end
%%-------------------------------------------------------------------------

-spec lookup() ->
    lookup().

lookup() ->
    cloudi_core_i_spawn:environment_lookup().

%%-------------------------------------------------------------------------
%% @doc
%% ===Transform a string, substituting environment variable values from the lookup.===
%% Use ${VARIABLE} or $VARIABLE syntax, where VARIABLE is a name with
%% [a-zA-Z0-9_] ASCII characters.
%% @end
%%-------------------------------------------------------------------------

-spec transform(String :: string()) ->
    string().

transform(String) ->
    Lookup = lookup(),
    cloudi_core_i_spawn:environment_transform(String, Lookup).

%%-------------------------------------------------------------------------
%% @doc
%% ===Transform a string, substituting environment variable values from the lookup.===
%% Use ${VARIABLE} or $VARIABLE syntax, where VARIABLE is a name with
%% [a-zA-Z0-9_] ASCII characters.
%% @end
%%-------------------------------------------------------------------------

-spec transform(String :: string(),
                Lookup :: lookup()) ->
    string().

transform(String, Lookup) ->
    cloudi_core_i_spawn:environment_transform(String, Lookup).

