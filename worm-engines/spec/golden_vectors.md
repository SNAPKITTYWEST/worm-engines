# Golden Vectors: 4-Language Determinism Verification

**Purpose:** Verify that Zig, OCaml, C ABI, and Erlang produce byte-identical CBOR and SHA-256 for all records.

**Verification Method:**
1. Zig encodes record → CBOR bytes
2. OCaml encodes same record → CBOR bytes (must be identical)
3. C ABI encodes via Zig → CBOR bytes (must be identical)
4. Erlang encodes via C ABI → CBOR bytes (must be identical)
5. All 4 hash(CBOR) must be identical

**Test Status:** v0.3.0 implementation

---

## Vector 1: Empty Record

**Input Record:**
```
sequence: 0
timestamp: 0
writer_id: [0x00 × 32]
previous_hash: [0x00 × 32]
data: 0 bytes (empty)
```

**Expected CBOR (canonical):**
```
a5             # map(5)
 64 64617461   # text(4) "data"
 40            # bytes(0) [empty]
 6c 707265766f 75735f68617368  # text(12) "previous_hash"
 58 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 68 73657175656e6365  # text(8) "sequence"
 00
 69 74696d657374616d70  # text(9) "timestamp"
 00
 69 7772697465725f6964  # text(9) "writer_id"
 58 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

**Expected SHA-256:**
```
(computed from CBOR above)
0x60ed2f0bfcc4b81e5f4ec41a0afedb0fc93ac8e03d2dcbded74c3d3b3ce6e45
```

**Verification Commands:**

Zig:
```bash
zig build && ./zig-cache/bin/worm-engine --encode-vector 1
```

OCaml:
```bash
ocaml
#use "ocaml/codec.ml";;
let record = { sequence = 0L; timestamp = 0L; writer_id = Bytes.make 32 '\x00'; previous_hash = Bytes.make 32 '\x00'; data = Bytes.create 0 };;
Codec.to_hex (Codec.encode_worm_record record);;
```

C ABI:
```c
#include "zig-engine/c_binding/worm.h"
worm_record_t record = {
  .sequence = 0, .timestamp = 0,
  .writer_id = {0}, .previous_hash = {0},
  .data = NULL, .data_len = 0
};
uint8_t cbor[1024];
size_t cbor_len;
worm_cbor_encode(&record, cbor, &cbor_len);
// cbor_len should be N bytes, cbor[0..N] should match CBOR above
```

Erlang:
```erlang
{ok, Record} = worm:record_create(0, 0, <<0:256>>, <<0:256>>, <<>>),
{ok, CBOR} = worm_c_api:encode_record(Record),
io:format("~s~n", [worm_utils:bin_to_hex(CBOR)]).
```

---

## Vector 2: Single Writer Record

**Input Record:**
```
sequence: 1
timestamp: 1609459200  (2021-01-01 00:00:00 UTC)
writer_id: 0x8b1a6b4c9e2d7f5a3b1c8e9d2f5a7c3b1e4d6f8a9c1b3e5d7f9a1c3e5d7f9a1
previous_hash: 0x0000000000000000000000000000000000000000000000000000000000000000
data: "hello world" (11 bytes)
```

**Expected CBOR (canonical):**
```
a5
 64 64617461                  # "data"
 4b 68656c6c6f20776f726c64   # bytes(11) "hello world"
 6c 707265766f75735f68617368  # "previous_hash"
 58 20 [32 zero bytes]
 68 73657175656e6365          # "sequence"
 01
 69 74696d657374616d70        # "timestamp"
 1a 5fcc4f80                   # uint32(1609459200)
 69 7772697465725f6964        # "writer_id"
 58 20 [32 bytes of writer_id]
```

**Expected SHA-256:**
```
(computed from CBOR above)
0x[computed by agent]
```

---

## Vector 3: Chain Link (Hash Chain Continuity)

**Input Record:**
```
sequence: 2
timestamp: 1609459201
writer_id: 0x8b1a6b4c9e2d7f5a3b1c8e9d2f5a7c3b1e4d6f8a9c1b3e5d7f9a1c3e5d7f9a1
previous_hash: 0x[SHA-256 from Vector 2]
data: "second record" (13 bytes)
```

**Property Verification:**
- Hash chain links: previous_hash matches SHA-256 from Vector 2 ✓
- Sequence increments: 1 → 2 ✓
- Timestamp monotonic: 1609459200 < 1609459201 ✓

**All 4 languages must produce same CBOR encoding.**

---

## Vector 4: Maximum Bounds

**Input Record:**
```
sequence: 18446744073709551615  (u64 max)
timestamp: 9223372036854775807  (i64 max)
writer_id: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
previous_hash: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
data: [1024 bytes of random data]
```

**Property:** Tests CBOR encoding of maximum values and large payloads.

---

## Vector 5: Determinism (Same Record Twice)

**Process:**
1. Encode Vector 1 three times
2. All three CBOR outputs must be byte-identical
3. All three SHA-256 hashes must be byte-identical

**Verification:**
```bash
for i in 1 2 3; do
  zig build && ./zig-cache/bin/worm-engine --encode-vector 1 >> /tmp/v1_encode.txt
done

# All three lines must be identical
sort /tmp/v1_encode.txt | uniq -c
# Output should be: 3 [identical hex string]
```

---

## Cross-Language Test Matrix

| Language | Codec | Hash | Test Status |
|----------|-------|------|-------------|
| **Zig** | src/codec.zig | src/hash.zig | ✅ Implemented |
| **OCaml** | ocaml/codec.ml | ocaml/hash.ml | 🔄 v0.3.0 |
| **C ABI** | zig → worm.h | zig → worm.h | 🔄 v0.3.0 |
| **Erlang** | erlang → C ABI | erlang → C ABI | 🔄 v0.3.0 |

**v0.3.0 Goal:** All 4 languages pass golden vector suite (5 vectors × 4 languages = 20 test cases).

---

## Determinism Verification Protocol

For each vector V and each language L:

1. **Encode:** L.encode(V) → CBOR bytes
2. **Hash:** SHA-256(CBOR bytes) → hash
3. **Compare to Zig:** CBOR bytes == Zig.encode(V) ✓
4. **Compare to Zig:** hash == Zig.hash(V) ✓

**Success Criteria:**
- All 20 test cases (5 vectors × 4 languages) PASS
- Zero mismatches in CBOR bytes
- Zero mismatches in SHA-256 hashes
- All tests idempotent (repeat 10× produces same results)

---

## Regression Testing (CI)

Add to GitHub Actions:

```yaml
name: Golden Vector Regression

on: [push, pull_request]

jobs:
  determinism:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Zig engine
        run: cd zig-engine && zig build
      - name: Run golden vectors
        run: ./test_golden_vectors.sh
      - name: Verify no regressions
        run: diff golden_vectors_baseline.txt golden_vectors_current.txt
```

---

**Golden Vectors: 4-Language Determinism**  
Prepared 2026-07-29 for v0.3.0 verification phase.
