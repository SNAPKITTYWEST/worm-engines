# WORM Engines

Multi-language append-only ledger fabric with Zig storage, SPARK formal specification, OCaml policy layer, and Erlang replication mesh.

**Current Status: 0.2.0-dev (Experimental, C-grade)**  
**Target: 1.0.0 (Production-ready, B+) in 3-6 months**  
**License: Business Source License 1.1 (→ AGPL-3.0 Dec 31, 2027)**

---

## ⚠️ Important: Not Production-Ready

WORM Engines is an **experimental prototype**. Do not use in production without careful review.

See **ASSURANCE_MATRIX.md** for exact evidence levels on each component.

---

## What Works Today

✅ **Zig append path** — Records durably written to segments + manifest  
✅ **C ABI** — 11 functions exposed, 2-language conformance  
✅ **Golden vectors** — Zig ↔ C byte-for-byte CBOR + SHA-256 match  
✅ **SPARK formal spec** — 12 invariants specified (not yet GNATprove verified)  
✅ **Erlang mesh design** — Gossip protocol, not yet tested  
✅ **Licensed** — Official BSL 1.1, change date 2027-12-31

---

## What Needs Work (P0)

❌ **Zig storage** — 10 critical bugs (recovery missing, validation incomplete)  
❌ **4-language vectors** — OCaml/Erlang generators not integrated  
❌ **Signing/verification** — Ed25519 functions not implemented  
❌ **Erlang replication** — NIF not implemented, no multi-node tests  
❌ **External audit** — Not yet security reviewed  

See **ROADMAP.md** for detailed path to v1.0.0.

---

## Quick Start (Experimental Only)

```bash
git clone https://github.com/SNAPKITTYWEST/worm-engines.git
cd worm-engines

# Build Zig storage
cd zig-engine
zig build

# Run conformance test (2-language only)
cd ../conformance/vectors
./run_all_tests.sh
```

**Result:** Zig and C produce identical records. ✅

---

## Architecture

```
Layer 5: Language Bindings    (Pending)
Layer 4: Erlang Mesh           (Designed, tests pending)
Layer 4: OCaml Policy          (Complete)
Layer 3: Ada SPARK (Formal)    (Specified, GNATprove pending)
Layer 2: C ABI (11 functions)  (Complete)
Layer 1: Zig Storage (Durable) (Append works, recovery pending)
────────────────────────────────────────
Foundation: CDDL Spec         (Complete)
```

---

## Evidence by Component

| Component | Specified | Implemented | Unit Tested | Integrated | GNATprove | Audited | Production |
|-----------|-----------|-------------|-------------|------------|-----------|---------|-----------|
| Zig storage | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | ❌ |
| C ABI | ✅ | ✅ | ✅ | ⏳ | ❌ | ❌ | ❌ |
| Vectors (Zig/C) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Vectors (all 4) | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ |
| SPARK invariants | ✅ | ✅ | ❌ | ❌ | ⏳ | ❌ | ❌ |
| Erlang mesh | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

**Full matrix:** See [ASSURANCE_MATRIX.md](ASSURANCE_MATRIX.md)

---

## Roadmap to Production

### v0.2.1 (2 weeks) — P0 Fixes
- [ ] Fix 10 critical Zig storage bugs
- [ ] Complete crash-injection harness
- [ ] Fix documentation contradictions

### v0.3.0 (4 weeks) — Evidence Cycle
- [ ] GNATprove verification (all 12 SPARK invariants)
- [ ] Complete 4-language vectors
- [ ] Ed25519 signing + verification

### v0.4.0 (4 weeks) — Complete Implementations
- [ ] Erlang NIF + 3-node mesh tests
- [ ] Key management + writer rotation
- [ ] User guide + architecture docs

### v0.5.0 (6 weeks) — Hardening & Audit
- [ ] 20+ crash-recovery scenarios
- [ ] Fuzz testing (all parsers)
- [ ] External security audit
- [ ] Reproducible builds + SBOM

### v1.0.0 (2 weeks) — Production Release
- [ ] All quality gates passed
- [ ] Signed release artifacts
- [ ] Enterprise support ready

**Total:** ~3-6 months, 3-4 FTE equivalent

See [ROADMAP.md](ROADMAP.md) for full details.

---

## Documentation

- **[ASSURANCE_MATRIX.md](ASSURANCE_MATRIX.md)** — Evidence levels per component
- **[ROADMAP.md](ROADMAP.md)** — Path to v1.0.0 (detailed)
- **[COMMERCIAL.md](COMMERCIAL.md)** — Licensing tiers + SaaS restrictions
- **[SECURITY.md](SECURITY.md)** — Threat model + verification scope
- **[PROOF_STATUS.md](PROOF_STATUS.md)** — Formal assurance status
- **[SPECIFICATION.md](SPECIFICATION.md)** — CDDL record format
- **[GATE_5_SPARK_PROOF.md](GATE_5_SPARK_PROOF.md)** — 12 formal invariants
- **[GATE_6_REPLICATION_HARNESS.md](GATE_6_REPLICATION_HARNESS.md)** — Erlang mesh protocol

---

## Repository

**GitHub:** https://github.com/SNAPKITTYWEST/worm-engines  
**License:** Business Source License 1.1 (Elastic Commons Clause)  
**Change Date:** December 31, 2027 (→ AGPL-3.0-only)

---

## Licensing

### Community Use
Free under BSL 1.1 for:
- Internal evaluation
- Non-production use
- Open-source projects (after 2028)

### Commercial Use
License required for:
- SaaS hosting
- Closed-source integration
- Production deployment

Contact: **licensing@snapkittywest.dev**

See [COMMERCIAL.md](COMMERCIAL.md) for tiers and pricing.

---

## Contributing

WORM Engines is actively developed. See [ROADMAP.md](ROADMAP.md) for current priorities.

**How to help:**
1. Report bugs (issues with ASSURANCE_MATRIX evidence level)
2. Review P0 fixes (Zig storage)
3. Contribute tests (crash-recovery, fuzzing)
4. Security review (informal welcome; formal audit in v0.5)

---

## Contact

- **Licensing:** licensing@snapkittywest.dev
- **Security:** security@snapkittywest.dev
- **Support:** support@snapkittywest.dev
- **GitHub Issues:** https://github.com/SNAPKITTYWEST/worm-engines/issues

---

**WORM Engines: Deterministic. Verifiable. On the Path to Production.**

Last updated: 2026-07-29  
Next release target: v0.2.1 (2 weeks)
