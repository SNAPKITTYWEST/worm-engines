// Main C ABI: Exports all functions from worm_abi.h
// Implements the C calling convention interface

const std = @import("std");
const WormWriter = @import("writer.zig").WormWriter;
const WormRecord = @import("record.zig").WormRecord;
const hash_mod = @import("hash.zig");
const cbor = @import("cbor.zig");
const ed25519 = @import("ed25519.zig");
const invariants = @import("invariants.zig");
const Storage = @import("storage.zig").Storage;

// Error codes from worm_abi.h
pub const WORM_OK: i32 = 0;
pub const WORM_ERR_INVALID_WRITER: i32 = -1;
pub const WORM_ERR_INVALID_RECORD: i32 = -2;
pub const WORM_ERR_INVALID_BUFFER: i32 = -3;
pub const WORM_ERR_INVALID_SIGNATURE: i32 = -4;
pub const WORM_ERR_SEQUENCE_MISMATCH: i32 = -5;
pub const WORM_ERR_TIMESTAMP_INVALID: i32 = -6;
pub const WORM_ERR_HASH_CHAIN_BROKEN: i32 = -7;
pub const WORM_ERR_IMMUTABLE_VIOLATION: i32 = -8;
pub const WORM_ERR_WRITER_MISMATCH: i32 = -9;
pub const WORM_ERR_POLICY_ROLLBACK: i32 = -10;
pub const WORM_ERR_CBOR_ENCODE_FAILED: i32 = -11;
pub const WORM_ERR_CBOR_DECODE_FAILED: i32 = -12;
pub const WORM_ERR_BUFFER_TOO_SMALL: i32 = -13;
pub const WORM_ERR_OUT_OF_MEMORY: i32 = -14;
pub const WORM_ERR_INVARIANT_VIOLATED: i32 = -15;
pub const WORM_ERR_STREAM_NOT_INITIALIZED: i32 = -16;

// Global allocator (uses GPA for now, could be configurable)
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

/// Initialize a new WormWriter
export fn worm_init_writer(writer_id: [*c]const u8) ?*WormWriter {
    const writer_id_slice: [32]u8 = writer_id[0..32].*;
    return WormWriter.init(allocator, writer_id_slice) catch null;
}

/// Create a new WormRecord
export fn worm_create_record(
    writer: ?*WormWriter,
    stream_id: [*c]const u8,
    payload_hash: [*c]const u8,
) ?*WormRecord {
    if (writer == null) return null;

    const stream_id_slice: [32]u8 = stream_id[0..32].*;
    const payload_hash_slice: [32]u8 = payload_hash[0..32].*;

    // Initialize stream if needed
    if (!writer.?.isInitialized()) {
        writer.?.initializeStream(stream_id_slice);
    }

    const policy_hash = writer.?.getLastPolicyHash();
    const record = writer.?.createRecord(payload_hash_slice, policy_hash);

    // Allocate on heap
    const record_ptr = allocator.create(WormRecord) catch return null;
    record_ptr.* = record;

    return record_ptr;
}

/// Append a record to local storage (enforces all invariants)
export fn worm_append_local(writer: ?*WormWriter, record: ?*WormRecord) i32 {
    if (writer == null or record == null) return WORM_ERR_INVALID_WRITER;

    const w = writer.?;
    const r = record.?;

    // Validate all invariants
    invariants.validateAll(w, r) catch |err| {
        return switch (err) {
            error.SequenceNotMonotone => WORM_ERR_SEQUENCE_MISMATCH,
            error.TimestampNotMonotone => WORM_ERR_TIMESTAMP_INVALID,
            error.HashChainBroken => WORM_ERR_HASH_CHAIN_BROKEN,
            error.ImmutableViolation => WORM_ERR_IMMUTABLE_VIOLATION,
            error.WriterMismatch => WORM_ERR_WRITER_MISMATCH,
            error.PolicyRollback => WORM_ERR_POLICY_ROLLBACK,
            error.SignatureInvalid => WORM_ERR_INVALID_SIGNATURE,
            error.StreamNotInitialized => WORM_ERR_STREAM_NOT_INITIALIZED,
            else => WORM_ERR_INVARIANT_VIOLATED,
        };
    };

    // Compute record hash
    const record_hash = hash_mod.hashRecord(r);

    // Mark as committed
    r.markCommitted();

    // Update writer state
    w.updateFromRecord(r, record_hash);

    // TODO: Write to storage (needs stream_id -> file mapping)
    // For now, we just validate and update state

    return WORM_OK;
}

/// Compute hash of a WormRecord
export fn worm_hash_record(record: ?*WormRecord) [*c]u8 {
    if (record == null) return null;

    const hash_value = hash_mod.hashRecord(record.?);

    // Allocate on heap and return pointer
    const hash_ptr = allocator.create([32]u8) catch return null;
    hash_ptr.* = hash_value;

    return @ptrCast(hash_ptr);
}

/// Encode a WormRecord to CBOR
export fn worm_cbor_encode(record: ?*WormRecord, buffer: [*c]u8, len: [*c]usize) i32 {
    if (record == null or buffer == null or len == null) return WORM_ERR_INVALID_BUFFER;

    const buffer_slice = buffer[0..len.*];

    const encoded_len = cbor.encode(record.?, buffer_slice) catch |err| {
        return switch (err) {
            error.NoSpaceLeft => WORM_ERR_BUFFER_TOO_SMALL,
            else => WORM_ERR_CBOR_ENCODE_FAILED,
        };
    };

    len.* = encoded_len;
    return WORM_OK;
}

/// Decode a WormRecord from CBOR
export fn worm_cbor_decode(buffer: [*c]const u8, len: usize) ?*WormRecord {
    if (buffer == null) return null;

    const buffer_slice = buffer[0..len];

    const record = cbor.decode(buffer_slice, allocator) catch return null;

    // Allocate on heap
    const record_ptr = allocator.create(WormRecord) catch return null;
    record_ptr.* = record;

    return record_ptr;
}

/// Sign a WormRecord with a private key
export fn worm_sign_record(record: ?*WormRecord, private_key: [*c]const u8) i32 {
    if (record == null or private_key == null) return WORM_ERR_INVALID_RECORD;

    const private_key_slice: [32]u8 = private_key[0..32].*;

    ed25519.signRecord(record.?, private_key_slice) catch {
        return WORM_ERR_INVALID_SIGNATURE;
    };

    return WORM_OK;
}

/// Verify a WormRecord's signature
export fn worm_verify_signature(record: ?*WormRecord, public_key: [*c]const u8) i32 {
    if (record == null or public_key == null) return WORM_ERR_INVALID_RECORD;

    const public_key_slice: [32]u8 = public_key[0..32].*;

    ed25519.verifySignature(record.?, public_key_slice) catch {
        return WORM_ERR_INVALID_SIGNATURE;
    };

    return WORM_OK;
}

/// Query the last sequence number from a writer
export fn worm_query_sequence(writer: ?*WormWriter) u64 {
    if (writer == null) return 0;
    return writer.?.getLastSequence();
}

/// Query the last hash from a writer
export fn worm_query_previous_hash(writer: ?*WormWriter) [*c]u8 {
    if (writer == null) return null;

    const hash_value = writer.?.getLastHash();

    // Allocate on heap
    const hash_ptr = allocator.create([32]u8) catch return null;
    hash_ptr.* = hash_value;

    return @ptrCast(hash_ptr);
}

/// Free any object allocated by the WORM engine
export fn worm_free(obj: ?*anyopaque) void {
    if (obj == null) return;

    // Try to free as different types
    // This is unsafe but necessary for C compatibility
    // Caller must know what type they're freeing
    allocator.destroy(@as(*WormWriter, @ptrCast(@alignCast(obj))));
}

// Tests
test "C ABI basic flow" {
    const testing = std.testing;

    // Generate keypair
    const keypair = try ed25519.generateKeypair();

    // Initialize writer
    const writer = worm_init_writer(@ptrCast(&keypair.public));
    try testing.expect(writer != null);
    defer worm_free(writer);

    // Create genesis record
    const stream_id = [_]u8{0xaa} ** 32;
    const payload_hash = [_]u8{0xbb} ** 32;

    const record = worm_create_record(writer, @ptrCast(&stream_id), @ptrCast(&payload_hash));
    try testing.expect(record != null);
    defer worm_free(record);

    // Sign the record
    const sign_result = worm_sign_record(record, @ptrCast(&keypair.private));
    try testing.expectEqual(WORM_OK, sign_result);

    // Verify signature
    const verify_result = worm_verify_signature(record, @ptrCast(&keypair.public));
    try testing.expectEqual(WORM_OK, verify_result);

    // Append to local storage
    const append_result = worm_append_local(writer, record);
    try testing.expectEqual(WORM_OK, append_result);

    // Query sequence
    const sequence = worm_query_sequence(writer);
    try testing.expectEqual(@as(u64, 0), sequence);
}
