// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub const Segment = struct {
    path: []const u8,
    file: std.fs.File,
    allocator: std.mem.Allocator,

    pub fn create(allocator: std.mem.Allocator, path: []const u8) !Segment {
        const file = try std.fs.cwd().createFile(path, .{ .truncate = false });
        return Segment{
            .path = path,
            .file = file,
            .allocator = allocator,
        };
    }

    pub fn write_record(self: *Segment, encoded: []const u8) !void {
        const len = @as(u32, @intCast(encoded.len));
        var len_bytes: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &len_bytes, len);
        try self.file.writeAll(&len_bytes);
        try self.file.writeAll(encoded);

        var crc: u32 = 0xFFFFFFFF;
        for (encoded) |b| {
            crc = crc32_update(crc, b);
        }
        crc ^= 0xFFFFFFFF;

        var crc_bytes: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &crc_bytes, crc);
        try self.file.writeAll(&crc_bytes);
    }

    pub fn fsync(self: *Segment) !void {
        try self.file.sync();
    }

    pub fn close(self: *Segment) void {
        self.file.close();
    }

    fn crc32_update(crc: u32, byte: u8) u32 {
        const poly: u32 = 0xEDB88320;
        var c = crc ^ byte;
        for (0..8) |_| {
            if ((c & 1) != 0) {
                c = (c >> 1) ^ poly;
            } else {
                c = c >> 1;
            }
        }
        return c;
    }
};
