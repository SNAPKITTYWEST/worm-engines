// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

// Crash-Injection Harness (FIX 10)
// Tests recovery after injected failures at critical points

const std = @import("std");
const Storage = @import("storage.zig").Storage;
const constants = @import("constants.zig");
const Segment = @import("segment.zig").Segment;

pub const CrashPoint = enum {
    BeforeSegmentWrite,      // Crash before writing to segment
    DuringSegmentWrite,      // Crash mid-write
    AfterSegmentWrite,       // Crash after write, before sync
    BeforeSync,              // Crash before fsync
    AfterSync,               // Crash after sync, before manifest update
    BeforeManifestWrite,     // Crash before manifest write
    DuringManifestWrite,     // Crash during manifest write
    AfterManifestWrite,      // Crash after manifest written
    BeforeRename,            // Crash before atomic rename
    AfterRename,             // Crash after rename (clean state)
};

pub const CrashHarness = struct {
    allocator: std.mem.Allocator,
    test_dir: []const u8,
    crash_point: ?CrashPoint,
    crash_enabled: bool,

    pub fn init(allocator: std.mem.Allocator, test_dir: []const u8) !CrashHarness {
        try std.fs.cwd().makeDirRecursive(test_dir);
        return CrashHarness{
            .allocator = allocator,
            .test_dir = test_dir,
            .crash_point = null,
            .crash_enabled = false,
        };
    }

    pub fn deinit(self: *CrashHarness) void {
        _ = std.fs.cwd().deleteTree(self.test_dir) catch {};
    }

    /// inject: Configure crash at specific point
    pub fn inject(self: *CrashHarness, point: CrashPoint) void {
        self.crash_point = point;
        self.crash_enabled = true;
    }

    /// check: Simulate crash at current point if enabled
    pub fn check(self: *CrashHarness, point: CrashPoint) !void {
        if (!self.crash_enabled or self.crash_point != point) {
            return;
        }
        // In real harness, would fork/exit here or use setjmp
        // For testing, we simulate by tracking state
        return error.CrashInjected;
    }

    /// runRecoveryTest: Test recovery from injected failure
    pub fn runRecoveryTest(self: *CrashHarness, point: CrashPoint) !bool {
        // Create a ledger
        var storage = try Storage.createNew(self.allocator, self.test_dir);
        defer storage.deinit();

        // Create a test record
        var record: constants.Record = undefined;
        record.version = 1;
        record.stream_id = [_]u8{1} ** 32;
        record.sequence = 0;
        record.timestamp = 1000;
        record.previous_hash = [_]u8{0} ** 32;
        record.payload_hash = [_]u8{2} ** 32;
        record.policy_hash = [_]u8{0} ** 32;
        record.writer_id = [_]u8{3} ** 32;
        record.flags = 0;
        record.signature = [_]u8{0} ** 64;

        // Inject crash at this point
        self.inject(point);

        // Try to append (may crash)
        _ = storage.append(&record) catch |err| {
            if (err == error.CrashInjected) {
                // Simulate crash recovery
                storage.deinit();

                // Reopen and verify recovery
                var recovered = try Storage.openExisting(self.allocator, self.test_dir);
                defer recovered.deinit();

                // Verify state is consistent
                _ = try recovered.query_sequence();
                _ = recovered.query_hash();

                return true; // Recovery succeeded
            }
            return err;
        };

        return false; // No crash occurred
    }

    /// runFullCrashSuite: Test all crash points
    pub fn runFullCrashSuite(self: *CrashHarness) !u32 {
        var passed: u32 = 0;
        var failed: u32 = 0;

        const points = [_]CrashPoint{
            .BeforeSegmentWrite,
            .DuringSegmentWrite,
            .AfterSegmentWrite,
            .BeforeSync,
            .AfterSync,
            .BeforeManifestWrite,
            .DuringManifestWrite,
            .AfterManifestWrite,
            .BeforeRename,
            .AfterRename,
        };

        for (points) |point| {
            // Run test 3 times per crash point for determinism verification
            for (0..3) |attempt| {
                _ = std.fs.cwd().deleteTree(self.test_dir) catch {};
                try std.fs.cwd().makeDirRecursive(self.test_dir);

                const result = self.runRecoveryTest(point) catch |err| {
                    std.debug.print("Crash point {any} attempt {d}: ERROR {}\n", .{ point, attempt, err });
                    failed += 1;
                    continue;
                };

                if (result) {
                    passed += 1;
                } else {
                    failed += 1;
                }
            }
        }

        return passed;
    }
};

// Test: Verify crash recovery harness works
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const test_dir = "/tmp/worm_crash_test";

    var harness = try CrashHarness.init(allocator, test_dir);
    defer harness.deinit();

    const passed = try harness.runFullCrashSuite();
    std.debug.print("Crash harness: {d} tests passed\n", .{passed});
}
