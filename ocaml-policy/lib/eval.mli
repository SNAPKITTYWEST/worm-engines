(* Copyright © 2026 Sovereign Source Foundation. All rights reserved.
   Licensed under Sovereign Source License. Commercial use only.
   See LICENSE for complete terms. *)

type record = {
  sequence: int64;
  timestamp: int64;
  writer_id: string;
}

type evaluation_result = {
  matched: bool;
  action: Policy.action option;
  matched_rules: Policy.rule list;
}

val run : Policy.bytecode -> record -> Policy.action option
val eval_predicate : Policy.predicate -> record -> bool
val all_matches : Policy.policy -> record -> evaluation_result
val evaluate_in_order : Policy.rule list -> record -> Policy.action option
