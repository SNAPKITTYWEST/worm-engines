// constants.zig — Shared types and error codes for LOCKER / WORM Engine
// This file defines the Record type and shared constants used across
// storage.zig, abi.zig, and segment.zig.

const std = @import("std");

/// The canonical WORM record type used by the storage and ABI layers.
/// This mirrors WormRecord in record.zig but is the flat C-ABI-safe version
/// used for encode/decode operations in the storage layer.
pub const Record = struct {
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

    pub fn isGenesis(self: *const Record) bool {
        return self.sequence == 0;
    }

    pub fn isCommitted(self: *const Record) bool {
        return (self.flags & 0x01) != 0;
    }
};

pub const WORM_VERSION: u32 = 1;
pub const STREAM_ID_LEN: usize = 32;
pub const HASH_LEN: usize = 32;
pub const SIG_LEN: usize = 64;

pub const Error = error{
    InvalidRecord,
    SequenceMismatch,
    HashChainBroken,
    TimestampInvalid,
    WriterMismatch,
    PolicyRollback,
    SignatureInvalid,
    BufferTooSmall,
    OutOfMemory,
    InvariantViolated,
    StreamNotInitialized,
};
