// record.zig — Immutable LOCKER record (post-quantum, ML-DSA-44)
//
// Signature field upgraded from Ed25519 [64]u8 to ML-DSA-44 [2420]u8.
// writer_id remains [32]u8 — it is the SHA-256 identity hash derived
// from the ML-DSA public key (see pq_sign.deriveWriterId).
//
// LOCKER record format version: 2

const std = @import("std");
const ml = @import("ml_dsa.zig");

pub const SIG_LEN: usize = ml.SIG_LEN;   // 2420 bytes (ML-DSA-44)
pub const RECORD_VERSION: u32 = 2;

pub const WormRecord = struct {
    version: u32,
    stream_id: [32]u8,
    sequence: u64,
    timestamp: u64,
    previous_hash: [32]u8,
    payload_hash: [32]u8,
    policy_hash: [32]u8,
    writer_id: [32]u8,       // H(ml_dsa_public_key || "LOCKER-WRITER-ID-v1")
    receipt_id: [32]u8,
    flags: u32,
    signature: [SIG_LEN]u8, // ML-DSA-44: 2420 bytes

    pub const Flags = struct {
        pub const COMMITTED: u32 = 0x01;
        pub const PQ_SIGNED: u32 = 0x02;  // Record uses ML-DSA-44 signature
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
            .version = RECORD_VERSION,
            .stream_id = stream_id,
            .sequence = sequence,
            .timestamp = timestamp,
            .previous_hash = previous_hash,
            .payload_hash = payload_hash,
            .policy_hash = policy_hash,
            .writer_id = writer_id,
            .receipt_id = [_]u8{0} ** 32,
            .flags = 0,
            .signature = [_]u8{0} ** SIG_LEN,
        };
    }

    pub fn isCommitted(self: *const WormRecord) bool {
        return (self.flags & Flags.COMMITTED) != 0;
    }

    pub fn isPqSigned(self: *const WormRecord) bool {
        return (self.flags & Flags.PQ_SIGNED) != 0;
    }

    pub fn markCommitted(self: *WormRecord) void {
        self.flags |= Flags.COMMITTED;
    }

    pub fn setSignature(self: *WormRecord, sig: [SIG_LEN]u8) void {
        self.signature = sig;
        self.flags |= Flags.PQ_SIGNED;
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
            0,
            timestamp,
            zero_hash,
            payload_hash,
            policy_hash,
            writer_id,
        );
    }
};
