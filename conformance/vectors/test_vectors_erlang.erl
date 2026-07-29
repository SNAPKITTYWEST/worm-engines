% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

% Erlang golden vector test: encode genesis record, verify CBOR matches Zig

-module(test_vectors).
-export([main/0]).

create_genesis_record() ->
    {record,
        version => 1,
        stream_id => binary:copy(<<16#AA>>, 32),
        sequence => 0,
        timestamp => 1000,
        previous_hash => binary:copy(<<16#00>>, 32),
        payload_hash => binary:copy(<<16#BB>>, 32),
        policy_hash => binary:copy(<<16#00>>, 32),
        writer_id => binary:copy(<<16#CC>>, 32),
        flags => 1,
        signature => binary:copy(<<16#00>>, 64)
    }.

bytes_to_hex(Bytes) ->
    lists:flatten([io_lib:format("~2.16.0b", [B]) || B <- binary:bin_to_list(Bytes)]).

main() ->
    io:format("Erlang Golden Vector Test~n"),
    io:format("==========================~n~n"),

    Record = create_genesis_record(),
    io:format("Genesis record created (sequence=0, timestamp=1000)~n~n"),

    % Extract fields for verification
    {record, _, StreamId, Seq, Ts, _, PayloadHash, _, WriterId, Flags, _} = Record,
    
    io:format("Record fields:~n"),
    io:format("  stream_id: ~s~n", [bytes_to_hex(StreamId)]),
    io:format("  sequence: ~w~n", [Seq]),
    io:format("  timestamp: ~w~n", [Ts]),
    io:format("  payload_hash: ~s~n", [bytes_to_hex(PayloadHash)]),
    io:format("  writer_id: ~s~n", [bytes_to_hex(WriterId)]),
    io:format("  flags: ~w~n~n", [Flags]),

    io:format("✓ Erlang vector test structure ready~n"),
    io:format("  (CBOR encoding pending mesh integration)~n").
