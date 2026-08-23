# LOCKER — Protected Inventions

Copyright (C) 2026 Ahmad Ali Parr, Jessica L. Williams / SNAPKITTYWEST  
Bel Esprit D'Accord Irrevocable Trust

All six inventions listed below are disclosed in DEFENSIVE_PUBLICATION.md
and are patent-pending. Use is governed by the tri-license in LICENSE.

---

## Protected Invention 1
**ML-DSA-44 post-quantum WORM sealing**

Per-record cryptographic attestation using CRYSTALS-Dilithium (NIST FIPS 204,
ML-DSA-44) over the canonical 180-byte hash domain. Writer identity derived as
SHA-256(ml_dsa_public_key || "LOCKER-WRITER-ID-v1"), separating identity from
signing key. Shor-resistant. Implemented in: `zig-engine/src/ml_dsa.zig`,
`zig-engine/src/pq_sign.zig`.

## Protected Invention 2
**Multiplicity-based thickness metric for sovereignty enforcement**

Runtime-enforceable structural metric Multiplicity(S) = |primes(S)| + anchors(S)
+ ERE_passes(S). Contractivity invariant: thickness(φ ∘ T) ≤ thickness(T) + ε
under any lawful composition. State inflation attacks are structurally impossible,
not detectable after the fact. Implemented in: `zig-engine/src/invariants.zig`.

## Protected Invention 3
**PCSL-gated SUBLEQ transition with contractivity envelope**

τ_law = PCSL_post ∘ τ_A,B,C ∘ PCSL_pre wrapping the universal SUBLEQ instruction.
Adversarial Contractivity Envelope: sup ||τ_law(S) - Proj_lawful(S)||_{Λ_m} ≤ k < 1
over the first 256 primes. Recursive stability guaranteed. Implemented in:
`zig-engine/src/invariants.zig`, `spark/worm_invariants.ads`.

## Protected Invention 4
**ERE five-pass filtration integrated into append-only commit path**

Five-stage sieve (canonical factorization → policy compliance → non-expansion →
anchor integrity → WORM survival) where filtration result is itself appended to
the ledger as a verifiable immunological record. Dual-token separation: Token 1
(truth vector) fixed before mutation; Token 2 (expression) synthesized only on
surviving paths. Implemented in: `zig-engine/src/invariants.zig`,
`zig-engine/src/storage.zig`.

## Protected Invention 5
**RegHom Merkle-anchored morphism registry with sovereign boundary irreducibility**

Constitutional object mapping prime pairs (p_s, p_t) to morphism operators φ.
Theorem: if (p_s, p_t) ∉ RegHom then δ(S, Δ) = ⊥_R(E) and ||S||_M unchanged.
Transitions across unregistered domain boundaries are structurally impossible.
Implemented in: `zig-engine/src/invariants.zig`, `spark/worm_invariants.ads`.

## Protected Invention 6
**Prime-vector commitment with IPA-compatible update stability**

C(v) = Σ_{p ∈ Primes} s_p · g^p over prime-indexed multiplicity vector v.
Homomorphic, no trusted setup, logarithmic proof size. Update stability:
||v'|| ≤ ||v|| + ε ⟹ ||ΔC||_G ≤ κ(ε + anchor_delta). Integrates into ERE Pass 4
as drop-in replacement for Merkle root on high-throughput adversarial paths.
Specified in: `DEFENSIVE_PUBLICATION.md` §2.6.

---

First public disclosure: 2026-08-22  
Repository commit establishing prior art: https://github.com/SNAPKITTYWEST/worm-engines
