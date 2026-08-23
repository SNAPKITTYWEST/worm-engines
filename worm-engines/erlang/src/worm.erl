%% WORM Engines Erlang NIF Module
%% Wraps C ABI for Erlang/OTP integration
%% All operations deterministic and memory-safe

-module(worm).
-export([
  ledger_create/1,
  ledger_open/1,
  ledger_open_or_create/1,
  ledger_recover/1,
  ledger_close/1,
  ledger_append/2,
  ledger_query_sequence/1,
  ledger_query_hash/1,
  ledger_validate_record/2,
  sha256/1,
  crc32/1,
  sign_record/2,
  verify_record/3,
  cbor_encode/1,
  cbor_decode/1
]).

-on_load(init/0).

%% NIF stubs (implemented in Zig via C ABI)

init() ->
  SoName = case code:priv_dir(worm) of
    {error, bad_name} -> filename:join(code:root_dir(), "priv/worm");
    PrivDir -> filename:join(PrivDir, "worm")
  end,
  erlang:load_nif(SoName, 0).

%% Ledger Lifecycle

-spec ledger_create(Path :: string()) -> {ok, Ledger :: term()} | {error, Reason :: atom()}.
ledger_create(_Path) ->
  erlang:nif_error(not_loaded).

-spec ledger_open(Path :: string()) -> {ok, Ledger :: term()} | {error, Reason :: atom()}.
ledger_open(_Path) ->
  erlang:nif_error(not_loaded).

-spec ledger_open_or_create(Path :: string()) -> {ok, Ledger :: term()} | {error, Reason :: atom()}.
ledger_open_or_create(_Path) ->
  erlang:nif_error(not_loaded).

-spec ledger_recover(Ledger :: term()) -> ok | {error, Reason :: atom()}.
ledger_recover(_Ledger) ->
  erlang:nif_error(not_loaded).

-spec ledger_close(Ledger :: term()) -> ok.
ledger_close(_Ledger) ->
  erlang:nif_error(not_loaded).

%% Record Operations

-spec ledger_append(Ledger :: term(), Record :: map()) -> ok | {error, Reason :: atom()}.
ledger_append(_Ledger, _Record) ->
  erlang:nif_error(not_loaded).

-spec ledger_query_sequence(Ledger :: term()) -> {ok, Sequence :: non_neg_integer()} | {error, Reason :: atom()}.
ledger_query_sequence(_Ledger) ->
  erlang:nif_error(not_loaded).

-spec ledger_query_hash(Ledger :: term()) -> {ok, Hash :: binary()} | {error, Reason :: atom()}.
ledger_query_hash(_Ledger) ->
  erlang:nif_error(not_loaded).

-spec ledger_validate_record(Ledger :: term(), Record :: map()) -> ok | {error, Reason :: atom()}.
ledger_validate_record(_Ledger, _Record) ->
  erlang:nif_error(not_loaded).

%% Cryptography

-spec sha256(Data :: binary()) -> {ok, Hash :: binary()} | {error, Reason :: atom()}.
sha256(_Data) ->
  erlang:nif_error(not_loaded).

-spec crc32(Data :: binary()) -> {ok, CRC :: non_neg_integer()} | {error, Reason :: atom()}.
crc32(_Data) ->
  erlang:nif_error(not_loaded).

-spec sign_record(Record :: map(), PrivateKey :: binary()) -> {ok, Signature :: binary()} | {error, Reason :: atom()}.
sign_record(_Record, _PrivateKey) ->
  erlang:nif_error(not_loaded).

-spec verify_record(Record :: map(), PublicKey :: binary(), Signature :: binary()) -> ok | {error, Reason :: atom()}.
verify_record(_Record, _PublicKey, _Signature) ->
  erlang:nif_error(not_loaded).

%% CBOR Codec

-spec cbor_encode(Record :: map()) -> {ok, CBOR :: binary()} | {error, Reason :: atom()}.
cbor_encode(_Record) ->
  erlang:nif_error(not_loaded).

-spec cbor_decode(CBOR :: binary()) -> {ok, Record :: map()} | {error, Reason :: atom()}.
cbor_decode(_CBOR) ->
  erlang:nif_error(not_loaded).
