# WORM Engines: External Audit Scope

**Target Release:** v1.0.0 (Post-v0.5.0)  
**Audit Type:** Security + Assurance Review  
**Estimated Duration:** 4-6 weeks  
**Estimated Cost:** $30-60K  

---

## Executive Summary

WORM Engines is a multi-language append-only ledger fabric designed for enterprise infrastructure. This document specifies the scope of a professional security audit to validate:

1. **12 Formal Invariants** — Proven via GNATprove + independent verification
2. **Crash Recovery Determinism** — Under 10+ failure scenarios
3. **Cryptographic Correctness** — SHA-256, Ed25519, CRC32 implementation
4. **Memory Safety** — No use-after-free, double-free, or leaks
5. **Cross-Language Determinism** — All 5 languages (Zig, Ada/SPARK, OCaml, Erlang, C ABI) produce identical output

---

## In-Scope Components

### 1. Zig Storage Engine (zig-engine/)

**What it does:**
- Durably writes records to append-only segments
- Maintains atomic manifest coordination
- Recovers from crashes deterministically

**Attack surface:**
- Segment corruption / bit flips (CRC32 detection)
- Concurrent writes (locking/serialization)
- Manifest race conditions (temp-rename atomicity)
- Path traversal attacks (directory restrictions)
- Integer overflow in length fields

**Invariants to verify:**
- Write-Once (no record rewritten)
- Sequence Order (monotonic increments)
- Hash Chain (unbroken linkage)
- Timestamp Monotonicity
- Writer Consistency
- Manifest Integrity
- Segment Durability
- CRC32 Protection
- Crash Recovery Determinism
- Concurrency Safety

**Evidence provided:**
- Source code (all 5 languages, ~2000 LoC)
- GNATprove proofs (SPARK)
- Unit test suite (80%+ coverage)
- Crash recovery test matrix (30 scenarios)
- Golden vector suite (Zig ↔ C ↔ OCaml determinism)

### 2. Ada SPARK Formal Specification (spark/)

**What it does:**
- Formally specifies all 12 invariants in machine-checkable language
- Enables GNATprove to prove correctness

**Attack surface:**
- Proof gaps (unproven subgoals)
- Incorrect assumptions in contracts
- Mismatch between spec and implementation

**Verification tasks:**
- Review GNATprove proof certificate for all 12 invariants
- Verify no `sorry` terms (unproven lemmas)
- Check assumptions match implementation behavior
- Test proof robustness (minor code change should re-prove)

### 3. C ABI Integration Boundary (zig-engine/c_binding/)

**What it does:**
- Exposes Zig storage to C/Erlang/OCaml via 11 C functions
- Ensures zero-copy interop

**Attack surface:**
- Buffer overflow in function parameters
- Type confusion (C casting errors)
- Memory ownership confusion (who frees what?)
- Null pointer dereference
- Struct packing/alignment issues

**Verification tasks:**
- Review all 11 function signatures for safety
- Test C caller with fuzzing
- Verify memory ownership contracts
- Check struct layout correctness across platforms

### 4. OCaml Policy Engine (ocaml/)

**What it does:**
- Validates records before durability
- Enforces retention policies

**Attack surface:**
- Policy bypass (logic error)
- Non-termination (infinite loops)
- Exception safety

**Verification tasks:**
- Verify policy engine cannot be bypassed
- Check all exceptions are caught
- Fuzz with invalid policies

### 5. Erlang Replication Mesh (erlang/)

**What it does:**
- Replicates ledger across nodes
- Coordinates crash recovery

**Attack surface:**
- Byzantine node attacks (send bad manifests)
- Network partition behavior
- Split-brain scenarios

**Verification tasks:**
- Review replication protocol for safety
- Verify Byzantine fault tolerance assumptions
- Test under network failures (latency, loss, duplication)

---

## Out-of-Scope

❌ Network security (TLS/mTLS at deployment layer)  
❌ Key management policy (that's the deployment engineer's role)  
❌ Performance benchmarks (not security)  
❌ Ethereum/blockchain integration (if mentioned elsewhere)  
❌ Non-English documentation  

---

## Testing & Evidence Requirements

### Pre-Audit (Provided by WORM Engines Team)

**Code artifacts:**
- Full source code in all 5 languages
- Build scripts (Zig, GNAT, OCaml, Erlang)
- No third-party dependencies (or minimal, listed)

**Test suite:**
- Unit tests (each invariant: happy path + error cases)
- Integration tests (Zig ↔ C ↔ OCaml round-trips)
- Crash recovery determinism tests (30 scenarios)
- Fuzz tests (symbolic execution where applicable)

**Documentation:**
- ASSURANCE_MATRIX.md (evidence by level)
- GATE_5_SPARK_PROOF.md (formal specs)
- GATE_6_REPLICATION_HARNESS.md (Erlang design)
- AUDIT_SCOPE.md (this document)
- Architecture diagrams (all layers)

**Cryptographic artifacts:**
- SHA-256 test vectors (NIST standard)
- Ed25519 test vectors (RFC 8032)
- CRC32 test vectors (known bad inputs)

**GNATprove artifacts:**
- Proof certificates for all 12 invariants
- Coverage report (% of code annotated with contracts)
- Any unproven subgoals with justification

### Audit Activities

1. **Code Review** (40% time)
   - Line-by-line review of safety-critical paths
   - Invariant enforcement verification
   - Error handling completeness

2. **Automated Analysis** (20% time)
   - Static analysis (undefined behavior, type confusion)
   - Symbolic execution (if tools available)
   - Fuzzing (C ABI boundary + invalid inputs)

3. **Testing & Validation** (25% time)
   - Reproduce provided test cases
   - Develop additional test cases for edge cases
   - Verify determinism under stress

4. **Documentation Review** (10% time)
   - Verify claims match code
   - Check completeness of threat model
   - Assess audit trail (git history)

5. **Report & Sign-Off** (5% time)
   - Prepare findings report
   - Recommend remediations
   - Issue audit certificate (if PASS)

---

## Audit Pass Criteria

**PASS** = All of the following:

- ✅ All 12 invariants enforced in code
- ✅ GNATprove proofs verified (no unproven subgoals)
- ✅ Crash recovery deterministic under all 10+ failure modes
- ✅ No memory safety violations (UAF, double-free, leaks, overflow)
- ✅ Cross-language determinism verified (Zig ↔ C ↔ OCaml ↔ Erlang)
- ✅ C ABI memory ownership contracts clear and verified
- ✅ No logic bugs in policy enforcement
- ✅ Replication protocol Byzantine-fault-tolerant
- ✅ Test coverage ≥ 80% for safety-critical code
- ✅ Documentation accurate and complete

**CONDITIONAL** = Pass with required remediations:

- Unproven GNATprove subgoals (with justification provided)
- Low-severity logic issues (fixable without redesign)
- Test coverage 60-80% (acceptable if evidence of correctness via proofs)

**FAIL** = Any of the following:

- Invariant violation (write-once violated, hash chain broken, etc.)
- Memory safety issue in safety-critical code
- Unverifiable randomness (GNATprove proof gaps without justification)
- Byzantine attack feasible
- Determinism loss across languages

---

## Engagement Structure

### Phase 1: Setup & Planning (1 week)

- Audit firm assigns team (lead + 2-3 reviewers)
- Initial code review (architecture overview)
- Test environment setup
- Clarify any specification gaps

### Phase 2: Deep Review (2-3 weeks)

- Code review (all 5 languages)
- GNATprove proof verification
- Test reproduction and expansion
- Automated analysis (static, fuzzing)

### Phase 3: Findings & Remediation (1-2 weeks)

- Document findings (severity: Critical/High/Medium/Low)
- Communicate blockers (Critical/High must be fixed before sign-off)
- Negotiate remediations
- WORM Engines team fixes + re-audit if needed

### Phase 4: Final Verification & Report (1 week)

- Verify remediations
- Generate audit report
- Issue audit certificate (if PASS)
- Publish findings (redacted) if requested

---

## Deliverables (Audit Firm to WORM Engines)

1. **Audit Report** (30-50 pages)
   - Executive Summary (1 pager: PASS/FAIL/CONDITIONAL)
   - Methodology (how audit was conducted)
   - Findings (by severity)
   - Remediations (required vs. recommended)
   - Appendix (test results, proof verification)

2. **Test Results**
   - Reproducible test suite execution (all pass)
   - Fuzz campaign results (crashes/hangs found/fixed)
   - Determinism validation (Zig ↔ C ↔ OCaml round-trip logs)

3. **Audit Certificate**
   - Signed statement: "WORM Engines v1.0.0 meets production-ready assurance standards"
   - Valid for 12 months (or until code changes significantly)
   - Optional: SOC 2 Type II alignment statement

4. **Proof Verification Report**
   - Verification of GNATprove certificates
   - Any gaps / additional lemmas needed

---

## Budget & Timing

| Item | Cost | Duration |
|------|------|----------|
| Audit firm engagement | $30-60K | 4-6 weeks |
| Team (3 people × 4-6 weeks) | Included | 4-6 weeks |
| Travel (if on-site review) | $5-10K | 1-2 weeks |
| **Total** | **$35-70K** | **4-6 weeks** |

---

## Audit Firm Selection Criteria

Prefer audit firms with:

- ✅ Experience in formal verification (GNATprove, Lean, Coq)
- ✅ Experience in multi-language systems (C, Rust, Zig interop)
- ✅ Cryptographic protocol expertise (blockchain, ledgers, consensus)
- ✅ Memory safety background (C, Rust security)
- ✅ Previous FOSS audits (can reference)
- ✅ Academic partnerships (theorem proving)

**Not required but nice:**
- 🟡 Prior Ada/SPARK experience
- 🟡 Erlang/OTP knowledge
- 🟡 Prior ledger system audits

---

## Sample RFP Language

> We seek a professional security audit of WORM Engines, a multi-language append-only ledger fabric. The engagement scope includes:
> 
> 1. **Code Review** — All source code in Zig, Ada SPARK, OCaml, Erlang, and C ABI
> 2. **Formal Verification** — GNATprove proof certificate review for 12 invariants
> 3. **Testing** — Reproducible test execution, fuzz-driven testing, determinism validation
> 4. **Report** — Findings by severity, audit certificate (if PASS), publication-ready document
>
> **Timeline:** 4-6 weeks  
> **Budget:** $30-60K  
> **Deliverables:** Audit report, test results, audit certificate, proof verification report
>
> Preference for firms with formal verification and multi-language security experience.

---

## Post-Audit: Public Disclosure

After PASS (or CONDITIONAL with remediations fixed):

1. **Publish audit report** (GitHub + marketing materials)
2. **Display audit certificate** on worm-engines.dev landing page
3. **Announce on social media** (LinkedIn, Twitter, if applicable)
4. **Use in sales/marketing:** "Security audited by [Firm], [Certificate #]"
5. **Add to ASSURANCE_MATRIX:** Evidence Level 7 achieved

---

## Questions for Audit Firm

When contacting prospective audit firms, ask:

1. **GNATprove experience?** Can you verify SPARK proof certificates?
2. **Multi-language audits?** Have you reviewed systems with Zig + Erlang + OCaml interop?
3. **Formal methods?** Do you use symbolic execution, fuzzing, or theorem provers?
4. **References?** Can you provide 2-3 prior ledger/consensus system audits?
5. **Timeline?** Can you deliver a 4-6 week audit by [target date]?
6. **Report format?** Do you publish findings? (We want to share publicly if PASS.)

---

**WORM Engines Audit Scope**  
Prepared 2026-07-29 for professional security audit engagement.
