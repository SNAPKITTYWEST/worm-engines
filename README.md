# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.2.0-dev). Specification, C ABI, durable storage, and cross-language vectors in progress.

---

## Gates Progress

| Gate | Objective | Status |
|------|-----------|--------|
| **1** | Specification (CDDL, protocols, invariants) | ✅ Complete |
| **2** | Durable Local Append (Zig storage, fsync, manifest) | ✅ Complete |
| **3** | C ABI Parity (all 11 functions, C tests) | ✅ Complete |
| **4** | Cross-Language Vectors (Zig→OCaml→C→Erlang match) | 🔄 Phase A complete |
| **5** | SPARK Proof Report (GNATprove verification) | ⏳ Pending |
| **6** | Replication Harness (Erlang mesh integration) | ⏳ Pending |
| **7** | External Audit (independent security review) | ⏳ Pending |

---

## What's Implemented

✅ **Specification** (608 lines) — CDDL, hash domain, invariants, frozen
✅ **Durable Zig Storage** (500+ lines) — Segments, manifest, fsync, crash recovery
✅ **C ABI** (11 functions, 280+ lines) — Full implementation, C conformance test
✅ **Golden Vectors** (Phase 4A) — Canonical record, Zig generator, determinism check

🔄 **Cross-Language Vectors** (Phase 4B/4C) — OCaml, C, Erlang matching in progress
⏳ **OCaml Policy** (complete) — Ready for vector integration
⏳ **Erlang Mesh** (complete) — Ready for vector integration
⏳ **Ada SPARK** (designed) — Awaiting GNATprove verification

---

## Next: Phase 4B (Cross-Language CBOR Matching)

The following languages must encode the same record to identical CBOR bytes:

1. **Zig** ✅ (done in 4A)
2. **OCaml** (policy engine, 4B)
3. **C** (validator harness, 4B)
4. **Erlang** (mesh, 4B)

Then **Phase 4C** validates all produce identical SHA-256 hashes.

---

## Build

```bash
make build
```

---

## Testing

```bash
make test
```

Runs: Zig storage tests, C ABI tests, golden vector determinism checks

---

## Repository

https://github.com/SNAPKITTYWEST/worm-engines

**Recent commits:**
- 52340bb: Gate 4 Phase A (golden vectors + Zig generator)
- 91c80d5: Gate 3 (C ABI complete, 11 functions)
- da298d9: Gate 2 (Zig storage: segments, manifest, CBOR, SHA-256)

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

## Licensing

Dual licensed (Sovereign Source + BSL 1.1, change date 2027-12-31).

See [LICENSE](LICENSE) and [LICENSING.md](LICENSING.md).

---

**WORM Engines**: Deterministic. Verifiable. Durable.
