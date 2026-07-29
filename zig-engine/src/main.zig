// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const std = @import("std");
const WormWriter = @import("writer.zig").WormWriter;

pub const WORM_OK: i32 = 0;

export fn worm_init_writer(_: [*c]const u8) ?*WormWriter {
    return null;
}

export fn worm_free(_: ?*anyopaque) void {}

test "zig engine imports" {
    const testing = std.testing;
    try testing.expect(true);
}
