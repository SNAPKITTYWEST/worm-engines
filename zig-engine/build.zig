// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License + Business Source License 1.1.
// Change Date: December 31, 2027 — after which, licensed under AGPL-3.0-only.
// See LICENSE for complete terms.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared library (for C interop)
    const lib = b.addSharedLibrary(.{
        .name = "worm_engine",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Export C symbols
    lib.linkLibC();

    b.installArtifact(lib);

    // Static library (for Zig consumers)
    const static_lib = b.addStaticLibrary(.{
        .name = "worm_engine_static",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(static_lib);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
