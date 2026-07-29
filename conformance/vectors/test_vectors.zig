// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const constants = @import("../../zig-engine/src/constants.zig");
const codec = @import("../../zig-engine/src/codec.zig");
const hash_mod = @import("../../zig-engine/src/hash.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Genesis record: sequence 0, all hashes zero except payload
    var record: constants.Record = undefined;
    record.version = 1;
    @memset(&record.stream_id, 0xAA);
    record.sequence = 0;
    record.timestamp = 1000;
    @memset(&record.previous_hash, 0x00);
    @memset(&record.payload_hash, 0xBB);
    @memset(&record.policy_hash, 0x00);
    @memset(&record.writer_id, 0xCC);
    record.flags = 1;
    @memset(&record.signature, 0x00);

    // Encode to CBOR
    const encoded = try codec.encode_record(allocator, &record);
    
    // Print CBOR hex
    std.debug.print("CBOR Hex: ", .{});
    for (encoded[0..256]) |b| {
        std.debug.print("{x:0>2}", .{b});
    }
    std.debug.print("\n", .{});

    // Compute hash
    const hash = try hash_mod.hash_record(&record);
    
    // Print hash hex
    std.debug.print("Hash Hex: ", .{});
    for (hash) |b| {
        std.debug.print("{x:0>2}", .{b});
    }
    std.debug.print("\n", .{});

    // Verify determinism: encode again
    const encoded2 = try codec.encode_record(allocator, &record);
    const hash2 = try hash_mod.hash_record(&record);

    var cbor_match = true;
    for (encoded[0..256]) |b, i| {
        if (encoded2[i] != b) {
            cbor_match = false;
            break;
        }
    }

    var hash_match = true;
    for (hash) |b, i| {
        if (hash2[i] != b) {
            hash_match = false;
            break;
        }
    }

    std.debug.print("\nDeterminism Check:\n", .{});
    std.debug.print("CBOR Match: {}\n", .{cbor_match});
    std.debug.print("Hash Match: {}\n", .{hash_match});

    if (cbor_match and hash_match) {
        std.debug.print("\n✓ PASS: Deterministic encoding and hashing\n", .{});
        return;
    } else {
        std.debug.print("\n✗ FAIL: Non-deterministic output\n", .{});
        return error.NonDeterministic;
    }
}
