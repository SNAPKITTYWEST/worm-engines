-- Copyright © 2026 Sovereign Source Foundation. All rights reserved.
-- Licensed under Sovereign Source License. Commercial use only.
-- See LICENSE for complete terms.

pragma Ada_2012;
pragma SPARK_Mode (On);

package body Worm_Control is

   function Init_Writer (Writer_Id : PublicKey) return Writer_Type is
      Writer : Writer_Type;
   begin
      Writer.Writer_Id := Writer_Id;
      Writer.State := UNINITIALIZED;
      Writer.Sequence := 0;
      Writer.Timestamp := 0;
      return Writer;
   end Init_Writer;

   function Create_Record (Writer : Writer_Type; Payload_Hash : Hash256)
      return Record_Type is
      Record : Record_Type;
   begin
      Record.Version := 1;
      Record.Sequence := Writer.Sequence + 1;
      Record.Timestamp := Writer.Timestamp;
      Record.Previous_Hash := Writer.Previous_Hash;
      Record.Payload_Hash := Payload_Hash;
      Record.Writer_Id := Writer.Writer_Id;
      Record.Flags := 0;
      return Record;
   end Create_Record;

   function Validate_Record (Writer : Writer_Type; Record : Record_Type)
      return Error_Code is
   begin
      if not Invariant_Sequence_Monotone (Writer.Sequence, Record.Sequence) then
         return WORM_ERR_SEQUENCE_MISMATCH;
      end if;

      if not Invariant_Timestamp_Monotone (Writer.Timestamp, Record.Timestamp) then
         return WORM_ERR_TIMESTAMP_INVALID;
      end if;

      if not Invariant_Hash_Chain_Valid (Writer.Previous_Hash, Record.Previous_Hash) then
         return WORM_ERR_HASH_CHAIN_BROKEN;
      end if;

      if not Invariant_Committed_Immutable (Record.Flags) then
         return WORM_ERR_IMMUTABLE_VIOLATION;
      end if;

      if not Invariant_Writer_Identity_Stable (Writer.Writer_Id, Record.Writer_Id) then
         return WORM_ERR_WRITER_MISMATCH;
      end if;

      if not Invariant_Policy_Strengthen_Only (Writer.Previous_Hash, Record.Policy_Hash) then
         return WORM_ERR_POLICY_ROLLBACK;
      end if;

      if not Invariant_Signature_Authentic (Record.Signature, Record.Writer_Id) then
         return WORM_ERR_INVALID_SIGNATURE;
      end if;

      if not Invariant_Payload_Integrity (Record.Payload_Hash) then
         return WORM_ERR_INVARIANT_VIOLATED;
      end if;

      return WORM_OK;
   end Validate_Record;

   procedure Append_Local
      (Writer : in out Writer_Type;
       Record : in Record_Type;
       Result : out Error_Code) is
   begin
      Result := Validate_Record (Writer, Record);

      if Result = WORM_OK then
         Writer.Sequence := Record.Sequence;
         Writer.Timestamp := Record.Timestamp;
         Writer.State := SEALED;
      end if;
   end Append_Local;

   function Query_Sequence (Writer : Writer_Type) return Sequence is
   begin
      return Writer.Sequence;
   end Query_Sequence;

   function Query_Previous_Hash (Writer : Writer_Type) return Hash256 is
   begin
      return Writer.Previous_Hash;
   end Query_Previous_Hash;

end Worm_Control;
