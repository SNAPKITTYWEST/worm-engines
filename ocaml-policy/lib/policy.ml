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

let action_from_string = function
  | "accept" -> Accept
  | "reject" -> Reject
  | "forward" -> Forward
  | "escalate" -> Escalate
  | s -> failwith ("Unknown action: " ^ s)

let string_of_action = function
  | Accept -> "accept"
  | Reject -> "reject"
  | Forward -> "forward"
  | Escalate -> "escalate"

let rec string_of_predicate = function
  | Sequence_gte n -> Printf.sprintf "sequence_gte(%Ld)" n
  | Timestamp_lt t -> Printf.sprintf "timestamp_lt(%Ld)" t
  | Writer_eq w -> Printf.sprintf "writer_eq(%s)" w
  | And (p1, p2) -> Printf.sprintf "(%s AND %s)" 
      (string_of_predicate p1) (string_of_predicate p2)
  | Or (p1, p2) -> Printf.sprintf "(%s OR %s)" 
      (string_of_predicate p1) (string_of_predicate p2)
  | Not p -> Printf.sprintf "NOT(%s)" (string_of_predicate p)

let rec predicate_from_string str =
  let str = String.trim str in
  if String.length str > 0 && str.[0] = '(' then
    let inner = String.sub str 1 (String.length str - 2) in
    if String.contains inner '|' then
      let parts = String.split_on_char '|' inner in
      match parts with
      | [p1; p2] -> Or (predicate_from_string (String.trim p1), 
                       predicate_from_string (String.trim p2))
      | _ -> failwith "Invalid OR predicate"
    else if String.contains inner '&' then
      let parts = String.split_on_char '&' inner in
      match parts with
      | [p1; p2] -> And (predicate_from_string (String.trim p1), 
                        predicate_from_string (String.trim p2))
      | _ -> failwith "Invalid AND predicate"
    else
      failwith "Invalid predicate"
  else if String.starts_with ~prefix:"NOT(" str then
    let inner = String.sub str 4 (String.length str - 5) in
    Not (predicate_from_string inner)
  else if String.starts_with ~prefix:"sequence_gte(" str then
    let start = 13 in
    let end_pos = String.length str - 1 in
    let num_str = String.sub str start (end_pos - start) in
    Sequence_gte (Int64.of_string num_str)
  else if String.starts_with ~prefix:"timestamp_lt(" str then
    let start = 13 in
    let end_pos = String.length str - 1 in
    let num_str = String.sub str start (end_pos - start) in
    Timestamp_lt (Int64.of_string num_str)
  else if String.starts_with ~prefix:"writer_eq(" str then
    let start = 10 in
    let end_pos = String.length str - 1 in
    let writer = String.sub str start (end_pos - start) in
    Writer_eq writer
  else
    failwith ("Unknown predicate: " ^ str)

let rule_from_string str =
  let parts = String.split_on_char ':' str in
  match parts with
  | [id; pred_str; action_str; prio_str; desc] ->
      {
        id = String.trim id;
        predicate = predicate_from_string (String.trim pred_str);
        action = action_from_string (String.trim action_str);
        priority = int_of_string (String.trim prio_str);
        description = String.trim desc;
      }
  | _ -> failwith ("Invalid rule format: " ^ str)

let string_of_rule r =
  Printf.sprintf "%s:%s:%s:%d:%s"
    r.id
    (string_of_predicate r.predicate)
    (string_of_action r.action)
    r.priority
    r.description

let priority_sort rules =
  List.sort (fun r1 r2 -> Int.compare r2.priority r1.priority) rules

let compile str =
  let lines = String.split_on_char '\n' str in
  let lines = List.map String.trim lines in
  let lines = List.filter (fun s -> String.length s > 0) lines in
  let rules = List.map rule_from_string lines in
  priority_sort rules

let to_bytecode policy =
  let rules = priority_sort policy in
  {
    rules = rules;
    rule_count = List.length rules;
  }

let string_of_policy policy =
  let rules_str = List.map string_of_rule policy in
  String.concat "\n" rules_str
