# WORM ABI (Application Binary Interface)

## Overview

`worm_abi.h` is the canonical C interface for WORM Fabric. All language bindings use these 11 functions.

## 11 Core Functions

1. **worm_init_writer(writer_id)** — Create writer with Ed25519 public key
2. **worm_create_record(writer, stream_id, payload_hash)** — Create uncommitted record
3. **worm_append_local(writer, record)** — Validate and commit record (12 invariants enforced)
4. **worm_hash_record(record)** — Compute SHA-256 of record (180-byte domain, deterministic)
5. **worm_cbor_encode(record, buffer, len)** — Serialize to canonical CBOR
6. **worm_cbor_decode(buffer, len)** — Parse canonical CBOR
7. **worm_sign_record(record, private_key)** — Sign with Ed25519 (deterministic)
8. **worm_verify_signature(record, public_key)** — Verify Ed25519 signature
9. **worm_query_sequence(writer)** — Get current max sequence
10. **worm_query_previous_hash(writer)** — Get last record's hash
11. **worm_free(obj)** — Deallocate writer or record (zeros crypto material)

## Error Model

All functions return ErrorCode (int32_t) or NULL on failure.

ErrorCodes (negative values):
- WORM_OK (0): Success
- WORM_ERR_SEQUENCE_MISMATCH (-5): sequence != prev_sequence + 1
- WORM_ERR_TIMESTAMP_INVALID (-6): timestamp < prev_timestamp
- WORM_ERR_HASH_CHAIN_BROKEN (-7): previous_hash mismatch
- WORM_ERR_IMMUTABLE_VIOLATION (-8): attempt to modify committed record
- WORM_ERR_WRITER_MISMATCH (-9): writer_id mismatch
- WORM_ERR_POLICY_ROLLBACK (-10): policy_hash decreased
- WORM_ERR_INVALID_SIGNATURE (-4): signature verification failed
- (and 8 more)

## Key Properties

- **Deterministic**: All cryptographic operations produce identical results across implementations
- **Thread-Safe Per Writer**: Each WormWriter must be used by one thread (or externally synchronized)
- **Stateless Core Functions**: worm_query_sequence, worm_hash_record, etc. are read-only
- **Fixed Output Sizes**: All Hash256, Signature, etc. are fixed-byte arrays (stack-allocable)
- **No malloc in caller**: Core functions don't return heap pointers except writers/records

## Fixed-Size Types

- Hash256: uint8_t[32]
- Signature: uint8_t[64]
- PublicKey: uint8_t[32]
- PrivateKey: uint8_t[32]
- StreamId: uint8_t[32]
- ReceiptId: uint8_t[32]

## Hash Domain (Deterministic)

worm_hash_record computes SHA-256 of exactly 180 bytes:

```
0x57 0x4F 0x52 0x4D           (domain_tag "WORM")
|| version (4 bytes, big-endian uint32)
|| stream_id (32 bytes)
|| sequence (8 bytes, big-endian uint64)
|| previous_hash (32 bytes)
|| payload_hash (32 bytes)
|| policy_hash (32 bytes)
|| writer_id (32 bytes)
|| flags (4 bytes, big-endian uint32, bit 0 only)
```

Two implementations hashing the same record MUST produce identical output.

## CBOR Encoding

All records encoded as canonical CBOR (RFC 7049 deterministic):
- Definite-length only (no indefinite-length arrays/maps)
- Sorted key order (canonical)
- Typical size: 140-200 bytes
- Max: 512 bytes

Two implementations encoding the same record MUST produce identical bytes.

## Typical Workflow

```c
// 1. Create writer
PublicKey pub_key = {...};
WormWriter *writer = worm_init_writer(pub_key);

// 2. Create record
StreamId stream_id = {...};
Hash256 payload_hash = {...};
WormRecord *rec = worm_create_record(writer, stream_id, payload_hash);

// 3. Sign record
PrivateKey priv_key = {...};
worm_sign_record(rec, priv_key);

// 4. Append and validate (all 12 invariants enforced)
ErrorCode err = worm_append_local(writer, rec);
if (err != WORM_OK) {
    // validation failed, check error code
}

// 5. Query state
uint64_t seq = worm_query_sequence(writer);
Hash256 prev = worm_query_previous_hash(writer);

// 6. Encode to CBOR
uint8_t buf[512];
size_t buf_len = sizeof(buf);
worm_cbor_encode(rec, buf, &buf_len);

// 7. Clean up
worm_free(rec);
worm_free(writer);
```

## Invariants Enforced by worm_append_local

1. sequence_monotone: new_sequence = prev_sequence + 1
2. timestamp_monotone: new_timestamp >= prev_timestamp
3. hash_chain_valid: previous_hash matches computed hash
4. committed_immutable: cannot overwrite committed record
5. writer_identity_stable: writer_id fixed at genesis
6. policy_strengthen_only: policy_hash cannot decrease (lexicographic)
7. signature_authentic: Ed25519 signature must verify
8. payload_integrity: payload_hash commitment
9. record_collision_free: SHA-256 uniqueness
10. recovery_longest_prefix: (implicit)
11. replication_no_rewind: (implicit)
12. genesis_unique_per_stream: (implicit)

See spec/invariants.md for full definitions.

## Language Bindings

The ABI is C99-compatible and can be bound from:
- Nim (via {.importc.} pragmas)
- OCaml (via External declarations)
- Erlang (via NIF wrappers)
- Ada (via pragma Import C)
- Rust (via extern "C" blocks)
- Go (via cgo)
- Python (via ctypes or cffi)

All bindings import this single header and link against the compiled WORM library.
