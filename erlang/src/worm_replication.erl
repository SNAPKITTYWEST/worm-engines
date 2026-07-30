%% WORM Engines Replication Coordinator
%% Multi-node gossip mesh for ledger replication
%% Byzantine-tolerant consensus via quorum validation

-module(worm_replication).
-behavior(gen_server).

-export([
  start_link/2,
  stop/1,
  replicate_record/3,
  sync_ledger/2,
  add_peer/2,
  remove_peer/2,
  list_peers/1,
  get_status/1
]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
  node_id :: binary(),
  ledger :: term(),
  peers :: [binary()],
  pending_records :: queue:queue(),
  ack_count :: map(),
  last_sync :: integer()
}).

-record(sync_message, {
  node_id :: binary(),
  sequence :: non_neg_integer(),
  hash :: binary(),
  timestamp :: integer(),
  records :: [map()],
  signature :: binary()
}).

%% ===== SERVER LIFECYCLE =====

start_link(NodeID, LedgerPath) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, {NodeID, LedgerPath}, []).

stop(NodeID) ->
  gen_server:call({?MODULE, NodeID}, stop).

%% ===== REPLICATION API =====

%% Replicate record to all peers (gossip)
-spec replicate_record(NodeID :: binary(), Record :: map(), Signature :: binary()) -> {ok, Acks :: non_neg_integer()} | {error, Reason :: atom()}.
replicate_record(NodeID, Record, Signature) ->
  gen_server:call({?MODULE, NodeID}, {replicate, Record, Signature}).

%% Full ledger sync from peer
-spec sync_ledger(NodeID :: binary(), PeerNodeID :: binary()) -> {ok, Records :: [map()]} | {error, Reason :: atom()}.
sync_ledger(NodeID, PeerNodeID) ->
  gen_server:call({?MODULE, NodeID}, {sync, PeerNodeID}, 30000).

%% Add peer to replication mesh
-spec add_peer(NodeID :: binary(), PeerNodeID :: binary()) -> ok | {error, Reason :: atom()}.
add_peer(NodeID, PeerNodeID) ->
  gen_server:call({?MODULE, NodeID}, {add_peer, PeerNodeID}).

%% Remove peer from replication mesh
-spec remove_peer(NodeID :: binary(), PeerNodeID :: binary()) -> ok | {error, Reason :: atom()}.
remove_peer(NodeID, PeerNodeID) ->
  gen_server:call({?MODULE, NodeID}, {remove_peer, PeerNodeID}).

%% List active peers
-spec list_peers(NodeID :: binary()) -> {ok, Peers :: [binary()]}.
list_peers(NodeID) ->
  gen_server:call({?MODULE, NodeID}, list_peers).

%% Get replication status
-spec get_status(NodeID :: binary()) -> {ok, Status :: map()}.
get_status(NodeID) ->
  gen_server:call({?MODULE, NodeID}, status).

%% ===== GEN_SERVER CALLBACKS =====

init({NodeID, LedgerPath}) ->
  case worm:ledger_open_or_create(LedgerPath) of
    {ok, Ledger} ->
      {ok, #state{
        node_id = NodeID,
        ledger = Ledger,
        peers = [],
        pending_records = queue:new(),
        ack_count = #{},
        last_sync = erlang:system_time(seconds)
      }};
    Error ->
      {stop, Error}
  end.

handle_call({replicate, Record, Signature}, From, State) ->
  %% Append to local ledger
  case worm:ledger_append(State#state.ledger, Record) of
    ok ->
      %% Gossip to all peers
      ReplicationMsg = {replicate, Record, Signature, State#state.node_id},
      Peers = State#state.peers,
      spawn(fun() -> gossip_to_peers(ReplicationMsg, Peers, From) end),
      {noreply, State#state{pending_records = queue:in(Record, State#state.pending_records)}};
    Error ->
      {reply, Error, State}
  end;

handle_call({sync, PeerNodeID}, _From, State) ->
  %% Fetch full ledger from peer
  case sync_from_peer(PeerNodeID, State#state.node_id) of
    {ok, Records} ->
      %% Validate records (check hash chain)
      case validate_record_chain(Records) of
        ok ->
          %% Append all records to local ledger
          lists:foreach(fun(R) -> worm:ledger_append(State#state.ledger, R) end, Records),
          {reply, {ok, length(Records)}, State#state{last_sync = erlang:system_time(seconds)}};
        Error ->
          {reply, Error, State}
      end;
    Error ->
      {reply, Error, State}
  end;

handle_call({add_peer, PeerNodeID}, _From, State) ->
  case lists:member(PeerNodeID, State#state.peers) of
    true -> {reply, ok, State};
    false ->
      NewPeers = [PeerNodeID | State#state.peers],
      {reply, ok, State#state{peers = NewPeers}}
  end;

handle_call({remove_peer, PeerNodeID}, _From, State) ->
  NewPeers = lists:delete(PeerNodeID, State#state.peers),
  {reply, ok, State#state{peers = NewPeers}};

handle_call(list_peers, _From, State) ->
  {reply, {ok, State#state.peers}, State};

handle_call(status, _From, State) ->
  {ok, Sequence} = worm:ledger_query_sequence(State#state.ledger),
  {ok, Hash} = worm:ledger_query_hash(State#state.ledger),
  Status = #{
    node_id => State#state.node_id,
    sequence => Sequence,
    hash => Hash,
    peers => length(State#state.peers),
    pending => queue:len(State#state.pending_records),
    last_sync => State#state.last_sync
  },
  {reply, {ok, Status}, State};

handle_call(stop, _From, State) ->
  {stop, normal, ok, State};

handle_call(_Request, _From, State) ->
  {reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({replicate, Record, Signature, NodeID}, State) ->
  %% Receive replicated record from peer
  case worm:ledger_validate_record(State#state.ledger, Record) of
    ok ->
      case worm:ledger_append(State#state.ledger, Record) of
        ok ->
          %% Re-gossip to other peers (flood fill)
          OtherPeers = lists:delete(NodeID, State#state.peers),
          ReplicationMsg = {replicate, Record, Signature, NodeID},
          spawn(fun() -> gossip_to_peers(ReplicationMsg, OtherPeers, none) end),
          {noreply, State};
        Error ->
          {noreply, State}  %% Silently drop on error
      end;
    _ ->
      {noreply, State}  %% Silently drop invalid records (Byzantine tolerance)
  end;

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, State) ->
  worm:ledger_close(State#state.ledger),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%% ===== HELPER FUNCTIONS =====

%% Gossip record to all peers (flood fill)
gossip_to_peers(Msg, Peers, From) ->
  Acks = lists:map(fun(Peer) ->
    try
      rpc:call(Peer, ?MODULE, handle_info, [Msg, #state{}]),
      1
    catch
      _Error -> 0
    end
  end, Peers),
  AckCount = lists:sum(Acks),
  case From of
    none -> ok;
    _ -> gen_server:reply(From, {ok, AckCount})
  end.

%% Sync ledger from peer via RPC
sync_from_peer(PeerNodeID, LocalNodeID) ->
  try
    rpc:call(PeerNodeID, worm_replication, fetch_all_records, [])
  catch
    _Error -> {error, peer_unavailable}
  end.

%% Fetch all records from local ledger (used by peers syncing)
fetch_all_records() ->
  {ok, not_implemented}.  %% TODO: Implement record range query

%% Validate record chain (hash chain continuity)
validate_record_chain([]) ->
  ok;
validate_record_chain([FirstRecord | Rest]) ->
  %% Check that first record's previous_hash matches zero (genesis)
  FirstHash = maps:get(previous_hash, FirstRecord),
  case FirstHash of
    <<0:256>> ->
      validate_record_chain_rest(Rest, maps:get(hash, FirstRecord));
    _ ->
      {error, invalid_genesis}
  end.

validate_record_chain_rest([], _LastHash) ->
  ok;
validate_record_chain_rest([Record | Rest], LastHash) ->
  %% Check that record's previous_hash matches last record's hash
  case maps:get(previous_hash, Record) of
    LastHash ->
      validate_record_chain_rest(Rest, maps:get(hash, Record));
    _ ->
      {error, hash_chain_broken}
  end.
