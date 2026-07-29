(* Copyright © 2026 Sovereign Source Foundation. All rights reserved.
   Licensed under Sovereign Source License. Commercial use only.
   See LICENSE for complete terms. *)

let usage_msg = "worm-policy - WORM Policy Compiler and Evaluator"

let compile_mode = ref false
let eval_mode = ref false
let input_file = ref ""
let record_str = ref ""

let () =
  Arg.parse
    [("--compile", Arg.Set compile_mode, "Compile policy to bytecode");
     ("--eval", Arg.Set eval_mode, "Evaluate policy against record");
     ("--input", Arg.Set_string input_file, "Input policy file");
     ("--record", Arg.Set_string record_str, "Record for evaluation")]
    (fun s -> input_file := s)
    usage_msg;
  
  if !compile_mode then begin
    if String.length !input_file = 0 then (
      Printf.printf "Error: --input required for compile mode\n";
      exit 1
    );
    let ic = open_in !input_file in
    let policy_str = really_input_string ic (in_channel_length ic) in
    close_in ic;
    let policy = Worm_policy.Policy.compile policy_str in
    Printf.printf "Compiled %d rules\n" (List.length policy);
    List.iter (fun rule ->
      Printf.printf "Rule: %s (priority=%d)\n" 
        rule.Worm_policy.Policy.id rule.Worm_policy.Policy.priority
    ) policy;
  end
  else if !eval_mode then begin
    if String.length !input_file = 0 then (
      Printf.printf "Error: --input required for eval mode\n";
      exit 1
    );
    if String.length !record_str = 0 then (
      Printf.printf "Error: --record required for eval mode\n";
      exit 1
    );
    let ic = open_in !input_file in
    let policy_str = really_input_string ic (in_channel_length ic) in
    close_in ic;
    let policy = Worm_policy.Policy.compile policy_str in
    let bytecode = Worm_policy.Policy.to_bytecode policy in
    
    let parts = String.split_on_char ',' !record_str in
    let seq = Int64.of_string (List.nth parts 0) in
    let ts = Int64.of_string (List.nth parts 1) in
    let writer = List.nth parts 2 in
    let record = { Worm_policy.Eval.sequence = seq; timestamp = ts; writer_id = writer } in
    
    let result = Worm_policy.Eval.run bytecode record in
    (match result with
     | Some action -> Printf.printf "Action: %s\n" (Worm_policy.Policy.string_of_action action)
     | None -> Printf.printf "No matching rule\n")
  end
  else begin
    Printf.printf "%s\n" usage_msg;
    exit 1
  end
