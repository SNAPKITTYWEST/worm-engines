// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub fn hash_record(record: *const constants.Record) ![32]u8 {
    var domain: [180]u8 = undefined;
    var pos: usize = 0;

    // domain_tag: 0x57 0x4F 0x52 0x4D ("WORM")
    domain[pos] = 0x57;
    pos += 1;
    domain[pos] = 0x4F;
    pos += 1;
    domain[pos] = 0x52;
    pos += 1;
    domain[pos] = 0x4D;
    pos += 1;

    // version (4 bytes, big-endian)
    std.mem.writeIntBig(u32, domain[pos..][0..4], record.version);
    pos += 4;

    // stream_id (32 bytes)
    @memcpy(domain[pos..][0..32], &record.stream_id);
    pos += 32;

    // sequence (8 bytes, big-endian)
    std.mem.writeIntBig(u64, domain[pos..][0..8], record.sequence);
    pos += 8;

    // previous_hash (32 bytes)
    @memcpy(domain[pos..][0..32], &record.previous_hash);
    pos += 32;

    // payload_hash (32 bytes)
    @memcpy(domain[pos..][0..32], &record.payload_hash);
    pos += 32;

    // policy_hash (32 bytes)
    @memcpy(domain[pos..][0..32], &record.policy_hash);
    pos += 32;

    // writer_id (32 bytes)
    @memcpy(domain[pos..][0..32], &record.writer_id);
    pos += 32;

    // flags (4 bytes, big-endian)
    std.mem.writeIntBig(u32, domain[pos..][0..4], record.flags);
    pos += 4;

    var hash: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(&domain, &hash, .{});
    return hash;
}
