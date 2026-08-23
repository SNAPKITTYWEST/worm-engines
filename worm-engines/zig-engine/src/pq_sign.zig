// pq_sign.zig — Post-quantum signing interface for LOCKER
//
// Drop-in replacement for ed25519.zig using ML-DSA-44 (FIPS 204).
// All callers that previously used Ed25519 [64]u8 signatures now use
// ML-DSA-44 [2420]u8 signatures and [1312]u8 public keys.
//
// Migration note:
//   Old: writer_id = [32]u8 Ed25519 public key (doubled as identity)
//   New: writer_id = [32]u8 identity hash (H(ml_dsa_public_key))
//        signing done against a separate [1312]u8 ML-DSA public key
//        stored in the keystore (keystore.zig)

const std = @import("std");
const ml = @import("ml_dsa.zig");
const WormRecord = @import("record.zig").WormRecord;
const hash_mod = @import("hash.zig");

pub const PrivateKey = ml.PrivateKey;
pub const PublicKey = ml.PublicKey;
pub const Signature = ml.Signature;

pub const SIG_LEN = ml.SIG_LEN;
pub const PK_LEN = ml.PK_LEN;
pub const SK_LEN = ml.SK_LEN;

pub const Error = ml.Error;

/// Generate a new ML-DSA-44 keypair from OS randomness.
pub fn generateKeypair() !struct { private: PrivateKey, public: PublicKey } {
    return ml.generateKeypair();
}

/// Derive a 32-byte writer identity from an ML-DSA public key.
/// writer_id = SHA-256(public_key || "LOCKER-WRITER-ID-v1")
pub fn deriveWriterId(public_key: *const PublicKey) [32]u8 {
    var hash: [32]u8 = undefined;
    var h = std.crypto.hash.sha2.Sha256.init(.{});
    h.update(public_key);
    h.update("LOCKER-WRITER-ID-v1");
    h.final(&hash);
    return hash;
}

/// Sign a WormRecord. The signature is computed over the canonical
/// 180-byte hash domain (same domain as Ed25519 used).
pub fn signRecord(record: *WormRecord, private_key: *const PrivateKey) Error!void {
    const domain = hash_mod.buildHashDomain(record);
    const sig = try ml.signMsg(&domain, private_key);
    record.setSignature(sig);
}

/// Verify a WormRecord's ML-DSA signature against its canonical hash domain.
pub fn verifySignature(record: *const WormRecord, public_key: *const PublicKey) Error!void {
    const domain = hash_mod.buildHashDomain(record);
    try ml.verifyMsg(&record.signature, &domain, public_key);
}

test "pq_sign round-trip on WormRecord" {
    const testing = std.testing;
    const kp = try generateKeypair();
    const writer_id = deriveWriterId(&kp.public);

    var record = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        writer_id,
    );

    try signRecord(&record, &kp.private);
    try verifySignature(&record, &kp.public);
}

test "pq_sign rejects tampered record" {
    const testing = std.testing;
    const kp = try generateKeypair();
    const writer_id = deriveWriterId(&kp.public);

    var record = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        writer_id,
    );

    try signRecord(&record, &kp.private);

    // Tamper with payload hash
    record.payload_hash[0] ^= 0xFF;

    const result = verifySignature(&record, &kp.public);
    try testing.expectError(Error.InvalidSignature, result);
}
