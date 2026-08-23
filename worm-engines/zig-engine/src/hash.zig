// Hash: SHA-256 domain hashing per spec
// Constructs deterministic 180-byte hash domain and computes SHA-256

const std = @import("std");
const WormRecord = @import("record.zig").WormRecord;

pub const DOMAIN_TAG: u32 = 0x574F524D; // "WORM" in ASCII
pub const HASH_DOMAIN_SIZE: usize = 180;

/// Construct the canonical 180-byte hash domain for a WormRecord
/// Layout: domain_tag(4) || version(4) || stream_id(32) || sequence(8) ||
///         previous_hash(32) || payload_hash(32) || policy_hash(32) ||
///         writer_id(32) || flags(4)
pub fn buildHashDomain(record: *const WormRecord) [HASH_DOMAIN_SIZE]u8 {
    var domain: [HASH_DOMAIN_SIZE]u8 = undefined;
    var offset: usize = 0;

    // Domain tag (4 bytes, big-endian)
    std.mem.writeInt(u32, domain[offset..][0..4], DOMAIN_TAG, .big);
    offset += 4;

    // Version (4 bytes, big-endian)
    std.mem.writeInt(u32, domain[offset..][0..4], record.version, .big);
    offset += 4;

    // Stream ID (32 bytes)
    @memcpy(domain[offset .. offset + 32], &record.stream_id);
    offset += 32;

    // Sequence (8 bytes, big-endian)
    std.mem.writeInt(u64, domain[offset..][0..8], record.sequence, .big);
    offset += 8;

    // Previous hash (32 bytes)
    @memcpy(domain[offset .. offset + 32], &record.previous_hash);
    offset += 32;

    // Payload hash (32 bytes)
    @memcpy(domain[offset .. offset + 32], &record.payload_hash);
    offset += 32;

    // Policy hash (32 bytes)
    @memcpy(domain[offset .. offset + 32], &record.policy_hash);
    offset += 32;

    // Writer ID (32 bytes)
    @memcpy(domain[offset .. offset + 32], &record.writer_id);
    offset += 32;

    // Flags (4 bytes, big-endian)
    std.mem.writeInt(u32, domain[offset..][0..4], record.flags, .big);
    offset += 4;

    std.debug.assert(offset == HASH_DOMAIN_SIZE);

    return domain;
}

/// Compute SHA-256 hash of a WormRecord using the canonical hash domain
pub fn hashRecord(record: *const WormRecord) [32]u8 {
    const domain = buildHashDomain(record);
    var hash: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(&domain, &hash, .{});
    return hash;
}

/// Hash a constants.Record by translating to WormRecord and hashing the canonical domain.
/// Used by storage.zig to update the manifest head_hash after each append.
pub fn hash_record(record: *const @import("constants.zig").Record) ![32]u8 {
    const worm = WormRecord{
        .version = record.version,
        .stream_id = record.stream_id,
        .sequence = record.sequence,
        .timestamp = record.timestamp,
        .previous_hash = record.previous_hash,
        .payload_hash = record.payload_hash,
        .policy_hash = record.policy_hash,
        .writer_id = record.writer_id,
        .receipt_id = record.receipt_id,
        .flags = record.flags,
        .signature = record.signature,
    };
    return hashRecord(&worm);
}

/// Hash raw CBOR bytes directly (used during recovery to rebuild the hash chain
/// from serialized frame payloads without decoding the full record).
pub fn hash_record_cbor(cbor_bytes: []const u8) ![32]u8 {
    var hash: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(cbor_bytes, &hash, .{});
    return hash;
}

/// Verify that a record's previous_hash matches the computed hash of the prior record
pub fn verifyHashChain(prev_record: *const WormRecord, curr_record: *const WormRecord) bool {
    const computed_hash = hashRecord(prev_record);
    return std.mem.eql(u8, &computed_hash, &curr_record.previous_hash);
}

test "hash domain construction" {
    const testing = std.testing;

    var record = WormRecord.genesis(
        [_]u8{0xf1} ** 32, // stream_id
        [_]u8{0xb0} ** 32, // payload_hash
        [_]u8{0xc0} ** 32, // policy_hash
        [_]u8{0xd0} ** 32, // writer_id
    );
    record.markCommitted();

    const domain = buildHashDomain(&record);

    // Verify domain tag
    const tag = std.mem.readInt(u32, domain[0..4], .big);
    try testing.expectEqual(DOMAIN_TAG, tag);

    // Verify version
    const version = std.mem.readInt(u32, domain[4..8], .big);
    try testing.expectEqual(@as(u32, 1), version);

    // Verify sequence (genesis = 0)
    const sequence = std.mem.readInt(u64, domain[40..48], .big);
    try testing.expectEqual(@as(u64, 0), sequence);

    // Verify total size
    try testing.expectEqual(HASH_DOMAIN_SIZE, domain.len);
}

test "hash determinism" {
    const testing = std.testing;

    var record = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
    );

    const hash1 = hashRecord(&record);
    const hash2 = hashRecord(&record);

    try testing.expectEqualSlices(u8, &hash1, &hash2);
}

test "hash chain verification" {
    const testing = std.testing;

    var genesis = WormRecord.genesis(
        [_]u8{0xaa} ** 32,
        [_]u8{0xbb} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
    );

    const genesis_hash = hashRecord(&genesis);

    // Create next record with correct previous_hash
    var next = WormRecord.init(
        genesis.stream_id,
        1,
        genesis.timestamp + 1,
        genesis_hash,
        [_]u8{0xee} ** 32,
        genesis.policy_hash,
        genesis.writer_id,
    );

    try testing.expect(verifyHashChain(&genesis, &next));

    // Modify previous_hash to break the chain
    next.previous_hash = [_]u8{0xff} ** 32;
    try testing.expect(!verifyHashChain(&genesis, &next));
}
