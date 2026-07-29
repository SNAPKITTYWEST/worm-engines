# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Durable storage complete, cross-language vectors in progress.

---

## Gates Progress

| Gate | Objective | Status |
|------|-----------|--------|
| **1** | Specification (CDDL, protocols, invariants) | ✅ Complete |
| **2** | Durable Local Append (Zig storage, fsync, manifest) | ✅ Complete |
| **3** | C ABI Parity (all 11 functions, C tests) | ✅ Complete |
| **4A** | Golden Vectors (Zig generator, determinism) | ✅ Complete |
| **4B** | Cross-Language Matching (Zig, OCaml, C, Erlang) | 🔄 Complete (2/4 langs) |
| **4C** | Composite Test Suite (all 4 match) | ⏳ Next |
| **5** | SPARK Proof Report (GNATprove verification) | ⏳ Pending |

---

## What's Implemented

✅ **Specification** (608 lines)  
✅ **Durable Zig Storage** (500+ lines)  
✅ **C ABI** (11 functions, 280+ lines)  
✅ **Golden Vectors** (Zig generator)  
✅ **Cross-Language Tests** (Zig ✓, C ✓, OCaml ready, Erlang ready)  

---

## Cross-Language Vectors (Gate 4)

**Genesis record encoded in all languages:**

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

**Phase 4B Status:**
- Zig: ✅ Encodes deterministically to CBOR, hashes deterministically to SHA-256
- C: ✅ Matches Zig byte-for-byte
- OCaml: 🔄 Scaffold ready (awaiting CBOR library)
- Erlang: 🔄 Scaffold ready (awaiting mesh integration)

**Phase 4C:** Composite test comparing all 4 languages (expected: identical CBOR + hash)

---

## Build & Test

```bash
make build
make test
```

Runs all vector tests (Zig, C, OCaml, Erlang).

---

## Repository

https://github.com/SNAPKITTYWEST/worm-engines (14 commits)

Recent:
- 2a86e33: Gate 4 Phase B (cross-language tests)
- 3971823: README (gates progress)
- 52340bb: Gate 4 Phase A (golden vectors)
- 91c80d5: Gate 3 (C ABI complete)
- da298d9: Gate 2 (Zig storage complete)

---

## Architecture

```
Layer 5: Language Bindings (Nim, Python, JavaScript) — Pending
Layer 4: Erlang Mesh (consensus, replication) — Designed ✅
Layer 4: OCaml Policy (rule evaluation) — Complete ✅
Layer 3: Ada SPARK (state machine) — Designed ✅
Layer 2: C ABI (11 functions) — Complete ✅
Layer 1: Zig Storage (durable append) — Complete ✅
Foundation: Specification (CDDL, protocols) — Complete ✅
```

---

## Next: Phase 4C

Create composite test runner that:
1. Runs all 4 language generators
2. Compares CBOR hex strings (must all match)
3. Compares SHA-256 hashes (must all match)
4. Reports: PASS if identical, FAIL if any differ

---

## Licensing

Dual licensed (Sovereign Source + BSL 1.1, change date 2027-12-31).

---

**WORM Engines**: Deterministic. Verifiable. Durable.
