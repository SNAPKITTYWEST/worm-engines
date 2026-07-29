// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("constants.zig");

pub fn encode_record(allocator: std.mem.Allocator, record: *const constants.Record) ![512]u8 {
    _ = allocator;
    var buffer: [512]u8 = undefined;
    var pos: usize = 0;

    // CBOR map with 10 fields
    buffer[pos] = 0xa9;
    pos += 1;

    // version
    buffer[pos] = 0x00;
    pos += 1;
    buffer[pos] = 0x18;
    pos += 1;
    buffer[pos] = @as(u8, @intCast(record.version & 0xFF));
    pos += 1;

    // stream_id
    buffer[pos] = 0x01;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 32;
    pos += 1;
    @memcpy(buffer[pos..][0..32], &record.stream_id);
    pos += 32;

    // sequence
    buffer[pos] = 0x02;
    pos += 1;
    buffer[pos] = 0x1b;
    pos += 1;
    std.mem.writeIntBig(u64, buffer[pos..][0..8], record.sequence);
    pos += 8;

    // timestamp
    buffer[pos] = 0x03;
    pos += 1;
    buffer[pos] = 0x1b;
    pos += 1;
    std.mem.writeIntBig(u64, buffer[pos..][0..8], record.timestamp);
    pos += 8;

    // previous_hash
    buffer[pos] = 0x04;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 32;
    pos += 1;
    @memcpy(buffer[pos..][0..32], &record.previous_hash);
    pos += 32;

    // payload_hash
    buffer[pos] = 0x05;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 32;
    pos += 1;
    @memcpy(buffer[pos..][0..32], &record.payload_hash);
    pos += 32;

    // policy_hash
    buffer[pos] = 0x06;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 32;
    pos += 1;
    @memcpy(buffer[pos..][0..32], &record.policy_hash);
    pos += 32;

    // writer_id
    buffer[pos] = 0x07;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 32;
    pos += 1;
    @memcpy(buffer[pos..][0..32], &record.writer_id);
    pos += 32;

    // flags
    buffer[pos] = 0x08;
    pos += 1;
    buffer[pos] = 0x1a;
    pos += 1;
    std.mem.writeIntBig(u32, buffer[pos..][0..4], record.flags);
    pos += 4;

    // signature
    buffer[pos] = 0x09;
    pos += 1;
    buffer[pos] = 0x58;
    pos += 1;
    buffer[pos] = 64;
    pos += 1;
    @memcpy(buffer[pos..][0..64], &record.signature);
    pos += 64;

    var result: [512]u8 = undefined;
    @memcpy(result[0..pos], buffer[0..pos]);
    return result;
}
