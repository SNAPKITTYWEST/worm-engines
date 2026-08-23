// Invariants: Enforcement of all 12 WORM invariants
// Each function validates one invariant and returns an error if violated

const std = @import("std");
const WormRecord = @import("record.zig").WormRecord;
const WormWriter = @import("writer.zig").WormWriter;
const hash_mod = @import("hash.zig");

pub const InvariantError = error{
    SequenceNotMonotone,
    TimestampNotMonotone,
    HashChainBroken,
    ImmutableViolation,
    WriterMismatch,
    PolicyRollback,
    SignatureInvalid,
    PayloadIntegrityViolation,
    RecordCollision,
    RecoveryFailure,
    ReplicationRewind,
    GenesisNotUnique,
};

/// Invariant 1: Sequence Monotonicity
/// sequence_new = sequence_previous + 1
pub fn checkSequenceMonotone(writer: *WormWriter, record: *const WormRecord) !void {
    const expected = writer.getLastSequence() + 1;
    if (record.sequence != expected) {
        std.debug.print("Sequence mismatch: expected {}, got {}\n", .{ expected, record.sequence });
        return InvariantError.SequenceNotMonotone;
    }
}

/// Invariant 2: Timestamp Monotonicity
/// timestamp_new >= timestamp_previous
pub fn checkTimestampMonotone(writer: *WormWriter, record: *const WormRecord) !void {
    const last_timestamp = writer.getLastTimestamp();
    if (record.timestamp < last_timestamp) {
        std.debug.print("Timestamp rewind: last={}, new={}\n", .{ last_timestamp, record.timestamp });
        return InvariantError.TimestampNotMonotone;
    }
}

/// Invariant 3: Hash Chain Integrity
/// previous_hash = sha256(hash_domain(prev_record))
pub fn checkHashChain(writer: *WormWriter, record: *const WormRecord) !void {
    const expected_hash = writer.getLastHash();
    if (!std.mem.eql(u8, &expected_hash, &record.previous_hash)) {
        std.debug.print("Hash chain broken\n", .{});
        return InvariantError.HashChainBroken;
    }
}

/// Invariant 4: Commitment Immutability
/// committed_record cannot be modified
pub fn checkCommittedImmutable(record: *const WormRecord, existing_sequence: ?u64) !void {
    if (existing_sequence) |seq| {
        if (seq == record.sequence) {
            std.debug.print("Attempted to overwrite committed record at sequence {}\n", .{seq});
            return InvariantError.ImmutableViolation;
        }
    }
}

/// Invariant 5: Writer Identity Stability
/// writer_id never changes
pub fn checkWriterStable(writer: *WormWriter, record: *const WormRecord) !void {
    if (!std.mem.eql(u8, &writer.writer_id, &record.writer_id)) {
        std.debug.print("Writer ID mismatch\n", .{});
        return InvariantError.WriterMismatch;
    }
}

/// Invariant 6: Policy Monotonicity
/// policy_hash_new >= policy_hash_previous (lexicographic)
pub fn checkPolicyMonotone(writer: *WormWriter, record: *const WormRecord) !void {
    const last_policy = writer.getLastPolicyHash();

    // Lexicographic comparison
    const cmp = std.mem.order(u8, &last_policy, &record.policy_hash);
    if (cmp == .gt) {
        std.debug.print("Policy rollback detected\n", .{});
        return InvariantError.PolicyRollback;
    }
}

/// Invariant 7: Signature Validity
/// signature_valid(record, writer_id) = true
pub fn checkSignatureValid(record: *const WormRecord) !void {
    const ed25519 = @import("ed25519.zig");
    ed25519.verifySignature(record, record.writer_id) catch {
        std.debug.print("Signature verification failed\n", .{});
        return InvariantError.SignatureInvalid;
    };
}

/// Invariant 8: Payload Commitment
/// payload_hash = sha256(payload_bytes)
/// Note: This check requires the actual payload, which is not part of the record
/// The caller must compute the payload hash and verify it matches
pub fn checkPayloadIntegrity(expected_hash: [32]u8, actual_hash: [32]u8) !void {
    if (!std.mem.eql(u8, &expected_hash, &actual_hash)) {
        std.debug.print("Payload hash mismatch\n", .{});
        return InvariantError.PayloadIntegrityViolation;
    }
}

/// Invariant 9: Unique Record Identity
/// hash(record) is globally unique
/// Note: This is a probabilistic guarantee (2^-128 collision probability)
/// We check for exact duplicates in the stream
pub fn checkRecordUnique(record_hash: [32]u8, existing_hashes: []const [32]u8) !void {
    for (existing_hashes) |existing| {
        if (std.mem.eql(u8, &record_hash, &existing)) {
            std.debug.print("Duplicate record detected\n", .{});
            return InvariantError.RecordCollision;
        }
    }
}

/// Invariant 10: Recovery Longest Prefix Selection
/// Not implemented in this module (requires recovery logic)

/// Invariant 11: Replication Causality
/// replicated_sequence >= local_sequence
pub fn checkReplicationCausality(local_sequence: u64, replicated_sequence: u64) !void {
    if (replicated_sequence < local_sequence) {
        std.debug.print("Replication rewind: local={}, replicated={}\n", .{ local_sequence, replicated_sequence });
        return InvariantError.ReplicationRewind;
    }
}

/// Invariant 12: Genesis Uniqueness
/// one genesis per stream_id
pub fn checkGenesisUnique(is_genesis: bool, stream_initialized: bool) !void {
    if (is_genesis and stream_initialized) {
        std.debug.print("Attempted to create second genesis record\n", .{});
        return InvariantError.GenesisNotUnique;
    }
}

/// Validate all applicable invariants for a new record
pub fn validateAll(writer: *WormWriter, record: *const WormRecord) !void {
    // Genesis record (sequence = 0)
    if (record.sequence == 0) {
        try checkGenesisUnique(true, writer.isInitialized());
        try checkWriterStable(writer, record);
        try checkSignatureValid(record);
        return;
    }

    // Non-genesis records
    if (!writer.isInitialized()) {
        return error.StreamNotInitialized;
    }

    try checkSequenceMonotone(writer, record);
    try checkTimestampMonotone(writer, record);
    try checkHashChain(writer, record);
    try checkWriterStable(writer, record);
    try checkPolicyMonotone(writer, record);
    try checkSignatureValid(record);
}

test "sequence monotonicity" {
    const testing = std.testing;

    var writer = try WormWriter.init(testing.allocator, [_]u8{0xaa} ** 32);
    defer writer.deinit();

    writer.initializeStream([_]u8{0xbb} ** 32);
    writer.updateFromRecord(&WormRecord.init(
        [_]u8{0xbb} ** 32,
        0,
        1000,
        [_]u8{0} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
        [_]u8{0xaa} ** 32,
    ), [_]u8{0xee} ** 32);

    // Valid: sequence = 1
    var record1 = WormRecord.init(
        [_]u8{0xbb} ** 32,
        1,
        1001,
        [_]u8{0xee} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
        [_]u8{0xaa} ** 32,
    );

    try checkSequenceMonotone(writer, &record1);

    // Invalid: sequence = 3 (skipped 2)
    var record2 = record1;
    record2.sequence = 3;

    try testing.expectError(InvariantError.SequenceNotMonotone, checkSequenceMonotone(writer, &record2));
}

test "timestamp monotonicity" {
    const testing = std.testing;

    var writer = try WormWriter.init(testing.allocator, [_]u8{0xaa} ** 32);
    defer writer.deinit();

    writer.initializeStream([_]u8{0xbb} ** 32);
    writer.updateFromRecord(&WormRecord.init(
        [_]u8{0xbb} ** 32,
        0,
        1000,
        [_]u8{0} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
        [_]u8{0xaa} ** 32,
    ), [_]u8{0xee} ** 32);

    // Valid: timestamp >= last
    var record1 = WormRecord.init(
        [_]u8{0xbb} ** 32,
        1,
        1001,
        [_]u8{0xee} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0xdd} ** 32,
        [_]u8{0xaa} ** 32,
    );

    try checkTimestampMonotone(writer, &record1);

    // Invalid: timestamp < last
    record1.timestamp = 999;
    try testing.expectError(InvariantError.TimestampNotMonotone, checkTimestampMonotone(writer, &record1));
}

test "policy monotonicity" {
    const testing = std.testing;

    var writer = try WormWriter.init(testing.allocator, [_]u8{0xaa} ** 32);
    defer writer.deinit();

    writer.initializeStream([_]u8{0xbb} ** 32);
    writer.updateFromRecord(&WormRecord.init(
        [_]u8{0xbb} ** 32,
        0,
        1000,
        [_]u8{0} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0x50} ** 32, // policy_hash = 0x50...
        [_]u8{0xaa} ** 32,
    ), [_]u8{0xee} ** 32);

    // Valid: policy_hash >= last (0x60 > 0x50)
    var record1 = WormRecord.init(
        [_]u8{0xbb} ** 32,
        1,
        1001,
        [_]u8{0xee} ** 32,
        [_]u8{0xcc} ** 32,
        [_]u8{0x60} ** 32,
        [_]u8{0xaa} ** 32,
    );

    try checkPolicyMonotone(writer, &record1);

    // Invalid: policy_hash < last (0x40 < 0x50)
    record1.policy_hash = [_]u8{0x40} ** 32;
    try testing.expectError(InvariantError.PolicyRollback, checkPolicyMonotone(writer, &record1));
}
