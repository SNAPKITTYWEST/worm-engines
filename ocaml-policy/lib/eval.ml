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

let rec eval_predicate pred rec =
  match pred with
  | Policy.Sequence_gte n -> rec.sequence >= n
  | Policy.Timestamp_lt t -> rec.timestamp < t
  | Policy.Writer_eq w -> String.equal rec.writer_id w
  | Policy.And (p1, p2) -> eval_predicate p1 rec && eval_predicate p2 rec
  | Policy.Or (p1, p2) -> eval_predicate p1 rec || eval_predicate p2 rec
  | Policy.Not p -> not (eval_predicate p rec)

let all_matches policy record =
  let matching_rules = List.filter (fun rule ->
    eval_predicate rule.Policy.predicate record
  ) policy in
  let action = match matching_rules with
    | [] -> None
    | rule :: _ -> Some rule.Policy.action
  in
  {
    matched = List.length matching_rules > 0;
    action = action;
    matched_rules = matching_rules;
  }

let evaluate_in_order rules record =
  let rec find_first_match = function
    | [] -> None
    | rule :: rest ->
        if eval_predicate rule.Policy.predicate record then
          Some rule.Policy.action
        else
          find_first_match rest
  in
  find_first_match rules

let run bytecode record =
  evaluate_in_order bytecode.Policy.rules record
