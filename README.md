# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Durable storage complete, cross-language vectors validated, minimal slice integration in progress.

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
✅ **Minimal Slice Integration** — Phase 5 stubs in sovereign-forge, j-matrix-twin, snapkitty-resonance-isa

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

## Minimal Slice Integration (Phase 5 Stubs)

**sovereign-forge** (commit 4890859)
- Module: `src/receipts/worm_integration.{h,c}`
- Function: `worm_append_verification_receipt()` — seal verification results to WORM
- API ready for production CBOR encoding + Ed25519

**j-matrix-twin** (commit 6bb3ed2)
- Module: `worm_receipts.nim`
- Function: `sealJMatrixResult()` — finalize matrix computations as WORM receipts
- Nim ↔ C ABI bridge complete

**snapkitty-resonance-isa** (commit 6a8e2e8)
- Module: `src/worm_integration.rs`
- Function: `seal_resonance_result()` — append Resonance ISA proofs to ledger
- Rust FFI bindings ready

---

## Repository

https://github.com/SNAPKITTYWEST/worm-engines (17 commits)

Recent:
- fa1b489: README updated for Gate 4 completion
- 15d0aa1: Gate 4 Phase C (composite test runner)
- 2a86e33: Gate 4 Phase B (cross-language scaffolds)
- 52340bb: Gate 4 Phase A (golden vectors)
- 91c80d5: Gate 3 (C ABI complete)
- da298d9: Gate 2 (Zig storage complete)

---

## Next: Gate 5 (SPARK Proof Report)

Formalize the 12 WORM invariants in Ada SPARK:
1. Sequence monotonicity
2. Timestamp monotonicity
3. Hash chain integrity
4. Committed immutability
5. Writer stability
6. Policy monotonicity
7. Signature authenticity
8. Payload commitment
9. Record uniqueness
10. Recovery prefix
11. Replication causality
12. Genesis uniqueness

---

## Architecture

```
Layer 5: Language Bindings — Pending (Phase 5)
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
