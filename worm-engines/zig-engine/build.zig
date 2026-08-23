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

    // Individual test modules
    const test_files = [_][]const u8{
        "src/hash.zig",
        "src/cbor.zig",
        "src/ed25519.zig",
        "src/invariants.zig",
        "src/storage.zig",
    };

    for (test_files) |test_file| {
        const module_test = b.addTest(.{
            .root_source_file = b.path(test_file),
            .target = target,
            .optimize = optimize,
        });

        const run_module_test = b.addRunArtifact(module_test);
        test_step.dependOn(&run_module_test.step);
    }
}
