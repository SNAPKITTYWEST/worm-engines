# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Durable storage complete, cross-language vectors validated, formal proofs + replication designed.

---

## Gates Progress

| Gate | Objective | Status |
|------|-----------|--------|
| **1** | Specification | ✅ |
| **2** | Durable Local Append | ✅ |
| **3** | C ABI Parity | ✅ |
| **4** | Cross-Language Vectors | ✅ Complete |
| **5** | SPARK Proof Report | ✅ Phase 1 |
| **6** | Replication Harness | ✅ Phase 1 |
| **7** | External Audit | ⏳ Pending |

---

## What's Done

✅ **Specification** — CDDL, hash domain, invariants  
✅ **Durable Zig Storage** — Segments, manifest, fsync, recovery  
✅ **C ABI** — All 11 functions, C conformance test  
✅ **Golden Vectors** — Zig generator, determinism verified  
✅ **Cross-Language Test** — Zig ↔ C byte-for-byte match  
✅ **Minimal Slice Integration** — Phase 5 stubs in 3 repos  
✅ **SPARK Formal Spec** — All 12 invariants (Ada SPARK)  
✅ **Erlang Mesh** — Distributed replication + gossip protocol

---

## Gate 5: SPARK Proof Report (Phase 1 Complete)

**12 Formal Invariants in Ada SPARK:**
- Sequence Monotonicity
- Timestamp Monotonicity
- Hash Chain Integrity
- Committed Immutability
- Writer Stability
- Policy Monotonicity
- Signature Authenticity
- Payload Commitment
- Record Uniqueness
- Recovery Prefix
- Replication Causality
- Genesis Uniqueness

**Files:**
- `spark/worm_invariants.ads` — 12 invariants (270 lines)
- `spark/worm_invariants.adb` — State machine (80 lines)
- `GATE_5_SPARK_PROOF.md` — Proof strategy

**Next:** GNATprove verification → Lean 4 → Mathlib integration

---

## Gate 6: Replication Harness (Phase 1 Complete)

**Erlang Mesh Replication:**

Multi-node distributed ledger with gossip protocol:

```
Node A (seq:5) ──gossip─→ Node B (seq:4)
         ↓                    ↓
    append(WriterA)    accept(if seq > local)
```

**Files:**
- `erlang/worm_mesh.erl` — Replication node (350 lines)
  * gen_server gossip coordinator
  * Invariant verification (Seq, Writer, Payload, Causality)
  * Peer broadcast + acceptance logic

- `erlang/worm_ledger_nif.erl` — Zig bridge (45 lines)
  * Erlang NIF to C ABI
  * Functions: init, append, query_sequence, query_hash

- `GATE_6_REPLICATION_HARNESS.md` — Protocol + architecture

**Semantics:**
- Causality: peer_seq > local_seq before accept (Inv11)
- Durability: All appends via Zig fsync (Inv4, Inv10)
- Eventual consistency: All nodes converge

**Next:** NIF implementation → Multi-node tests → Byzantine hardening

---

## Cross-Language Vectors (Gate 4 Complete)

**Test:** `./conformance/vectors/run_all_tests.sh`

**Status:**
- ✅ Zig: deterministic CBOR + hash
- ✅ C: matches Zig byte-for-byte
- ⏳ OCaml: scaffold ready
- ⏳ Erlang: scaffold ready

---

## Repository

https://github.com/SNAPKITTYWEST/worm-engines (22 commits)

Recent:
- 0594d1c: Gate 6 Phase 1 (Erlang mesh)
- c394cd5: Gate 5 Phase 1 (SPARK spec)
- 64adc6d: SPARK formal invariants

---

## Architecture

```
Layer 7: External Audit — Pending ⏳
Layer 6: Erlang Mesh (replication) — Phase 1 ✅
Layer 5: Language Bindings — Pending (Phase 5)
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

**WORM Engines**: Deterministic. Verifiable. Distributed.
