# WORM Engine - Zig Implementation

Zig-based storage engine implementing the WORM (Write-Once-Read-Many) protocol with cryptographic guarantees and formal invariant enforcement.

## Architecture

```
zig-engine/
├── build.zig          - Build configuration, outputs shared library + static library
├── src/
│   ├── main.zig       - C ABI exports (implements worm_abi.h)
│   ├── writer.zig     - WormWriter state machine (per-stream)
│   ├── record.zig     - WormRecord immutable structure
│   ├── storage.zig    - Append-only file operations
│   ├── hash.zig       - SHA-256 hash domain (180-byte deterministic)
│   ├── cbor.zig       - Canonical CBOR encoding/decoding
│   ├── ed25519.zig    - Ed25519 signing and verification
│   └── invariants.zig - 12 WORM invariant enforcement checks
├── test/
│   ├── storage_test.zig
│   └── invariants_test.zig
└── README.md
```

## Features

### Core Invariants (12/12 Enforced)

1. **Sequence Monotonicity**: `sequence_new = sequence_previous + 1`
2. **Timestamp Monotonicity**: `timestamp_new >= timestamp_previous`
3. **Hash Chain Integrity**: `previous_hash = SHA256(hash_domain(prev_record))`
4. **Commitment Immutability**: Committed records cannot be modified
5. **Writer Identity Stability**: Writer ID fixed at genesis
6. **Policy Monotonicity**: Policy can only tighten (lexicographic ordering)
7. **Signature Validity**: Ed25519 verification on every record
8. **Payload Commitment**: Payload hash cryptographically binds payload to record
9. **Record Uniqueness**: SHA-256 hash provides 2^-128 collision probability
10. **Recovery Longest Prefix**: (Storage layer, not yet implemented)
11. **Replication Causality**: No backward sequence progression
12. **Genesis Uniqueness**: One genesis per stream_id

### Cryptographic Properties

- **Hash Domain**: 180-byte deterministic construction per spec
  - Domain tag: `0x574F524D` ("WORM")
  - Big-endian integers
  - SHA-256 output: 32 bytes
- **Ed25519 Signatures**: Deterministic signing over hash domain
- **CBOR Encoding**: Canonical (RFC 7049) for byte-for-byte determinism

### Thread Safety

- Per-writer synchronization via `std.Thread.Mutex`
- Read-safe operations (hash computation, signature verification)
- Storage operations are serialized per stream

## Build

```bash
# Build shared library (for C interop)
zig build

# Build static library
zig build -Doptimize=ReleaseFast

# Run all tests
zig build test

# Output: zig-out/lib/libworm_engine.so (or .dylib/.dll)
```

## C ABI Functions

All functions exported from `worm_abi.h`:

```c
WormWriter* worm_init_writer(const PublicKey writer_id);
WormRecord* worm_create_record(WormWriter *writer, const StreamId stream_id, const Hash256 payload_hash);
ErrorCode worm_append_local(WormWriter *writer, WormRecord *record);
Hash256 worm_hash_record(WormRecord *record);
ErrorCode worm_cbor_encode(WormRecord *record, uint8_t *buffer, size_t *len);
WormRecord* worm_cbor_decode(const uint8_t *buffer, size_t len);
ErrorCode worm_sign_record(WormRecord *record, const PrivateKey private_key);
ErrorCode worm_verify_signature(WormRecord *record, const PublicKey public_key);
uint64_t worm_query_sequence(WormWriter *writer);
Hash256 worm_query_previous_hash(WormWriter *writer);
void worm_free(void *obj);
```

## Usage Example (C)

```c
#include "worm_abi.h"

// Generate Ed25519 keypair (outside WORM engine)
PublicKey public_key = {...};
PrivateKey private_key = {...};

// Initialize writer
WormWriter *writer = worm_init_writer(public_key);

// Create genesis record
StreamId stream_id = {...};
Hash256 payload_hash = {...}; // SHA-256 of your payload

WormRecord *record = worm_create_record(writer, stream_id, payload_hash);

// Sign the record
worm_sign_record(record, private_key);

// Append to local storage (enforces all 12 invariants)
ErrorCode result = worm_append_local(writer, record);

if (result == WORM_OK) {
    printf("Record appended successfully\n");
} else {
    printf("Invariant violation: %d\n", result);
}

// Cleanup
worm_free(record);
worm_free(writer);
```

## Usage Example (Zig)

```zig
const std = @import("std");
const WormWriter = @import("writer.zig").WormWriter;
const WormRecord = @import("record.zig").WormRecord;
const hash_mod = @import("hash.zig");
const ed25519 = @import("ed25519.zig");
const invariants = @import("invariants.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Generate keypair
    const keypair = try ed25519.generateKeypair();

    // Initialize writer
    var writer = try WormWriter.init(allocator, keypair.public);
    defer writer.deinit();

    // Create genesis record
    const stream_id = [_]u8{0xaa} ** 32;
    const payload_hash = [_]u8{0xbb} ** 32;
    const policy_hash = [_]u8{0xcc} ** 32;

    var genesis = WormRecord.genesis(stream_id, payload_hash, policy_hash, keypair.public);

    // Sign
    try ed25519.signRecord(&genesis, keypair.private);

    // Validate all invariants
    try invariants.validateAll(writer, &genesis);

    // Update writer state
    const genesis_hash = hash_mod.hashRecord(&genesis);
    writer.updateFromRecord(&genesis, genesis_hash);

    std.debug.print("Genesis record created: sequence={}\n", .{genesis.sequence});
}
```

## Storage Format

Each record is stored as:

```
[4-byte big-endian length][CBOR-encoded WormRecord]
```

File layout:
```
record_0: [len_0][cbor_0]
record_1: [len_1][cbor_1]
record_2: [len_2][cbor_2]
...
```

- Append-only (no overwrites)
- Sequential reads for recovery
- Max record size: 1MB (configurable)

## Testing

```bash
# Run all tests
zig build test

# Test coverage:
# - Hash domain construction (180-byte determinism)
# - CBOR encode/decode round-trip
# - Ed25519 sign/verify
# - All 12 invariant checks
# - Storage append/read
# - C ABI integration
```

## Error Codes

```c
WORM_OK                          = 0
WORM_ERR_INVALID_WRITER          = -1
WORM_ERR_INVALID_RECORD          = -2
WORM_ERR_INVALID_BUFFER          = -3
WORM_ERR_INVALID_SIGNATURE       = -4
WORM_ERR_SEQUENCE_MISMATCH       = -5
WORM_ERR_TIMESTAMP_INVALID       = -6
WORM_ERR_HASH_CHAIN_BROKEN       = -7
WORM_ERR_IMMUTABLE_VIOLATION     = -8
WORM_ERR_WRITER_MISMATCH         = -9
WORM_ERR_POLICY_ROLLBACK         = -10
WORM_ERR_CBOR_ENCODE_FAILED      = -11
WORM_ERR_CBOR_DECODE_FAILED      = -12
WORM_ERR_BUFFER_TOO_SMALL        = -13
WORM_ERR_OUT_OF_MEMORY           = -14
WORM_ERR_INVARIANT_VIOLATED      = -15
WORM_ERR_STREAM_NOT_INITIALIZED  = -16
```

## Spec Compliance

- ✅ Hash domain: 180 bytes, big-endian, SHA-256
- ✅ CBOR: Canonical encoding (RFC 7049)
- ✅ Ed25519: Deterministic signatures
- ✅ All 12 invariants enforced
- ✅ C ABI: 11 functions exported
- ✅ Thread-safe: Per-writer mutex
- ⚠️ Storage: Basic file append (recovery not yet implemented)
- ⚠️ Replication: Wire protocol not yet implemented

## Future Work

1. **Recovery**: Longest sealed prefix selection (invariant 10)
2. **Replication**: Wire protocol (Unix socket / TCP, per `protocol.md`)
3. **Storage Optimization**: mmap, zero-copy reads
4. **Policy Engine**: Policy hash interpretation and enforcement
5. **Receipt Verification**: 3rd-party witness integration

## License

Same as parent project (worm-engines).

## References

- Spec: `../spec/hash-domain.md`, `../spec/invariants.md`, `../spec/worm-record.cddl`
- C ABI: `../abi/worm_abi.h`
- Protocol: `../spec/protocol.md`
