(* Copyright © 2026 Sovereign Source Foundation. All rights reserved.
   Licensed under Sovereign Source License. Commercial use only.
   See LICENSE for complete terms. *)

type predicate =
  | Sequence_gte of int64
  | Timestamp_lt of int64
  | Writer_eq of string
  | And of predicate * predicate
  | Or of predicate * predicate
  | Not of predicate

type action =
  | Accept
  | Reject
  | Forward
  | Escalate

type rule = {
  id: string;
  predicate: predicate;
  action: action;
  priority: int;
  description: string;
}

type policy = rule list

type bytecode = {
  rules: rule list;
  rule_count: int;
}

val compile : string -> policy
val to_bytecode : policy -> bytecode
val priority_sort : rule list -> rule list
val rule_from_string : string -> rule
val predicate_from_string : string -> predicate
val action_from_string : string -> action
val string_of_predicate : predicate -> string
val string_of_action : action -> string
val string_of_rule : rule -> string
val string_of_policy : policy -> string
