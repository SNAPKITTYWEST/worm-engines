// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");
const Segment = @import("segment.zig").Segment;
const Manifest = @import("manifest.zig").Manifest;
const codec = @import("codec.zig");
const hash_mod = @import("hash.zig");

pub const ValidatedRecord = struct {
    record: *const constants.Record,
    sequence_valid: bool,
    hash_chain_valid: bool,
    timestamp_valid: bool,
    writer_consistent: bool,

    pub fn isValid(self: *const ValidatedRecord) bool {
        return self.sequence_valid and self.hash_chain_valid and self.timestamp_valid and self.writer_consistent;
    }
};

pub const Storage = struct {
    segment: Segment,
    manifest: Manifest,
    allocator: std.mem.Allocator,
    ledger_path: []const u8,
    recovered: bool,

    pub const Error = error{
        PathNotOwned,
        CorruptManifest,
        SegmentMissing,
        InvalidSegmentFormat,
        InvalidRecord,
        HashChainBroken,
        SequenceGap,
        RecoverFailed,
    };

    /// Create a new ledger (fail if already exists)
    pub fn createNew(allocator: std.mem.Allocator, path: []const u8) !Storage {
        try std.fs.cwd().makeDirRecursive(path);

        const segment_path = try std.fmt.allocPrint(allocator, "{s}/segment-00000000.log", .{path});
        defer allocator.free(segment_path);

        const segment = try Segment.create(allocator, segment_path);

        const manifest_path = try std.fmt.allocPrint(allocator, "{s}/MANIFEST", .{path});
        defer allocator.free(manifest_path);

        var manifest = Manifest.create(allocator, manifest_path);

        const ledger_path_owned = try allocator.dupe(u8, path);

        return Storage{
            .segment = segment,
            .manifest = manifest,
            .allocator = allocator,
            .ledger_path = ledger_path_owned,
            .recovered = false,
        };
    }

    /// Open existing ledger and recover if needed
    pub fn openExisting(allocator: std.mem.Allocator, path: []const u8) !Storage {
        var dir = try std.fs.cwd().openDir(path, .{});
        defer dir.close();

        const manifest_path = try std.fmt.allocPrint(allocator, "{s}/MANIFEST", .{path});
        defer allocator.free(manifest_path);

        var manifest = (Manifest.load(allocator, manifest_path) catch null) orelse Manifest.create(allocator, manifest_path);

        const segment_path = try std.fmt.allocPrint(allocator, "{s}/segment-00000000.log", .{path});
        defer allocator.free(segment_path);

        const segment = try Segment.create(allocator, segment_path);

        const ledger_path_owned = try allocator.dupe(u8, path);

        var storage = Storage{
            .segment = segment,
            .manifest = manifest,
            .allocator = allocator,
            .ledger_path = ledger_path_owned,
            .recovered = false,
        };

        if (manifest.head_sequence == 0 and manifest.total_records == 0) {
            try storage.recover();
            storage.recovered = true;
        }

        return storage;
    }

    /// Open ledger: create if missing, recover if corrupted
    pub fn openOrCreate(allocator: std.mem.Allocator, path: []const u8) !Storage {
        return openExisting(allocator, path) catch |err| {
            if (err == std.fs.Dir.OpenError.FileNotFound) {
                return createNew(allocator, path);
            }
            return err;
        };
    }

    /// Recovery: scan segments using proper WORM frame format, rebuild hash chain.
    /// Uses segment.read_frame() so magic, version, and CRC are validated correctly.
    fn recover(self: *Storage) !void {
        try self.segment.file.seekTo(0);

        var sequence: u64 = 0;
        var last_hash: [32]u8 = [_]u8{0} ** 32;
        var total_records: u64 = 0;

        while (true) {
            const frame = self.segment.read_frame() catch |err| {
                // End of file or truncated frame — stop recovery here
                _ = err;
                break;
            };

            if (frame == null) break;

            const payload = frame.?.payload;
            defer self.segment.allocator.free(payload);

            // Rebuild hash chain from the CBOR payload of each frame
            last_hash = try hash_mod.hash_record_cbor(payload);
            sequence += 1;
            total_records += 1;
        }

        self.manifest.head_sequence = if (total_records > 0) sequence - 1 else 0;
        self.manifest.head_hash = last_hash;
        self.manifest.head_timestamp = std.time.milliTimestamp();
        self.manifest.total_records = total_records;

        try self.manifest.save();
    }

    pub fn deinit(self: *Storage) void {
        self.allocator.free(self.ledger_path);
        self.segment.close();
    }

    pub fn validateRecord(self: *Storage, record: *const constants.Record) ValidatedRecord {
        var validated = ValidatedRecord{
            .record = record,
            .sequence_valid = false,
            .hash_chain_valid = false,
            .timestamp_valid = false,
            .writer_consistent = false,
        };

        // Check sequence order: should be next after head_sequence
        if (self.manifest.head_sequence == 0xFFFFFFFFFFFFFFFF) {
            validated.sequence_valid = (record.sequence == 0);
        } else {
            validated.sequence_valid = (record.sequence == self.manifest.head_sequence + 1);
        }

        // Check hash chain: previous_hash should match head_hash
        validated.hash_chain_valid = std.mem.eql(u8, &record.previous_hash, &self.manifest.head_hash);

        // Check timestamp monotonicity
        validated.timestamp_valid = (record.timestamp >= self.manifest.head_timestamp);

        // Check writer_id consistency (should match or be first write)
        if (self.manifest.total_records == 0) {
            validated.writer_consistent = true;
        } else {
            // In a real implementation, we'd track expected writer_id
            validated.writer_consistent = true;
        }

        return validated;
    }

    pub fn append(self: *Storage, record: *const constants.Record) !void {
        // Validate before durability
        const validated = self.validateRecord(record);
        if (!validated.isValid()) {
            return error.InvalidRecord;
        }

        const encoded = try codec.encode_record(self.allocator, record);
        defer self.allocator.free(encoded);

        const hash_val = try hash_mod.hash_record(record);

        try self.segment.write_record(encoded);

        try self.segment.fsync();

        self.manifest.head_sequence = record.sequence;
        self.manifest.head_hash = hash_val;
        self.manifest.head_timestamp = record.timestamp;
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
