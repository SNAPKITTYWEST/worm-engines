# Security Policy

## Supported Versions

| Version | Status | Support End |
|---------|--------|-------------|
| 0.1.x | Development | N/A |
| 1.0.x | Planned | TBD |

**Current**: 0.1.0-dev (experimental, not for production)

## Vulnerability Reporting

**Private Disclosure**: Email security@sovereigncode.dev

Do not open public GitHub issues for security vulnerabilities.

Include:
- Affected component (Zig, Ada, OCaml, Erlang, ABI)
- Severity (critical, high, medium, low)
- Reproduction steps or proof of concept
- Suggested fix (if any)

Response time: 48 hours.

## Threat Boundary (Current)

WORM Engines defends against:
- ✅ Record truncation (incomplete chain)
- ✅ Record reordering (sequence violation)
- ✅ Record mutation (hash mismatch)
- ✅ Forged writer identity (signature invalid)
- ✅ Duplicate genesis (multiple stream heads)

WORM Engines does NOT defend against:
- ❌ Compromised operating system
- ❌ Physical tampering with storage
- ❌ Compromised cryptographic keys
- ❌ Byzantine majority in replication mesh (requires >1/3 faulty nodes)
- ❌ Cryptanalysis of SHA-256 or Ed25519

## Cryptographic Assumptions

WORM Engines relies on:
- **SHA-256**: Collision resistance (256-bit security)
- **Ed25519**: Signature existential unforgeability
- **CSPRNG**: For nonce generation

If any assumption is broken, WORM guarantees fail.

## Denial-of-Service Limits

Current implementation (0.1.0-dev) has no DoS protections:
- ❌ No maximum record size checks
- ❌ No rate limiting
- ❌ No memory allocation caps
- ❌ No timeout enforcement

These will be added before v1.0.

## Non-Goals

- Confidentiality (records are not encrypted)
- Real-time availability (crash recovery prioritized over latency)
- Quantum resistance (post-quantum algorithms not supported)
- Non-repudiation across governance transitions (policy changes are tracked, not revoked)

## Disclosure Timeline

Once a security issue is confirmed:
1. **Day 0**: Acknowledge receipt
2. **Day 7**: Notify downstream users
3. **Day 14**: Publish fix
4. **Day 30**: Public disclosure (with credit to reporter)

## No Bug Bounty Program

Sovereign Source does not currently offer a bug bounty program.

Security contributions are valued and will be credited in release notes and CHANGELOG.

## Legal

See LICENSE and LICENSING.md for commercial support terms.
