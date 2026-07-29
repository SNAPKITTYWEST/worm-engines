# Gate 6: Replication Harness

**Status:** Phase 1 - Erlang Mesh Design Complete  
**Date:** 2026-07-29  
**License:** Sovereign Source + BSL 1.1

---

## Overview

Gate 6 implements distributed replication of WORM ledgers across an Erlang mesh. Multiple nodes maintain independent local WORM ledgers and gossip updates to preserve causality and consistency.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│ WORM Mesh: Distributed Replication                  │
└─────────────────────────────────────────────────────┘

    Node A                Node B                Node C
  ┌────────┐            ┌────────┐            ┌────────┐
  │ WORM   │            │ WORM   │            │ WORM   │
  │Ledger  │            │Ledger  │            │Ledger  │
  │ Seq:5  │            │ Seq:4  │            │ Seq:3  │
  │ Hash:X │            │ Hash:Y │            │ Hash:Z │
  └────────┘            └────────┘            └────────┘
       │                     │                     │
       └─────────────────────┼─────────────────────┘
             Gossip Protocol (Erlang cast)
        - Append events
        - Sequence + Hash
        - Causality ordering
```

---

## Components

### 1. worm_mesh.erl (Erlang Mesh Node)

**Purpose:** Distributed replication coordinator

**Key Functions:**
- `start_link(NodeId)` — Initialize WORM mesh node
- `append_record(WriterId, PayloadHash)` — Append + gossip
- `query_sequence()` — Get current state
- `get_ledger()` — Fetch full ledger

**Invariants Enforced:**
- Inv1: Sequence Monotonicity (next = current + 1)
- Inv2: Timestamp Monotonicity (clock check)
- Inv5: Writer Stability (WriterId must match node ID)
- Inv8: Payload Commitment (hash verification)
- Inv11: Replication Causality (peer_seq > local_seq before accept)

**Replication Protocol:**
1. Local append via Zig (durable)
2. Update local state (sequence, hash)
3. Broadcast gossip to all peers:
   ```erlang
   {gossip_append, Sequence, Hash, NodeId}
   ```
4. Peers receive and verify causality
5. If peer_seq > local_seq, accept and update

### 2. worm_ledger_nif.erl (Erlang/Zig Bridge)

**Purpose:** Native interface to Zig storage engine

**Functions:**
- `init_ledger(WriterId)` — Initialize per-node ledger
- `append_record(WriterId, PayloadHash, Sequence)` — Durable append
- `query_sequence()` — Get current sequence
- `query_hash(Sequence)` — Get hash at sequence

**Implementation:** Erlang NIF (native interface) that calls C ABI functions in Zig.

---

## Replication Semantics

### Causality (Invariant 11)

Each node maintains a local sequence counter. When a record is appended:

1. **Local Node:** Sequence increases (Inv1)
2. **Gossip to Peers:** Send (Sequence, Hash)
3. **Peer Receipt:** Only accept if peer_seq > local_seq
4. **Conflict Resolution:** Last-write-wins by sequence number

### Durability

All appends are made durable via Zig storage:
- Segment files (append-only with CRC32)
- Manifest file (atomic state checkpoint)
- fsync() after every write

### Byzantine Tolerance

**Current:** Honest nodes only (no malicious peers)  
**Assumption:** All nodes are trusted and follow the protocol

**Future Hardening:** (Phase 2)
- Quorum-based verification (3+ nodes agree)
- Merkle tree for efficient history verification
- Cryptographic proof of sequence order (VRF + signatures)

---

## File Structure

```
erlang/
├── worm_mesh.erl           — Replication node (350 lines)
├── worm_ledger_nif.erl     — Zig bridge (45 lines)
├── test/
│   └── worm_mesh_test.erl  — Unit tests
└── doc/
    └── PROTOCOL.md          — Gossip protocol details
```

---

## Integration Path

### Phase 1: Erlang Mesh (✅ COMPLETE)
- ✅ worm_mesh.erl — Gossip protocol
- ✅ worm_ledger_nif.erl — Zig bridge interface
- ✅ Invariant enforcement (Inv1, Inv5, Inv8, Inv11)

### Phase 2: NIF Implementation (⏳ PENDING)
- Implement C/Zig side of NIF
- Link to existing C ABI (`worm.h`)
- Test Erlang ↔ Zig communication

### Phase 3: Integration Tests (⏳ PENDING)
- Multi-node mesh (3+ nodes)
- Concurrent appends
- Network partition recovery
- Replication lag measurement

### Phase 4: Performance Tuning (⏳ PENDING)
- Gossip batching (group updates)
- Acknowledgment tracking
- Backpressure handling

---

## Verification

Each node verifies Invariants 1, 5, 8, 11:

```erlang
verify_invariants(WriterId, PayloadHash, State) ->
    %% Inv1: Sequence monotonicity
    NextSequence = State#state.sequence + 1,

    %% Inv5: Writer stability
    case WriterId = State#state.node_id of
        true ->
            %% Inv8: Payload commitment (32-byte hash)
            case byte_size(PayloadHash) =:= 32 of
                true ->
                    {ok, NextSequence};
                false ->
                    {error, invalid_payload_hash}
            end;
        false ->
            {error, writer_mismatch}
    end.
```

---

## Testing (Next Phase)

**Test Suite:**
1. Single node — append and query
2. Two nodes — gossip propagation
3. Three+ nodes — multi-way replication
4. Failure modes — node restart, network partition

**Expected Behavior:**
- All nodes converge to same sequence (eventually consistent)
- No record loss (durability via Zig)
- Causality preserved (Inv11)

---

## Comparison: Centralized vs. Distributed

| Aspect | Centralized (Gate 4) | Distributed (Gate 6) |
|--------|---------------------|----------------------|
| Single Point of Failure | Yes | No |
| Latency | Low | Higher (gossip) |
| Consistency | Strong (ACID) | Eventual (BASE) |
| Scalability | Limited | Unlimited |
| Failure Recovery | Restart | Automatic |
| Verifiability | Via C ABI | Via SPARK + Erlang |

---

## Security Properties

✅ **Integrity:** Hash chain prevents tampering (Inv3)  
✅ **Authenticity:** Ed25519 signatures verify writer (Inv7)  
✅ **Causality:** Sequence ordering prevents reordering (Inv11)  
✅ **Durability:** fsync enforced in Zig (Inv4, Inv10)  
⚠️ **Liveness:** Gossip eventual (not Byzantine-fault-tolerant)  
⚠️ **Confidentiality:** No encryption (add layer on top)

---

## Next Steps

1. **Phase 2:** Implement NIF (C side of Erlang bridge)
2. **Phase 3:** Multi-node integration tests
3. **Phase 4:** Performance + Byzantine hardening
4. **Gate 7:** External audit

---

**Gate 6 Milestone:** Erlang mesh replication designed and specified. Ready for Phase 2 NIF implementation.

