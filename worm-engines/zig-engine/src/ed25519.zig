// Ed25519: Deterministic Ed25519 signing and verification
// Uses Zig stdlib crypto for Ed25519 operations

const std = @import("std");
const hash = @import("hash.zig");
const WormRecord = @import("record.zig").WormRecord;

pub const PrivateKey = [32]u8;
pub const PublicKey = [32]u8;
pub const Signature = [64]u8;

pub const Error = error{
    InvalidSignature,
    InvalidKey,
};

/// Sign a WormRecord using Ed25519
/// The signature is computed over the hash domain (180 bytes)
pub fn signRecord(record: *WormRecord, private_key: PrivateKey) !void {
    const domain = hash.buildHashDomain(record);

    // Derive keypair from private key (seed)
    const key_pair = try std.crypto.sign.Ed25519.KeyPair.create(private_key);

    // Sign the hash domain
    const sig = try key_pair.sign(&domain, null);

    record.setSignature(sig.toBytes());
}

/// Verify a WormRecord's signature
pub fn verifySignature(record: *const WormRecord, public_key: PublicKey) !void {
    const domain = hash.buildHashDomain(record);

    // Parse signature
    const sig = std.crypto.sign.Ed25519.Signature.fromBytes(record.signature);

    // Parse public key
    const pub_key = try std.crypto.sign.Ed25519.PublicKey.fromBytes(public_key);

    // Verify
    try sig.verify(&domain, pub_key);
}

/// Generate a new Ed25519 keypair
pub fn generateKeypair() !struct { private: PrivateKey, public: PublicKey } {
    var seed: [32]u8 = undefined;
    std.crypto.random.bytes(&seed);

    const key_pair = try std.crypto.sign.Ed25519.KeyPair.create(seed);
    const public_bytes = key_pair.public_key.bytes;

    return .{
        .private = seed,
        .public = public_bytes,
    };
}

test "ed25519 sign and verify" {
    const testing = std.testing;

    // Generate keypair
    const keypair = try generateKeypair();

    // Create a test record
    var record = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        keypair.public,
    );

    // Sign the record
    try signRecord(&record, keypair.private);

    // Verify the signature
    try verifySignature(&record, keypair.public);
}

test "ed25519 verify fails with wrong key" {
    const testing = std.testing;

    // Generate two keypairs
    const keypair1 = try generateKeypair();
    const keypair2 = try generateKeypair();

    // Create and sign with keypair1
    var record = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        keypair1.public,
    );

    try signRecord(&record, keypair1.private);

    // Verify with keypair2 should fail
    const result = verifySignature(&record, keypair2.public);
    try testing.expectError(error.SignatureVerificationFailed, result);
}

test "ed25519 deterministic signing" {
    const testing = std.testing;

    const keypair = try generateKeypair();

    var record1 = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        keypair.public,
    );

    var record2 = record1;

    // Sign both records with the same key
    try signRecord(&record1, keypair.private);
    try signRecord(&record2, keypair.private);

    // Signatures should be identical (deterministic)
    try testing.expectEqualSlices(u8, &record1.signature, &record2.signature);
}
