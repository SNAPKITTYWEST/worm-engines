# WORM Engines

Multi-language append-only ledger fabric with a Zig storage engine, SPARK-verified control invariants, OCaml policy layer, Erlang replication mesh, and stable C ABI.

**Status**: Early development (0.1.0-dev). Specification and framework architecture complete. Local durable storage and cross-language integration in progress.

---

## What This Is

WORM Engines is a framework for building deterministic, append-only, tamper-evident record chains across multiple languages.

**WORM** = Write-Once-Read-Many.

The system enforces 12 mathematical invariants:
- Sequence monotonicity
- Timestamp monotonicity  
- Hash chain integrity
- Committed immutability
- Writer identity stability
- Policy strengthening
- Signature authenticity
- Payload commitment
- Record uniqueness
- Recovery prefix selection
- Replication causality
- Genesis uniqueness

### Core Components

| Component | Language | Status | Purpose |
|-----------|----------|--------|---------|
| **Specification** | CDDL / Markdown | ✅ Complete | Canonical record format, protocol, invariants |
| **C ABI** | C99 | ⚠️ Partial | Language-agnostic interface (exports not yet complete) |
| **Zig Storage** | Zig | 🔄 Scaffold | Local append-only ledger (in-memory scaffold, needs durability) |
| **Ada Runtime** | Ada/SPARK | ✅ Design | Formally verified state machine (proof design complete) |
| **SPARK Proofs** | SPARK | ✅ Design | Invariant proof obligations (ready for GNATprove) |
| **OCaml Policy** | OCaml | ✅ Complete | Rule evaluation engine (fully functional) |
| **Erlang Mesh** | Erlang/OTP | ✅ Design | Quorum consensus and replication (skeleton complete) |

---

## Current Limitations

**The current implementation is NOT production-ready.** The following are not yet implemented:

- ❌ **Durable local storage**: Records are only held in memory
- ❌ **Actual cryptographic signing**: Signatures are zero-filled placeholders
- ❌ **CBOR serialization**: Encoding/decoding functions are stubs
- ❌ **SHA-256 hashing**: Hash domain construction is defined, implementation pending
- ❌ **Recovery from crash**: No segment persistence or chain reconstruction
- ❌ **Fsync/durability boundary**: No defined commit semantics
- ❌ **C ABI conformance**: Function exports do not match header declarations
- ❌ **Cross-language test vectors**: Compatibility tests not yet written
- ❌ **GNATprove reports**: SPARK proof verification not yet run

**This is currently a specification and design scaffold.** The architecture is solid, but production use requires building the durable storage layer first.

---

## Repository Structure

```
spec/               Canonical specification
abi/                C ABI header and conformance tests
zig-engine/         Local append-only storage (scaffold)
ada-control/        State machine design
spark-core/         Formal proof obligations
ocaml-policy/       Policy compilation and evaluation
erlang-mesh/        Replication mesh design
conformance/        Cross-language test vectors (planned)
docs/               Threat model, durability, architecture guides
.github/workflows/  CI/CD pipelines
```

---

## Building

### Requirements

- Zig 0.11+
- GNAT & GNATprove
- OCaml 4.14+
- Erlang/OTP 24+
- C compiler

### Build All

```bash
make build
```

---

## Roadmap to v1.0

✅ Gate 1 — Specification (complete)
🔄 Gate 2 — Durable Local Append (in progress)
⏳ Gate 3 — C ABI Parity (planned)
⏳ Gate 4 — Cross-Language Vectors (planned)
⏳ Gate 5 — SPARK Proof Report (planned)

---

## Licensing

Dual licensed:
- **Sovereign Source License** (commercial only until 2027-12-31)
- **Business Source License 1.1** (Apache 2.0 after 2027-12-31)

See [LICENSE](LICENSE) and [LICENSING.md](LICENSING.md).

---

## Security

See [SECURITY.md](SECURITY.md).

---

**WORM Engines**: Deterministic. Verifiable. Durable.
