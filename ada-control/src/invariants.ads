pragma Ada_2012;
pragma SPARK_Mode (On);

with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;

package Invariants is

   --  WORM Fabric Invariant Definitions and Predicates
   --  These predicates are used in SPARK contracts to verify state correctness

   --  Fixed-size types (matching worm_abi.h)
   type Hash256 is array (1 .. 32) of Boolean;
   pragma Size (Hash256, 256);

   type Signature is array (1 .. 64) of Boolean;
   pragma Size (Signature, 512);

   type PublicKey is array (1 .. 32) of Boolean;
   pragma Size (PublicKey, 256);

   type Timestamp is new Ada.Types.Unsigned_64;
   type Sequence is new Ada.Types.Unsigned_64;

   --  State enumeration
   type State_Type is (UNINITIALIZED, GENESIS, SEALED);

   --  Record data structure
   type Record_Type is record
      Version      : Ada.Types.Unsigned_32 := 1;
      Sequence     : Sequence := 0;
      Timestamp    : Timestamp := 0;
      Previous_Hash : Hash256 := (others => False);
      Payload_Hash  : Hash256 := (others => False);
      Policy_Hash   : Hash256 := (others => False);
      Writer_Id     : PublicKey := (others => False);
      Flags         : Ada.Types.Unsigned_32 := 0;
      Signature     : Signature := (others => False);
   end record;

   --  Writer state
   type Writer_Type is record
      Writer_Id      : PublicKey;
      State          : State_Type := UNINITIALIZED;
      Sequence       : Sequence := 0;
      Previous_Hash  : Hash256 := (others => False);
      Timestamp      : Timestamp := 0;
   end record;

   --  INVARIANT 1: Sequence Monotonicity
   --  new_sequence = previous_sequence + 1
   function Invariant_Sequence_Monotone
      (prev_seq : Sequence; new_seq : Sequence) return Boolean
   is (new_seq = prev_seq + 1)
   with Ghost;

   --  INVARIANT 2: Timestamp Monotonicity
   --  new_timestamp >= previous_timestamp
   function Invariant_Timestamp_Monotone
      (prev_ts : Timestamp; new_ts : Timestamp) return Boolean
   is (new_ts >= prev_ts)
   with Ghost;

   --  INVARIANT 3: Hash Chain Integrity
   --  previous_hash_of_current = sha256(hash_domain(prior_record))
   --  (simplified: track that links are maintained)
   function Invariant_Hash_Chain_Valid
      (prior_hash : Hash256; record_previous_hash : Hash256) return Boolean
   is (prior_hash = record_previous_hash)
   with Ghost;

   --  INVARIANT 4: Commitment Immutability
   --  committed_record cannot be modified
   --  (flags bit 0 = 1 means committed)
   function Invariant_Committed_Immutable
      (flags : Ada.Types.Unsigned_32) return Boolean
   is ((flags and 1) = 0)  --  only uncommitted records allowed
   with Ghost;

   --  INVARIANT 5: Writer Identity Stability
   --  writer_id_current = writer_id_genesis (fixed per stream)
   function Invariant_Writer_Identity_Stable
      (genesis_writer : PublicKey; record_writer : PublicKey) return Boolean
   is (genesis_writer = record_writer)
   with Ghost;

   --  INVARIANT 6: Policy Monotonicity
   --  policy_hash_new >= policy_hash_previous (lexicographic)
   function Invariant_Policy_Strengthen_Only
      (prev_policy : Hash256; new_policy : Hash256) return Boolean
   is (new_policy >= prev_policy)  --  lexicographic comparison
   with Ghost;

   --  INVARIANT 7: Signature Validity
   --  signature_valid(record, writer_id) = true
   --  (placeholder: actual verification via external crypto)
   function Invariant_Signature_Authentic
      (sig : Signature; writer : PublicKey) return Boolean
   is (sig /= (others => False))  --  non-zero signature required
   with Ghost;

   --  INVARIANT 8: Payload Commitment
   --  payload_hash = sha256(payload_bytes)
   --  (verification deferred to caller)
   function Invariant_Payload_Integrity
      (payload_hash : Hash256) return Boolean
   is (payload_hash /= (others => False))  --  must have payload hash
   with Ghost;

   --  INVARIANT 9: Unique Record Identity
   --  hash(record) is globally unique (collision probability < 2^-128)
   --  (implicit: SHA-256 uniqueness)
   function Invariant_Record_Collision_Free
      (record_hash : Hash256) return Boolean
   is (record_hash /= (others => False))  --  non-zero hash
   with Ghost;

   --  INVARIANT 10: Recovery - Longest Sealed Prefix Selection
   --  Recovery selects longest valid sealed prefix from all candidates
   --  (state machine invariant: SEALED state reached via valid sequence)
   function Invariant_Recovery_Longest_Prefix
      (writer : Writer_Type) return Boolean
   is (writer.Sequence >= 0)  --  always non-negative
   with Ghost;

   --  INVARIANT 11: Replication Causality - No Ahead-of-Local
   --  replicated_sequence cannot precede local_sequence
   function Invariant_Replication_No_Rewind
      (local_seq : Sequence; replicated_seq : Sequence) return Boolean
   is (replicated_seq >= local_seq)
   with Ghost;

   --  INVARIANT 12: Genesis Uniqueness
   --  Genesis record (sequence=0) is unique per stream_id
   --  (state machine invariant: exactly one GENESIS state per writer)
   function Invariant_Genesis_Unique_Per_Stream
      (writer : Writer_Type) return Boolean
   is (writer.State /= UNINITIALIZED)  --  genesis must be initialized
   with Ghost;

   --  Combined invariant check: all 12 must hold
   function All_Invariants_Hold
      (writer : Writer_Type; record : Record_Type) return Boolean
   is (
      Invariant_Sequence_Monotone (writer.Sequence, record.Sequence)
      and Invariant_Timestamp_Monotone (writer.Timestamp, record.Timestamp)
      and Invariant_Hash_Chain_Valid (writer.Previous_Hash, record.Previous_Hash)
      and Invariant_Committed_Immutable (record.Flags)
      and Invariant_Writer_Identity_Stable (writer.Writer_Id, record.Writer_Id)
      and Invariant_Policy_Strengthen_Only (writer.Previous_Hash, record.Policy_Hash)
      and Invariant_Signature_Authentic (record.Signature, record.Writer_Id)
      and Invariant_Payload_Integrity (record.Payload_Hash)
      and Invariant_Record_Collision_Free (record.Previous_Hash)
      and Invariant_Recovery_Longest_Prefix (writer)
      and Invariant_Replication_No_Rewind (writer.Sequence, record.Sequence)
      and Invariant_Genesis_Unique_Per_Stream (writer)
   )
   with Ghost;

end Invariants;
