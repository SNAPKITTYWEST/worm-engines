// WormRecord: Immutable record structure
const std = @import("std");

pub const WormRecord = struct {
    version: u32 = 1,
    stream_id: [32]u8,
    sequence: u64,
    timestamp: u64,
    previous_hash: [32]u8,
    payload_hash: [32]u8,
    policy_hash: [32]u8,
    writer_id: [32]u8,
    receipt_id: [32]u8 = [_]u8{0} ** 32,
    flags: u32 = 0,
    signature: [64]u8 = [_]u8{0} ** 64,
    committed: bool = false,

    pub fn genesis(stream_id: [32]u8, payload_hash: [32]u8, policy_hash: [32]u8, writer_id: [32]u8) WormRecord {
        return WormRecord{
            .stream_id = stream_id,
            .sequence = 0,
            .timestamp = 0,
            .previous_hash = [_]u8{0} ** 32,
            .payload_hash = payload_hash,
            .policy_hash = policy_hash,
            .writer_id = writer_id,
        };
    }

    pub fn init(stream_id: [32]u8, sequence: u64, timestamp: u64, previous_hash: [32]u8, payload_hash: [32]u8, policy_hash: [32]u8, writer_id: [32]u8) WormRecord {
        return WormRecord{
            .stream_id = stream_id,
            .sequence = sequence,
            .timestamp = timestamp,
            .previous_hash = previous_hash,
            .payload_hash = payload_hash,
            .policy_hash = policy_hash,
            .writer_id = writer_id,
        };
    }

    pub fn markCommitted(self: *WormRecord) void {
        self.committed = true;
    }
};
