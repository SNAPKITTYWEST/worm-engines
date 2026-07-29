// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

const WormRecord = @import("record.zig").WormRecord;
pub const Error = error{ EncodeFailed };
pub fn encode(_: *const WormRecord, _: []u8) !usize {
    return 0;
}
