# WORM Fabric Invariants

## Formal Invariants for SPARK Ada Proof

These 12 invariants are the core theorems that SPARK will formally verify. Each invariant must hold at all record commit points and all recovery decision points.

---

## 1. Sequence Monotonicity

Invariant: sequence_new = sequence_previous + 1

Why it matters: Records form a linear chain. Out-of-order records corrupt the stream irreversibly.

SPARK Theorem Name: sequence_monotone

---

## 2. Timestamp Monotonicity

Invariant: timestamp_new >= timestamp_previous

Why it matters: Time cannot flow backward. Prevents causal reversals and merge algorithm failures.

SPARK Theorem Name: timestamp_monotone

---

## 3. Hash Chain Integrity

Invariant: previous_hash_of_curr = sha256(hash_domain(prev_record))

Why it matters: Every record cryptographically commits to its predecessor. Breaking the hash chain forges the entire sequence.

SPARK Theorem Name: hash_chain_valid

---

## 4. Commitment Immutability

Invariant: committed_record cannot be modified

Why it matters: Once committed (flags bit 0 = 1), records are permanent. The ledger is only as immutable as its committed prefix.

SPARK Theorem Name: committed_immutable

---

## 5. Writer Identity Stability

Invariant: writer_id_current = writer_id_previous

Why it matters: A stream has one authority. Writer ID is fixed at genesis and never changes.

SPARK Theorem Name: writer_identity_stable

---

## 6. Policy Monotonicity

Invariant: policy_hash_new >= policy_hash_previous (lexicographic)

Why it matters: Security policy can only tighten or remain the same, never weaken. Prevents policy rollback.

SPARK Theorem Name: policy_strengthen_only

---

## 7. Signature Validity

Invariant: signature_valid(record, writer_id) = true

Why it matters: Each record is signed by the writer. Invalid signatures indicate tampering or software bugs.

SPARK Theorem Name: signature_authentic

---

## 8. Payload Commitment

Invariant: payload_hash = sha256(payload_bytes)

Why it matters: The record commits to its payload. Prevents silent payload corruption.

SPARK Theorem Name: payload_integrity

---

## 9. Unique Record Identity

Invariant: hash(record) is globally unique

Why it matters: Each record has unique cryptographic identity. Deduplication logic relies on this.

SPARK Theorem Name: record_collision_free

---

## 10. Recovery: Longest Sealed Prefix Selection

Invariant: Recovery selects the longest valid sealed prefix from all candidate streams

Why it matters: After crash or partition, the correct choice is the longest prefix where all records are committed and hash-chain-valid.

SPARK Theorem Name: recovery_longest_prefix

---

## 11. Replication Causality: No Ahead-of-Local

Invariant: replicated_sequence cannot precede local_sequence

Why it matters: Peers can only extend the local sequence. Prevents causal reversals and fork attacks.

SPARK Theorem Name: replication_no_rewind

---

## 12. Genesis Uniqueness

Invariant: Genesis record (sequence=0) is unique per stream_id

Why it matters: Two different genesis records with same stream_id create ambiguity and fork attacks.

SPARK Theorem Name: genesis_unique_per_stream

---

## Summary Table

| # | Theorem Name | Category |
|---|---|---|
| 1 | sequence_monotone | Ordering |
| 2 | timestamp_monotone | Ordering |
| 3 | hash_chain_valid | Cryptography |
| 4 | committed_immutable | Durability |
| 5 | writer_identity_stable | Authority |
| 6 | policy_strengthen_only | Security |
| 7 | signature_authentic | Cryptography |
| 8 | payload_integrity | Integrity |
| 9 | record_collision_free | Uniqueness |
| 10 | recovery_longest_prefix | Recovery |
| 11 | replication_no_rewind | Replication |
| 12 | genesis_unique_per_stream | Uniqueness |

---

## Deployment and Monitoring

Invariant Violation = Critical Failure

If any invariant is violated at runtime:
1. Log the violation with full record details
2. Halt the stream (do not accept new records)
3. Alert operator
4. Do not attempt automatic recovery (requires investigation)

Metrics to track:
- invariant_violations_total (per invariant, per stream)
- recovery_success_rate
- replication_rejections

---

## Conformance Testing

Implementations must demonstrate:
1. Monotonicity: Send records with gaps or reordering, verify rejection
2. Hash Chain: Mutate previous_hash, verify rejection
3. Immutability: Attempt to overwrite committed record, verify rejection
4. Writer Stability: Create records with mismatched writer IDs, verify rejection
5. Policy Tightening: Attempt to weaken policy hash, verify rejection
6. Signature: Sign record with wrong key, verify rejection
7. Payload Integrity: Mutate payload, send outdated payload_hash, verify rejection
8. Recovery: Kill process mid-stream, restart, verify longest prefix selected
9. Replication: Attempt to merge stream with lower sequence, verify rejection
10. Genesis: Create two genesis records for same stream, verify only one accepted
