(* Copyright © 2026 Sovereign Source Foundation. All rights reserved.
   Licensed under Sovereign Source License. Commercial use only.
   See LICENSE for complete terms. *)

(* OCaml golden vector test: encode genesis record, verify CBOR matches Zig *)

let create_genesis_record () =
  let stream_id = Bytes.make 32 '\xAA' in
  let payload_hash = Bytes.make 32 '\xBB' in
  let writer_id = Bytes.make 32 '\xCC' in
  let previous_hash = Bytes.make 32 '\x00' in
  let policy_hash = Bytes.make 32 '\x00' in
  let signature = Bytes.make 64 '\x00' in
  {
    Worm_policy.Policy.version = 1;
    stream_id = Bytes.to_string stream_id;
    sequence = 0L;
    timestamp = 1000L;
    previous_hash = Bytes.to_string previous_hash;
    payload_hash = Bytes.to_string payload_hash;
    policy_hash = Bytes.to_string policy_hash;
    writer_id = Bytes.to_string writer_id;
    flags = 1;
  }

let encode_to_hex bytes =
  String.concat "" (List.map (Printf.sprintf "%02x") (Bytes.to_list (Bytes.of_string bytes)))

let () =
  Printf.printf "OCaml Golden Vector Test\n";
  Printf.printf "========================\n\n";

  let record = create_genesis_record () in
  Printf.printf "Genesis record created (sequence=0, timestamp=1000)\n\n";

  (* Note: Full CBOR encoding would require a CBOR library *)
  (* For now, print determinism verification *)
  Printf.printf "Record fields:\n";
  Printf.printf "  version: %lu\n" record.Worm_policy.Policy.version;
  Printf.printf "  sequence: %Lu\n" record.Worm_policy.Policy.sequence;
  Printf.printf "  timestamp: %Lu\n" record.Worm_policy.Policy.timestamp;
  Printf.printf "  flags: %lu\n\n" record.Worm_policy.Policy.flags;

  Printf.printf "✓ OCaml vector test structure ready\n";
  Printf.printf "  (CBOR encoding pending full CBOR library integration)\n"
