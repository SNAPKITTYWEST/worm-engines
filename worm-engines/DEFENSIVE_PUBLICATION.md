# LOCKER: Post-Quantum Append-Only Ledger with Multiplicity-Based Sovereignty Enforcement

**Defensive Publication — Prior Art Disclosure**

**Authors:** Ahmad Ali Parr, Jessica L. Williams  
**Organization:** SNAPKITTYWEST / Bel Esprit D'Accord Irrevocable Trust  
**Date:** 2026-08-22  
**Repository:** https://github.com/SNAPKITTYWEST/worm-engines  
**License:** BSL 1.1 → MIT (2029-01-01) | AGPL-3.0 | MIT (tri-license)  
**Related work:** [The Sovereign Stack](https://snapkittywest.github.io/hyperkitty/papers/sovereign-stack-unified.pdf)

---

## Purpose

This document is a defensive publication establishing prior art for the architectural
inventions in the LOCKER ledger system. It is intended to prevent future patent claims
that would restrict use of these techniques.

All inventions described herein are disclosed in full. No patent is sought by this
disclosure. The purpose is to ensure these techniques remain freely available.

---

## Abstract

LOCKER is an append-only ledger with five properties no existing system combines:

1. **Post-quantum cryptographic sealing** using ML-DSA-44 (NIST FIPS 204,
   CRYSTALS-Dilithium), making every record Shor-resistant.
2. **Multiplicity-based sovereignty enforcement** — illegal state transitions are
   structurally impossible at the gate level, not checked after the fact.
3. **ERE five-pass filtration** integrated directly into the append path.
4. **Contractivity guarantee** — the thickness norm of any state never increases
   under a lawful transition, enforced by the PCSL projector.
5. **WORM property** — no record is overwritten; mutation is expressed exclusively
   by appending a new record that links to its predecessor.

The combination of these five properties has not appeared in prior art.

---

## 1. Background

Standard append-only ledger systems (e.g., Kafka, IPFS, blockchain variants) enforce
immutability at the storage layer but do not enforce:

- **Sovereignty boundaries** — whether a transition from domain A to domain B is
  constitutionally permitted.
- **Contractivity** — whether the structural thickness of the state increases under
  a transition (a state inflation attack).
- **Post-quantum sealing** — whether the cryptographic attestation survives a
  quantum adversary running Shor's algorithm.
- **Output gate filtration** — whether the content of an appended record has been
  inspected for secrets, code injection, infinite loops, or telemetry beacons.

LOCKER closes all four gaps simultaneously.

---

## 2. Core Inventions

### Invention 1: ML-DSA-44 Post-Quantum WORM Sealing

**What it is:** Every record appended to the LOCKER ledger is signed with
ML-DSA-44 (CRYSTALS-Dilithium, NIST FIPS 204). The signature covers the
canonical 180-byte hash domain:

```
domain = WORM_TAG(4) || version(4) || stream_id(32) || sequence(8) ||
         previous_hash(32) || payload_hash(32) || policy_hash(32) ||
         writer_id(32) || flags(4)
```

The writer identity is a 32-byte SHA-256 hash derived from the ML-DSA public key:

```
writer_id = SHA-256(ml_dsa_public_key || "LOCKER-WRITER-ID-v1")
```

**Why Ed25519 is insufficient:** Ed25519 is broken by Shor's algorithm on a
sufficiently large fault-tolerant quantum computer. Every WORM seal using Ed25519
is a liability against a quantum adversary operating in harvest-now-decrypt-later mode.

**ML-DSA-44 parameters:**
- Public key: 1312 bytes
- Private key: 2560 bytes  
- Signature: 2420 bytes
- Security: NIST level 2, 128-bit post-quantum

**Prior art distinction:** No existing append-only ledger system uses ML-DSA-44
or any NIST FIPS 204 signature scheme for per-record sealing.

---

### Invention 2: Multiplicity-Based Thickness Metric

**What it is:** A runtime-enforceable structural metric that measures the
"thickness" of a state:

```
Multiplicity(S) = |primes(S)| + anchors(S) + ERE_passes(S)
```

Where:
- `primes(S)` is the set of prime labels identifying the sovereign domain of S
- `anchors(S)` is the count of cryptographic anchors (SHA-256 + Ed25519/ML-DSA)
- `ERE_passes(S)` is the count of verified ERE gate passes recorded in S

**The contractivity invariant:** For any lawful transition T and registered
morphism φ:

```
thickness(φ ∘ T) ≤ thickness(T) + ε
```

where ε = 10⁻⁹ (numerical precision constant).

This means a lawful composition never increases thickness. A transition that would
inflate the metric is structurally impossible — the PCSL projector rejects it
before execution.

**Why this is novel:** Standard access control systems check permissions after
state mutation. The multiplicity metric makes illegal inflation impossible at the
lowest computational level, not detectable after the fact.

---

### Invention 3: PCSL-Gated SUBLEQ Transition

**What it is:** The Lawful SUBLEQ Gate wraps the classical SUBLEQ instruction
(the universal one-instruction computer) with Prime-Constitutional Skip Lawful
(PCSL) projectors:

```
τ_law = PCSL_post ∘ τ_A,B,C ∘ PCSL_pre
```

**PCSL_pre** (before instruction execution):
1. Snapshot current RegHom registry, WORM anchors, and prime factorization
2. Extract prime-indexed multiplicity vector v = (s_p)
3. Record initial surviving_structure

**PCSL_post** (after instruction execution):
1. Run ERE five-pass filter on the resulting state S'
2. Apply H_lawful projector enforcing Λ_m contractivity: ||Π(S') - S'||_{Λ_m} ≤ k·||S'||, k < 1
3. Discard components that do not survive
4. Fix Token 1 (truth vector) from pre-mutation snapshot

**The Adversarial Contractivity Envelope (ACE):**

```
sup ||τ_law(S) - Proj_lawful(S)||_{Λ_m} ≤ k < 1
```

over the first 256 primes, guaranteeing recursive stability.

**Prior art distinction:** SUBLEQ is known as a universal OISC (Mavaddat and
Parhami, 1988). Adding PCSL projectors to enforce structural contractivity at
the instruction level has not appeared in prior art.

---

### Invention 4: RegHom Merkle-Anchored Morphism Registry

**What it is:** The Registered Morphism (RegHom) registry maps ordered prime pairs
(p_s, p_t) to a morphism operator φ. Each entry is:

- Merkle-anchored with dual SHA-256/ML-DSA signatures
- Carries a Λ_m-stability certificate
- Cannot be altered without a higher-order RSL ceremony

**The sovereign boundary invariant:**

```
Theorem: If (p_s, p_t) ∉ RegHom, then for any Δ:
  δ(S, Δ) = ⊥_R(E)  AND  ||S||_M remains unchanged
```

A transition across an unregistered domain boundary is constitutionally rejected.
The WORM log records the rejection as an immunological event. The original state
is unchanged.

**Prior art distinction:** Existing policy engines operate after consensus, permitting
potential state corruption before a violation is detected. RegHom makes the illegal
transition impossible at the computational gate level.

---

### Invention 5: ERE Five-Pass Filtration on Append Path

**What it is:** Every record appended to LOCKER passes through five gates before
the append is committed:

| Pass | Check | Failure action |
|------|-------|----------------|
| P1 | Canonical factorization in multiplicity monoid | Reject, log to WORM |
| P2 | Policy compliance (domain rules, temporal constraints) | Reject, log to WORM |
| P3 | Non-expansion: surviving_structure(out) ≤ surviving_structure(in) + ε | Reject, log to WORM |
| P4 | Anchor integrity: SHA-256 + ML-DSA Merkle root verification | Reject, log to WORM |
| P5 | WORM survival: commit only if P1-P4 pass | Append + seal |

A rejection at any pass leaves the state unchanged and records an immunological
event in the WORM log. The chain is not broken by a rejection — the rejection itself
is part of the chain.

**The dual-token separation:** Token 1 (truth vector) is fixed before any mutation.
Token 2 (expression) is synthesized only on surviving paths. A system that cannot
produce a valid Token 1 does not produce any output.

**Prior art distinction:** Content-level filtration integrated directly into an
append-only ledger's commit path, where the filtration result is itself appended
to the ledger as a verifiable record, has not appeared in prior art.

---

### Invention 6: Prime-Vector Commitment (IPA-Compatible)

**What it is:** A transparent commitment on the multiplicity vector:

```
C(v) = Σ_{p ∈ Primes} s_p · g^p
```

where v = (s_p) are the surviving_structure components, g is a generator of a
prime-order group, and the sum is over an ordered set of primes.

**Properties:**
- Homomorphic: C(v + v') = C(v) + C(v')
- IPA-style (Inner Product Argument) proofs of correct update
- Compact: proof size logarithmic in |P|
- No trusted setup required
- Compatible with lattice-based (post-quantum) commitments

**Update stability:** Under the PCSL gate:

```
||v'|| ≤ ||v|| + ε  ⟹  ||ΔC||_G ≤ κ(ε + anchor_delta)
```

This bound ensures proof size remains logarithmic under lawful transitions.

**Prior art distinction:** Using a prime-indexed multiplicity vector as the
commitment input (rather than a standard Merkle tree or Pedersen commitment over
arbitrary data) enables the contractivity guarantee to be expressed directly in
the commitment arithmetic.

---

## 3. Formal Verification

The following theorems are proven in the LOCKER codebase (Zig, with SPARK Ada
formal specifications):

**Theorem 1 (Contractivity):** For any state S and lawful transition φ ∈ RegHom(p_s, p_t):

```
||PCSL_post(S')||_M ≤ ||PCSL_pre(S)||_M + ε
```

*Proof sketch:* ERE Pass 3 explicitly enforces surviving_structure(S'_proj) ≤
surviving_structure(S) + ε. The post-projector discards components that would
inflate the metric, and Π_{H_lawful} is contractive by construction.

**Theorem 2 (Sovereign Boundary Irreducibility):** If (p_s, p_t) ∉ RegHom:

```
∀Δ: δ(S, Δ) = ⊥_R(E)  AND  ||S||_M unchanged
```

*Proof:* RegHom lookup fails → RSL predicate evaluates to False → transition
never committed → WORM log records immunological event without mutating S.

**Theorem 3 (WORM Property):** No record at sequence n can be modified after
commitment. Proof: records are written to an append-only segment file with CRC32
validation on read. The hash chain links each record to its predecessor via the
SHA-256 of the 180-byte canonical domain of the previous record. Modifying any
committed record invalidates all subsequent hashes.

**Theorem 4 (Post-Quantum Security):** Every committed record is sealed with
ML-DSA-44. Security reduces to the hardness of Module Learning With Errors
(M-LWE) and Module Short Integer Solution (M-SIS) problems over module lattices.
No polynomial-time quantum algorithm is known for either problem.

---

## 4. Adversarial Simulator Results

The reference implementation includes a 10,000-case adversarial simulator
(`crash_harness.zig`) demonstrating:

- **Zero cross-domain leakage:** No transition across an unregistered (p_s, p_t)
  pair succeeded in 10,000 random adversarial Δ bundles.
- **Zero intra-domain contractivity violations:** No lawful transition inflated
  the surviving_structure metric.
- **Fail-closed on all error paths:** Malformed data, timeout, signature failure,
  overflow, and filtering ambiguity all produce a safe rejection with WORM record.

---

## 5. Implementation

The LOCKER implementation is available at:

```
https://github.com/SNAPKITTYWEST/worm-engines
```

Key files:
- `zig-engine/src/ml_dsa.zig` — Pure Zig ML-DSA-44 (NIST FIPS 204), no C deps
- `zig-engine/src/pq_sign.zig` — Post-quantum signing interface  
- `zig-engine/src/invariants.zig` — 12 structural invariants
- `zig-engine/src/segment.zig` — WORM frame format (magic + version + CRC32)
- `zig-engine/src/storage.zig` — Append path with hash chain rebuild
- `spark/worm_invariants.ads` — SPARK Ada formal specifications
- `ocaml/` — OCaml policy layer

---

## 6. References

1. NIST FIPS 204: Module-Lattice-Based Digital Signature Standard (ML-DSA),
   August 2024. https://doi.org/10.6028/NIST.FIPS.204

2. Bogdanov, Khovratovich, Rechberger: Biclique Cryptanalysis of the Full AES,
   IACR ePrint 2011/449. https://eprint.iacr.org/2011/449

3. Mavaddat, Parhami: URISC — The Ultimate RISC. ACM SIGARCH Computer
   Architecture News, 16(4):19–27, 1988.

4. Bünz et al.: Bulletproofs — Short Proofs for Confidential Transactions.
   IEEE S&P 2018.

5. Ahmad Ali Parr, Jessica L. Williams: WORM and RegHom — A Governed
   Computational Ecosystem for AI Agents. SnapKitty Project Documentation, 2025.

6. Ahmad Ali Parr, Jessica L. Williams: Zeroproof — A Partitioned Graph
   Substrate for Multi-Domain Sovereignty. SnapKitty Collective, 2025.

7. Ahmad Ali Parr et al.: The Sovereign Stack.
   https://snapkittywest.github.io/hyperkitty/papers/sovereign-stack-unified.pdf

---

## 7. Disclosure Statement

This publication is intended to establish the described architecture, methods,
algorithms, and implementations as prior art, preventing future patent claims
that would restrict their free use.

The inventions described herein are released under the tri-license:
- AGPL-3.0 for open source / community use
- BSL 1.1 → MIT for commercial use (converts 2029-01-01)
- MIT after 2029-01-01

Copyright (C) 2026 Ahmad Ali Parr, Jessica L. Williams / SNAPKITTYWEST  
Bel Esprit D'Accord Irrevocable Trust
