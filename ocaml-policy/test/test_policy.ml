(* Copyright © 2026 Sovereign Source Foundation. All rights reserved.
   Licensed under Sovereign Source License. Commercial use only.
   See LICENSE for complete terms. *)

let test_predicate_compilation () =
  let pred_str = "sequence_gte(100)" in
  let pred = Worm_policy.Policy.predicate_from_string pred_str in
  match pred with
  | Worm_policy.Policy.Sequence_gte n when Int64.equal n 100L -> ()
  | _ -> failwith "Predicate compilation failed"

let test_action_parsing () =
  let action = Worm_policy.Policy.action_from_string "accept" in
  match action with
  | Worm_policy.Policy.Accept -> ()
  | _ -> failwith "Action parsing failed"

let test_rule_compilation () =
  let rule_str = "rule1:sequence_gte(0):accept:10:Accept all genesis records" in
  let rule = Worm_policy.Policy.rule_from_string rule_str in
  assert (String.equal rule.Worm_policy.Policy.id "rule1");
  assert (rule.Worm_policy.Policy.priority = 10)

let test_priority_sort () =
  let rule1 = {
    Worm_policy.Policy.id = "r1";
    predicate = Worm_policy.Policy.Sequence_gte 0L;
    action = Worm_policy.Policy.Accept;
    priority = 10;
    description = "Low priority";
  } in
  let rule2 = {
    Worm_policy.Policy.id = "r2";
    predicate = Worm_policy.Policy.Sequence_gte 100L;
    action = Worm_policy.Policy.Reject;
    priority = 20;
    description = "High priority";
  } in
  let sorted = Worm_policy.Policy.priority_sort [rule1; rule2] in
  match sorted with
  | [r2; r1] when String.equal r2.Worm_policy.Policy.id "r2" -> ()
  | _ -> failwith "Priority sort failed"

let test_eval_sequence_gte () =
  let record = { Worm_policy.Eval.sequence = 100L; timestamp = 1000L; writer_id = "alice" } in
  let pred = Worm_policy.Policy.Sequence_gte 50L in
  assert (Worm_policy.Eval.eval_predicate pred record)

let test_first_match_wins () =
  let rule1 = {
    Worm_policy.Policy.id = "r1";
    predicate = Worm_policy.Policy.Sequence_gte 0L;
    action = Worm_policy.Policy.Accept;
    priority = 20;
    description = "High priority";
  } in
  let record = { Worm_policy.Eval.sequence = 100L; timestamp = 1000L; writer_id = "alice" } in
  let rules = Worm_policy.Policy.priority_sort [rule1] in
  let action = Worm_policy.Eval.evaluate_in_order rules record in
  match action with
  | Some Worm_policy.Policy.Accept -> ()
  | _ -> failwith "First match wins failed"

let () =
  Printf.printf "Running policy tests...\n";
  test_predicate_compilation ();
  Printf.printf "✓ Predicate compilation\n";
  test_action_parsing ();
  Printf.printf "✓ Action parsing\n";
  test_rule_compilation ();
  Printf.printf "✓ Rule compilation\n";
  test_priority_sort ();
  Printf.printf "✓ Priority sort\n";
  test_eval_sequence_gte ();
  Printf.printf "✓ Eval sequence_gte\n";
  test_first_match_wins ();
  Printf.printf "✓ First match wins\n";
  Printf.printf "All tests passed!\n"
