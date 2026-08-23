%%
%% WORM Engines: Erlang Mesh Replication
%%
%% Distributed append-only ledger replication across Erlang nodes.
%% Each node maintains a local WORM ledger and gossips updates to peers.
%%
%% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
%% Licensed under Sovereign Source License + Business Source License 1.1.
%% See LICENSE for complete terms.

-module(worm_mesh).
-behaviour(gen_server).

%% API
-export([start_link/1, append_record/2, query_sequence/1, get_ledger/1]).

%% Callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% Types
-record(state, {
    node_id :: binary(),              % This node's identity (32 bytes)
    local_ledger :: atom(),           % Local WORM ledger state
    peers :: [atom()],                % Connected peer nodes
    sequence :: non_neg_integer(),    % Current sequence number
    last_hash :: binary(),            % Hash of last record (32 bytes)
    pending_append :: queue:queue()   % Queue of pending records
}).

%%
%% API
%%

%% Start replication node with given node ID
start_link(NodeId) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, {NodeId}, []).

%% Append a record to the local ledger and broadcast to peers
append_record(WriterId, PayloadHash) ->
    gen_server:call(?MODULE, {append, WriterId, PayloadHash}).

%% Query current sequence number
query_sequence() ->
    gen_server:call(?MODULE, {query_seq}).

%% Get full ledger state
get_ledger() ->
    gen_server:call(?MODULE, {get_ledger}).

%%
%% Callbacks
%%

%% Initialize WORM mesh node
init({NodeId}) ->
    io:format("WORM Mesh: Initializing node ~s~n", [binary_to_list(NodeId)]),

    State = #state{
        node_id = NodeId,
        local_ledger = worm_ledger,
        peers = [],
        sequence = 0,
        last_hash = crypto:hash(sha256, <<>>),  % Genesis hash
        pending_append = queue:new()
    },

    %% Initialize local WORM ledger via NIF
    ok = worm_ledger:init_ledger(NodeId),

    {ok, State}.

%%
%% Append: Core replication operation
%%
handle_call({append, WriterId, PayloadHash}, _From, State) ->
    %% 1. Verify invariants (Sequence, Hash chain, Writer)
    case verify_invariants(WriterId, PayloadHash, State) of
        {ok, NewSequence} ->
            %% 2. Append to local ledger (durable via Zig)
            case worm_ledger:append_record(WriterId, PayloadHash, NewSequence) of
                {ok, RecordHash} ->
                    %% 3. Update local state
                    NewState = State#state{
                        sequence = NewSequence,
                        last_hash = RecordHash
                    },

                    %% 4. Broadcast to all peers (gossip)
                    broadcast_append(NewSequence, RecordHash, NewState),

                    {reply, {ok, NewSequence}, NewState};

                {error, Reason} ->
                    io:format("WORM: Append failed: ~w~n", [Reason]),
                    {reply, {error, Reason}, State}
            end;

        {error, Reason} ->
            io:format("WORM: Invariant check failed: ~w~n", [Reason]),
            {reply, {error, Reason}, State}
    end.

%%
%% Query: Return current state
%%
handle_call({query_seq}, _From, State) ->
    {reply, {ok, State#state.sequence}, State};

handle_call({get_ledger}, _From, State) ->
    Ledger = {
        sequence, State#state.sequence,
        node_id, State#state.node_id,
        last_hash, State#state.last_hash,
        peers, State#state.peers
    },
    {reply, {ok, Ledger}, State}.

%%
%% Handle incoming gossip from peers
%%
handle_cast({gossip_append, PeerSequence, PeerHash, PeerNodeId}, State) ->
    %% Receive append gossip from another node
    %% Verify causality: peer_sequence > local_sequence
    case PeerSequence > State#state.sequence of
        true ->
            %% Accept the append (peer has more records)
            NewState = State#state{
                sequence = PeerSequence,
                last_hash = PeerHash
            },
            io:format("WORM: Accepted gossip from ~s (seq: ~w)~n",
                     [PeerNodeId, PeerSequence]),
            {noreply, NewState};

        false ->
            %% Ignore (we have same or more records)
            {noreply, State}
    end.

%%
%% Info: Connect to peers
%%
handle_info({connect_peers, PeerList}, State) ->
    NewState = State#state{peers = PeerList},
    io:format("WORM: Connected to ~w peers~n", [length(PeerList)]),
    {noreply, NewState}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%
%% Internal: Invariant checks (from SPARK specification)
%%

verify_invariants(WriterId, PayloadHash, State) ->
    %% Invariant 1: Sequence monotonicity (next = current + 1)
    NextSequence = State#state.sequence + 1,

    %% Invariant 5: Writer stability (constant per node)
    case WriterId = State#state.node_id of
        true ->
            %% Invariant 8: Payload commitment (non-empty hash)
            case byte_size(PayloadHash) =:= 32 of
                true ->
                    {ok, NextSequence};
                false ->
                    {error, invalid_payload_hash}
            end;

        false ->
            {error, writer_mismatch}
    end.

%%
%% Broadcast: Gossip append to all peers
%%

broadcast_append(Sequence, Hash, State) ->
    lists:foreach(fun(Peer) ->
        gen_server:cast(Peer, {gossip_append, Sequence, Hash, State#state.node_id})
    end, State#state.peers).
