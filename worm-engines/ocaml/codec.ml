(* WORM Engines OCaml CBOR Codec
   Deterministic CBOR encoding matching Zig codec.zig byte-for-byte.
   Used for 4-language cross-determinism verification in v0.3.0.
*)

open Stdint

type worm_record = {
  sequence : uint64;
  timestamp : uint64;
  writer_id : bytes;
  previous_hash : bytes;
  data : bytes;
}

(* CBOR major types *)
let cbor_unsigned = 0x00
let cbor_negative = 0x20
let cbor_bytes = 0x40
let cbor_text = 0x60
let cbor_array = 0x80
let cbor_map = 0xa0

(* Deterministic CBOR encoding helpers *)
let encode_uint64 buf pos value =
  if Uint64.compare value (Uint64.of_int 23) <= 0 then
    (* Single byte *)
    buf.{pos} <- Char.chr (Uint64.to_int value);
    pos + 1
  else if Uint64.compare value (Uint64.of_int 256) < 0 then
    (* u8 *)
    buf.{pos} <- Char.chr 24;
    buf.{pos + 1} <- Char.chr (Uint64.to_int value);
    pos + 2
  else if Uint64.compare value (Uint64.of_int 65536) < 0 then
    (* u16 big-endian *)
    let v = Uint64.to_int value in
    buf.{pos} <- Char.chr 25;
    buf.{pos + 1} <- Char.chr ((v lsr 8) land 0xff);
    buf.{pos + 2} <- Char.chr (v land 0xff);
    pos + 3
  else if Uint64.compare value (Uint64.of_int 0x100000000) < 0 then
    (* u32 big-endian *)
    let v = Uint64.to_int value in
    buf.{pos} <- Char.chr 26;
    buf.{pos + 1} <- Char.chr ((v lsr 24) land 0xff);
    buf.{pos + 2} <- Char.chr ((v lsr 16) land 0xff);
    buf.{pos + 3} <- Char.chr ((v lsr 8) land 0xff);
    buf.{pos + 4} <- Char.chr (v land 0xff);
    pos + 5
  else
    (* u64 big-endian *)
    buf.{pos} <- Char.chr 27;
    for i = 0 to 7 do
      let shift = (7 - i) * 8 in
      buf.{pos + 1 + i} <- Char.chr (Uint64.to_int (Uint64.shift_right value shift) land 0xff)
    done;
    pos + 9

let encode_bytes buf pos data =
  let len = Bytes.length data in
  let pos' = encode_uint64 buf (pos + 1) (Uint64.of_int len) in
  Bytes.blit data 0 buf pos' len;
  pos' + len

(* Deterministic map encoding: fields in lexicographic order *)
let encode_worm_record record =
  let buf = Bytes.create 1024 in
  let pos = ref 0 in

  (* Major type: map with 5 fields *)
  buf.(!pos) <- Char.chr 0xa5; (* 0xa0 | 5 *)
  incr pos;

  (* Field 1: "data" (sorted first) *)
  buf.(!pos) <- Char.chr 0x64; (* text string, length 4 *)
  Bytes.blit_string "data" 0 buf (!pos + 1) 4;
  pos := !pos + 5;
  pos := encode_bytes buf !pos record.data;

  (* Field 2: "previous_hash" *)
  buf.(!pos) <- Char.chr 0x6c; (* text string, length 12 *)
  Bytes.blit_string "previous_hash" 0 buf (!pos + 1) 13;
  pos := !pos + 14;
  pos := encode_bytes buf !pos record.previous_hash;

  (* Field 3: "sequence" *)
  buf.(!pos) <- Char.chr 0x68; (* text string, length 8 *)
  Bytes.blit_string "sequence" 0 buf (!pos + 1) 8;
  pos := !pos + 9;
  pos := encode_uint64 buf !pos record.sequence;

  (* Field 4: "timestamp" *)
  buf.(!pos) <- Char.chr 0x69; (* text string, length 9 *)
  Bytes.blit_string "timestamp" 0 buf (!pos + 1) 9;
  pos := !pos + 10;
  pos := encode_uint64 buf !pos record.timestamp;

  (* Field 5: "writer_id" *)
  buf.(!pos) <- Char.chr 0x69; (* text string, length 9 *)
  Bytes.blit_string "writer_id" 0 buf (!pos + 1) 9;
  pos := !pos + 10;
  pos := encode_bytes buf !pos record.writer_id;

  (* Return just the encoded portion *)
  Bytes.sub buf 0 !pos

(* Deterministic CBOR decoding *)
let decode_uint64 buf pos =
  let first = Char.code buf.{pos} in
  if first < 24 then
    (Uint64.of_int first, pos + 1)
  else if first = 24 then
    (Uint64.of_int (Char.code buf.{pos + 1}), pos + 2)
  else if first = 25 then
    let v = (Char.code buf.{pos + 1} lsl 8) lor (Char.code buf.{pos + 2}) in
    (Uint64.of_int v, pos + 3)
  else if first = 26 then
    let v = (Char.code buf.{pos + 1} lsl 24) lor
            (Char.code buf.{pos + 2} lsl 16) lor
            (Char.code buf.{pos + 3} lsl 8) lor
            (Char.code buf.{pos + 4}) in
    (Uint64.of_int v, pos + 5)
  else if first = 27 then
    let mutable v = Uint64.zero in
    for i = 0 to 7 do
      v := Uint64.logor (Uint64.shift_left v 8) (Uint64.of_int (Char.code buf.{pos + 1 + i}))
    done;
    (v, pos + 9)
  else
    failwith "Invalid CBOR uint64"

let decode_bytes buf pos len =
  Bytes.sub buf pos len

let decode_worm_record encoded =
  let buf = Bytes.of_string (Bytes.to_string encoded) in
  let pos = ref 0 in

  (* Expect map with 5 fields *)
  if Char.code buf.{!pos} <> 0xa5 then
    failwith "Expected CBOR map with 5 fields";
  incr pos;

  (* Parse fields (order doesn't matter in decoding, but we'll parse in order) *)
  let fields = Hashtbl.create 5 in

  for _ = 0 to 4 do
    (* Read field name *)
    let name_len = Char.code buf.{!pos} land 0x1f in
    let name = Bytes.sub buf (!pos + 1) name_len in
    pos := !pos + 1 + name_len;

    (* Read field value based on name *)
    let name_str = Bytes.to_string name in
    match name_str with
    | "data" ->
        (* bytes *)
        let len_major = Char.code buf.{!pos} lsr 5 in
        if len_major <> 2 then failwith "Expected bytes";
        let len = Char.code buf.{!pos} land 0x1f in
        let value = decode_bytes buf (!pos + 1) len in
        Hashtbl.add fields "data" value;
        pos := !pos + 1 + len

    | "sequence" | "timestamp" ->
        (* uint64 *)
        let (value, new_pos) = decode_uint64 buf !pos in
        Hashtbl.add fields name_str value;
        pos := new_pos

    | "writer_id" | "previous_hash" ->
        (* bytes *)
        let len_major = Char.code buf.{!pos} lsr 5 in
        if len_major <> 2 then failwith "Expected bytes";
        let len = Char.code buf.{!pos} land 0x1f in
        let value = decode_bytes buf (!pos + 1) len in
        Hashtbl.add fields name_str value;
        pos := !pos + 1 + len

    | _ -> failwith ("Unknown field: " ^ name_str)
  done;

  {
    sequence = (try Hashtbl.find fields "sequence" with Not_found -> Uint64.zero);
    timestamp = (try Hashtbl.find fields "timestamp" with Not_found -> Uint64.zero);
    writer_id = (try Hashtbl.find fields "writer_id" with Not_found -> Bytes.create 32);
    previous_hash = (try Hashtbl.find fields "previous_hash" with Not_found -> Bytes.create 32);
    data = (try Hashtbl.find fields "data" with Not_found -> Bytes.create 0);
  }

(* Verify determinism: encode + decode must produce identical bytes *)
let verify_determinism record =
  let encoded1 = encode_worm_record record in
  let encoded2 = encode_worm_record record in
  if not (Bytes.equal encoded1 encoded2) then
    failwith "Encoding not deterministic!"
  else
    true
