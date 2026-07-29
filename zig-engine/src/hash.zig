const WormRecord = @import("record.zig").WormRecord;
pub const HASH_DOMAIN_SIZE: usize = 180;
pub fn hashRecord(_: *const WormRecord) [32]u8 {
    return [_]u8{0} ** 32;
}
