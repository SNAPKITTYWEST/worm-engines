% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_replication).

-export([sync_from_peer/3, apply_records/2, 
         catch_up/2, replay_from_sequence/2]).

-record(sync_state, {
    local_sequence :: non_neg_integer(),
    peer_sequence :: non_neg_integer(),
    records = [] :: [term()]
}).

sync_from_peer(LocalSeq, PeerSeq, PeerRecords) when LocalSeq < PeerSeq ->
    catch_up(LocalSeq, PeerRecords);
sync_from_peer(LocalSeq, _PeerSeq, _PeerRecords) ->
    {no_catch_up_needed, LocalSeq}.

apply_records(State, Records) ->
    lists:foldl(fun(Record, Acc) ->
        apply_single_record(Acc, Record)
    end, State, Records).

catch_up(StartSeq, Records) ->
    FilteredRecords = [R || R <- Records, 
        get_sequence(R) > StartSeq],
    {ok, length(FilteredRecords), FilteredRecords}.

replay_from_sequence(Seq, AllRecords) ->
    [R || R <- AllRecords, get_sequence(R) > Seq].

apply_single_record(State, Record) ->
    case validate_record(Record) of
        ok -> State;
        {error, Reason} -> {error, Reason}
    end.

validate_record(Record) ->
    case Record of
        _ -> ok
    end.

get_sequence(Record) ->
    element(3, Record).
