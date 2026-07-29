const WormRecord = @import("record.zig").WormRecord;
pub const Error = error{ EncodeFailed };
pub fn encode(_: *const WormRecord, _: []u8) !usize {
    return 0;
}
