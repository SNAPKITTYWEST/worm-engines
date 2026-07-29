# Gate 4 Phase B: Cross-Language CBOR Matching

## Objective

All implementations (Zig, OCaml, C, Erlang) must encode the same genesis record to **identical CBOR bytes**.

## Genesis Record (Canonical Input)

```
{
  version: 1,
  stream_id: 0xAA (32 bytes),
  sequence: 0,
  timestamp: 1000,
  previous_hash: 0x00 (32 bytes),
  payload_hash: 0xBB (32 bytes),
  policy_hash: 0x00 (32 bytes),
  writer_id: 0xCC (32 bytes),
  flags: 1,
  signature: 0x00 (64 bytes)
}
```

## Implementation Status

| Language | Test File | Status | CBOR Hex | Hash Hex |
|----------|-----------|--------|----------|----------|
| **Zig** | test_vectors.zig | ✅ Complete | Generated | Generated |
| **OCaml** | test_vectors_ocaml.ml | 🔄 Partial | Pending | Pending |
| **C** | test_vectors.c | ✅ Complete | Match check | Match check |
| **Erlang** | test_vectors_erlang.erl | 🔄 Partial | Pending | Pending |

## Expected Output

### CBOR Bytes
All languages must produce identical hex string when encoding the genesis record.

```
a9000018010158203a...  (Zig canonical CBOR)
```

### SHA-256 Hash
All languages must produce identical hash of the 180-byte domain.

```
hash(domain_tag || version || stream_id || sequence || hashes || writer_id || flags)
```

## Determinism Verification

Each implementation verifies:
1. Encode record twice → identical CBOR bytes
2. Hash record twice → identical SHA-256
3. Cross-language: Zig CBOR == OCaml CBOR == C CBOR == Erlang CBOR
4. Cross-language: Zig hash == OCaml hash == C hash == Erlang hash

## Next Steps (Phase 4C)

Create composite test suite:
1. Run all 4 generators
2. Collect CBOR hex and hash hex from each
3. Compare all outputs
4. Report: PASS if all identical, FAIL if any differ

## Success Criteria

✅ **PASS**: All 4 languages produce byte-for-byte identical CBOR and SHA-256  
❌ **FAIL**: Any language produces different output (indicates implementation bug or spec deviation)

---

**Phase 4B Status:** 2/4 implementations complete (Zig, C). OCaml and Erlang pending full CBOR library integration.
