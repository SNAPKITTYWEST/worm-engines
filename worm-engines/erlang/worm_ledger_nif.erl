%%
%% WORM Engines: Erlang NIF Bridge to Zig Storage
%%
%% Native interface functions that call the Zig storage engine.
%% All operations are durable (fsync enforced in Zig).
%%
%% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
%% Licensed under Sovereign Source License + Business Source License 1.1.
%% See LICENSE for complete terms.

-module(worm_ledger).

%% NIF exports
-export([init_ledger/1, append_record/3, query_sequence/1, query_hash/1]).

%% Load NIF library
-on_load(load_nif/0).

load_nif() ->
    Nif = filename:join([code:priv_dir(worm_engines), "worm_ledger_nif"]),
    erlang:load_nif(Nif, 0).

%%
%% Initialize WORM ledger for this node
%% Args: WriterId (32-byte binary)
%% Returns: ok | {error, Reason}
%%
init_ledger(_WriterId) ->
    erlang:nif_error(not_loaded).

%%
%% Append a record to the WORM ledger (durable)
%% Args: WriterId, PayloadHash (both 32-byte binaries), Sequence (integer)
%% Returns: {ok, RecordHash} | {error, Reason}
%%
append_record(_WriterId, _PayloadHash, _Sequence) ->
    erlang:nif_error(not_loaded).

%%
%% Query current sequence number
%% Returns: {ok, Sequence} | {error, Reason}
%%
query_sequence() ->
    erlang:nif_error(not_loaded).

%%
%% Query hash of record at given sequence
%% Args: Sequence (integer)
%% Returns: {ok, Hash} | {error, Reason}
%%
query_hash(_Sequence) ->
    erlang:nif_error(not_loaded).
