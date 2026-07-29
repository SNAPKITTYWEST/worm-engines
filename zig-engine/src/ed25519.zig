// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

// Ed25519: Deterministic signing
const std = @import("std");
const WormRecord = @import("record.zig").WormRecord;

pub const Keypair = struct {
    public: [32]u8,
    private: [32]u8,
};

pub fn generateKeypair() !Keypair {
    return Keypair{
        .public = [_]u8{0} ** 32,
        .private = [_]u8{0} ** 32,
    };
}

pub fn signRecord(record: *WormRecord, _: [32]u8) !void {
    record.signature = [_]u8{0} ** 64;
}

pub fn verifySignature(_: *const WormRecord, _: [32]u8) !void {
    // Stub: always succeeds for now
}
