%% WORM Engines Key Management Module
%% Ed25519 key generation, storage, rotation
%% All keys stored encrypted at rest (AES-256-GCM)

-module(worm_keys).
-export([
  generate_keypair/0,
  keypair_to_pem/1,
  pem_to_keypair/1,
  encrypt_private_key/2,
  decrypt_private_key/2,
  sign_record/3,
  verify_record/4,
  rotate_key/2,
  list_keys/0,
  delete_key/1
]).

-record(keypair, {
  private_key :: binary(),
  public_key :: binary(),
  created_at :: integer(),
  key_id :: binary()
}).

-record(encrypted_key, {
  ciphertext :: binary(),
  iv :: binary(),
  tag :: binary(),
  salt :: binary(),
  key_id :: binary()
}).

%% ===== KEY GENERATION =====

%% Generate Ed25519 keypair
-spec generate_keypair() -> {ok, Keypair :: term()} | {error, Reason :: atom()}.
generate_keypair() ->
  case crypto:generate_key(eddsa, ed25519) of
    {PublicKey, PrivateKey} ->
      KeyID = crypto:hash(sha256, PublicKey),
      {ok, #keypair{
        private_key = PrivateKey,
        public_key = PublicKey,
        created_at = erlang:system_time(seconds),
        key_id = KeyID
      }};
    Error ->
      {error, Error}
  end.

%% ===== KEY SERIALIZATION =====

%% Convert keypair to PEM format (unencrypted)
-spec keypair_to_pem(Keypair :: term()) -> {ok, PEM :: binary()} | {error, Reason :: atom()}.
keypair_to_pem(#keypair{private_key = PrivKey, public_key = PubKey}) ->
  try
    PemEntry = public_key:pem_entry_encode('PrivateKeyInfo', {
      'PrivateKeyInfo',
      1,
      {'AlgorithmIdentifier', {1,3,101,112}, 'NULL'},
      PrivKey,
      asn1_NOVALUE
    }),
    {ok, PemEntry}
  catch
    Error -> {error, Error}
  end.

%% Convert PEM to keypair
-spec pem_to_keypair(PEM :: binary()) -> {ok, Keypair :: term()} | {error, Reason :: atom()}.
pem_to_keypair(PEM) ->
  try
    [PemEntry] = public_key:pem_decode(PEM),
    case public_key:pem_entry_decode(PemEntry) of
      {'PrivateKeyInfo', 1, _Algo, PrivKey, _Attrs} ->
        {ok, PubKey} = crypto:generate_key(eddsa, ed25519, PrivKey),
        KeyID = crypto:hash(sha256, PubKey),
        {ok, #keypair{
          private_key = PrivKey,
          public_key = PubKey,
          created_at = erlang:system_time(seconds),
          key_id = KeyID
        }};
      Error -> {error, Error}
    end
  catch
    Error -> {error, Error}
  end.

%% ===== KEY ENCRYPTION =====

%% Encrypt private key with passphrase (AES-256-GCM)
-spec encrypt_private_key(Keypair :: term(), Passphrase :: binary()) -> {ok, Encrypted :: term()} | {error, Reason :: atom()}.
encrypt_private_key(#keypair{private_key = PrivKey, key_id = KeyID}, Passphrase) ->
  try
    %% Derive encryption key from passphrase (PBKDF2)
    Salt = crypto:strong_rand_bytes(16),
    Key = crypto:pbkdf2_hmac(sha256, Passphrase, Salt, 100000, 32),

    %% Encrypt with AES-256-GCM
    IV = crypto:strong_rand_bytes(12),
    AAD = KeyID,  %% Additional authenticated data
    {Ciphertext, Tag} = crypto:crypto_one_time_aead(aes_256_gcm, Key, IV, PrivKey, AAD, true),

    {ok, #encrypted_key{
      ciphertext = Ciphertext,
      iv = IV,
      tag = Tag,
      salt = Salt,
      key_id = KeyID
    }}
  catch
    Error -> {error, Error}
  end.

%% Decrypt private key with passphrase
-spec decrypt_private_key(Encrypted :: term(), Passphrase :: binary()) -> {ok, PrivateKey :: binary()} | {error, Reason :: atom()}.
decrypt_private_key(#encrypted_key{ciphertext = CT, iv = IV, tag = Tag, salt = Salt, key_id = KeyID}, Passphrase) ->
  try
    %% Derive decryption key from passphrase
    Key = crypto:pbkdf2_hmac(sha256, Passphrase, Salt, 100000, 32),

    %% Decrypt with AES-256-GCM
    AAD = KeyID,
    PrivKey = crypto:crypto_one_time_aead(aes_256_gcm, Key, IV, CT, AAD, Tag, false),

    {ok, PrivKey}
  catch
    Error -> {error, Error}
  end.

%% ===== SIGNING & VERIFICATION =====

%% Sign record with private key
-spec sign_record(Record :: map(), PrivateKey :: binary(), PublicKey :: binary()) -> {ok, Signature :: binary()} | {error, Reason :: atom()}.
sign_record(Record, PrivateKey, PublicKey) ->
  try
    %% Serialize record to CBOR
    {ok, CBOR} = worm:cbor_encode(Record),

    %% Hash CBOR with SHA-256
    {ok, Hash} = worm:sha256(CBOR),

    %% Sign hash with Ed25519
    Signature = crypto:sign(eddsa, sha256, Hash, [PrivateKey, PublicKey]),
    {ok, Signature}
  catch
    Error -> {error, Error}
  end.

%% Verify record signature
-spec verify_record(Record :: map(), PublicKey :: binary(), Signature :: binary(), CBOR :: binary()) -> ok | {error, Reason :: atom()}.
verify_record(Record, PublicKey, Signature, CBOR) ->
  try
    %% Hash CBOR with SHA-256
    {ok, Hash} = worm:sha256(CBOR),

    %% Verify signature with Ed25519
    case crypto:verify(eddsa, sha256, Hash, Signature, [PublicKey]) of
      true -> ok;
      false -> {error, signature_verification_failed}
    end
  catch
    Error -> {error, Error}
  end.

%% ===== KEY ROTATION =====

%% Rotate to new key (old key becomes inactive)
-spec rotate_key(OldKeypair :: term(), NewKeypair :: term()) -> {ok, RotationRecord :: term()} | {error, Reason :: atom()}.
rotate_key(OldKeypair, NewKeypair) ->
  try
    RotationRecord = {
      old_key_id = OldKeypair#keypair.key_id,
      new_key_id = NewKeypair#keypair.key_id,
      rotated_at = erlang:system_time(seconds),
      signature = crypto:sign(eddsa, sha256,
        crypto:hash(sha256, OldKeypair#keypair.key_id),
        [OldKeypair#keypair.private_key, OldKeypair#keypair.public_key])
    },
    {ok, RotationRecord}
  catch
    Error -> {error, Error}
  end.

%% ===== KEY STORAGE =====

%% List all key IDs
-spec list_keys() -> {ok, [KeyID :: binary()]} | {error, Reason :: atom()}.
list_keys() ->
  case ets:lookup(worm_keys, all_key_ids) of
    [{all_key_ids, KeyIDs}] -> {ok, KeyIDs};
    [] -> {ok, []}
  end.

%% Delete key by ID (mark as revoked)
-spec delete_key(KeyID :: binary()) -> ok | {error, Reason :: atom()}.
delete_key(KeyID) ->
  ets:delete(worm_keys, KeyID),
  {ok, KeyIDs} = list_keys(),
  NewKeyIDs = [K || K <- KeyIDs, K =/= KeyID],
  ets:insert(worm_keys, {all_key_ids, NewKeyIDs}),
  ok.
