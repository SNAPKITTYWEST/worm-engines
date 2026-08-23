// codec.zig — CBOR encode/decode bridge for the storage layer
// Wraps cbor.zig's WormRecord encoder to work with constants.Record,
// and provides encode_record returning an allocator-owned slice whose
// length reflects the actual encoded byte count (not hardcoded 256).

const std = @import("std");
const constants = @import("constants.zig");
const cbor = @import("cbor.zig");
const WormRecord = @import("record.zig").WormRecord;

/// Maximum CBOR-encoded size for a single LOCKER record.
/// ML-DSA-44 signature = 2420 bytes + CBOR overhead ~10 bytes
/// All other fields total ~350 bytes with CBOR headers.
/// 3072 bytes is safe with margin.
pub const MAX_ENCODED_SIZE: usize = 3072;

/// Encode a constants.Record to CBOR, returning an allocator-owned slice.
/// Caller must free the returned slice.
pub fn encode_record(allocator: std.mem.Allocator, record: *const constants.Record) ![]u8 {
    // Translate constants.Record → WormRecord for the cbor encoder
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

    var buf: [MAX_ENCODED_SIZE]u8 = undefined;
    const written = try cbor.encode(&worm, &buf);

    // Return an owned copy of exactly the bytes written
    const out = try allocator.alloc(u8, written);
    @memcpy(out, buf[0..written]);
    return out;
}

/// Decode a CBOR buffer into a constants.Record.
pub fn decode_record(data: []const u8, allocator: std.mem.Allocator) !constants.Record {
    const worm = try cbor.decode(data, allocator);
    return constants.Record{
        .version = worm.version,
        .stream_id = worm.stream_id,
        .sequence = worm.sequence,
        .timestamp = worm.timestamp,
        .previous_hash = worm.previous_hash,
        .payload_hash = worm.payload_hash,
        .policy_hash = worm.policy_hash,
        .writer_id = worm.writer_id,
        .receipt_id = worm.receipt_id,
        .flags = worm.flags,
        .signature = worm.signature,
    };
}

test "encode_record round-trips through decode_record" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const record = constants.Record{
        .version = 1,
        .stream_id = [_]u8{0xaa} ** 32,
        .sequence = 42,
        .timestamp = 1_700_000_000_000,
        .previous_hash = [_]u8{0x11} ** 32,
        .payload_hash = [_]u8{0x22} ** 32,
        .policy_hash = [_]u8{0x33} ** 32,
        .writer_id = [_]u8{0x44} ** 32,
        .receipt_id = [_]u8{0} ** 32,
        .flags = 0x01,
        .signature = [_]u8{0x55} ** 64,
    };

    const encoded = try encode_record(allocator, &record);
    defer allocator.free(encoded);

    try testing.expect(encoded.len > 0);
    try testing.expect(encoded.len <= MAX_ENCODED_SIZE);

    const decoded = try decode_record(encoded, allocator);
    try testing.expectEqual(record.sequence, decoded.sequence);
    try testing.expectEqual(record.flags, decoded.flags);
    try testing.expectEqualSlices(u8, &record.stream_id, &decoded.stream_id);
}
