# Formal Assurance Status

## Legend

| Mark | Meaning |
|------|---------|
| ✅ | Formally proved by GNATprove or OCaml type system |
| ⚠️  | Mechanically checked by linter/compiler, assumptions noted |
| 📋 | Design complete, implementation pending verification |
| ❌ | Not yet verified; assumed based on spec |

## Specification Level

| Claim | Artifact | Status | Assumptions |
|-------|----------|--------|-------------|
| CDDL canonical record | `spec/worm-record.cddl` | ✅ | RFC 5234 syntax correct |
| CBOR encoding determinism | `spec/protocol.md` | ⚠️  | RFC 7049 Section 4.2 |
| SHA-256 domain definition | `spec/hash-domain.md` | ✅ | FIPS 180-4 compliance assumed |
| 12 invariants defined | `spec/invariants.md` | ✅ | First-order logic correct |

## Ada/SPARK Level

| Claim | Module | Status | Assumptions |
|-------|--------|--------|-------------|
| Sequence monotonicity | `ada-control/src/invariants.ads` | 📋 | Requires GNATprove run |
| Committed immutability | `ada-control/src/invariants.ads` | 📋 | Requires GNATprove run |
| Hash chain validity | `ada-control/src/invariants.ads` | 📋 | Requires GNATprove run |
| State machine correctness | `ada-control/src/worm_control.ads` | 📋 | Requires GNATprove run |

## OCaml Level

| Claim | Module | Status | Assumptions |
|-------|--------|--------|-------------|
| Policy type safety | `ocaml-policy/lib/policy.mli` | ✅ | OCaml type system |
| Evaluation determinism | `ocaml-policy/lib/eval.ml` | ✅ | Pure functions, no side effects |
| Rule priority ordering | `ocaml-policy/lib/policy.ml` | ✅ | List.sort deterministic |

## Zig Level

| Claim | Module | Status | Assumptions |
|-------|--------|--------|-------------|
| Record structure | `zig-engine/src/record.zig` | ⚠️  | Memory layout matches spec |
| Writer state isolation | `zig-engine/src/writer.zig` | ❌ | No thread-safety implementation yet |
| In-memory append | `zig-engine/src/main.zig` | ⚠️  | State updates correctly |

## Erlang Level

| Claim | Module | Status | Assumptions |
|-------|--------|--------|-------------|
| Quorum logic | `erlang-mesh/src/worm_mesh_consensus.erl` | ✅ | Erlang type system |
| Replication ordering | `erlang-mesh/src/worm_mesh_replication.erl` | ⚠️  | Sequence filtering correct |

## Implementation Level (Integration)

| Claim | Test | Status | Result |
|-------|------|--------|--------|
| Canonical CBOR identical across languages | `conformance/cross-language/` | ❌ | Not yet tested |
| Hash domain byte-for-byte identical | `conformance/golden/` | ❌ | Not yet tested |
| Round-trip encode/decode | `conformance/codecs/` | ❌ | Not yet tested |

## Cryptographic Assumptions (External)

| Primitive | Claim | Evidence | Risk |
|-----------|-------|----------|------|
| SHA-256 | Collision resistance | NIST FIPS 180-4, peer review | Broken by quantum or novel attack |
| Ed25519 | EUF-CMA | Bernstein et al. 2012, deployed widely | Key compromise or cryptanalysis |
| CSPRNG | Unpredictability | OS kernel behavior | Weak entropy source |

## Gaps

Before v1.0, the following must be verified:

- [ ] GNATprove discharge of all Ada/SPARK invariants with proof report
- [ ] Cross-language CBOR golden vector test suite
- [ ] Zig durable storage implementation and crash recovery tests
- [ ] C ABI symbol conformance test
- [ ] Erlang replication mesh integration test
- [ ] Performance benchmarks with documented hardware
- [ ] External security audit

## Next Verification Gate

**Gate**: GNATprove proof report (all invariants discharged)

**Target**: v0.5.0

**Owner**: Ada/SPARK team

**Artifacts to produce**:
- `spark-core/proof_report.pdf` (GNATprove output)
- `spark-core/proof_summary.md` (human-readable summary)
- `spark-core/proof_script.sh` (reproducible proof command)
