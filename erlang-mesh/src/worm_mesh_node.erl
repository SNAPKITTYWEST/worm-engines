% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_node).
-behaviour(gen_server).

-export([start_link/2, append/2, query_sequence/1, replicate_from/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(NumReplicas, NodeId) ->
    gen_server:start_link(?MODULE, {NumReplicas, NodeId}, []).

append(Pid, Record) ->
    gen_server:call(Pid, {append, Record}).

query_sequence(Pid) ->
    gen_server:call(Pid, query_sequence).

replicate_from(Source, Target) ->
    gen_server:call(Target, {replicate_from, Source}).

init({NumReplicas, NodeId}) ->
    {ok, #{num_replicas => NumReplicas, node_id => NodeId, sequence => 0, records => []}}.

handle_call({append, Record}, _From, State) ->
    {reply, {ok, hash}, State};

handle_call(query_sequence, _From, State = #{sequence := Seq}) ->
    {reply, Seq, State};

handle_call({replicate_from, _Source}, _From, State) ->
    {reply, {ok, 0}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
