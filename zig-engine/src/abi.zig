// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

// C ABI: Language-agnostic interface matching worm_abi.h
const std = @import("std");
const constants = @import("constants.zig");
const Storage = @import("storage.zig").Storage;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var writers: std.StringHashMap(*Writer) = undefined;
var initialized = false;

pub const Writer = struct {
    id: [32]u8,
    stream_id: [32]u8,
    storage: ?Storage,
    sequence: u64,
    hash: [32]u8,
    allocator: std.mem.Allocator,
};

pub const WORM_OK = 0;
pub const WORM_ERR_INVALID_WRITER = -1;
pub const WORM_ERR_INVALID_RECORD = -2;
pub const WORM_ERR_INVALID_BUFFER = -3;
pub const WORM_ERR_INVALID_SIGNATURE = -4;
pub const WORM_ERR_SEQUENCE_MISMATCH = -5;
pub const WORM_ERR_TIMESTAMP_INVALID = -6;
pub const WORM_ERR_HASH_CHAIN_BROKEN = -7;
pub const WORM_ERR_IMMUTABLE_VIOLATION = -8;
pub const WORM_ERR_WRITER_MISMATCH = -9;
pub const WORM_ERR_POLICY_ROLLBACK = -10;
pub const WORM_ERR_CBOR_ENCODE_FAILED = -11;
pub const WORM_ERR_CBOR_DECODE_FAILED = -12;
pub const WORM_ERR_BUFFER_TOO_SMALL = -13;
pub const WORM_ERR_OUT_OF_MEMORY = -14;
pub const WORM_ERR_INVARIANT_VIOLATED = -15;
pub const WORM_ERR_STREAM_NOT_INITIALIZED = -16;

// C export: worm_init_writer(writer_id: [32]u8) -> *Writer
export fn worm_init_writer(writer_id: [*c]const u8) ?*Writer {
    if (!initialized) {
        writers = std.StringHashMap(*Writer).init(gpa.allocator());
        initialized = true;
    }

    if (writer_id == null) return null;

    const id_slice: [32]u8 = writer_id[0..32].*;
    const writer = gpa.allocator().create(Writer) catch return null;

    writer.* = Writer{
        .id = id_slice,
        .stream_id = [_]u8{0} ** 32,
        .storage = null,
        .sequence = 0xFFFFFFFFFFFFFFFF,
        .hash = [_]u8{0} ** 32,
        .allocator = gpa.allocator(),
    };

    return writer;
}

// C export: worm_create_record(writer: *Writer, stream_id: [32]u8, payload_hash: [32]u8) -> *Record
export fn worm_create_record(
    writer: ?*Writer,
    stream_id: [*c]const u8,
    payload_hash: [*c]const u8,
) ?*constants.Record {
    if (writer == null or stream_id == null or payload_hash == null) return null;

    const w = writer.?;
    const stream_id_slice: [32]u8 = stream_id[0..32].*;
    const payload_hash_slice: [32]u8 = payload_hash[0..32].*;

    // Initialize stream if needed
    if (w.storage == null) {
        @memcpy(&w.stream_id, &stream_id_slice);
        w.sequence = 0xFFFFFFFFFFFFFFFF;
        w.hash = [_]u8{0} ** 32;
    }

    const sequence = if (w.sequence == 0xFFFFFFFFFFFFFFFF) 0 else w.sequence + 1;
    const timestamp = @as(u64, @intCast(std.time.milliTimestamp()));

    const record = gpa.allocator().create(constants.Record) catch return null;
    record.* = constants.Record{
        .version = 1,
        .stream_id = stream_id_slice,
        .sequence = sequence,
        .timestamp = timestamp,
        .previous_hash = w.hash,
        .payload_hash = payload_hash_slice,
        .policy_hash = [_]u8{0} ** 32,
        .writer_id = w.id,
        .flags = 0,
        .signature = [_]u8{0} ** 64,
    };

    return record;
}

// C export: worm_append_local(writer: *Writer, record: *Record) -> i32
export fn worm_append_local(writer: ?*Writer, record: ?*constants.Record) i32 {
    if (writer == null or record == null) return WORM_ERR_INVALID_WRITER;

    const w = writer.?;
    const r = record.?;

    // Initialize storage on first append
    if (w.storage == null) {
        const path = "/tmp/worm_test_ledger" catch return WORM_ERR_INVARIANT_VIOLATED;
        w.storage = Storage.create(w.allocator, path) catch return WORM_ERR_INVARIANT_VIOLATED;
    }

    // Append to storage
    w.storage.?.append(r) catch return WORM_ERR_INVARIANT_VIOLATED;

    // Update writer state
    w.sequence = r.sequence;
    w.hash = w.storage.?.query_hash();

    return WORM_OK;
}

// C export: worm_query_sequence(writer: *Writer) -> u64
export fn worm_query_sequence(writer: ?*Writer) u64 {
    if (writer == null) return 0;
    return writer.?.storage.?.query_sequence();
}

// C export: worm_query_previous_hash(writer: *Writer, out: [32]u8) -> i32
export fn worm_query_previous_hash(writer: ?*Writer, out: [*c]u8) i32 {
    if (writer == null or out == null) return WORM_ERR_INVALID_WRITER;
    const hash = writer.?.query_hash();
    @memcpy(out[0..32], &hash);
    return WORM_OK;
}

// C export: worm_hash_record(record: *Record, out: [32]u8) -> i32
export fn worm_hash_record(record: ?*constants.Record, out: [*c]u8) i32 {
    if (record == null or out == null) return WORM_ERR_INVALID_RECORD;
    const hash_mod = @import("hash.zig");
    const hash = hash_mod.hash_record(record.?) catch return WORM_ERR_INVARIANT_VIOLATED;
    @memcpy(out[0..32], &hash);
    return WORM_OK;
}

// C export: worm_cbor_encode(record: *Record, buffer: [*]u8, len: *usize) -> i32
export fn worm_cbor_encode(record: ?*constants.Record, buffer: [*c]u8, len: [*c]usize) i32 {
    if (record == null or buffer == null or len == null) return WORM_ERR_INVALID_BUFFER;
    const codec = @import("codec.zig");
    const encoded = codec.encode_record(gpa.allocator(), record.?) catch return WORM_ERR_CBOR_ENCODE_FAILED;
    if (len.* < 256) return WORM_ERR_BUFFER_TOO_SMALL;
    @memcpy(buffer[0..256], encoded[0..256]);
    len.* = 256;
    return WORM_OK;
}

// C export: worm_cbor_decode(buffer: [*]u8, len: usize) -> *Record
export fn worm_cbor_decode(buffer: [*c]const u8, len: usize) ?*constants.Record {
    if (buffer == null or len < 100) return null;
    // Stub for now - full CBOR decode requires parser
    const record = gpa.allocator().create(constants.Record) catch return null;
    record.* = constants.Record{
        .version = 1,
        .stream_id = [_]u8{0} ** 32,
        .sequence = 0,
        .timestamp = 0,
        .previous_hash = [_]u8{0} ** 32,
        .payload_hash = [_]u8{0} ** 32,
        .policy_hash = [_]u8{0} ** 32,
        .writer_id = [_]u8{0} ** 32,
        .flags = 0,
        .signature = [_]u8{0} ** 64,
    };
    return record;
}

// C export: worm_sign_record(record: *Record, private_key: [32]u8) -> i32
export fn worm_sign_record(record: ?*constants.Record, private_key: [*c]const u8) i32 {
    if (record == null or private_key == null) return WORM_ERR_INVALID_RECORD;
    // Placeholder: signature remains zero
    return WORM_OK;
}

// C export: worm_verify_signature(record: *Record, public_key: [32]u8) -> i32
export fn worm_verify_signature(record: ?*constants.Record, public_key: [*c]const u8) i32 {
    if (record == null or public_key == null) return WORM_ERR_INVALID_RECORD;
    // Placeholder: all signatures verify
    return WORM_OK;
}

// C export: worm_free(obj: *anyopaque) -> void
export fn worm_free(obj: ?*anyopaque) void {
    if (obj == null) return;
    gpa.allocator().destroy(@as(*Writer, @ptrCast(@alignCast(obj))));
}
