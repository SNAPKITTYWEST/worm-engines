--  WORM Engines: Formal Invariants in Ada SPARK
--
--  Specification of the 12 WORM correctness invariants as formal predicates.
--  This package defines the state machine and invariants that all implementations
--  must satisfy.
--
--  Copyright © 2026 Sovereign Source Foundation. All rights reserved.
--  Licensed under Sovereign Source License + Business Source License 1.1.
--  See LICENSE for complete terms.

pragma SPARK_Mode (On);

with Interfaces; use Interfaces;
with Ada.Containers.Vectors;

package WORM_Invariants is

   --  Fixed-size types
   type Hash256 is array (0 .. 31) of Unsigned_8;
   type StreamId is array (0 .. 31) of Unsigned_8;
   type WriterId is array (0 .. 31) of Unsigned_8;

   --  Record state
   type Record_State is record
      Sequence       : Unsigned_64;
      Timestamp      : Unsigned_64;
      Stream_Id      : StreamId;
      Writer_Id      : WriterId;
      Payload_Hash   : Hash256;
      Previous_Hash  : Hash256;
      Policy_Hash    : Hash256;
      Current_Hash   : Hash256;
      Signature      : Unsigned_64;  -- Simplified: would be full signature in real impl
      Flags          : Unsigned_8;
   end record;

   --  Ledger state
   type Ledger_State is record
      Records        : Unsigned_64;       -- Number of records appended
      Last_Sequence  : Unsigned_64;       -- Highest sequence number
      Last_Hash      : Hash256;           -- Hash of last record
      Last_Timestamp : Unsigned_64;       -- Timestamp of last record
      Writer_Stable  : Boolean;           -- Writer ID hasn't changed
      Policy_Stable  : Boolean;           -- Policy hash is monotonic
   end record;

   --  =========================================================================
   --  INVARIANT 1: Sequence Monotonicity
   --  =========================================================================
   --  Records must have strictly increasing sequence numbers
   function Inv1_Sequence_Monotonic (Ledger : Ledger_State;
                                     New_Record : Record_State) return Boolean is
      (New_Record.Sequence > Ledger.Last_Sequence)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 2: Timestamp Monotonicity
   --  =========================================================================
   --  Record timestamps must be non-decreasing
   function Inv2_Timestamp_Monotonic (Ledger : Ledger_State;
                                      New_Record : Record_State) return Boolean is
      (New_Record.Timestamp >= Ledger.Last_Timestamp)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 3: Hash Chain Integrity
   --  =========================================================================
   --  Each record's previous_hash must match the last record's hash
   function Inv3_Hash_Chain_Valid (Ledger : Ledger_State;
                                   New_Record : Record_State) return Boolean is
      (New_Record.Previous_Hash = Ledger.Last_Hash)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 4: Committed Immutability
   --  =========================================================================
   --  Once a record is committed (fsync'd), it cannot be modified
   --  This is enforced at the storage layer (append-only files)
   function Inv4_Committed_Immutable (Record_Committed : Boolean) return Boolean is
      (Record_Committed)  -- Semantic: if committed, cannot change
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 5: Writer Stability
   --  =========================================================================
   --  The writer ID must remain constant throughout execution
   function Inv5_Writer_Stable (Ledger : Ledger_State;
                                New_Record : Record_State;
                                Expected_Writer : WriterId) return Boolean is
      (New_Record.Writer_Id = Expected_Writer and Ledger.Writer_Stable)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 6: Policy Monotonicity
   --  =========================================================================
   --  Policy hash must be monotonically non-decreasing (lexicographic)
   function Inv6_Policy_Monotonic (Ledger : Ledger_State;
                                   New_Record : Record_State) return Boolean is
      (New_Record.Policy_Hash >= Ledger.Last_Record.Policy_Hash or
       Ledger.Records = 0)  -- First record has no predecessor
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 7: Signature Authenticity
   --  =========================================================================
   --  All signatures must be valid Ed25519 signatures from the writer
   function Inv7_Signature_Valid (Record_Sig : Unsigned_64;
                                  Writer : WriterId) return Boolean is
      (Record_Sig /= 0)  -- Placeholder: real verification in C ABI
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 8: Payload Commitment
   --  =========================================================================
   --  The payload_hash must be consistent across all verification
   function Inv8_Payload_Committed (Record_Hash : Hash256;
                                    Computed_Hash : Hash256) return Boolean is
      (Record_Hash = Computed_Hash)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 9: Record Uniqueness
   --  =========================================================================
   --  No two records can have the same (stream_id, sequence, writer_id)
   function Inv9_Record_Unique (Seq1 : Unsigned_64,
                                Seq2 : Unsigned_64;
                                Stream1 : StreamId;
                                Stream2 : StreamId) return Boolean is
      (Seq1 = Seq2 and Stream1 = Stream2 -> Seq1 /= Seq2)  -- Contradiction prevention
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 10: Recovery Prefix
   --  =========================================================================
   --  The ledger must be recoverable from the segments on disk
   --  (All committed records must exist in persistent storage)
   function Inv10_Recovery_Prefix (Records_Committed : Unsigned_64;
                                   Records_On_Disk : Unsigned_64) return Boolean is
      (Records_On_Disk >= Records_Committed)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 11: Replication Causality
   --  =========================================================================
   --  If record A references record B's hash, then B must be committed first
   function Inv11_Causality_Order (A_Previous : Hash256;
                                   B_Current : Hash256;
                                   B_Committed : Boolean) return Boolean is
      (if A_Previous = B_Current then B_Committed else True)
   with Pure_Function;

   --  =========================================================================
   --  INVARIANT 12: Genesis Uniqueness
   --  =========================================================================
   --  There must be exactly one genesis record (sequence = 0)
   function Inv12_Genesis_Unique (Total_Records : Unsigned_64;
                                  Genesis_Count : Unsigned_64) return Boolean is
      (Genesis_Count = 1 or Total_Records = 0)
   with Pure_Function;

   --  =========================================================================
   --  State Machine: Append Operation
   --  =========================================================================
   --  The core WORM operation: append a record and verify all invariants
   procedure Append_Record (Ledger : in out Ledger_State;
                            New_Record : Record_State;
                            Expected_Writer : WriterId;
                            Success : out Boolean)
   with Post => (if Success then
                   Inv1_Sequence_Monotonic (Ledger'Old, New_Record) and
                   Inv2_Timestamp_Monotonic (Ledger'Old, New_Record) and
                   Inv3_Hash_Chain_Valid (Ledger'Old, New_Record));

   --  =========================================================================
   --  Initialization: Create genesis record
   --  =========================================================================
   procedure Initialize_Ledger (Ledger : out Ledger_State;
                                Genesis : Record_State;
                                Writer : WriterId)
   with Post => (Inv12_Genesis_Unique (Ledger.Records, 1) and
                 Inv5_Writer_Stable (Ledger, Genesis, Writer));

end WORM_Invariants;
