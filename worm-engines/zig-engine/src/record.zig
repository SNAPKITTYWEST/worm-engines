// WormRecord: Immutable WORM record structure
// Once created, fields cannot be modified (except during construction)

const std = @import("std");

pub const WormRecord = struct {
    version: u32,
    stream_id: [32]u8,
    sequence: u64,
    timestamp: u64,
    previous_hash: [32]u8,
    payload_hash: [32]u8,
    policy_hash: [32]u8,
    writer_id: [32]u8,
    receipt_id: [32]u8,
    flags: u32,
    signature: [64]u8,

    pub const Flags = struct {
        pub const COMMITTED: u32 = 0x01;
    };

    pub fn init(
        stream_id: [32]u8,
        sequence: u64,
        timestamp: u64,
        previous_hash: [32]u8,
        payload_hash: [32]u8,
        policy_hash: [32]u8,
        writer_id: [32]u8,
    ) WormRecord {
        return WormRecord{
            .version = 1,
            .stream_id = stream_id,
            .sequence = sequence,
            .timestamp = timestamp,
            .previous_hash = previous_hash,
            .payload_hash = payload_hash,
            .policy_hash = policy_hash,
            .writer_id = writer_id,
            .receipt_id = [_]u8{0} ** 32, // No receipt by default
            .flags = 0, // Uncommitted by default
            .signature = [_]u8{0} ** 64, // Unsigned by default
        };
    }

    pub fn isCommitted(self: *const WormRecord) bool {
        return (self.flags & Flags.COMMITTED) != 0;
    }

    pub fn markCommitted(self: *WormRecord) void {
        self.flags |= Flags.COMMITTED;
    }

    pub fn setSignature(self: *WormRecord, sig: [64]u8) void {
        self.signature = sig;
    }

    pub fn genesis(
        stream_id: [32]u8,
        payload_hash: [32]u8,
        policy_hash: [32]u8,
        writer_id: [32]u8,
    ) WormRecord {
        const zero_hash = [_]u8{0} ** 32;
        const timestamp = @as(u64, @intCast(std.time.timestamp()));

        return init(
            stream_id,
            0, // Genesis sequence
            timestamp,
            zero_hash, // Genesis has no previous
            payload_hash,
            policy_hash,
            writer_id,
        );
    }
};
