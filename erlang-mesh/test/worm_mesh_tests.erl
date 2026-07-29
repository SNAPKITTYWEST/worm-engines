-module(worm_mesh_tests).

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

consensus_test() ->
    Session = worm_mesh_consensus:new_vote_session(3),
    UpdatedSession = worm_mesh_consensus:vote_append(Session, 1, true),
    UpdatedSession2 = worm_mesh_consensus:vote_append(UpdatedSession, 2, true),
    Consensus = worm_mesh_consensus:quorum_met(UpdatedSession2, 2),
    ?assert(Consensus).

protocol_encode_decode_test() ->
    Record = #worm_record{
        stream_id = <<"stream123">>,
        sequence = 0,
        timestamp = 1000
    },
    {ok, Encoded} = worm_mesh_protocol:encode_record(Record),
    {ok, Decoded} = worm_mesh_protocol:decode_record(Encoded),
    ?assertEqual(Record, Decoded).

protocol_frame_test() ->
    Data = <<"test_data">>,
    Framed = worm_mesh_protocol:frame(Data),
    {ok, Unframed, Rest} = worm_mesh_protocol:unframe(Framed),
    ?assertEqual(Data, Unframed),
    ?assertEqual(<<>>, Rest).

replication_no_catch_up_test() ->
    Records = [
        #worm_record{sequence = 0},
        #worm_record{sequence = 1}
    ],
    {Status, _} = worm_mesh_replication:sync_from_peer(1, 1, Records),
    ?assertEqual(no_catch_up_needed, Status).

replication_catch_up_test() ->
    Records = [
        #worm_record{sequence = 0},
        #worm_record{sequence = 1},
        #worm_record{sequence = 2},
        #worm_record{sequence = 3}
    ],
    {ok, Count, _} = worm_mesh_replication:sync_from_peer(1, 3, Records),
    ?assertEqual(2, Count).

split_brain_recovery_test() ->
    Session1 = worm_mesh_consensus:new_vote_session(5),
    Session2 = worm_mesh_consensus:vote_append(Session1, 1, true),
    Session3 = worm_mesh_consensus:vote_append(Session2, 2, true),
    Session4 = worm_mesh_consensus:vote_append(Session3, 3, true),
    Consensus = worm_mesh_consensus:quorum_met(Session4, 3),
    ?assert(Consensus).
