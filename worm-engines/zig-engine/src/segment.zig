// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub const Segment = struct {
    path: []const u8,
    file: std.fs.File,
    allocator: std.mem.Allocator,

    pub const MAGIC: u32 = 0x574F524D; // "WORM"
    pub const VERSION: u16 = 1;

    pub const SegmentError = error{
        InvalidMagic,
        UnsupportedVersion,
        CorruptFrame,
    };

    pub fn create(allocator: std.mem.Allocator, path: []const u8) !Segment {
        const file = try std.fs.cwd().createFile(path, .{ .truncate = false });
        return Segment{
            .path = path,
            .file = file,
            .allocator = allocator,
        };
    }

    pub fn write_record(self: *Segment, encoded: []const u8) !void {
        // Frame format:
        // magic (4) + version (2) + flags (2) + length (4) + payload + crc32 (4)

        var frame: [12]u8 = undefined;
        var pos: usize = 0;

        // Write magic
        std.mem.writeIntBig(u32, frame[pos..][0..4], MAGIC);
        pos += 4;

        // Write version
        std.mem.writeIntBig(u16, frame[pos..][0..2], VERSION);
        pos += 2;

        // Write flags (reserved, all zero)
        std.mem.writeIntBig(u16, frame[pos..][0..2], 0);
        pos += 2;

        // Write length
        const len = @as(u32, @intCast(encoded.len));
        std.mem.writeIntBig(u32, frame[pos..][0..4], len);
        pos += 4;

        // Write frame header
        try self.file.writeAll(&frame);
        try self.file.writeAll(encoded);

        // Compute and write CRC
        var crc: u32 = 0xFFFFFFFF;
        for (&frame) |b| {
            crc = crc32_update(crc, b);
        }
        for (encoded) |b| {
            crc = crc32_update(crc, b);
        }
        crc ^= 0xFFFFFFFF;

        var crc_bytes: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &crc_bytes, crc);
        try self.file.writeAll(&crc_bytes);
    }

    pub fn read_frame(self: *Segment) !?struct { magic: u32, version: u16, payload: []u8 } {
        var frame_header: [12]u8 = undefined;

        const read_len = self.file.read(&frame_header) catch |err| {
            if (err == error.EndOfStream) return null;
            return err;
        };

        if (read_len == 0) return null;
        if (read_len != 12) return error.CorruptFrame;

        var pos: usize = 0;

        // Read and validate magic
        const magic = std.mem.readIntBig(u32, frame_header[pos..][0..4]);
        pos += 4;
        if (magic != MAGIC) return error.InvalidMagic;

        // Read version
        const version = std.mem.readIntBig(u16, frame_header[pos..][0..2]);
        pos += 2;
        if (version != VERSION) {
            // Unknown version - skip gracefully
            pos += 2; // skip flags
            const length = std.mem.readIntBig(u32, frame_header[pos..][0..4]);
            // Skip payload + CRC
            _ = try self.file.seekBy(length + 4);
            return null;
        }

        // Skip flags (reserved)
        pos += 2;

        // Read length
        const length = std.mem.readIntBig(u32, frame_header[pos..][0..4]);

        // Read payload
        var payload = try self.allocator.alloc(u8, length);
        const payload_read = try self.file.readAll(payload);
        if (payload_read != length) {
            self.allocator.free(payload);
            return error.CorruptFrame;
        }

        // Read and validate CRC
        var crc_bytes: [4]u8 = undefined;
        const crc_read = self.file.read(&crc_bytes) catch |err| {
            self.allocator.free(payload);
            if (err == error.EndOfStream) return error.CorruptFrame;
            return err;
        };

        if (crc_read != 4) {
            self.allocator.free(payload);
            return error.CorruptFrame;
        }

        const stored_crc = std.mem.readIntBig(u32, &crc_bytes);
        var computed_crc: u32 = 0xFFFFFFFF;
        for (&frame_header) |b| {
            computed_crc = crc32_update(computed_crc, b);
        }
        for (payload) |b| {
            computed_crc = crc32_update(computed_crc, b);
        }
        computed_crc ^= 0xFFFFFFFF;

        if (stored_crc != computed_crc) {
            self.allocator.free(payload);
            return error.CorruptFrame;
        }

        return .{
            .magic = magic,
            .version = version,
            .payload = payload,
        };
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
