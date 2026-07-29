# WORM Engines: Roadmap to Production

**Current Version:** 0.2.0-dev (Experimental, C-grade)  
**Target Release:** 1.0.0 (Production-ready, B+ minimum)  
**Timeline:** 3-6 months (intensive hardening cycle)  
**Change Date:** December 31, 2027 (BSL 1.1 → AGPL-3.0-only)

---

## Phase Overview

```
0.2.x: P0 Fixes (Correctness)
  ↓
0.3.x: Evidence Cycle (Testing)
  ↓
0.4.x: Complete Implementations (Completeness)
  ↓
0.5.x: Hardening & Audit (Security)
  ↓
1.0.0: Production Release (Certified)
```

---

# v0.2.1: P0 Correctness Fixes (2 weeks)

**Goal:** Fix all critical storage and specification bugs.  
**Status:** Experimental (C)  
**Gate:** All P0 items resolved

## Zig Storage Fixes

- [ ] **Remove hardcoded encoded_len**
  - Actual: Use codec's returned length
  - Files: `zig-engine/src/storage.zig`
  - Test: Round-trip encode→write→read
  - Owner: Storage team

- [ ] **Add allocation free (defer)**
  - Fix: `defer allocator.free(encoded)`
  - Files: `zig-engine/src/storage.zig`, `zig-engine/src/abi.zig`
  - Test: Valgrind leak check
  - Owner: Storage team

- [ ] **Fully initialize manifest bytes**
  - Fix: All 88 bytes defined (or reduce to 60)
  - Files: `zig-engine/src/manifest.zig`
  - Test: Determinism check (same input → same bytes)
  - Owner: Storage team

- [ ] **Distinguish missing vs corrupted manifests**
  - Error types: ManifestNotFound, ManifestCorrupt, ManifestTruncated
  - Files: `zig-engine/src/manifest.zig`
  - Test: Deliberate corruption + recovery attempt
  - Owner: Storage team

- [ ] **Add record validation at storage boundary**
  - Validate: sequence, previous_hash, writer, timestamp
  - Use distinct type: `ValidatedRecord`
  - Files: `zig-engine/src/storage.zig`
  - Test: Reject invalid records before durability
  - Owner: Storage team

- [ ] **Make manifest updates transactional in memory**
  - Pattern: Build candidate → durable save → update process state
  - Files: `zig-engine/src/storage.zig`
  - Test: Simulate save failure, verify memory state unchanged
  - Owner: Storage team

- [ ] **Add MAX_RECORD_SIZE limit**
  - Define: `pub const MAX_RECORD_SIZE = 1024 * 1024;` (1 MB)
  - Files: `zig-engine/src/storage.zig`
  - Test: Reject > 1MB
  - Owner: Storage team

- [ ] **Implement recovery path (openExisting)**
  - Functions: `createNew()`, `openExisting()`, `openOrCreate()`
  - Scan segments, validate CRC, rebuild chain
  - Files: `zig-engine/src/storage.zig`
  - Test: Crash-recovery harness (10+ injection points)
  - Owner: Storage team

- [ ] **Add segment format magic + version**
  - Frame: `[magic:4][version:2][flags:2][len:4][payload][crc:4]`
  - Files: `zig-engine/src/segment.zig`
  - Test: Version mismatch → error
  - Owner: Storage team

- [ ] **Path ownership (dupe ledger_path)**
  - Fix: `allocator.dupe()` + free in close
  - Files: `zig-engine/src/storage.zig`
  - Owner: Storage team

## Documentation Fixes

- [ ] Rewrite README (reflect ASSURANCE_MATRIX only)
- [ ] Update SECURITY.md (remove unsupported claims)
- [ ] Update PROOF_STATUS.md (reconcile with reality)

## Test Infrastructure

- [ ] Add crash-injection harness (10+ failure points)
- [ ] Add Valgrind leak checks to CI
- [ ] Add determinism tests (same input → byte-identical output)

**Deliverable:** v0.2.1 release  
**Gate:** All 10 storage fixes + CI green

---

# v0.3.0: Evidence Cycle (4 weeks)

**Goal:** Build mechanical verification + test evidence.  
**Status:** Mechanically Checked (C+)  
**Gate:** GNATprove + 4-language vectors

## SPARK Verification

- [ ] Run GNATprove on Ada specs
  - Command: Record exact GNATprove version + flags
  - Target: All 12 invariants mechanically verified
  - Files: `spark/worm_invariants.ads/adb`
  - Owner: Formal methods team

- [ ] Discharge unproved obligations
  - Triage: Legitimate assumptions vs actual gaps
  - Document: Assumptions file with rationale
  - Owner: Formal methods team

- [ ] Generate GNATprove report
  - Artifact: `assurance/gnatprove/report.txt`
  - Include: Proof statistics, discharged obligations, assumptions

## Complete Cross-Language Vectors

- [ ] Implement OCaml vector generator
  - Use: dune + CBOR library
  - Test: Matches Zig output byte-for-byte
  - Files: `conformance/vectors/test_vectors.ml`
  - Owner: OCaml team

- [ ] Implement Erlang vector generator
  - Use: rebar3 + binary encoding
  - Test: Matches Zig output byte-for-byte
  - Files: `conformance/vectors/test_vectors.erl`
  - Owner: Erlang team

- [ ] Expand malformed input tests
  - Vectors: Truncated records, bad CRC, oversized length, invalid UTF-8
  - Expect: Same rejection from all languages
  - Files: `conformance/vectors/malformed.json`
  - Owner: QA team

- [ ] Add round-trip decode tests
  - Encode → serialize → deserialize → decode → compare
  - All 4 languages
  - Owner: QA team

- [ ] Run cross-language test suite in CI
  - Command: `./conformance/vectors/run_all_tests.sh`
  - Gate: All 4 languages match
  - Owner: CI team

## C ABI Completion

- [ ] Implement worm_sign_record (Ed25519)
  - Use: std library or libsodium
  - Test: Known vector verification
  - Files: `abi/src/sign.c`
  - Owner: Crypto team

- [ ] Implement worm_verify_signature
  - Test: Valid + invalid signatures rejected
  - Files: `abi/src/verify.c`
  - Owner: Crypto team

- [ ] Symbol export verification
  - Tool: nm + expected symbol list
  - CI gate: Prevents accidental symbol hiding
  - Owner: CI team

- [ ] Add C consumer test (GCC + Clang)
  - Compile: Both toolchains, C99 strict
  - Test: All 11 functions exercised
  - Files: `abi/tests/conformance.c`
  - Owner: QA team

## CI/CD Automation

- [ ] Add GNATprove workflow
  - Trigger: Every commit
  - Artifact: `assurance/gnatprove/summary.json`

- [ ] Add cross-language vector workflow
  - Trigger: Every commit
  - Artifact: `conformance/vectors/results.json`

- [ ] Add crash-injection workflow
  - Trigger: Daily
  - Artifact: `conformance/crash/report.txt`

- [ ] Add fuzz harness
  - Targets: CBOR decoder, segment scanner, manifest loader
  - Tool: libFuzzer
  - Run: 24h continuous

**Deliverable:** v0.3.0 release  
**Gate:** GNATprove green + 4-language parity + CI passing

---

# v0.4.0: Complete Implementations (4 weeks)

**Goal:** Finish all incomplete features + integration.  
**Status:** Integrated (C+ → B)  
**Gate:** Replication tested + signing working

## Erlang Replication

- [ ] Implement NIF (C side of Erlang bridge)
  - Link: To existing C ABI (`worm.h`)
  - Test: Erlang calls into Zig via NIF
  - Files: `erlang/c_src/worm_ledger_nif.c`
  - Owner: Erlang team

- [ ] Multi-node integration test (3+ nodes)
  - Scenario: A appends → gossips → B/C receive
  - Verify: All nodes converge to same sequence
  - Files: `erlang/test/worm_mesh_test.erl`
  - Owner: Erlang team

- [ ] Partition recovery test
  - Scenario: Network partition → merge
  - Verify: No data loss, causality preserved
  - Owner: Erlang team

- [ ] Add backpressure handling
  - Drop or queue when overwhelmed
  - Test: Sustained 10K appends/sec
  - Owner: Erlang team

## Cryptography Completion

- [ ] Define key management policy
  - Doc: `docs/key-management.md`
  - Covers: Storage, HSM support, rotation, revocation

- [ ] Implement writer rotation protocol
  - Spec: Old writer signs → new writer takes over
  - Test: Rotation + verification
  - Owner: Crypto team

- [ ] Add key compromise recovery procedure
  - Doc: `docs/compromise-recovery.md`
  - Procedure: Invalidate compromised writer, authorize replacement

- [ ] Domain separation for crypto operations
  - Ensure: SHA-256, Ed25519, HMAC all have unique domain tags
  - Test: Vector verification against known outputs
  - Owner: Crypto team

## Policy Engine (OCaml)

- [ ] Implement basic policy evaluation
  - Rules: Record accepted/rejected based on policy
  - Files: `ocaml-policy/src/policy.ml`
  - Owner: OCaml team

- [ ] Add policy upgrade mechanism
  - Monotonic: New policy ≥ old policy (Inv6)
  - Test: Policy transitions
  - Owner: OCaml team

## Documentation

- [ ] Complete user guide
  - 13 sections (concepts, installation, first ledger, etc.)
  - Include: Examples, troubleshooting, operations

- [ ] Create operator runbook
  - Backup/restore, monitoring, upgrades, incident response

- [ ] Create architecture document
  - Layer diagrams, data flow, protocol details

**Deliverable:** v0.4.0 release  
**Gate:** Erlang + signing integrated + 3-node mesh tested

---

# v0.5.0: Hardening & Security (6 weeks)

**Goal:** Production-grade reliability + security.  
**Status:** Externally Audited (B)  
**Gate:** Security audit passed + SLA certification

## Crash Recovery Hardening

- [ ] Comprehensive crash-recovery matrix
  - 20+ failure injection points
  - Verify: Valid prefix recovery 100% of attempts
  - Owner: Reliability team

- [ ] Handle all corruption scenarios
  - Segment CRC mismatch, manifest corruption, partial writes
  - Quarantine corrupted data, emit alerts
  - Owner: Storage team

- [ ] Implement graceful degradation
  - If manifest corrupt but segment intact, rebuild manifest
  - If multiple segments corrupt, skip to next valid
  - Owner: Storage team

## Security Hardening

- [ ] Fuzz all parsers (libFuzzer)
  - Targets: CBOR decoder, segment scanner, manifest loader, policy parser
  - Run: 1000+ hours corpus collection
  - Owner: Security team

- [ ] Add resource limits
  - Max record size, max manifest size, rate limiting
  - Test: DoS resistance
  - Owner: Security team

- [ ] Add timing attack resistance
  - Signature verification time-constant
  - Hash comparison time-constant
  - Owner: Crypto team

- [ ] Isolate Erlang NIF
  - Use dirty schedulers for blocking work
  - Catch panics, prevent VM crash
  - Owner: Erlang team

- [ ] Add security logging
  - Signature failures, policy violations, corruption detected
  - Include: Timestamp, actor, details
  - Owner: Operations team

## Performance & Scalability

- [ ] Benchmark append latency
  - Target: < 10ms local append
  - Target: < 100ms with quorum replication
  - Owner: Performance team

- [ ] Measure throughput
  - Target: 1000+ records/sec per node
  - Owner: Performance team

- [ ] Add metrics collection
  - Prometheus format, exportable
  - Metrics: Latency, throughput, error rate, memory usage
  - Owner: Operations team

## External Security Audit

- [ ] Hire independent security firm
  - Scope: Code review (Zig, C, Ada), cryptography, threat model
  - Duration: 4-6 weeks
  - Deliverable: Audit report + remediation plan
  - Owner: Executive team

- [ ] Remediate audit findings
  - P0: Fix before v1.0
  - P1: Fix before 6 months post-release
  - P2: Backlog
  - Owner: Engineering team

## Compliance & Certification

- [ ] Generate SBOM
  - Tool: syft or similar
  - Format: SPDX JSON
  - Include: All dependencies + licenses

- [ ] Add reproducible builds
  - Script: `build-reproducible.sh`
  - Verify: Bit-identical output on different machines
  - Owner: Infra team

- [ ] Sign release artifacts
  - Tool: cosign or GPG
  - Key: Stored in hardware security module
  - Owner: Infra team

## Documentation

- [ ] Create deployment guide
  - Infrastructure requirements, network config, HA setup
  - Runbooks: Start, stop, upgrade, backup/restore

- [ ] Create SLA terms
  - Uptime guarantees, incident response procedures
  - Escalation policy

- [ ] Finalize commercial support tiers
  - Professional, Enterprise, OEM terms locked

**Deliverable:** v0.5.0 release (Release Candidate)  
**Gate:** Security audit passed + SLA certified + reproducible builds

---

# v1.0.0: Production Release (2 weeks)

**Goal:** Official production-ready release.  
**Status:** Production Qualified (B+ minimum)  
**Gate:** All release gates passed

## Pre-Release Checklist

- [ ] Update ASSURANCE_MATRIX to "Production Qualified"
- [ ] All P0/P1 audit items closed
- [ ] GNATprove report published
- [ ] Security audit report published
- [ ] SBOM generated and signed
- [ ] Release notes written
- [ ] Documentation complete and tested
- [ ] Performance benchmarks published
- [ ] SLA terms finalized
- [ ] Commercial license agreements ready

## Release Actions

- [ ] Tag v1.0.0
- [ ] Build signed artifacts (all 4 platforms)
- [ ] Generate SBOM (all platforms)
- [ ] Publish GitHub release
- [ ] Update website
- [ ] Send announcement
- [ ] Create support tickets for enterprise customers

## Post-Release (Week 1)

- [ ] Monitor production deployments (if any)
- [ ] Triage bug reports
- [ ] Prepare hotfix if needed
- [ ] Update roadmap for v1.1

**Deliverable:** v1.0.0 on GitHub  
**Status:** Production-ready (B+)

---

# Quality Gates by Version

| Version | GNATprove | 4-Lang | Audit | SLA | Security | SBOM | Sign | Prod-Ready |
|---------|-----------|--------|-------|-----|----------|------|------|-----------|
| 0.2.1 | ⏳ | ⏳ | ❌ | ❌ | ⏳ | ❌ | ❌ | ❌ |
| 0.3.0 | ✅ | ✅ | ❌ | ❌ | ⏳ | ❌ | ❌ | ❌ |
| 0.4.0 | ✅ | ✅ | ❌ | ❌ | ⏳ | ❌ | ❌ | ❌ |
| 0.5.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ | ❌ |
| **1.0.0** | **✅** | **✅** | **✅** | **✅** | **✅** | **✅** | **✅** | **✅** |

---

# Resource Requirements

## Team

| Role | Weeks Needed | Phases |
|------|--------------|--------|
| Zig/Storage | 10 weeks | 0.2.1, 0.3.0, 0.4.0, 0.5.0 |
| Formal Methods | 6 weeks | 0.3.0, 0.4.0 |
| Erlang/Replication | 8 weeks | 0.4.0, 0.5.0 |
| Crypto | 8 weeks | 0.3.0, 0.4.0, 0.5.0 |
| QA/Testing | 12 weeks | All |
| Security/Audit | 10 weeks | 0.5.0 (external firm) |
| DevOps/CI | 6 weeks | All |
| Documentation | 6 weeks | All |
| **Total** | **~66 person-weeks** | **3-6 months (3-4 FTE)** |

## External

- Security audit firm: $30K–$60K
- GNATprove license (if needed): $0–$5K
- Hardware security module (HSM): $5K–$10K

---

# Risk Mitigation

## Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| GNATprove finds critical gap | Medium | High | Early run (0.3.0), contingency proof strategy |
| Erlang NIF destabilizes VM | Low | High | Dirty schedulers, panic isolation, fuzzing |
| Recovery fails on real corruption | Medium | Critical | Crash injection in CI, external audit |
| 4-language determinism breaks | Low | High | Unit tests before integration |

## Organizational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Timeline slip | High | Medium | Weekly milestone reviews, buffer in plan |
| Team availability | Medium | High | Cross-training, runbooks |
| External audit delays | Medium | Medium | Book early (v0.4.0), parallel work |

---

# Success Criteria

✅ v1.0.0 is ready when:

1. **All P0 storage fixes** committed and tested
2. **SPARK verified** by GNATprove (all 12 invariants)
3. **4-language vectors** match byte-for-byte
4. **Erlang mesh** tested on 3+ nodes, partitions handled
5. **Signing/verification** working end-to-end
6. **External audit** passed with no P0 findings
7. **Reproducible builds** confirmed
8. **Documentation** complete and accurate
9. **SLA metrics** published + certified
10. **No critical bugs** in last 2 weeks

---

# Release Strategy

## v1.0.0 Launch

- Public: Production-ready, open source via AGPL-3.0
- Commercial: Optional paid license for SaaS/embedding
- Enterprise: Professional + support tiers
- OEM: Custom licensing

## v1.1 + Beyond

After v1.0.0:

- Byzantine fault tolerance (v1.1)
- Hardware security module integration (v1.2)
- Advanced replication protocols (v1.3)
- Formal proof export to Lean (ongoing)

---

**Last updated:** 2026-07-29  
**Owner:** Engineering team  
**Review cadence:** Weekly
