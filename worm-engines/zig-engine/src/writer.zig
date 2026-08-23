// WormWriter: Per-stream mutable state machine
// Tracks sequence progression and enforces invariants

const std = @import("std");
const WormRecord = @import("record.zig").WormRecord;

pub const WormWriter = struct {
    writer_id: [32]u8,
    stream_id: [32]u8,
    last_sequence: u64,
    last_hash: [32]u8,
    last_timestamp: u64,
    last_policy_hash: [32]u8,
    is_initialized: bool,
    mutex: std.Thread.Mutex,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, writer_id: [32]u8) !*WormWriter {
        const writer = try allocator.create(WormWriter);
        writer.* = WormWriter{
            .writer_id = writer_id,
            .stream_id = [_]u8{0} ** 32,
            .last_sequence = 0,
            .last_hash = [_]u8{0} ** 32,
            .last_timestamp = 0,
            .last_policy_hash = [_]u8{0} ** 32,
            .is_initialized = false,
            .mutex = std.Thread.Mutex{},
            .allocator = allocator,
        };
        return writer;
    }

    pub fn deinit(self: *WormWriter) void {
        self.allocator.destroy(self);
    }

    pub fn initializeStream(self: *WormWriter, stream_id: [32]u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.stream_id = stream_id;
        self.is_initialized = true;
    }

    pub fn updateFromRecord(self: *WormWriter, record: *const WormRecord, record_hash: [32]u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (!self.is_initialized) {
            self.stream_id = record.stream_id;
            self.is_initialized = true;
        }

        self.last_sequence = record.sequence;
        self.last_hash = record_hash;
        self.last_timestamp = record.timestamp;
        self.last_policy_hash = record.policy_hash;
    }

    pub fn getLastSequence(self: *WormWriter) u64 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.last_sequence;
    }

    pub fn getLastHash(self: *WormWriter) [32]u8 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.last_hash;
    }

    pub fn getLastTimestamp(self: *WormWriter) u64 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.last_timestamp;
    }

    pub fn getLastPolicyHash(self: *WormWriter) [32]u8 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.last_policy_hash;
    }

    pub fn createRecord(
        self: *WormWriter,
        payload_hash: [32]u8,
        policy_hash: [32]u8,
    ) WormRecord {
        self.mutex.lock();
        defer self.mutex.unlock();

        const timestamp = @as(u64, @intCast(std.time.timestamp()));
        const next_sequence = if (self.is_initialized) self.last_sequence + 1 else 0;
        const previous_hash = if (self.is_initialized) self.last_hash else [_]u8{0} ** 32;

        return WormRecord.init(
            self.stream_id,
            next_sequence,
            timestamp,
            previous_hash,
            payload_hash,
            policy_hash,
            self.writer_id,
        );
    }

    pub fn isInitialized(self: *WormWriter) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.is_initialized;
    }
};
