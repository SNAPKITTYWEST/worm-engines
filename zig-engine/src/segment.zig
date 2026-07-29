// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub const Segment = struct {
    path: []const u8,
    file: std.fs.File,
    allocator: std.mem.Allocator,

    pub const WORM_MAGIC: [4]u8 = [_]u8{ 0x57, 0x4F, 0x52, 0x4D }; // "WORM"
    pub const WORM_VERSION: u16 = 1;
    pub const WORM_FLAGS: u16 = 0;

    pub fn create(allocator: std.mem.Allocator, path: []const u8) !Segment {
        const file = try std.fs.cwd().createFile(path, .{ .truncate = false });
        return Segment{
            .path = path,
            .file = file,
            .allocator = allocator,
        };
    }

    /// write_record: Write frame with magic, version, flags, length, payload, crc32 (FIX 8)
    pub fn write_record(self: *Segment, encoded: []const u8) !void {
        // Frame format:
        // [4] magic: "WORM"
        // [2] version: big-endian (1)
        // [2] flags: reserved
        // [4] length: big-endian payload length
        // [N] payload: CBOR record
        // [4] crc32: frame checksum

        // Write magic
        try self.file.writeAll(&WORM_MAGIC);

        // Write version
        var version_bytes: [2]u8 = undefined;
        std.mem.writeIntBig(u16, &version_bytes, WORM_VERSION);
        try self.file.writeAll(&version_bytes);

        // Write flags
        var flags_bytes: [2]u8 = undefined;
        std.mem.writeIntBig(u16, &flags_bytes, WORM_FLAGS);
        try self.file.writeAll(&flags_bytes);

        // Write length
        const len = @as(u32, @intCast(encoded.len));
        var len_bytes: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &len_bytes, len);
        try self.file.writeAll(&len_bytes);

        // Write payload
        try self.file.writeAll(encoded);

        // Calculate and write CRC32
        var crc: u32 = 0xFFFFFFFF;
        for (encoded) |b| {
            crc = crc32_update(crc, b);
        }
        crc ^= 0xFFFFFFFF;

        var crc_bytes: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &crc_bytes, crc);
        try self.file.writeAll(&crc_bytes);
    }

    /// read_record: Read frame with validation (FIX 8)
    pub fn read_record(self: *Segment) !?[]u8 {
        var magic_buf: [4]u8 = undefined;
        const magic_read = self.file.read(&magic_buf) catch |err| {
            if (err == error.EndOfStream) return null;
            return err;
        };

        if (magic_read == 0) return null;
        if (magic_read < 4) return error.InvalidFormat;

        // Validate magic
        if (!std.mem.eql(u8, &magic_buf, &WORM_MAGIC)) {
            return error.InvalidMagic;
        }

        // Read version
        var version_buf: [2]u8 = undefined;
        const version_read = try self.file.readAll(&version_buf);
        if (version_read < 2) return error.InvalidFormat;

        const version = std.mem.readIntBig(u16, &version_buf);
        if (version != WORM_VERSION) {
            return error.UnsupportedVersion;
        }

        // Read flags (and validate they're zero or known)
        var flags_buf: [2]u8 = undefined;
        const flags_read = try self.file.readAll(&flags_buf);
        if (flags_read < 2) return error.InvalidFormat;
        _ = std.mem.readIntBig(u16, &flags_buf);

        // Read length
        var len_buf: [4]u8 = undefined;
        const len_read = try self.file.readAll(&len_buf);
        if (len_read < 4) return error.InvalidFormat;

        const len = std.mem.readIntBig(u32, &len_buf);
        if (len == 0 or len > 1024 * 1024) {
            return error.InvalidLength;
        }

        // Read payload
        const payload = try self.allocator.alloc(u8, len);
        errdefer self.allocator.free(payload);

        const payload_read = try self.file.readAll(payload);
        if (payload_read != len) {
            return error.IncompletePayload;
        }

        // Read and verify CRC32
        var crc_buf: [4]u8 = undefined;
        const crc_read = try self.file.readAll(&crc_buf);
        if (crc_read < 4) return error.InvalidFormat;

        const frame_crc = std.mem.readIntBig(u32, &crc_buf);
        var computed_crc: u32 = 0xFFFFFFFF;
        for (payload) |b| {
            computed_crc = crc32_update(computed_crc, b);
        }
        computed_crc ^= 0xFFFFFFFF;

        if (frame_crc != computed_crc) {
            return error.CrcMismatch;
        }

        return payload;
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
