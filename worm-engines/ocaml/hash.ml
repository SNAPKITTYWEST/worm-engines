(* WORM Engines OCaml SHA-256 Hash Module
   Deterministic SHA-256 matching Zig hash.zig byte-for-byte.
   Used for 4-language cross-determinism verification in v0.3.0.
*)

open Stdint

(* SHA-256 constants (NIST FIPS 180-4) *)
let k = [|
  0x428a2f98l; 0x71374491l; 0xb5c0fbcfl; 0xe9b5dba5l; 0x3956c25bl; 0x59f111f1l; 0x923f82a4l; 0xab1c5ed5l;
  0xd807aa98l; 0x12835b01l; 0x243185bel; 0x550c7dc3l; 0x72be5d74l; 0x80deb1fel; 0x9bdc06a7l; 0xc19bf174l;
  0xe49b69c1l; 0xefbe4786l; 0x0fc19dc6l; 0x240ca1ccl; 0x2de92c6fl; 0x4a7484aal; 0x5cb0a9dcl; 0x76f988dal;
  0x983e5152l; 0xa831c66dl; 0xb00327c8l; 0xbf597fc7l; 0xc6e00bf3l; 0xd5a79147l; 0x06ca6351l; 0x14292967l;
  0x27b70a85l; 0x2e1b2138l; 0x4d2c6dfcl; 0x53380d13l; 0x650a7354l; 0x766a0abbl; 0x81c2c92el; 0x92722c85l;
  0xa2bfe8a1l; 0xa81a664bl; 0xc24b8b70l; 0xc76c51a3l; 0xd192e819l; 0xd6990624l; 0xf40e3585l; 0x106aa070l;
  0x19a4c116l; 0x1e376c08l; 0x2748774cl; 0x34b0bcb5l; 0x391c0cb3l; 0x4ed8aa4al; 0x5b9cca4fl; 0x682e6ff3l;
  0x748f82eel; 0x78a5636fl; 0x84c87814l; 0x8cc70208l; 0x90befffal; 0xa4506cebl; 0xbef9a3f7l; 0xc67178f2l;
|]

(* Initial hash values *)
let h0 = 0x6a09e667l
let h1 = 0xbb67ae85l
let h2 = 0x3c6ef372l
let h3 = 0xa54ff53al
let h4 = 0x510e527fl
let h5 = 0x9b05688cl
let h6 = 0x1f83d9abl
let h7 = 0x5be0cd19l

(* Bitwise operations *)
let rotr n x =
  Int32.logor (Int32.shift_right_logical x n) (Int32.shift_left x (32 - n))

let shr n x = Int32.shift_right_logical x n

let ch x y z = Int32.logxor (Int32.logand x y) (Int32.logand (Int32.lognot x) z)

let maj x y z = Int32.logxor (Int32.logxor (Int32.logand x y) (Int32.logand x z)) (Int32.logand y z)

let sigma0 x = Int32.logxor (Int32.logxor (rotr 2 x) (rotr 13 x)) (rotr 22 x)

let sigma1 x = Int32.logxor (Int32.logxor (rotr 6 x) (rotr 11 x)) (rotr 25 x)

let gamma0 x = Int32.logxor (Int32.logxor (rotr 7 x) (rotr 18 x)) (shr 3 x)

let gamma1 x = Int32.logxor (Int32.logxor (rotr 17 x) (rotr 19 x)) (shr 10 x)

(* Process a single 512-bit block *)
let process_block state block =
  let (h0, h1, h2, h3, h4, h5, h6, h7) = state in
  let w = Array.make 64 0l in

  (* Prepare message schedule *)
  for i = 0 to 15 do
    let offset = i * 4 in
    let b0 = Int32.of_int (Char.code block.{offset}) in
    let b1 = Int32.of_int (Char.code block.{offset + 1}) in
    let b2 = Int32.of_int (Char.code block.{offset + 2}) in
    let b3 = Int32.of_int (Char.code block.{offset + 3}) in
    w.(i) <- Int32.logor (Int32.logor (Int32.shift_left b0 24) (Int32.shift_left b1 16))
                         (Int32.logor (Int32.shift_left b2 8) b3)
  done;

  for i = 16 to 63 do
    w.(i) <- Int32.add (Int32.add (gamma1 w.(i - 2)) w.(i - 7))
                       (Int32.add (gamma0 w.(i - 15)) w.(i - 16))
  done;

  (* Main loop *)
  let mutable a = h0 in
  let mutable b = h1 in
  let mutable c = h2 in
  let mutable d = h3 in
  let mutable e = h4 in
  let mutable f = h5 in
  let mutable g = h6 in
  let mutable h = h7 in

  for i = 0 to 63 do
    let t1 = Int32.add (Int32.add (Int32.add (Int32.add h (sigma1 e)) (ch e f g)) k.(i)) w.(i) in
    let t2 = Int32.add (sigma0 a) (maj a b c) in
    h := g;
    g := f;
    f := e;
    e := Int32.add d t1;
    d := c;
    c := b;
    b := a;
    a := Int32.add t1 t2;
  done;

  (Int32.add h0 a, Int32.add h1 b, Int32.add h2 c, Int32.add h3 d,
   Int32.add h4 e, Int32.add h5 f, Int32.add h6 g, Int32.add h7 h)

(* SHA-256 main function *)
let sha256 data =
  let len = Bytes.length data in
  let len_bits = Int64.mul (Int64.of_int len) 8L in

  (* Padding *)
  let pad_len = (55 - (len mod 64)) mod 64 in
  let padded = Bytes.create (len + pad_len + 9) in
  Bytes.blit data 0 padded 0 len;
  padded.{len} <- '\x80';
  for i = 0 to pad_len - 1 do
    padded.{len + 1 + i} <- '\x00'
  done;

  (* Length in bits (big-endian) *)
  let offset = len + pad_len + 1 in
  for i = 0 to 7 do
    padded.{offset + i} <- Char.chr (Int64.to_int (Int64.shift_right_logical len_bits (56 - i * 8)) land 0xff)
  done;

  (* Process blocks *)
  let mutable state = (h0, h1, h2, h3, h4, h5, h6, h7) in
  for i = 0 to (Bytes.length padded / 64) - 1 do
    let block = Bytes.sub padded (i * 64) 64 in
    state := process_block state block
  done;

  let (a, b, c, d, e, f, g, h) = state in
  let result = Bytes.create 32 in
  let hashes = [| a; b; c; d; e; f; g; h |] in
  Array.iteri (fun i hash ->
    let offset = i * 4 in
    result.{offset} <- Char.chr (Int32.to_int (Int32.shift_right_logical hash 24) land 0xff);
    result.{offset + 1} <- Char.chr (Int32.to_int (Int32.shift_right_logical hash 16) land 0xff);
    result.{offset + 2} <- Char.chr (Int32.to_int (Int32.shift_right_logical hash 8) land 0xff);
    result.{offset + 3} <- Char.chr (Int32.to_int hash land 0xff)
  ) hashes;
  result

(* Hex string for debugging *)
let to_hex data =
  let buf = Buffer.create (Bytes.length data * 2) in
  Bytes.iter (fun c ->
    Buffer.add_string buf (Printf.sprintf "%02x" (Char.code c))
  ) data;
  Buffer.contents buf
