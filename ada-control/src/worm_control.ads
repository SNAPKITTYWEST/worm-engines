-- Copyright © 2026 Sovereign Source Foundation. All rights reserved.
-- Licensed under Sovereign Source License. Commercial use only.
-- See LICENSE for complete terms.

pragma Ada_2012;
pragma SPARK_Mode (On);

with Invariants;
use Invariants;

package Worm_Control is

   type Error_Code is new Ada.Types.Integer_32;

   WORM_OK                          : constant Error_Code := 0;
   WORM_ERR_INVALID_WRITER          : constant Error_Code := -1;
   WORM_ERR_INVALID_RECORD          : constant Error_Code := -2;
   WORM_ERR_SEQUENCE_MISMATCH       : constant Error_Code := -5;
   WORM_ERR_TIMESTAMP_INVALID       : constant Error_Code := -6;
   WORM_ERR_HASH_CHAIN_BROKEN       : constant Error_Code := -7;
   WORM_ERR_IMMUTABLE_VIOLATION     : constant Error_Code := -8;
   WORM_ERR_WRITER_MISMATCH         : constant Error_Code := -9;
   WORM_ERR_POLICY_ROLLBACK         : constant Error_Code := -10;
   WORM_ERR_INVALID_SIGNATURE       : constant Error_Code := -4;
   WORM_ERR_INVARIANT_VIOLATED      : constant Error_Code := -15;

   function Init_Writer (Writer_Id : PublicKey) return Writer_Type
   with Pure_Function, Global => null,
      Post => (Init_Writer'Result.Writer_Id = Writer_Id
         and Init_Writer'Result.State = UNINITIALIZED);

   function Create_Record (Writer : Writer_Type; Payload_Hash : Hash256)
      return Record_Type
   with Pure_Function, Global => null,
      Pre => (Writer.State = UNINITIALIZED or Writer.State = GENESIS),
      Post => (Create_Record'Result.Sequence = Writer.Sequence + 1
         and Create_Record'Result.Writer_Id = Writer.Writer_Id);

   function Validate_Record (Writer : Writer_Type; Record : Record_Type)
      return Error_Code
   with Pure_Function, Global => null,
      Post => (Validate_Record'Result in
         WORM_OK | WORM_ERR_SEQUENCE_MISMATCH | WORM_ERR_TIMESTAMP_INVALID |
         WORM_ERR_HASH_CHAIN_BROKEN | WORM_ERR_IMMUTABLE_VIOLATION |
         WORM_ERR_WRITER_MISMATCH | WORM_ERR_POLICY_ROLLBACK |
         WORM_ERR_INVALID_SIGNATURE);

   procedure Append_Local
      (Writer : in out Writer_Type;
       Record : in Record_Type;
       Result : out Error_Code)
   with Global => null,
      Pre => (Record.Sequence = Writer.Sequence + 1
         and Record.Writer_Id = Writer.Writer_Id),
      Post => (if Result = WORM_OK then
         Writer.Sequence = Record.Sequence and Writer.State = SEALED);

   function Query_Sequence (Writer : Writer_Type) return Sequence
   with Pure_Function, Global => null;

   function Query_Previous_Hash (Writer : Writer_Type) return Hash256
   with Pure_Function, Global => null;

end Worm_Control;
