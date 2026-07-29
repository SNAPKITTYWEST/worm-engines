-module(worm_mesh_replica_tests).

-include_lib("eunit/include/eunit.hrl").

-record(worm_record, {
    version = 1,
    stream_id,
    sequence,
    timestamp,
    previous_hash,
    payload_hash,
    policy_hash,
    writer_id,
    flags = 0,
    signature
}).

replay_from_sequence_test() ->
    Records = [
        #worm_record{sequence = 0},
        #worm_record{sequence = 1},
        #worm_record{sequence = 2},
        #worm_record{sequence = 3}
    ],
    Replayed = worm_mesh_replication:replay_from_sequence(1, Records),
    ?assertEqual(3, length(Replayed)).

apply_records_test() ->
    State = ok,
    Records = [
        #worm_record{sequence = 0},
        #worm_record{sequence = 1}
    ],
    Result = worm_mesh_replication:apply_records(State, Records),
    ?assertEqual(ok, Result).

catch_up_multiple_records_test() ->
    Records = [
        #worm_record{sequence = 0},
        #worm_record{sequence = 1},
        #worm_record{sequence = 2},
        #worm_record{sequence = 3},
        #worm_record{sequence = 4}
    ],
    {ok, Count, _CatchUpRecords} = worm_mesh_replication:sync_from_peer(2, 4, Records),
    ?assertEqual(2, Count).

no_replication_needed_test() ->
    Records = [#worm_record{sequence = 0}],
    {Status, _} = worm_mesh_replication:sync_from_peer(5, 5, Records),
    ?assertEqual(no_catch_up_needed, Status).
