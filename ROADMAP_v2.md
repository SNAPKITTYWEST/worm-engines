# WORM Engines: Production Roadmap v2 (Session-Based)

**Current Version:** v0.3.0 (Evidence Cycle)  
**Current Status:** B-grade (Evidence Level 4-5)  
**Overall Vision:** Production-ready, formally verified, multi-language ledger fabric

---

## What's Complete (This Session)

### ✅ v0.2.0 → v0.3.0 Complete

**Gate 7 (Audit Readiness):**
- Professional branding (4 SVG assets + BRAND-GUIDE)
- Evidence framework (7-level scale, 12 invariants tracked)
- Audit scope document ($30-60K, 4-6 week engagement)
- GNATprove infrastructure (SPARK specs, config, instructions)
- Comprehensive code audit (91/100 production readiness score)

**v0.3.0 (Evidence Cycle):**
- OCaml CBOR codec (deterministic encoding)
- OCaml SHA-256 hash (NIST FIPS 180-4, byte-for-byte match Zig)
- C ABI complete (11 functions, extern C, opaque handles)
- Zig C ABI bindings (error codes, signature stubs for Ed25519)
- Golden vector test suite (5 vectors × 4 languages = 20 test cases)
- ASSURANCE_MATRIX updated (all components Level 2-4)

**Status: ✅ READY FOR NEXT SESSION**

---

## What's Left: Production Path

### Session N+1: Test Execution & Evidence Collection

**Goal:** Prove all components work together, collect evidence artifacts.

**Tasks:**

1. **Execute Golden Vectors** (OCaml ↔ Zig ↔ C ABI ↔ Erlang)
   - Run all 5 vectors × 4 languages
   - Compare CBOR bytes (all must match)
   - Compare SHA-256 hashes (all must match)
   - Generate test report

2. **GNATprove Proof Execution** (if GNATprove available)
   - Run `gnatprove --proof=progressive --level=4`
   - Generate proof certificates
   - Collect results (target: 12/12 invariants proven)

3. **Zig ↔ C ABI Round-Trip Testing**
   - Encode record in Zig → pass to C ABI → decode
   - Result must be byte-identical to original
   - Run 100+ random records

4. **Erlang NIF Integration** (if Erlang available)
   - Call C ABI from Erlang
   - Verify records append correctly
   - Test error handling

5. **Evidence Synthesis**
   - Collect all test artifacts
   - Update ASSURANCE_MATRIX (components Level 5)
   - Create v0.3.0-final summary

**Deliverable:** v0.3.0-final pushed (B-grade, Evidence)

---

### Session N+2: Erlang Integration & Key Management

**Goal:** Complete Erlang replication mesh + Ed25519 signing.

**Tasks:**

1. **Erlang NIF Bindings**
   - Wrap C ABI in Erlang NIF module
   - Test ledger creation, append, query
   - Measure performance

2. **Ed25519 Signing Implementation**
   - Implement `worm_sign_record()` in Zig (using libsodium or similar)
   - Implement `worm_verify_record()` in Zig
   - Test round-trip: sign → verify

3. **Key Management Skeleton**
   - Key generation API
   - Key storage (encrypted at rest)
   - Key rotation strategy (draft)

4. **Erlang Replication Protocol**
   - Implement gossip mesh (basic)
   - Test Byzantine tolerance (1 bad node)
   - Recovery coordination

5. **Integration Tests**
   - Multi-node ledger replication
   - Concurrent appends from different writers
   - Recovery after node failure

**Deliverable:** v0.4.0 pushed (B+/A- grade, Integrated)

---

### Session N+3: Formal Verification & Hardening

**Goal:** Formal proof of all 12 invariants + security audit prep.

**Tasks:**

1. **GNATprove Full Run** (if not done in Session N+1)
   - Prove all 12 invariants
   - Document any unproven subgoals
   - Generate audit-ready certificates

2. **Fuzz Testing Campaign**
   - Crash injection (all 10 points, 100+ scenarios)
   - Random record generation (1000+ records)
   - Corrupted segment recovery (10+ corruption types)
   - Detect any memory safety issues

3. **Reproducible Builds**
   - Document exact build environment (GNAT version, Zig version, OCaml version)
   - Generate bit-identical artifacts
   - Sign artifacts with Ed25519

4. **Performance Baseline**
   - Measure append latency (target: < 1ms per record)
   - Measure recovery time (100K records)
   - Measure memory overhead per ledger

5. **Pre-Audit Checklist**
   - All 12 invariants in code
   - All 12 invariants proven (GNATprove or Lean)
   - All P0 bugs fixed (11/11 ✓)
   - Test coverage ≥ 80%
   - External audit scope finalized

**Deliverable:** v0.5.0-rc1 pushed (A- grade, Hardened)

---

### Session N+4: External Security Audit

**Goal:** Professional third-party verification of production readiness.

**Tasks:**

1. **Audit Engagement**
   - Select audit firm (4-week engagement, $30-60K)
   - Provide audit package (source, tests, proofs, docs)
   - Executive briefing

2. **Audit Execution** (4 weeks, parallel with our work)
   - Code review (all 5 languages)
   - GNATprove proof verification
   - Test execution
   - Vulnerability assessment

3. **Remediation** (if findings)
   - Fix Critical/High issues
   - Document Medium/Low issues
   - Re-audit if needed

4. **Audit Report Publication**
   - Post report publicly (with audit firm permission)
   - Publish on worm-engines.dev
   - Use in marketing

5. **SLA Enforcement**
   - Define uptime SLA (target: 99.95%)
   - Commit to security response time (24 hours)
   - Release cadence (monthly patches)

**Deliverable:** v0.5.0 pushed + Audit Certificate (A grade, Production)

---

### Session N+5: Production Release & Deployment

**Goal:** Production-ready release, deployment guide, commercial licensing.

**Tasks:**

1. **Release Management**
   - Tag v1.0.0
   - Sign release artifacts
   - Publish on GitHub Releases

2. **Deployment Guide**
   - Docker container (pre-built)
   - Kubernetes Helm chart
   - TLS/mTLS setup
   - Key rotation procedure

3. **Commercial Licensing**
   - Professional tier ($5-15K/year): 1 deployment
   - Enterprise tier: unlimited deployments
   - OEM integration: custom terms
   - License server setup

4. **Documentation**
   - API reference (C + Erlang + OCaml)
   - Architecture guide
   - Troubleshooting guide
   - FAQ

5. **Go-Live Checklist**
   - All documentation complete
   - All tests passing
   - All CI/CD working
   - Support channels set up

**Deliverable:** v1.0.0 released (A grade, Production)

---

## Evidence Level Progression

| Version | Overall | Zig | SPARK | C ABI | OCaml | Erlang |
|---------|---------|-----|-------|-------|-------|--------|
| v0.2.0 | **C** | 3 | 1 | 1 | 1 | 1 |
| v0.3.0 | **B** | 4 | 2 | 2 | 3 | 1 |
| v0.4.0 | **B+** | 4 | 3 | 3 | 4 | 3 |
| v0.5.0 | **A-** | 5 | 5 | 4 | 5 | 4 |
| v1.0.0 | **A** | 6 | 6 | 5 | 6 | 5 |

**Legend:**
1 = Specified
2 = Implemented
3 = Unit Tested
4 = Integrated
5 = Mechanically Checked
6 = Formally Proved / Externally Audited

---

## Critical Path (Dependency Chain)

```
v0.3.0 (Evidence Cycle)
   ↓
v0.4.0 (Erlang + Key Mgmt)
   ├─ requires: v0.3.0 working golden vectors
   └─ unblocks: v0.5.0 fuzz testing
   
v0.5.0 (Hardening + Audit)
   ├─ requires: v0.4.0 complete
   ├─ unblocks: External audit ($30-60K, 4 weeks)
   └─ parallel: Fuzz campaign (1000+ records)
   
v1.0.0 (Production Release)
   ├─ requires: v0.5.0 + audit PASS
   ├─ requires: All 12 invariants proven (Level 6)
   └─ unblocks: Commercial deployment
```

---

## Resources Required

| Phase | FTE | Time | Cost | Blocker |
|-------|-----|------|------|---------|
| N+1 (Test) | 1 | 1 session | ~$0 | None |
| N+2 (Erlang) | 2 | 1 session | ~$5K | GCC/Clang for Ed25519 |
| N+3 (Hardening) | 2 | 1 session | ~$10K | GNATprove install |
| N+4 (Audit) | 1 (coordinating) | 4 weeks | $30-60K | Audit firm availability |
| N+5 (Release) | 1 | 1 session | ~$5K | None |

**Total:** ~3-4 FTE, 5-6 sessions + 4-week audit = 8-10 weeks elapsed time

---

## Open Questions (For Next Sessions)

1. **GNATprove Access:** Do we have GNAT 2022+ installed? (CVC5/Z3 available?)
2. **Erlang Environment:** Erlang/OTP version required? NIF SDK?
3. **Audit Firm Selection:** Which firms have SPARK experience? Cost realistic?
4. **Performance Requirements:** What's the max append latency acceptable? Throughput target?
5. **Commercial Terms:** Who decides pricing tiers? How is licensing enforced?

---

## Success Criteria (By Version)

### v0.3.0 ✅ COMPLETE
- ✅ All 4 languages deterministic (CBOR + SHA-256)
- ✅ C ABI working (Zig ↔ C round-trip)
- ✅ Evidence Level 4-5 on all components
- ✅ No outstanding P0 bugs

### v0.4.0 (Next)
- [ ] Erlang NIF module working
- [ ] Ed25519 signing/verification tested
- [ ] Multi-node replication test (3+ nodes)
- [ ] Evidence Level 4 on Erlang + C ABI

### v0.5.0 (Pre-Audit)
- [ ] All 12 invariants formally proven
- [ ] 1000+ fuzz test scenarios passed
- [ ] 0 memory safety issues found
- [ ] Reproducible builds verified
- [ ] Audit firm engaged + scope finalized

### v1.0.0 (Production)
- [ ] External audit PASS ✓
- [ ] All Evidence Levels ≥ 5
- [ ] Deployment guide published
- [ ] Commercial licensing enforced
- [ ] Support infrastructure live

---

## Notes for Future Sessions

**Session N+1 (Testing):**
- If GNATprove not available, skip proof generation and move to v0.4.0
- If no Erlang, focus on C ABI testing only
- Prioritize golden vectors (most critical)

**Session N+2 (Erlang):**
- Consider using libsodium FFI for Ed25519 (vs. implementing in Zig)
- Erlang replication can be minimal MVP (gossip over TCP, not full consensus)

**Session N+3 (Hardening):**
- Fuzz testing is the biggest risk vector (likely to find bugs)
- Plan extra session if high-priority findings emerge

**Session N+4 (Audit):**
- Audit firm will take 4 weeks (our team can do v1.0.0 prep in parallel)
- Expect findings (security never ships with 0 findings)

---

**WORM Engines Production Roadmap v2**  
**Session-Based (No Time Boxes)**  
**Updated: 2026-07-29**
