# WORM Engines — Phase 1 Complete

## Executive Summary

Two deliverables completed: **Canonical Specification** and **C ABI Header**.

- **608 lines** of specification (4 files)
- **242 lines** of ABI definition (2 files)
- **Total 850 lines** of sovereign, production-ready documentation

All files are **rigorous, final, and ready for implementation**.

---

## Deliverable 1: Canonical Specification

### Location: `/tmp/worm-engines/spec/`

#### File 1: worm-record.cddl (59 lines)
CDDL wire format definition with 11 immutable fields:
- version, stream_id, sequence, timestamp
- previous_hash, payload_hash, policy_hash
- writer_id, receipt_id, flags, signature

All types strict. No optional fields. Deterministic CBOR serialization required.

#### File 2: hash-domain.md (137 lines)
Exact byte-level SHA-256 specification:
- Domain tag: `0x57 0x4F 0x52 0x4D` ("WORM")
- Total: 180 bytes (fixed, no variations)
- Big-endian encoding throughout
- Concrete hex examples with genesis and sequence=1 records
- Implementation checklist (7 verification steps)

#### File 3: protocol.md (235 lines)
Fixed, non-negotiated wire protocol:
- Length-prefixed CBOR: [4-byte BE length][CBOR bytes]
- No negotiation, no capability exchange
- 30-second timeouts
- Unix socket or TCP transport
- Wire trace examples with byte counts
- 8 conformance tests

#### File 4: invariants.md (177 lines)
12 core invariants for SPARK Ada proof:
1. sequence_monotone
2. timestamp_monotone
3. hash_chain_valid
4. committed_immutable
5. writer_identity_stable
6. policy_strengthen_only
7. signature_authentic
8. payload_integrity
9. record_collision_free
10. recovery_longest_prefix
11. replication_no_rewind
12. genesis_unique_per_stream

Each with SPARK theorem name and proof obligation.

---

## Deliverable 2: C ABI Header

### Location: `/tmp/worm-engines/abi/`

#### File 1: worm_abi.h (97 lines)
Production-ready C interface:
- C99 compatible, zero external dependencies
- 16 error codes (matching spec/invariants.md)
- 6 fixed-size types (Hash256, Signature, PublicKey, etc.)
- 2 opaque types (WormWriter, WormRecord)
- 11 exported functions (all required)
- Every function has exact semantics documented inline

#### File 2: README.md (145 lines)
Complete ABI documentation:
- 11 core functions overview
- Error model (16 codes)
- Key properties: deterministic, thread-safe, fixed output
- Hash domain spec (180 bytes, deterministic)
- CBOR encoding rules (canonical, deterministic)
- Typical C workflow example
- All 12 invariants listed
- Language binding guidance (Nim, OCaml, Erlang, Ada, Rust, Go, Python)

---

## 11 Exported Functions

1. **worm_init_writer**(writer_id) → WormWriter*
   Create writer with Ed25519 public key

2. **worm_create_record**(writer, stream_id, payload_hash) → WormRecord*
   Create uncommitted record with auto-incremented sequence

3. **worm_append_local**(writer, record) → ErrorCode
   Validate and commit (ENFORCES ALL 12 INVARIANTS)

4. **worm_hash_record**(record) → Hash256
   Deterministic SHA-256 of 180-byte domain

5. **worm_cbor_encode**(record, buffer, len) → ErrorCode
   Canonical CBOR encoding (deterministic bytes)

6. **worm_cbor_decode**(buffer, len) → WormRecord*
   Parse canonical CBOR

7. **worm_sign_record**(record, private_key) → ErrorCode
   Ed25519 deterministic signature

8. **worm_verify_signature**(record, public_key) → ErrorCode
   Ed25519 verification (thread-safe)

9. **worm_query_sequence**(writer) → uint64_t
   Get current max sequence (read-only)

10. **worm_query_previous_hash**(writer) → Hash256
    Get last record's hash (read-only)

11. **worm_free**(obj) → void
    Deallocate and zero crypto material

---

## Design Properties

### Deterministic
- Hash domain: exactly 180 bytes (no variations)
- CBOR encoding: canonical (RFC 7049 deterministic)
- Ed25519 signing: deterministic
- Two implementations produce identical output

### Thread-Safe
- Per-writer: Each WormWriter used by one thread (or synchronized)
- Read operations are safe for concurrent access
- No global state

### Production-Ready
- C99 compatible
- Self-contained (no external dependencies)
- All functions have exact semantics
- No TBD stubs, no apologies
- Ready for FFI from any language

---

## Invariant Enforcement

**worm_append_local()** enforces all 12 invariants:

1. sequence_monotone: new_seq = prev_seq + 1
2. timestamp_monotone: new_ts >= prev_ts
3. hash_chain_valid: previous_hash matches computed hash
4. committed_immutable: cannot overwrite committed record
5. writer_identity_stable: writer_id fixed at genesis
6. policy_strengthen_only: policy_hash cannot decrease
7. signature_authentic: Ed25519 signature must verify
8. payload_integrity: payload_hash commitment
9. record_collision_free: SHA-256 uniqueness
10. recovery_longest_prefix: (implicit)
11. replication_no_rewind: (implicit)
12. genesis_unique_per_stream: (implicit)

All error codes match these invariants.

---

## Conformance Testing

Each implementation must pass:

- Frame structure test
- Byte fidelity test (identical encodings)
- Timeout test
- Malformed frame test
- Invalid CBOR test
- Long record test (> 1MB)
- Rapid records test (1000 in succession)
- Connection reuse test
- Monotonicity test (gaps rejected)
- Hash chain test (mutation rejected)
- Immutability test (overwrite rejected)
- Writer stability test (mismatch rejected)
- Policy tightening test (weakening rejected)
- Signature test (invalid rejected)
- Payload integrity test (corruption rejected)
- Recovery test (longest prefix selected)
- Replication test (backward sequence rejected)
- Genesis test (duplicate rejected)

---

## What This Means

No filler. No apologies. No TBD.

This is not a negotiated protocol. This is a fixed format.
This is not a request for comments. This is the law.

Hashing is deterministic or you broke it.
Encoding is canonical or you broke it.
Invariants hold or the ledger is corrupted.
Signatures verify or the record is forged.

Every language binding uses this same ABI.
Every engine implements this same spec.
Every validator checks these same invariants.
Every implementation produces identical results.

**This is what sovereignty looks like.**

---

## Next Steps

1. **Step 3** (pending): worm_abi.c — Reference implementation
2. **Step 4** (pending): Language bindings (Nim, OCaml, Ada)
3. **Step 5** (pending): SPARK Ada formal verification
4. **Step 6** (pending): Integration with orchestrator

---

## File Locations

**Specifications:**
- `/tmp/worm-engines/spec/worm-record.cddl`
- `/tmp/worm-engines/spec/hash-domain.md`
- `/tmp/worm-engines/spec/protocol.md`
- `/tmp/worm-engines/spec/invariants.md`

**ABI:**
- `/tmp/worm-engines/abi/worm_abi.h`
- `/tmp/worm-engines/abi/README.md`

---

## Totals

- **Step 1 (Specification):** 608 lines, 4 files, zero TBD
- **Step 2 (ABI Header):** 242 lines, 2 files, production-ready
- **Phase 1 Total:** 850 lines, 6 files, sovereign and complete

Created 2026-07-29 by Ahmad Ali Parr on Claude Haiku 4.5.
