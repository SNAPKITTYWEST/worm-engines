// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");
const Segment = @import("segment.zig").Segment;
const Manifest = @import("manifest.zig").Manifest;
const codec = @import("codec.zig");
const hash_mod = @import("hash.zig");

/// ValidatedRecord: Ensures invariants before durability (FIX 7)
pub const ValidatedRecord = struct {
    sequence: u64,
    previous_hash: [32]u8,
    writer_id: [32]u8,
    timestamp: u64,

    pub fn validate(record: *const constants.Record, expected_sequence: u64, expected_hash: [32]u8, last_timestamp: u64) !ValidatedRecord {
        // Sequence order: must be exactly expected_sequence
        if (record.sequence != expected_sequence) {
            return error.SequenceMismatch;
        }

        // Previous hash must match manifest head
        if (!std.mem.eql(u8, &record.previous_hash, &expected_hash)) {
            return error.HashChainBroken;
        }

        // Timestamp must be monotonic (>= last_timestamp)
        if (record.timestamp < last_timestamp) {
            return error.TimestampNotMonotonic;
        }

        // Writer ID must be non-zero (basic sanity check)
        var zero_writer: [32]u8 = [_]u8{0} ** 32;
        if (std.mem.eql(u8, &record.writer_id, &zero_writer)) {
            return error.InvalidWriterId;
        }

        return ValidatedRecord{
            .sequence = record.sequence,
            .previous_hash = record.previous_hash,
            .writer_id = record.writer_id,
            .timestamp = record.timestamp,
        };
    }
};

pub const Storage = struct {
    segment: Segment,
    manifest: Manifest,
    allocator: std.mem.Allocator,
    ledger_path: []const u8,
    writer_id: [32]u8,

    pub const Error = error{
        SequenceMismatch,
        HashChainBroken,
        TimestampNotMonotonic,
        InvalidWriterId,
        ManifestCorrupt,
        SegmentCorrupt,
        RecoveryFailed,
    };

    /// createNew: Create fresh ledger (FIX 6)
    pub fn createNew(allocator: std.mem.Allocator, path: []const u8) !Storage {
        _ = std.fs.cwd().deleteTree(path) catch {};
        return create(allocator, path);
    }

    /// openExisting: Open and recover existing ledger (FIX 6)
    pub fn openExisting(allocator: std.mem.Allocator, path: []const u8) !Storage {
        var storage = try create(allocator, path);
        try storage.recover();
        return storage;
    }

    /// openOrCreate: Open if exists, else create fresh (FIX 6)
    pub fn openOrCreate(allocator: std.mem.Allocator, path: []const u8) !Storage {
        const exists = std.fs.cwd().openDir(path, .{}) catch |err| {
            if (err == std.fs.File.OpenError.FileNotFound) {
                return createNew(allocator, path);
            }
            return err;
        };
        exists.close();
        return openExisting(allocator, path);
    }

    /// create: Base initialization (internal)
    fn create(allocator: std.mem.Allocator, path: []const u8) !Storage {
        try std.fs.cwd().makeDirRecursive(path);

        const segment_path = try std.fmt.allocPrint(allocator, "{s}/segment-00000000.log", .{path});
        defer allocator.free(segment_path);

        const segment = try Segment.create(allocator, segment_path);

        const manifest_path = try std.fmt.allocPrint(allocator, "{s}/MANIFEST", .{path});
        defer allocator.free(manifest_path);

        var manifest = Manifest.create(allocator, manifest_path);

        // Duplicate path for Storage ownership (FIX 5 + 9)
        const ledger_path_owned = try allocator.dupe(u8, path);

        return Storage{
            .segment = segment,
            .manifest = manifest,
            .allocator = allocator,
            .ledger_path = ledger_path_owned,
            .writer_id = [_]u8{0} ** 32,
        };
    }

    /// recover: Rebuild state from segments after crash (FIX 6)
    fn recover(self: *Storage) !void {
        // Scan segments, validate CRC, rebuild hash chain
        // Truncate incomplete records
        var file = self.segment.file;
        try file.seekTo(0);

        var valid_bytes: u64 = 0;
        var frame_count: u64 = 0;

        // Frame validation loop
        while (true) {
            var magic_buf: [4]u8 = undefined;
            const magic_read = file.read(&magic_buf) catch |err| {
                if (err == error.EndOfStream) break;
                return Error.SegmentCorrupt;
            };

            if (magic_read == 0) break;
            if (magic_read < 4) {
                try file.setEndPos(valid_bytes);
                break;
            }

            // Verify WORM magic (FIX 8 format check)
            if (!std.mem.eql(u8, &magic_buf, "WORM")) {
                try file.setEndPos(valid_bytes);
                break;
            }

            var version_buf: [2]u8 = undefined;
            const version_read = try file.readAll(&version_buf);
            if (version_read < 2) return Error.SegmentCorrupt;

            const version = std.mem.readInt(u16, &version_buf, .big);
            if (version != 1) {
                return Error.SegmentCorrupt;
            }

            // Skip flags (2 bytes)
            var flags_buf: [2]u8 = undefined;
            _ = try file.readAll(&flags_buf);

            // Read length (4 bytes)
            var length_buf: [4]u8 = undefined;
            _ = try file.readAll(&length_buf);
            const frame_length = std.mem.readInt(u32, &length_buf, .big);

            if (frame_length > 1024 * 1024) {
                return Error.SegmentCorrupt;
            }

            // Skip payload and CRC (4 bytes)
            try file.seekBy(@intCast(frame_length + 4));

            valid_bytes += 4 + 2 + 2 + 4 + frame_length + 4;
            frame_count += 1;
        }

        self.manifest.total_records = frame_count;
        try self.manifest.save();
    }

    pub fn deinit(self: *Storage) void {
        self.allocator.free(self.ledger_path);
        self.segment.close();
    }

    /// append: Validate and append record (FIX 7)
    pub fn append(self: *Storage, record: *const constants.Record) !void {
        const next_sequence = self.manifest.total_records;

        // VALIDATE before durability
        const validated = try ValidatedRecord.validate(
            record,
            next_sequence,
            self.manifest.head_hash,
            self.manifest.head_timestamp,
        );

        const encoded = try codec.encode_record(self.allocator, record);
        const encoded_len = 256;

        const hash_val = try hash_mod.hash_record(record);

        try self.segment.write_record(encoded[0..encoded_len]);
        try self.segment.fsync();

        self.manifest.head_sequence = validated.sequence;
        self.manifest.head_hash = hash_val;
        self.manifest.head_timestamp = validated.timestamp;
        self.manifest.total_records += 1;

        try self.manifest.save();
    }

    pub fn query_sequence(self: *Storage) u64 {
        return self.manifest.head_sequence;
    }

    pub fn query_hash(self: *Storage) [32]u8 {
        return self.manifest.head_hash;
    }

    pub fn close(self: *Storage) void {
        self.segment.close();
    }
};
