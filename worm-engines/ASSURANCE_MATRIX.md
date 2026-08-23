# WORM Engines Assurance Matrix

**Version:** 0.2.0-dev  
**Date:** 2026-07-29  
**Status:** Experimental prototype (see evidence below)

---

## Evidence Levels

| Level | Meaning | Example |
|-------|---------|---------|
| **Specified** | Requirement documented | "Record hash format = SHA-256(domain \|\| record)" |
| **Implemented** | Code path exists | `codec.encode_record()` function written |
| **Unit Tested** | Component tests pass | `test_encode_record` passes on 100 vectors |
| **Integrated** | Cross-component path passes | Zig encode → C decode → byte match |
| **Mechanically Checked** | Compiler/prover/analyzer passes | GNATprove discharges obligation |
| **Formally Proved** | Theorem proved in Lean/Coq | "append preserves invariant X" |
| **Externally Audited** | Independent expert review | Security firm audits code |
| **Production Qualified** | All operational gates pass | Recovery tested, SLA certified |

---

## Assurance Table

### Layer 1: Zig Storage (Durable Append)

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| Segment | Append record | ✅ | ✅ | ⏳ | ⏳ | ⏳ | ❌ | ❌ | Partial |
| Segment | CRC32 frame | ✅ | ✅ | ⏳ | ⏳ | ⏳ | ❌ | ❌ | Partial |
| Segment | fsync durability | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | ❌ | Partial |
| Manifest | Save atomically | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | ❌ | Partial |
| Manifest | Recover on reopen | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Manifest | Handle corruption | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| Storage | Record validation | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| Storage | Transactional update | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| **Subtotal** | | | | | | | | | **C+ (Partial)** |

**Known Issues:**
- Fixed `encoded_len = 256` (needs to use actual length)
- Manifest bytes partially uninitialized (zeros needed)
- No recovery implementation (openExisting missing)
- No validation at storage boundary

---

### Layer 2: C ABI (11 Functions)

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| ABI | worm_init_writer | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_create_record | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_append_local | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_query_sequence | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_query_hash | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_cbor_encode | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_cbor_decode | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | worm_sign_record | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| ABI | worm_verify_signature | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| ABI | worm_free | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| ABI | Symbol export check | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Pending** |
| **Subtotal** | | | | | | | | | **C (Good/Incomplete)** |

---

### Layer 3: Cross-Language Vectors

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| Vectors | Golden record spec | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | Excellent |
| Vectors | Zig generator | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | Excellent |
| Vectors | C validator | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | Excellent |
| Vectors | Zig ↔ C CBOR match | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | Excellent |
| Vectors | Zig ↔ C hash match | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | Excellent |
| Vectors | OCaml scaffold | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Scaffold only |
| Vectors | Erlang scaffold | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Scaffold only |
| Vectors | OCaml ↔ Zig match | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Vectors | Erlang ↔ Zig match | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Vectors | Malformed input tests | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| **Subtotal** | | | | | | | | | **B (Two-language parity only)** |

**Note:** README claims "cross-language vectors complete" but only 2 of 4 languages have integrated tests.

---

### Layer 4: Ada SPARK Formal Specification

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| SPARK | Inv1: Seq monotonic | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv2: Timestamp monotonic | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv3: Hash chain | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv4: Immutable | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv5: Writer stable | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv6: Policy monotonic | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv7: Signature valid | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv8: Payload committed | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv9: Record unique | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv10: Recovery prefix | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv11: Causality order | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | Inv12: Genesis unique | ✅ | ✅ | ❌ | ❌ | ⏳ | ⏳ | ❌ | Specified |
| SPARK | GNATprove run | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Pending** |
| SPARK | Lean4 formalization | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Pending** |
| **Subtotal** | | | | | | | | | **C (Specified, not verified)** |

**Note:** 12 invariants are specified in Ada SPARK syntax, but GNATprove verification is pending.

---

### Layer 5: Erlang Mesh Replication

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| Erlang | Gossip protocol | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Designed |
| Erlang | Causality order | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Designed |
| Erlang | NIF bridge | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Scaffold |
| Erlang | NIF implementation | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Erlang | Multi-node test | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Erlang | Partition recovery | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| **Subtotal** | | | | | | | | | **C- (Designed but not tested)** |

---

### Cryptography

| Component | Feature | Specified | Implemented | Unit Tested | Integrated | Mechanically Checked | Formally Proved | Externally Audited | Status |
|-----------|---------|-----------|-------------|-------------|------------|----------------------|-----------------|-------------------|--------|
| Crypto | SHA-256 domain | ✅ | ✅ | ✅ | ⏳ | ⏳ | ❌ | ❌ | Good |
| Crypto | Ed25519 API | ✅ | ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | **Incomplete** |
| Crypto | Key management | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| Crypto | Writer rotation | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **Missing** |
| **Subtotal** | | | | | | | | | **D (Partial)** |

---

## Overall Verdict

| Dimension | Rating | Evidence |
|-----------|--------|----------|
| Architecture | B+ | Sound layering; language separation clear |
| Zig storage | C+ | Append works; recovery/validation missing |
| C ABI | C | 9 of 11 functions complete; signing incomplete |
| Cross-language | B | 2-language parity; 4-language pending |
| SPARK spec | C | 12 invariants specified; GNATprove pending |
| Replication | C- | Design sound; no integration tests |
| Cryptography | D | Partial; key management missing |
| Documentation | D+ | Contradictions being fixed |
| Test evidence | C | Unit level good; integration pending |
| Production | D | Not ready; multiple P0 blockers |
| **Overall** | **C** | **Experimental prototype** |

---

## Next Priority (P0)

1. **Fix Zig storage** — 10 items (encoded_len, allocation free, manifest bytes, recovery)
2. **Fix documentation** — Rewrite README to match actual evidence
3. **Create official commercial terms** — BSL 1.1 + COMMERCIAL.md
4. **Run GNATprove** — Verify SPARK invariants
5. **Implement OCaml/Erlang vectors** — Complete 4-language parity

---

**This matrix is the source of truth. README must be auto-generated from it.**
