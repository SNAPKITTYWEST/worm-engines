% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_protocol).

-export([frame/1, unframe/1, encode_record/1, decode_record/1]).

frame(Data) ->
    Size = size(Data),
    <<Size:32/big-endian-unsigned-integer, Data/binary>>.

unframe(FramedData) ->
    case FramedData of
        <<Size:32/big-endian-unsigned-integer, Data:Size/binary, Rest/binary>> ->
            {Data, Rest};
        _ ->
            {incomplete, FramedData}
    end.

encode_record(Record) ->
    term_to_binary(Record).

decode_record(Binary) ->
    binary_to_term(Binary).
