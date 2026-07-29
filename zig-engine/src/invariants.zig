// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const WormWriter = @import("writer.zig").WormWriter;
const WormRecord = @import("record.zig").WormRecord;
pub const InvariantError = error{ SequenceNotMonotone };
pub fn validateAll(_: *WormWriter, _: *const WormRecord) !void {}
