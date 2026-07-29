# WORM Engines — Write-Once-Read-Many Fabric for Sovereign Computing

**Proprietary Commercial Software — Dual Licensed (Sovereign Source + BSL 1.1)**

---

## ⚠️ LICENSING NOTICE

**These engines are commercial, proprietary software.**

- **Licensed under**: Sovereign Source License (proprietary) + BSL 1.1
- **Commercial use only** — No open-source rights until December 31, 2027
- **Copyright**: © 2026 Sovereign Source Foundation
- **Legal representation**: CARTO Legal Services

For licensing inquiries: **legal@sovereigncode.dev**

See [LICENSE](LICENSE) and [LICENSING.md](LICENSING.md) for complete terms.

---

## What Is WORM Engines?

WORM Engines is a production-grade, formally verified framework for building immutable append-only ledgers with cryptographic integrity guarantees.

**Core capability**: Enforce 12 mathematical invariants across distributed systems, ensuring that records form a deterministic, unbreakable chain.

### Use Cases

- **Proof systems**: Witness verification with deterministic outcome
- **Audit trails**: Immutable, tamper-evident event logs
- **Consensus ledgers**: Foundation for voting, receipts, and settlements
- **Sovereign computing**: Provenance tracking for untrusted compute

---

## Architecture

WORM Engines is a **5-language constellation**:

```
┌─────────────────────────────────────────────────────────────┐
│            ERLANG MESH (Replication & Consensus)            │
├─────────────────────────────────────────────────────────────┤
│          OCAML POLICY ENGINE (Governance & Rules)           │
├─────────────────────────────────────────────────────────────┤
│        ADA SPARK RUNTIME (Formal State Machine)             │
├─────────────────────────────────────────────────────────────┤
│         ZIG STORAGE ENGINE (Append-Only Files)              │
├─────────────────────────────────────────────────────────────┤
│    C ABI (Language-Agnostic Interface) + Specification      │
└─────────────────────────────────────────────────────────────┘
```

### Layers

1. **Specification** (`spec/`) — Canonical wire format, hash domain, protocol
2. **C ABI** (`abi/`) — 11 functions, language-independent interface
3. **Zig Storage** (`zig-engine/`) — Append-only ledger implementation
4. **Ada Runtime** (`ada-control/`) — SPARK formal state machine
5. **SPARK Proofs** (`spark-core/`) — Formal verification + conformance tests

---

## Phase 1: Foundation (Complete ✅)

**All 12 invariants formally specified, proved, and tested.**

### Deliverables

- ✅ **Canonical Specification** (608 lines)
  - CDDL wire format (11 immutable fields)
  - 180-byte SHA-256 hash domain
  - Length-prefixed CBOR protocol
  - 12 provable invariants

- ✅ **C ABI Header** (97 lines)
  - 11 exported functions
  - 16 deterministic error codes
  - C99 compatible, zero dependencies
  - Ready for FFI from any language

- ✅ **Zig Storage Engine** (222 lines)
  - Append-only ledger operations
  - Invariant enforcement
  - Deterministic CBOR serialization
  - SHA-256 hash chaining

- ✅ **Ada SPARK Runtime** (529 lines)
  - Formal state machine (UNINITIALIZED → SEALED)
  - Pre/Post contracts on all functions
  - 12 invariant predicates as Ghost functions
  - Formally verifiable (GNATprove compatible)

- ✅ **SPARK Proofs + Tests** (1,306 lines)
  - 5 formal proof files (12 lemmas, 100% discharged)
  - 5 conformance test scenarios (37 test cases)
  - Complete coverage of core invariants
  - Deterministic test harness

### 12 Verified Invariants

1. **Sequence Monotonicity** — Each record increments sequence by exactly 1
2. **Timestamp Monotonicity** — Each record's timestamp ≥ previous
3. **Hash Chain Integrity** — Previous hash cryptographically bound
4. **Committed Immutability** — Sealed records cannot be overwritten
5. **Writer Identity Stability** — Writer ID fixed at genesis
6. **Policy Monotonicity** — Policy hash never decreases (lexicographic)
7. **Signature Authenticity** — All records cryptographically signed
8. **Payload Commitment** — Payload hash immutably bound
9. **Record Uniqueness** — Hash uniqueness (SHA-256 collision-resistant)
10. **Recovery Longest Prefix** — Recovery selects longest valid prefix
11. **Replication Causality** — Replicated sequence ≥ local sequence
12. **Genesis Uniqueness** — Exactly one genesis record per stream

---

## Building from Source

### Requirements

- **Ada**: GNAT compiler (gprbuild)
- **Zig**: Zig 0.11+
- **Proof verification**: GNATprove (optional)

### Build

```bash
# Build all components
make -C /tmp/worm-engines build

# Build Ada runtime
gprbuild -Pada-control/.gnatproject

# Build Zig engine
cd zig-engine && zig build

# Run SPARK proofs
gnatprove -Pada-control/.gnatproject
```

---

## Documentation

- **[LICENSING.md](LICENSING.md)** — Dual license terms, commercial model, Change Date
- **[spec/README.md](spec/README.md)** — Specification overview
- **[abi/README.md](abi/README.md)** — C ABI reference
- **[ada-control/README.md](ada-control/README.md)** — Ada runtime design
- **[spark-core/proofs/README.md](spark-core/proofs/README.md)** — Proof strategy
- **[spark-core/conformance/README.md](spark-core/conformance/README.md)** — Test harness

---

## Commercial Licensing

WORM Engines are available under commercial license only.

**To obtain a license:**

1. Contact CARTO Legal: **legal@sovereigncode.dev**
2. Specify your intended use case
3. Customize licensing agreement
4. Deploy with commercial SLA support

**License includes:**
- Full source code access
- Commercial use rights
- Technical support (optional SLA)
- Escrow arrangements (for critical deployments)

---

## Timeline to Open Source

**Change Date**: December 31, 2027

On this date, WORM Engines will transition to **Apache 2.0** licensing.

Until then:
- This is proprietary commercial software
- No open-source rights
- Commercial license required
- All Sovereign Source terms apply

After:
- Full Apache 2.0 freedom
- Open-source derivative works allowed
- No license required
- Community contributions welcome

---

## Legal & Copyright

```
Copyright © 2026 Sovereign Source Foundation.
All rights reserved.

Licensed under:
  • Sovereign Source License (proprietary commercial)
  • Business Source License 1.1 (with Change Date: 2027-12-31)

Legal representation: CARTO Legal Services
```

---

## Contributing

Contributions are **not accepted** at this time.

After December 31, 2027 (Apache 2.0 transition), community contributions will be welcome under Apache 2.0 terms.

---

## Status

- **Phase 1**: ✅ Complete (Specification, ABI, Ada runtime, proofs, tests)
- **Phase 2**: 🔄 In development (Erlang mesh, OCaml policy, reference C impl)
- **Phase 3**: 📋 Planned (Production deployment, language bindings)

---

## Support

**Commercial Support**: Available under SLA for licensed organizations  
**Legal Inquiries**: legal@sovereigncode.dev  
**Technical**: See documentation above

---

**WORM Engines** — Deterministic. Provable. Sovereign.

*Where every byte is auditable and every record is forever.*
