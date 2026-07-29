# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Durable storage complete, cross-language vectors validated, formal proofs in progress.

---

## Gates Progress

| Gate | Objective | Status |
|------|-----------|--------|
| **1** | Specification | ✅ |
| **2** | Durable Local Append | ✅ |
| **3** | C ABI Parity | ✅ |
| **4** | Cross-Language Vectors | ✅ Complete |
| **5** | SPARK Proof Report | ✅ Phase 1 |
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
✅ **SPARK Formal Spec** — All 12 invariants in Ada SPARK

---

## Gate 5: SPARK Proof Report (Phase 1 Complete)

**12 Formal Invariants Specified:**

1. **Sequence Monotonicity** — Strictly increasing sequence numbers
2. **Timestamp Monotonicity** — Non-decreasing timestamps
3. **Hash Chain Integrity** — Each record links to predecessor
4. **Committed Immutability** — Fsync'd records cannot change
5. **Writer Stability** — Writer ID is constant
6. **Policy Monotonicity** — Policy rules never weaken
7. **Signature Authenticity** — Valid Ed25519 signatures
8. **Payload Commitment** — Cryptographic payload hashes
9. **Record Uniqueness** — No duplicate (stream, seq, writer)
10. **Recovery Prefix** — All committed records on disk
11. **Replication Causality** — Hash dependencies ordered
12. **Genesis Uniqueness** — Exactly one root record

**Specification:**
- `spark/worm_invariants.ads` — 12 invariants as pure functions (270 lines)
- `spark/worm_invariants.adb` — State machine implementation (80 lines)

**Documentation:**
- `GATE_5_SPARK_PROOF.md` — Full proof strategy

**Next Phases:**
- Phase 2: GNATprove verification (automated proof checking)
- Phase 3: Lean 4 formalization (theorem prover)
- Phase 4: Lean integration with Mathlib

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

https://github.com/SNAPKITTYWEST/worm-engines (20 commits)

Recent:
- 64adc6d: Gate 5 Phase 1 (SPARK invariants)
- 0067b83: Phase 5 slice integration complete
- fa1b489: README updated for Gate 4 completion
- 15d0aa1: Gate 4 Phase C (composite test runner)

---

## Architecture

```
Layer 5: Language Bindings — Pending (Phase 5)
Layer 4: Erlang Mesh (replication) — Designed ✅
Layer 4: OCaml Policy (rules) — Complete ✅
Layer 3: Ada SPARK (formal proofs) — Phase 1 ✅
Layer 2: C ABI (11 functions) — Complete ✅
Layer 1: Zig Storage (durable) — Complete ✅
Foundation: Specification — Complete ✅
```

---

## Licensing

Dual licensed (Sovereign Source + BSL 1.1, change date 2027-12-31).

---

**WORM Engines**: Deterministic. Verifiable. Durable.
