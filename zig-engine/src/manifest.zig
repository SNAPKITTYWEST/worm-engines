// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub const Manifest = struct {
    path: []const u8,
    head_sequence: u64,
    head_hash: [32]u8,
    head_timestamp: u64,
    total_records: u64,
    allocator: std.mem.Allocator,

    pub fn create(allocator: std.mem.Allocator, path: []const u8) Manifest {
        var hash: [32]u8 = [_]u8{0} ** 32;
        return Manifest{
            .path = path,
            .head_sequence = 0,
            .head_hash = hash,
            .head_timestamp = 0,
            .total_records = 0,
            .allocator = allocator,
        };
    }

    pub fn save(self: *Manifest) !void {
        var buffer: [88]u8 = undefined;
        var pos: usize = 0;

        std.mem.writeIntBig(u32, buffer[pos..][0..4], constants.RECORD_VERSION);
        pos += 4;
        std.mem.writeIntBig(u64, buffer[pos..][0..8], self.head_sequence);
        pos += 8;
        @memcpy(buffer[pos..][0..32], &self.head_hash);
        pos += 32;
        std.mem.writeIntBig(u64, buffer[pos..][0..8], self.head_timestamp);
        pos += 8;
        std.mem.writeIntBig(u64, buffer[pos..][0..8], self.total_records);

        const tmp_path = try std.fmt.allocPrint(self.allocator, "{s}.tmp", .{self.path});
        defer self.allocator.free(tmp_path);

        var tmp_file = try std.fs.cwd().createFile(tmp_path, .{});
        defer tmp_file.close();

        try tmp_file.writeAll(&buffer);
        try tmp_file.sync();

        try std.fs.cwd().renameZ(tmp_path, self.path);
    }

    pub fn load(allocator: std.mem.Allocator, path: []const u8) !?Manifest {
        var buffer: [88]u8 = undefined;
        const file = std.fs.cwd().openFile(path, .{}) catch |err| {
            if (err == std.fs.File.OpenError.FileNotFound) return null;
            return err;
        };
        defer file.close();

        const bytes_read = try file.readAll(&buffer);
        if (bytes_read < 88) return null;

        var pos: usize = 0;
        const version = std.mem.readIntBig(u32, buffer[pos..][0..4]);
        pos += 4;
        if (version != constants.RECORD_VERSION) return null;

        const head_seq = std.mem.readIntBig(u64, buffer[pos..][0..8]);
        pos += 8;
        var head_hash: [32]u8 = undefined;
        @memcpy(&head_hash, buffer[pos..][0..32]);
        pos += 32;
        const head_ts = std.mem.readIntBig(u64, buffer[pos..][0..8]);
        pos += 8;
        const total = std.mem.readIntBig(u64, buffer[pos..][0..8]);

        return Manifest{
            .path = path,
            .head_sequence = head_seq,
            .head_hash = head_hash,
            .head_timestamp = head_ts,
            .total_records = total,
            .allocator = allocator,
        };
    }
};
