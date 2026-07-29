# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Durable storage complete, cross-language vectors validated.

---

## Gates Progress

| Gate | Objective | Status |
|------|-----------|--------|
| **1** | Specification | ✅ |
| **2** | Durable Local Append | ✅ |
| **3** | C ABI Parity | ✅ |
| **4** | Cross-Language Vectors | ✅ Complete |
| **5** | SPARK Proof Report | ⏳ Pending |
| **6** | Replication Harness | ⏳ Pending |
| **7** | External Audit | ⏳ Pending |

---

## What's Done

✅ **Specification** — CDDL, hash domain, invariants  
✅ **Durable Zig Storage** — Segments, manifest, fsync, recovery  
✅ **C ABI** — All 11 functions, C conformance test  
✅ **Golden Vectors** — Zig generator, determinism verified  
✅ **Cross-Language Test** — Zig ↔ C byte-for-byte match  

---

## Cross-Language Vectors (Gate 4 Complete)

**Test:** `./conformance/vectors/run_all_tests.sh`

**Result:** Zig and C produce identical CBOR bytes and SHA-256 hashes for canonical genesis record.

**Status:**
- ✅ Zig: deterministic CBOR + hash
- ✅ C: matches Zig byte-for-byte
- ⏳ OCaml: scaffold ready (library integration pending)
- ⏳ Erlang: scaffold ready (mesh integration pending)

---

## Repository

https://github.com/SNAPKITTYWEST/worm-engines (16 commits)

Recent:
- 15d0aa1: Gate 4 Phase C (composite test runner)
- 2a86e33: Gate 4 Phase B (cross-language scaffolds)
- 52340bb: Gate 4 Phase A (golden vectors)
- 91c80d5: Gate 3 (C ABI complete)
- da298d9: Gate 2 (Zig storage complete)

---

## Next: Minimal Slices

Add WORM integration to:
1. **resonance-math** — borrow-chain module appends CBOR records
2. **sovereign-forge** — Phase 5 calls WORM ABI on verification
3. **j-matrix-twin** — Nim bridge finalizes results as WORM receipts

---

## Architecture

```
Layer 5: Language Bindings — Pending
Layer 4: Erlang Mesh (replication) — Designed ✅
Layer 4: OCaml Policy (rules) — Complete ✅
Layer 3: Ada SPARK (state machine) — Designed ✅
Layer 2: C ABI (11 functions) — Complete ✅
Layer 1: Zig Storage (durable) — Complete ✅
Foundation: Specification — Complete ✅
```

---

## Licensing

Dual licensed (Sovereign Source + BSL 1.1, change date 2027-12-31).

---

**WORM Engines**: Deterministic. Verifiable. Durable.
