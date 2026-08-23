// telemetry.zig — Forensic telemetry for the LOCKER WORM engine.
//
// Rules:
//   - Events are small, deterministic, structured JSON lines.
//   - Telemetry NEVER enters the WORM record chain unless explicitly
//     configured as a separate audit stream. Observation must not change
//     the thing being observed.
//   - NEVER log: record payload, signing keys, full hashes (fingerprint only),
//     writer material, tokens, secrets, raw policy input.
//
// Levels:
//   TRACE  frame/read/write detail
//   DEBUG  lifecycle internals
//   INFO   append/recover/sync success
//   WARN   truncation/recovery/anomalous state
//   ERROR  invariant/CRC/hash/manifest failure
//   FATAL  engine cannot establish trusted state

const std = @import("std");

// ── Level ─────────────────────────────────────────────────────────────────────

pub const Level = enum {
    trace,
    debug,
    info,
    warn,
    @"error",
    fatal,

    pub fn str(self: Level) []const u8 {
        return switch (self) {
            .trace   => "trace",
            .debug   => "debug",
            .info    => "info",
            .warn    => "warn",
            .@"error" => "error",
            .fatal   => "fatal",
        };
    }
};

// ── Telemetry sink ────────────────────────────────────────────────────────────

pub const Sink = struct {
    min_level: Level = .info,
    writer: ?std.io.AnyWriter = null,  // null = stderr
    engine_id: []const u8 = "zig-storage",

    pub fn emit(self: *const Sink, comptime fmt: []const u8, args: anytype) void {
        if (@typeInfo(@TypeOf(args)) == .Struct) {
            _ = args;
        }
        const w = self.writer orelse std.io.getStdErr().writer().any();
        w.print(fmt ++ "\n", args) catch {};
    }
};

// ── Module-level default sink ─────────────────────────────────────────────────

var _sink: Sink = .{};

pub fn setSink(s: Sink) void { _sink = s; }
pub fn getSink() *const Sink { return &_sink; }

// ── Event helpers ─────────────────────────────────────────────────────────────

/// Short hex fingerprint (first 8 bytes) — never log full hash material.
pub fn fingerprint(hash: *const [32]u8) [16]u8 {
    var buf: [16]u8 = undefined;
    _ = std.fmt.bufPrint(&buf, "{s}", .{std.fmt.fmtSliceHexLower(hash[0..8])})
        catch return buf;
    return buf;
}

// ── Engine lifecycle ──────────────────────────────────────────────────────────

pub fn engineCreate(path: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.engine.create","level":"info","engine":"{s}","path":"{s}"}}
    , .{ _sink.engine_id, path });
}

pub fn engineOpen(path: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.engine.open","level":"debug","engine":"{s}","path":"{s}"}}
    , .{ _sink.engine_id, path });
}

pub fn engineClose() void {
    _sink.emit(
        \\{{"event":"worm.engine.close","level":"info","engine":"{s}"}}
    , .{_sink.engine_id});
}

pub fn engineError(reason: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.engine.error","level":"error","engine":"{s}","reason":"{s}"}}
    , .{ _sink.engine_id, reason });
}

pub fn engineFatal(reason: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.engine.fatal","level":"fatal","engine":"{s}","reason":"{s}"}}
    , .{ _sink.engine_id, reason });
}

// ── Recovery ──────────────────────────────────────────────────────────────────

pub fn recoverStart(segment_name: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.engine.recover.start","level":"info","engine":"{s}","segment":"{s}"}}
    , .{ _sink.engine_id, segment_name });
}

pub fn recoverFrameValid(frame_idx: usize, offset: u64) void {
    _sink.emit(
        \\{{"event":"worm.recovery.frame_valid","level":"trace","engine":"{s}","frame":{d},"offset":{d}}}
    , .{ _sink.engine_id, frame_idx, offset });
}

pub fn recoverTruncate(valid_bytes: u64, reason: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.recovery.truncate","level":"warn","engine":"{s}","valid_bytes":{d},"reason":"{s}"}}
    , .{ _sink.engine_id, valid_bytes, reason });
}

pub fn recoverComplete(record_count: usize, valid_bytes: u64) void {
    _sink.emit(
        \\{{"event":"worm.engine.recover.complete","level":"info","engine":"{s}","records":{d},"valid_bytes":{d},"result":"ok"}}
    , .{ _sink.engine_id, record_count, valid_bytes });
}

// ── Record validation ─────────────────────────────────────────────────────────

pub fn recordValidate(sequence: u64) void {
    _sink.emit(
        \\{{"event":"worm.record.validate","level":"trace","engine":"{s}","sequence":{d}}}
    , .{ _sink.engine_id, sequence });
}

pub fn recordValidationFailed(sequence: u64, reason: []const u8) void {
    _sink.emit(
        \\{{"event":"worm.record.validation_failed","level":"error","engine":"{s}","sequence":{d},"reason":"{s}","result":"rejected"}}
    , .{ _sink.engine_id, sequence, reason });
}

// ── Append path ───────────────────────────────────────────────────────────────

pub fn appendStart(sequence: u64) void {
    _sink.emit(
        \\{{"event":"worm.record.append.start","level":"trace","engine":"{s}","sequence":{d}}}
    , .{ _sink.engine_id, sequence });
}

pub fn appendPersisted(sequence: u64) void {
    _sink.emit(
        \\{{"event":"worm.record.append.persisted","level":"debug","engine":"{s}","sequence":{d}}}
    , .{ _sink.engine_id, sequence });
}

pub fn appendComplete(sequence: u64, records_total: u64, duration_ns: u64) void {
    _sink.emit(
        \\{{"event":"worm.record.append.complete","level":"info","engine":"{s}","sequence":{d},"records_total":{d},"duration_ns":{d},"result":"ok"}}
    , .{ _sink.engine_id, sequence, records_total, duration_ns });
}

// ── Segment ───────────────────────────────────────────────────────────────────

pub fn segmentWrite(payload_len: usize, frame_len: usize) void {
    _sink.emit(
        \\{{"event":"worm.segment.write","level":"trace","engine":"{s}","payload_bytes":{d},"frame_bytes":{d}}}
    , .{ _sink.engine_id, payload_len, frame_len });
}

pub fn segmentFsync(duration_ns: u64) void {
    _sink.emit(
        \\{{"event":"worm.segment.fsync","level":"debug","engine":"{s}","duration_ns":{d}}}
    , .{ _sink.engine_id, duration_ns });
}

pub fn segmentCrcValid(frame_idx: usize) void {
    _sink.emit(
        \\{{"event":"worm.segment.crc_valid","level":"trace","engine":"{s}","frame":{d}}}
    , .{ _sink.engine_id, frame_idx });
}

pub fn segmentCrcFailed(frame_idx: usize, offset: u64) void {
    _sink.emit(
        \\{{"event":"worm.segment.crc_failed","level":"error","engine":"{s}","frame":{d},"offset":{d}}}
    , .{ _sink.engine_id, frame_idx, offset });
}

pub fn segmentTruncated(at_offset: u64) void {
    _sink.emit(
        \\{{"event":"worm.segment.truncated","level":"warn","engine":"{s}","at_offset":{d}}}
    , .{ _sink.engine_id, at_offset });
}

pub fn segmentRead(frame_version: u16, crc_ok: bool) void {
    _sink.emit(
        \\{{"event":"worm.segment.read","level":"trace","engine":"{s}","frame_version":{d},"crc_ok":{}}}
    , .{ _sink.engine_id, frame_version, crc_ok });
}

// ── Manifest ──────────────────────────────────────────────────────────────────

pub fn manifestSave(sequence: u64, head_fp: [16]u8) void {
    _sink.emit(
        \\{{"event":"worm.manifest.save","level":"debug","engine":"{s}","head_sequence":{d},"head_hash_fp":"{s}"}}
    , .{ _sink.engine_id, sequence, &head_fp });
}

pub fn manifestHeadAdvanced(old_seq: u64, new_seq: u64) void {
    _sink.emit(
        \\{{"event":"worm.manifest.head_advanced","level":"info","engine":"{s}","from":{d},"to":{d}}}
    , .{ _sink.engine_id, old_seq, new_seq });
}

// ── Hash chain ────────────────────────────────────────────────────────────────

pub fn hashChainValid(sequence: u64) void {
    _sink.emit(
        \\{{"event":"worm.chain.hash_valid","level":"trace","engine":"{s}","sequence":{d}}}
    , .{ _sink.engine_id, sequence });
}

/// Log hash chain break — use fingerprints, never full 32-byte hashes.
pub fn hashChainBroken(sequence: u64, expected_fp: [16]u8, got_fp: [16]u8) void {
    _sink.emit(
        \\{{"event":"worm.chain.hash_broken","level":"error","engine":"{s}","sequence":{d},"expected_fp":"{s}","got_fp":"{s}","result":"rejected"}}
    , .{ _sink.engine_id, sequence, &expected_fp, &got_fp });
}
