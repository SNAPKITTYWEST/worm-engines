// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

// WormWriter: Per-stream mutable state
const std = @import("std");
const WormRecord = @import("record.zig").WormRecord;

pub const WormWriter = struct {
    allocator: std.mem.Allocator,
    writer_id: [32]u8,
    stream_id: [32]u8 = [_]u8{0} ** 32,
    last_sequence: u64 = 0xFFFFFFFFFFFFFFFF,
    last_timestamp: u64 = 0,
    last_hash: [32]u8 = [_]u8{0} ** 32,
    last_policy_hash: [32]u8 = [_]u8{0} ** 32,
    initialized: bool = false,

    pub fn init(allocator: std.mem.Allocator, writer_id: [32]u8) !*WormWriter {
        const writer = try allocator.create(WormWriter);
        writer.* = WormWriter{
            .allocator = allocator,
            .writer_id = writer_id,
        };
        return writer;
    }

    pub fn deinit(self: *WormWriter) void {
        self.allocator.destroy(self);
    }

    pub fn initializeStream(self: *WormWriter, stream_id: [32]u8) void {
        self.stream_id = stream_id;
        self.last_sequence = 0xFFFFFFFFFFFFFFFF;
        self.initialized = true;
    }

    pub fn isInitialized(self: *const WormWriter) bool {
        return self.initialized;
    }

    pub fn getLastSequence(self: *const WormWriter) u64 {
        if (self.last_sequence == 0xFFFFFFFFFFFFFFFF) return 0xFFFFFFFFFFFFFFFF;
        return self.last_sequence;
    }

    pub fn getLastTimestamp(self: *const WormWriter) u64 {
        return self.last_timestamp;
    }

    pub fn getLastHash(self: *const WormWriter) [32]u8 {
        return self.last_hash;
    }

    pub fn getLastPolicyHash(self: *const WormWriter) [32]u8 {
        return self.last_policy_hash;
    }

    pub fn createRecord(self: *WormWriter, payload_hash: [32]u8, policy_hash: [32]u8) WormRecord {
        const sequence = if (self.last_sequence == 0xFFFFFFFFFFFFFFFF) 0 else self.last_sequence + 1;
        const timestamp = std.time.milliTimestamp();

        return WormRecord.init(
            self.stream_id,
            sequence,
            @intCast(timestamp),
            self.last_hash,
            payload_hash,
            policy_hash,
            self.writer_id,
        );
    }

    pub fn updateFromRecord(self: *WormWriter, record: *const WormRecord, record_hash: [32]u8) void {
        self.last_sequence = record.sequence;
        self.last_timestamp = record.timestamp;
        self.last_hash = record_hash;
        self.last_policy_hash = record.policy_hash;
    }
};
