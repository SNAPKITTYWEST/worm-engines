const WormWriter = @import("writer.zig").WormWriter;
const WormRecord = @import("record.zig").WormRecord;
pub const InvariantError = error{ SequenceNotMonotone };
pub fn validateAll(_: *WormWriter, _: *const WormRecord) !void {}
