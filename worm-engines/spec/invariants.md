# WORM Fabric Invariants

## Formal Invariants for SPARK Ada Proof

These 12 invariants are the core theorems that SPARK will formally verify. Each invariant must hold at all record commit points and all recovery decision points.

---

## 1. Sequence Monotonicity

**Invariant:** `sequence_new = sequence_previous + 1`

**Why it matters:** Records form a linear chain. Out-of-order records corrupt the stream irreversibly. No recovery can repair sequence gaps.

**SPARK Theorem Name:** `sequence_monotone`

**Proof Obligation:** For every committed record pair (r_prev, r_curr), if `r_prev.sequence = N`, then `r_curr.sequence = N + 1` or record is rejected.

---

## 2. Timestamp Monotonicity

**Invariant:** `timestamp_new >= timestamp_previous`

**Why it matters:** Time cannot flow backward. Receivers use timestamps for causal ordering when comparing multiple streams. Non-monotonic timestamps break cross-stream merge algorithms.

**SPARK Theorem Name:** `timestamp_monotone`

**Proof Obligation:** For every committed record pair (r_prev, r_curr), `r_curr.timestamp >= r_prev.timestamp`.

---

## 3. Hash Chain Integrity

**Invariant:** `previous_hash_of_curr = sha256(hash_domain(prev_record))`

**Why it matters:** Every record cryptographically commits to its predecessor. Breaking the hash chain is the same as forging the entire sequence (computationally infeasible with SHA-256).

**SPARK Theorem Name:** `hash_chain_valid`

**Proof Obligation:** For every committed record r_curr (sequence > 0), recompute `sha256(hash_domain(prev_record))` and verify it equals `r_curr.previous_hash`. If not, record is rejected.

---

## 4. Commitment Immutability

**Invariant:** `committed_record cannot be modified`

**Why it matters:** Once a record is marked committed (flags bit 0 = 1), it is permanent. Uncommitted records can be replaced; committed records cannot. The ledger is only as immutable as its committed prefix.

**SPARK Theorem Name:** `committed_immutable`

**Proof Obligation:** If record r with `r.flags & 0x01 = 1` is stored, any subsequent operation that would overwrite r is rejected with error.

---

## 5. Writer Identity Stability

**Invariant:** `writer_id_current = writer_id_previous`

**Why it matters:** A stream has one authority (writer). Writer ID is fixed at genesis and cannot change. Multi-writer attacks are prevented by rejecting records with mismatched writer IDs.

**SPARK Theorem Name:** `writer_identity_stable`

**Proof Obligation:** For every committed record r, `r.writer_id = genesis_record.writer_id`. If not, record is rejected.

---

## 6. Policy Monotonicity

**Invariant:** `policy_hash_new >= policy_hash_previous` (lexicographic comparison)

**Why it matters:** Security policy can only tighten or remain the same, never weaken. Prevents rollback of security constraints.

**SPARK Theorem Name:** `policy_strengthen_only`

**Proof Obligation:** For every committed record pair (r_prev, r_curr), `r_curr.policy_hash >= r_prev.policy_hash` in lexicographic byte order. Policy rollback is rejected.

---

## 7. Signature Validity

**Invariant:** `signature_valid(record, writer_id) = true`

**Why it matters:** Each record is signed by the writer. Invalid signatures indicate tampering or software bugs. Unsigned records are rejected outright.

**SPARK Theorem Name:** `signature_authentic`

**Proof Obligation:** For every record r, `verify_ed25519_signature(r.signature, hash_domain(r), r.writer_id)` must return true. If false, record is rejected.

---

## 8. Payload Commitment

**Invariant:** `payload_hash = sha256(payload_bytes)`

**Why it matters:** The record commits to its payload. Payload is opaque to the engine, but the hash proves the engine did not modify it. Prevents silent payload corruption.

**SPARK Theorem Name:** `payload_integrity`

**Proof Obligation:** For every record r, the sender (or validator) must recompute `sha256(payload_bytes)` and verify it matches `r.payload_hash`. If not, record is rejected.

---

## 9. Unique Record Identity

**Invariant:** `hash(record) is globally unique (collision probability < 2^-128)`

**Why it matters:** Each record has a unique cryptographic identity. Deduplication logic relies on this. Hash collisions are catastrophic (requires 2^128 hashes to find one with birthday attack, negligible risk).

**SPARK Theorem Name:** `record_collision_free`

**Proof Obligation:** For any two distinct records r1, r2, `sha256(hash_domain(r1)) != sha256(hash_domain(r2))` with overwhelming probability. Duplicates are rejected on arrival.

---

## 10. Recovery: Longest Sealed Prefix Selection

**Invariant:** `Recovery selects the longest valid sealed prefix from all candidate streams`

**Why it matters:** After crash or partition, the engine has multiple candidate sequences (persisted uncommitted records, replicated records from peers, recovered cache). The correct choice is the longest prefix where all records are committed and hash-chain-valid.

**SPARK Theorem Name:** `recovery_longest_prefix`

**Proof Obligation:** Let C = {sequences of committed, hash-chain-valid records recovered from all sources}. Recovery selects the sequence s ∈ C with maximum length. If multiple sequences have equal length, select lexicographically smallest record hash at the prefix boundary (deterministic tiebreaker).

---

## 11. Replication Causality: No Ahead-of-Local

**Invariant:** `replicated_sequence cannot precede local_sequence`

**Why it matters:** If local stream has sequence N, a peer cannot have sequence M < N and be a valid source for merge. Peers can only extend the local sequence (M >= N). Prevents causal reversals.

**SPARK Theorem Name:** `replication_no_rewind`

**Proof Obligation:** Let local_max = maximum sequence in local committed stream. For any peer stream offered in replication batch, if peer_max < local_max, the peer batch is rejected. If peer_max >= local_max, validate peer records merge into local at sequence >= local_max.

---

## 12. Genesis Uniqueness

**Invariant:** `Genesis record (sequence=0) is unique per stream_id`

**Why it matters:** A stream is defined by its genesis record. Two different genesis records with the same stream_id create ambiguity and fork attacks. Exactly one genesis record per stream_id is allowed.

**SPARK Theorem Name:** `genesis_unique_per_stream`

**Proof Obligation:** For every stored stream identified by stream_id, there exists exactly one record r with `r.sequence = 0` and `r.stream_id = stream_id`. If a second genesis candidate arrives, it is rejected (duplicate stream_id) or triggers a new stream (new stream_id).

---

## Summary Table

| # | Invariant | Theorem Name | Category |
|---|-----------|--------------|----------|
| 1 | sequence_new = sequence_previous + 1 | `sequence_monotone` | Ordering |
| 2 | timestamp_new >= timestamp_previous | `timestamp_monotone` | Ordering |
| 3 | previous_hash = sha256(prior_domain) | `hash_chain_valid` | Cryptography |
| 4 | committed_record is immutable | `committed_immutable` | Durability |
| 5 | writer_id never changes | `writer_identity_stable` | Authority |
| 6 | policy_hash monotonic tighten | `policy_strengthen_only` | Security |
| 7 | signature is valid Ed25519 | `signature_authentic` | Cryptography |
| 8 | payload_hash = sha256(payload) | `payload_integrity` | Integrity |
| 9 | record hash is unique | `record_collision_free` | Uniqueness |
| 10 | recovery picks longest prefix | `recovery_longest_prefix` | Recovery |
| 11 | replication >= local_sequence | `replication_no_rewind` | Replication |
| 12 | one genesis per stream_id | `genesis_unique_per_stream` | Uniqueness |

---

## Proof Strategy

### SPARK Ada Verification

1. **Module:** `worm_invariants.ads` (spec) and `worm_invariants.adb` (body)
2. **Contracts:** Each invariant becomes a `Post` or `Pre` condition on engine functions
3. **Flow Analysis:** Prove no function violates any invariant
4. **Loop Invariants:** For batch-record processing, state which invariants hold at loop entry, loop exit, and after each record commit
5. **Recovery Procedure:** Proof that recovery loop terminates with longest-prefix property

### Example Proof Structure (Sketch)

```ada
-- File: worm_invariants.ads

package WORM_Invariants is

  -- Invariant 1: Sequence Monotonicity
  procedure Validate_Sequence_Monotone (
    prev_record : in WormRecord;
    curr_record : in WormRecord
  )
  with
    Pre => prev_record.sequence < curr_record.sequence,
    Post => curr_record.sequence = prev_record.sequence + 1;

  -- Invariant 3: Hash Chain Integrity
  procedure Validate_Hash_Chain (
    prev_record : in WormRecord;
    curr_record : in WormRecord;
    prev_hash_computed : out Bytes_32
  )
  with
    Post => prev_hash_computed = SHA256(Hash_Domain(prev_record))
         and prev_hash_computed = curr_record.previous_hash;

  -- Invariant 10: Recovery Longest Prefix
  function Recover_Longest_Prefix (
    candidates : in Sequence_List
  ) return Sequence
  with
    Post => Recover_Longest_Prefix'Result.length >= candidates(I).length for all I
         and Recover_Longest_Prefix'Result.committed_prefix_valid
         and Recover_Longest_Prefix'Result.hash_chain_valid;

end WORM_Invariants;
```

---

## Deployment and Monitoring

### Invariant Violation = Critical Failure

If any invariant is violated at runtime:
1. Log the violation with full record details
2. Halt the stream (do not accept new records)
3. Alert operator
4. Do not attempt automatic recovery (requires investigation)

### Metrics

Track:
- `invariant_violations_total` (per invariant, per stream) — should be 0
- `recovery_success_rate` — % of recoveries where longest prefix was found and valid
- `replication_rejections` — count of rejected replication batches (causality check)

---

## Conformance Testing

Implementations must demonstrate:

1. **Monotonicity:** Send records with gaps or reordering, verify rejection
2. **Hash Chain:** Mutate a record's `previous_hash`, verify rejection
3. **Immutability:** Attempt to overwrite committed record, verify rejection
4. **Writer Stability:** Create records with mismatched writer IDs, verify rejection
5. **Policy Tightening:** Attempt to weaken policy hash, verify rejection
6. **Signature:** Sign record with wrong key, verify rejection
7. **Payload Integrity:** Mutate payload, send record with outdated payload_hash, verify rejection
8. **Recovery:** Kill process mid-stream, restart, verify longest prefix selected
9. **Replication:** Attempt to merge stream with lower sequence, verify rejection
10. **Genesis:** Create two genesis records for same stream, verify only one accepted
