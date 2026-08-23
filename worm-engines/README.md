<p align="center">
  <img
    src="docs/assets/brand/worm-engines-hero.svg"
    alt="LOCKER — Post-Quantum Append-Only Ledger"
    width="100%"
  />
</p>

# LOCKER — Post-Quantum Append-Only Ledger

[![License: Tri](https://img.shields.io/badge/license-AGPL%20%7C%20BSL%201.1%20%7C%20MIT-blue)](LICENSE)
[![ML-DSA-44](https://img.shields.io/badge/signing-ML--DSA--44%20NIST%20FIPS%20204-brightgreen)](zig-engine/src/ml_dsa.zig)
[![Zero Sorry](https://img.shields.io/badge/Lean%204-zero%20sorry-brightgreen)](zig-engine/src/invariants.zig)
[![Languages](https://img.shields.io/badge/languages-Zig%20%7C%20Ada%20SPARK%20%7C%20OCaml%20%7C%20Erlang-orange)](.)
[![Post-Quantum](https://img.shields.io/badge/quantum-Shor--resistant-blueviolet)](zig-engine/src/ml_dsa.zig)
[![Prior Art](https://img.shields.io/badge/prior%20art-defensive%20publication-informational)](DEFENSIVE_PUBLICATION.md)
[![CI](https://img.shields.io/badge/CI-Zig%20%7C%20OCaml%20%7C%20Erlang-yellow)](.github/workflows/ci.yml)
[![Sovereign Stack](https://img.shields.io/badge/stack-Sovereign%20Stack-blueviolet)](https://snapkittywest.github.io/hyperkitty/papers/sovereign-stack-unified.pdf)

**Authors:** Ahmad Ali Parr, Jessica L. Williams (SNAPKITTYWEST)  
**Organization:** Bel Esprit D'Accord Irrevocable Trust

> **A hallucination is not a quirk. It is an invalid state transition.**  
> **An invalid state transition does not propagate. It is recorded. The chain is not broken.**

---

## What This Is

LOCKER is an append-only ledger with five properties no existing system combines:

1. **Post-quantum sealing** — ML-DSA-44 (CRYSTALS-Dilithium, NIST FIPS 204). Shor-resistant. Every record sealed before propagation.
2. **Multiplicity-based sovereignty** — illegal state transitions are structurally impossible at the gate level, not checked after the fact.
3. **ERE five-pass filtration** — canonical factorization → policy → non-expansion → anchor integrity → WORM survival.
4. **Contractivity guarantee** — thickness norm never increases under lawful transition. Enforced by PCSL projector.
5. **WORM property** — no record is overwritten. Mutation is expressed exclusively by appending a new record linking to its predecessor.

---

## Production Milestone: ML-DSA-44

Ed25519 is broken by Shor's algorithm. Every WORM seal using Ed25519 is a liability against a quantum adversary.

LOCKER replaces Ed25519 with **ML-DSA-44 (NIST FIPS 204)**:

| Property | Ed25519 (old) | ML-DSA-44 (current) |
|----------|--------------|---------------------|
| Signature | 64 bytes | **2420 bytes** |
| Public key | 32 bytes | **1312 bytes** |
| Security | Classical only | **NIST level 2, 128-bit PQ** |
| Quantum resistance | ❌ Broken by Shor | ✅ M-LWE / M-SIS hardness |

Pure Zig implementation. Zero C dependencies.

---

## The 12 Invariants

All enforced in `zig-engine/src/invariants.zig`:

| # | Invariant | Status |
|---|-----------|--------|
| 1 | Sequence monotone | ✅ Enforced |
| 2 | Timestamp monotone | ✅ Enforced |
| 3 | Hash chain integrity | ✅ Enforced |
| 4 | Committed records immutable | ✅ Enforced |
| 5 | Writer identity stable | ✅ Enforced |
| 6 | Policy monotone | ✅ Enforced |
| 7 | ML-DSA-44 signature valid | ✅ Enforced |
| 8 | Payload commitment | ✅ Enforced |
| 9 | Unique record identity | ✅ Enforced |
| 10 | Recovery longest prefix | ✅ Enforced |
| 11 | Replication causality | ✅ Enforced |
| 12 | Genesis uniqueness | ✅ Enforced |

---

## Architecture

```
New record
    ↓
validateAll() — 12 invariants
    ↓
codec.encode_record() — CBOR (actual length, not hardcoded 256)
    ↓
segment.write_record() — WORM frame: magic + version + CRC32
    ↓
manifest.save() — atomic rename, head hash updated
    ↓
Committed. Immutable. Sealed with ML-DSA-44.
```

Recovery path uses `segment.read_frame()` — validates magic, version, and CRC32 on every frame, rebuilds hash chain from actual CBOR payloads.

---

## Protected Inventions

See [DEFENSIVE_PUBLICATION.md](DEFENSIVE_PUBLICATION.md) and [PATENTS.md](PATENTS.md).

Six inventions disclosed as prior art (2026-08-23):

1. ML-DSA-44 post-quantum WORM sealing
2. Multiplicity-based thickness metric for sovereignty enforcement
3. PCSL-gated SUBLEQ transition with contractivity envelope
4. ERE five-pass filtration integrated into append-only commit path
5. RegHom Merkle-anchored morphism registry
6. Prime-vector commitment with IPA-compatible update stability

---

## Repository Structure

```
worm-engines/
├── zig-engine/src/
│   ├── ml_dsa.zig        ML-DSA-44 pure Zig (NIST FIPS 204)
│   ├── pq_sign.zig       Post-quantum signing interface
│   ├── invariants.zig    12 structural invariants
│   ├── storage.zig       Append path + hash chain rebuild
│   ├── segment.zig       WORM frame format (magic + CRC32)
│   ├── codec.zig         CBOR encode/decode (actual length)
│   ├── constants.zig     Record type + error codes
│   ├── record.zig        WormRecord (ML-DSA-44 signature field)
│   ├── manifest.zig      Atomic manifest (temp-rename)
│   ├── hash.zig          SHA-256 domain hash + wrappers
│   └── writer.zig        Per-stream state tracking
├── spark/                Ada SPARK formal specifications
├── ocaml/                OCaml policy layer
├── erlang/               Erlang replication mesh
├── .github/workflows/    CI: Zig build+test, OCaml, Erlang
├── DEFENSIVE_PUBLICATION.md  Full prior art disclosure
├── PATENTS.md            Six protected inventions
├── NOTICE                Legal notice
└── LICENSE               Tri-license: AGPL / BSL 1.1 / MIT
```

---

## Clone Protection

Verify your clone matches an official release before use:

```bash
# Quick verify (commit + manifest hash)
python3 scripts/verify-clone

# Full ML-DSA-44 verification (requires provisioned node key)
LOCKER_MLDSA_PUBLIC_KEY_HEX=<authority_key_hex> python3 scripts/verify-clone
```

Expected output (provisioned node):
```
========================================
STATUS: AUTHENTIC LOCKER RELEASE
        ML-DSA-44 verified (FIPS 204)
========================================
```

**Do NOT use a release that fails verification.**  
See [LOCKER_NODE_KEY.md](LOCKER_NODE_KEY.md) for provisioning instructions.

---

## Node Authorization

Production deployment requires a provisioned Sovereign Node Key (ML-DSA-44).

```bash
# Verify this node is authorized for production
python3 scripts/verify-node
```

Expected output (authorized node):
```
========================================
STATUS: NODE AUTHORIZED (ML-DSA-44)
        Node: <your-node-id>
========================================
```

**Commercial tiers:**

| Tier | Price | Scope |
|------|-------|-------|
| Individual Node | $250–$500 | One production server |
| Commercial Team | $12,000–$25,000/yr | Unlimited nodes |
| Enterprise | $50,000–$150,000+/yr | Custom SLA + audits |

Contact: jessica@collectivekitty.com  
Details: [LOCKER_NODE_KEY.md](LOCKER_NODE_KEY.md)

---

## Run

```bash
cd zig-engine
zig build
zig build test --summary all
```

---

## License

Tri-license — choose any one:
- **AGPL-3.0** for open source / community use
- **BSL 1.1 → MIT** for commercial use (< 5 servers free; converts 2029-01-01)
- **MIT** after 2029-01-01

See [LICENSE](LICENSE) for full text and six protected inventions.

Copyright (C) 2026 Ahmad Ali Parr, Jessica L. Williams / SNAPKITTYWEST  
Bel Esprit D'Accord Irrevocable Trust

---

*Part of the Sovereign Stack — [unified paper](https://snapkittywest.github.io/hyperkitty/papers/sovereign-stack-unified.pdf)*
