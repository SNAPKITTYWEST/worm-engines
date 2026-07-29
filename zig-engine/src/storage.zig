// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");
const Segment = @import("segment.zig").Segment;
const Manifest = @import("manifest.zig").Manifest;
const codec = @import("codec.zig");
const hash_mod = @import("hash.zig");

pub const Storage = struct {
    segment: Segment,
    manifest: Manifest,
    allocator: std.mem.Allocator,
    ledger_path: []const u8,

    pub fn create(allocator: std.mem.Allocator, path: []const u8) !Storage {
        try std.fs.cwd().makeDirRecursive(path);

        const segment_path = try std.fmt.allocPrint(allocator, "{s}/segment-00000000.log", .{path});
        defer allocator.free(segment_path);

        const segment = try Segment.create(allocator, segment_path);

        const manifest_path = try std.fmt.allocPrint(allocator, "{s}/MANIFEST", .{path});
        defer allocator.free(manifest_path);

        var manifest = Manifest.create(allocator, manifest_path);

        return Storage{
            .segment = segment,
            .manifest = manifest,
            .allocator = allocator,
            .ledger_path = path,
        };
    }

    pub fn append(self: *Storage, record: *const constants.Record) !void {
        // Encode record to CBOR
        const encoded = try codec.encode_record(self.allocator, record);
        const encoded_len = 256;

        // Compute hash
        const hash_val = try hash_mod.hash_record(record);

        // Write to segment
        try self.segment.write_record(encoded[0..encoded_len]);

        // Fsync segment
        try self.segment.fsync();

        // Update manifest
        self.manifest.head_sequence = record.sequence;
        self.manifest.head_hash = hash_val;
        self.manifest.head_timestamp = record.timestamp;
        self.manifest.total_records += 1;

        // Save manifest atomically
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
