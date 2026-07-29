# Gate 7: Evidence Collection Framework for v0.3.0

**Phase:** Production Readiness Audit  
**Target:** Move from v0.2.0-dev (C-grade) → v0.3.0 (B-grade)  
**Date:** 2026-07-29  
**Scope:** 12 formal invariants + 4-language determinism + audit preparation

---

## Evidence Scale (7 Levels)

| Level | Name | Definition | Example |
|-------|------|-----------|---------|
| **1** | **Specified** | Written down as a requirement/invariant | "Write-once: no record rewritten" |
| **2** | **Implemented** | Code exists and follows spec | Zig storage.zig validateRecord() |
| **3** | **Unit Tested** | Isolated test passes (single component) | Test: append → query_sequence == seq |
| **4** | **Integrated** | Component tested with others (Zig ↔ C determinism) | CBOR round-trip: Zig → C → identical bytes |
| **5** | **Mechanically Checked** | Automated tooling verifies (GNATprove, fuzzer) | SPARK proof of invariant, property-based test |
| **6** | **Formally Proved** | Mathematical proof of correctness | Lean/Coq theorem + evidence |
| **7** | **Externally Audited** | Third-party security review + sign-off | $30-60K audit firm report |

---

## 12 Invariants: Evidence Status

### Invariant 1: Write-Once (No Rewritten Records)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 15 | ✓ Done |
| **Code** | 2 | storage.zig::append() checks sequence uniqueness | ✓ Done |
| **Unit Test** | 3 | zig-engine/test/write_once_test.zig (todo) | **v0.3.0** |
| **Integration** | 4 | Zig append → C read → sequence never decreases | **v0.3.0** |
| **SPARK Proof** | 5 | GNATprove: sequence_valid = next iff sequence == head+1 | **v0.3.0** |
| **Formal Proof** | 6 | Lean: ∀ record. unique(sequence) | **v0.4.0** |
| **Audit** | 7 | External reviewer certifies no rewrite path | **v0.5.0** |

### Invariant 2: Sequence Order (Monotonic Increments)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 25 | ✓ Done |
| **Code** | 2 | validateRecord() checks record.sequence == head_sequence + 1 | ✓ Done |
| **Unit Test** | 3 | Test: append(seq=5) fails, append(seq=6) ok | **v0.3.0** |
| **Integration** | 4 | Erlang coordinator validates sequence on replication | **v0.4.0** |
| **SPARK Proof** | 5 | GNATprove: Σ_i (seq_i < seq_{i+1}) | **v0.3.0** |
| **Formal Proof** | 6 | Lean: sequence forms strict increasing sequence | **v0.4.0** |
| **Audit** | 7 | Audit report: "sequence monotonicity verified" | **v0.5.0** |

### Invariant 3: Hash Chain (Unbroken Cryptographic Linkage)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 35 | ✓ Done |
| **Code** | 2 | validateRecord() checks record.previous_hash == head_hash | ✓ Done |
| **Unit Test** | 3 | Test: wrong previous_hash rejected | **v0.3.0** |
| **Integration** | 4 | Zig ↔ C: hash chain matches byte-for-byte | **v0.3.0** |
| **SPARK Proof** | 5 | GNATprove: H(i) = SHA256(H(i-1) \|\| payload_i) | **v0.3.0** |
| **Formal Proof** | 6 | Lean: hash chain forms cryptographic tree | **v0.4.0** |
| **Audit** | 7 | Audit: "hash chain collision resistance verified" | **v0.5.0** |

### Invariant 4: Timestamp Monotonicity (Time Never Rewinds)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 45 | ✓ Done |
| **Code** | 2 | validateRecord() checks record.timestamp >= head_timestamp | ✓ Done |
| **Unit Test** | 3 | Test: past timestamp rejected | **v0.3.0** |
| **Integration** | 4 | Cross-replica time skew tolerance defined | **v0.4.0** |
| **SPARK Proof** | 5 | GNATprove: ∀ i, j. i < j → ts_i ≤ ts_j | **v0.3.0** |
| **Formal Proof** | 6 | Lean: timestamp sequence is weakly increasing | **v0.4.0** |
| **Audit** | 7 | Audit: "timestamp validation verified" | **v0.5.0** |

### Invariant 5: Writer Consistency (Same Writer Across Session)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 55 | ✓ Done |
| **Code** | 2 | validateRecord() checks writer_id consistency | ✓ Done |
| **Unit Test** | 3 | Test: multiple writers tracked correctly | **v0.3.0** |
| **Integration** | 4 | Writer authentication with key management | **v0.4.0** |
| **SPARK Proof** | 5 | GNATprove: writer_id unchanged within session | **v0.3.0** |
| **Formal Proof** | 6 | Lean: writer_id forms identity relation | **v0.4.0** |
| **Audit** | 7 | Audit: "writer identity verification" | **v0.5.0** |

### Invariant 6: Manifest Integrity (Atomic Updates via Temp-Rename)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 65 | ✓ Done |
| **Code** | 2 | manifest.zig saves to temp, then atomic rename | ✓ Done |
| **Unit Test** | 3 | Test: crash during write leaves old manifest intact | **v0.3.0** |
| **Integration** | 4 | Recovery rebuilds manifest from segments deterministically | ✓ Done |
| **SPARK Proof** | 5 | GNATprove: manifest save is atomic (temp → rename) | **v0.3.0** |
| **Formal Proof** | 6 | Lean: manifest update state machine is safe | **v0.4.0** |
| **Audit** | 7 | Audit: "atomic manifest protocol verified" | **v0.5.0** |

### Invariant 7: Segment Durability (fsync() After Every Write)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 75 | ✓ Done |
| **Code** | 2 | segment.zig::write_record() calls fsync() | ✓ Done |
| **Unit Test** | 3 | Test: power-loss simulator, data intact after recovery | **v0.3.0** |
| **Integration** | 4 | Crash harness validates durability (30 scenarios) | ✓ Done |
| **SPARK Proof** | 5 | GNATprove: all write paths call fsync | **v0.3.0** |
| **Formal Proof** | 6 | Lean: durability lemma (write ∧ fsync ⟹ persistent) | **v0.4.0** |
| **Audit** | 7 | Audit: "durability guarantees verified" | **v0.5.0** |

### Invariant 8: CRC32 Protection (Bit-Flip Detection)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 85 | ✓ Done |
| **Code** | 2 | segment.zig computes CRC32, recovery validates | ✓ Done |
| **Unit Test** | 3 | Test: bit flip in record detected by CRC | **v0.3.0** |
| **Integration** | 4 | Cross-language CRC validation (Zig ↔ OCaml) | **v0.3.0** |
| **SPARK Proof** | 5 | GNATprove: CRC32(data) detects Hamming distance 1-3 | **v0.3.0** |
| **Formal Proof** | 6 | Lean: CRC polynomial properties proved | **v0.4.0** |
| **Audit** | 7 | Audit: "CRC integrity verified" | **v0.5.0** |

### Invariant 9: Crash Recovery (Deterministic Rebuild from Segments)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 95 | ✓ Done |
| **Code** | 2 | storage.zig::recover() scans & rebuilds deterministically | ✓ Done |
| **Unit Test** | 3 | Test: recovery produces same manifest twice | **v0.3.0** |
| **Integration** | 4 | Crash harness: 30 scenarios all deterministic | ✓ Done |
| **SPARK Proof** | 5 | GNATprove: recover(segments) = f(segments) (pure) | **v0.3.0** |
| **Formal Proof** | 6 | Lean: recovery is idempotent and commutative | **v0.4.0** |
| **Audit** | 7 | Audit: "crash recovery determinism verified" | **v0.5.0** |

### Invariant 10: Concurrency Safety (No Partial Records)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 105 | ✓ Done |
| **Code** | 2 | segment.zig uses atomic writes (length + data + CRC) | ✓ Done |
| **Unit Test** | 3 | Test: concurrent append attempts synchronized | **v0.3.0** |
| **Integration** | 4 | Erlang mesh ensures single writer per segment | **v0.4.0** |
| **SPARK Proof** | 5 | GNATprove: write protocol is all-or-nothing | **v0.3.0** |
| **Formal Proof** | 6 | Lean: record writes are atomic in linearizability | **v0.4.0** |
| **Audit** | 7 | Audit: "concurrency safety verified" | **v0.5.0** |

### Invariant 11: Deterministic Output (Identical CBOR + SHA256 on Replay)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 115 | ✓ Done |
| **Code** | 2 | codec.zig CBOR, hash.zig SHA256 both deterministic | ✓ Done |
| **Unit Test** | 3 | Test: encode(record) twice yields identical bytes | **v0.3.0** |
| **Integration** | 4 | Golden vectors: Zig ↔ C ↔ OCaml byte-identical | **v0.3.0** |
| **SPARK Proof** | 5 | GNATprove: CBOR encoding is pure & deterministic | **v0.3.0** |
| **Formal Proof** | 6 | Lean: CBOR spec theorem (payload → unique encoding) | **v0.4.0** |
| **Audit** | 7 | Audit: "determinism verified" | **v0.5.0** |

### Invariant 12: Policy Enforcement (OCaml Layer Validation Before Durability)

| Aspect | Level | Evidence | Next |
|--------|-------|----------|------|
| **Spec** | 1 | GATE_5_SPARK_PROOF.md line 125 | ✓ Done |
| **Code** | 2 | OCaml policy engine (stub) | **v0.3.0** |
| **Unit Test** | 3 | Test: policy reject → record not appended | **v0.3.0** |
| **Integration** | 4 | Policy + Zig enforcement chain end-to-end | **v0.4.0** |
| **SPARK Proof** | 5 | GNATprove: policy decision recorded before durability | **v0.4.0** |
| **Formal Proof** | 6 | Lean: policy invariant preserved across operations | **v0.4.0** |
| **Audit** | 7 | Audit: "policy enforcement verified" | **v0.5.0** |

---

## v0.3.0 Verification Checklist (4 Weeks)

### Week 1: GNATprove Formal Verification

- [ ] **Install GNAT/GNATprove** on build system
- [ ] **Convert GATE_5 SPARK specs to provable theorems** (all 12 invariants)
- [ ] **Run GNATprove on each invariant:**
  - ✓ Write-Once invariant proven (level 5)
  - ✓ Sequence Order proven
  - ✓ Hash Chain proven
  - ✓ Timestamp Monotonicity proven
  - ✓ Writer Consistency proven
  - ✓ Manifest Integrity proven
  - ✓ Segment Durability proven
  - ✓ CRC32 Protection proven
  - ✓ Crash Recovery determinism proven
  - ✓ Concurrency Safety proven
  - ✓ Deterministic Output proven
  - ✓ Policy Enforcement proven
- [ ] **Generate GNATprove reports** (evidence artifacts)
- [ ] **Commit SPARK proofs** to repo

### Week 2: 4-Language Cross-Determinism

- [ ] **Implement OCaml codec** (CBOR encoding — must match Zig byte-for-byte)
- [ ] **Implement OCaml hash** (SHA-256 — must match Zig exactly)
- [ ] **Create golden vectors:** 50 diverse records
- [ ] **Cross-test suite:**
  - Zig encode → OCaml decode → identical payload
  - OCaml encode → Zig decode → identical bytes
  - Hash(Zig CBOR) == Hash(OCaml CBOR)
- [ ] **C ABI round-trip:** Zig → C struct → Zig identical
- [ ] **Erlang integration:** Erlang calls C ABI → same results
- [ ] **Generate determinism report** (golden vector pass/fail matrix)
- [ ] **Commit golden vectors** to spec/

### Week 3: C ABI Implementation

- [ ] **Implement all 11 C ABI functions:**
  - worm_ledger_create()
  - worm_ledger_open()
  - worm_ledger_append()
  - worm_ledger_recover()
  - worm_ledger_query_sequence()
  - worm_ledger_query_hash()
  - worm_ledger_validate_record()
  - worm_ledger_close()
  - worm_crc32()
  - worm_sha256()
  - worm_cbor_encode()
- [ ] **Add signing/verification functions:**
  - worm_record_sign() (Ed25519)
  - worm_record_verify()
- [ ] **Test C ABI:** Zig → C → Zig determinism
- [ ] **Generate C ABI specification document**
- [ ] **Commit C binding** to zig-engine/c_binding/

### Week 4: Documentation & Evidence Synthesis

- [ ] **Generate ASSURANCE_MATRIX update** (all components: level 4-5)
- [ ] **Compile verification artifacts:**
  - GNATprove HTML reports
  - Golden vector test matrix
  - C ABI conformance report
  - Crash recovery determinism log
- [ ] **Update ROADMAP** for v0.4.0 (Erlang + full docs)
- [ ] **Create EVIDENCE_SUMMARY.md** (one-pager for auditors)
- [ ] **Commit all evidence** to docs/evidence/
- [ ] **Tag release v0.3.0-rc1** and push

---

## Post-v0.3.0: Path to Audit (v0.4.0 + v0.5.0)

### v0.4.0 (Complete Implementation — 4 weeks)

- Erlang NIF wiring to C ABI
- Key management (Ed25519 key lifecycle)
- OCaml policy engine (full implementation)
- Comprehensive integration tests (all 5 languages)
- **Evidence level: 4-5 (Integrated + Mechanically Checked)**

### v0.5.0 (Hardening — 6 weeks)

- **Crash recovery matrix:** Fuzz-driven (1000+ scenarios)
- **External security audit:** $30-60K firm
- **Reproducible builds:** Bit-identical artifacts
- **Signed releases:** Ed25519 signature verification
- **SLA enforcement:** Uptime guarantees
- **Evidence level: 6-7 (Formally Proved + Externally Audited)**

### v1.0.0 (Production Release — 2 weeks)

- Public audit report (third-party certification)
- Production deployment guide
- Commercial licensing enforcement
- **Evidence level: 7 (Production Qualified)**

---

## Resource Requirements

| Phase | FTE | Duration | Cost | Audit |
|-------|-----|----------|------|-------|
| v0.3.0 | 1-2 | 4 weeks | ~$30K | Internal (GNATprove) |
| v0.4.0 | 1-2 | 4 weeks | ~$30K | Internal (property tests) |
| v0.5.0 | 2-3 | 6 weeks | ~$60K-90K | External ($30-60K) |
| v1.0.0 | 1 | 2 weeks | ~$15K | None (release only) |
| **Total** | **2-4** | **16 weeks** | **~$135-195K** | **$30-60K external** |

---

## Handoff to Audit Firm

When ready for external audit (end of v0.5.0):

1. **Provide audit package:**
   - Full source code (all 5 languages)
   - ASSURANCE_MATRIX.md + all evidence artifacts
   - GNATprove proofs
   - Golden vector test suite
   - Crash recovery determinism logs
   - Integration test coverage (% lines)

2. **Scope audit engagement:**
   - 12 invariants: verify enforcement + proofs
   - Crash recovery: determinism under 10+ failure modes
   - Cryptography: SHA-256, Ed25519, CRC32 correctness
   - Memory safety: No UAF, double-free, or leaks
   - Determinism: All languages produce identical output

3. **Expected audit outcome:**
   - PASS: "WORM Engines meets production-ready assurance standards"
   - CONDITIONAL: List of remediations required
   - FAIL: Blocker issues requiring redesign

---

## Gate 7 Sign-Off

**Responsible:** Jessica  
**Date Started:** 2026-07-29  
**Target Completion:** 2026-08-29 (v0.3.0 complete, ready for v0.4.0)

| Checkpoint | Target | Status |
|-----------|--------|--------|
| Zig P0 audit complete | 2026-07-29 | 🟡 In Progress (agent) |
| GNATprove infrastructure | 2026-08-02 | ⏳ Pending |
| 4-language determinism | 2026-08-09 | ⏳ Pending |
| C ABI complete | 2026-08-16 | ⏳ Pending |
| Evidence synthesis | 2026-08-23 | ⏳ Pending |
| v0.3.0 release | 2026-08-29 | ⏳ Pending |

---

**Gate 7: Evidence Collection Framework**  
Prepared 2026-07-29 for production audit readiness.
