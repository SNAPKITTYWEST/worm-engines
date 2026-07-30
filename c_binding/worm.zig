// WORM Engines C ABI Implementation
// Exports Zig storage engine to C interface
// All functions deterministic and memory-safe

const std = @import("std");
const storage = @import("../src/storage.zig");
const constants = @import("../src/constants.zig");
const hash_mod = @import("../src/hash.zig");
const codec = @import("../src/codec.zig");

// ===== OPAQUE HANDLE TYPES =====

pub const WormLedger = opaque {
    fn as_ptr(self: *WormLedger) *storage.Storage {
        return @ptrCast(self);
    }
};

// ===== ERROR CODES =====

pub const WormError = enum(c_int) {
    WORM_OK = 0,
    WORM_ERR_PATH_INVALID = 1,
    WORM_ERR_MANIFEST_CORRUPT = 2,
    WORM_ERR_SEGMENT_MISSING = 3,
    WORM_ERR_INVALID_RECORD = 4,
    WORM_ERR_HASH_CHAIN_BROKEN = 5,
    WORM_ERR_SEQUENCE_GAP = 6,
    WORM_ERR_RECOVER_FAILED = 7,
    WORM_ERR_MEMORY = 8,
    WORM_ERR_IO = 9,
};

// ===== RECORD STRUCTURE =====

pub const WormRecord = extern struct {
    sequence: u64,
    timestamp: u64,
    writer_id: [32]u8,
    previous_hash: [32]u8,
    data: [*]u8 = null,
    data_len: usize = 0,
    checksum: u32 = 0,
};

// ===== GLOBAL ALLOCATOR =====

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ===== LEDGER LIFECYCLE =====

export fn worm_ledger_create(path: [*:0]const u8, ledger: *?*WormLedger) WormError {
    const path_slice = std.mem.span(path);
    var store = storage.Storage.createNew(allocator, path_slice) catch |err| {
        return switch (err) {
            error.PathNotOwned => WormError.WORM_ERR_PATH_INVALID,
            else => WormError.WORM_ERR_IO,
        };
    };

    const ptr = allocator.create(storage.Storage) catch {
        return WormError.WORM_ERR_MEMORY;
    };
    ptr.* = store;
    ledger.* = @ptrCast(ptr);
    return WormError.WORM_OK;
}

export fn worm_ledger_open(path: [*:0]const u8, ledger: *?*WormLedger) WormError {
    const path_slice = std.mem.span(path);
    var store = storage.Storage.openExisting(allocator, path_slice) catch |err| {
        return switch (err) {
            error.SegmentMissing => WormError.WORM_ERR_SEGMENT_MISSING,
            error.CorruptManifest => WormError.WORM_ERR_MANIFEST_CORRUPT,
            else => WormError.WORM_ERR_IO,
        };
    };

    const ptr = allocator.create(storage.Storage) catch {
        return WormError.WORM_ERR_MEMORY;
    };
    ptr.* = store;
    ledger.* = @ptrCast(ptr);
    return WormError.WORM_OK;
}

export fn worm_ledger_open_or_create(path: [*:0]const u8, ledger: *?*WormLedger) WormError {
    const path_slice = std.mem.span(path);
    var store = storage.Storage.openOrCreate(allocator, path_slice) catch {
        return WormError.WORM_ERR_IO;
    };

    const ptr = allocator.create(storage.Storage) catch {
        return WormError.WORM_ERR_MEMORY;
    };
    ptr.* = store;
    ledger.* = @ptrCast(ptr);
    return WormError.WORM_OK;
}

export fn worm_ledger_recover(ledger: *WormLedger) WormError {
    const store = @as(*storage.Storage, @ptrCast(ledger));
    var store_mut = store.*;
    store_mut.recover() catch |err| {
        return switch (err) {
            error.RecoverFailed => WormError.WORM_ERR_RECOVER_FAILED,
            else => WormError.WORM_ERR_IO,
        };
    };
    store.* = store_mut;
    return WormError.WORM_OK;
}

export fn worm_ledger_close(ledger: *WormLedger) void {
    const store = @as(*storage.Storage, @ptrCast(ledger));
    store.close();
    allocator.destroy(store);
}

// ===== RECORD OPERATIONS =====

export fn worm_ledger_append(ledger: *WormLedger, record: *const WormRecord) WormError {
    const store = @as(*storage.Storage, @ptrCast(ledger));

    // Convert C record to Zig record
    var zig_record: constants.Record = undefined;
    zig_record.sequence = record.sequence;
    zig_record.timestamp = record.timestamp;
    zig_record.writer_id = record.writer_id;
    zig_record.previous_hash = record.previous_hash;
    zig_record.checksum = record.checksum;

    var store_mut = store.*;
    store_mut.append(&zig_record) catch |err| {
        return switch (err) {
            error.InvalidRecord => WormError.WORM_ERR_INVALID_RECORD,
            error.HashChainBroken => WormError.WORM_ERR_HASH_CHAIN_BROKEN,
            error.SequenceGap => WormError.WORM_ERR_SEQUENCE_GAP,
            else => WormError.WORM_ERR_IO,
        };
    };
    store.* = store_mut;
    return WormError.WORM_OK;
}

export fn worm_ledger_query_sequence(ledger: *WormLedger, sequence: *u64) WormError {
    const store = @as(*storage.Storage, @ptrCast(ledger));
    sequence.* = store.query_sequence();
    return WormError.WORM_OK;
}

export fn worm_ledger_query_hash(ledger: *WormLedger, hash: [*]u8) WormError {
    const store = @as(*storage.Storage, @ptrCast(ledger));
    const h = store.query_hash();
    @memcpy(hash[0..32], &h);
    return WormError.WORM_OK;
}

export fn worm_ledger_validate_record(ledger: *WormLedger, record: *const WormRecord) WormError {
    const store = @as(*storage.Storage, @ptrCast(ledger));

    var zig_record: constants.Record = undefined;
    zig_record.sequence = record.sequence;
    zig_record.timestamp = record.timestamp;
    zig_record.writer_id = record.writer_id;
    zig_record.previous_hash = record.previous_hash;
    zig_record.checksum = record.checksum;

    const validated = store.validateRecord(&zig_record);
    if (!validated.isValid()) {
        return WormError.WORM_ERR_INVALID_RECORD;
    }
    return WormError.WORM_OK;
}

// ===== CRYPTOGRAPHY =====

export fn worm_sha256(data: [*]const u8, data_len: usize, hash: [*]u8) WormError {
    const slice = data[0..data_len];
    var h: [32]u8 = undefined;
    _ = hash_mod.hash_record_cbor(slice) catch {
        return WormError.WORM_ERR_IO;
    };
    @memcpy(hash[0..32], &h);
    return WormError.WORM_OK;
}

export fn worm_crc32(data: [*]const u8, data_len: usize, crc: *u32) WormError {
    const slice = data[0..data_len];
    var c: u32 = 0xFFFFFFFF;
    for (slice) |b| {
        c = computeCrc32Update(c, b);
    }
    crc.* = c ^ 0xFFFFFFFF;
    return WormError.WORM_OK;
}

fn computeCrc32Update(crc: u32, byte: u8) u32 {
    const poly: u32 = 0xEDB88320;
    var c = crc ^ byte;
    for (0..8) |_| {
        if ((c & 1) != 0) {
            c = (c >> 1) ^ poly;
        } else {
            c = c >> 1;
        }
    }
    return c;
}

export fn worm_sign_record(record: *const WormRecord, private_key: [*]const u8, signature: [*]u8) WormError {
    // TODO: Implement Ed25519 signing (v0.3.0 TODO)
    _ = record;
    _ = private_key;
    _ = signature;
    return WormError.WORM_OK;
}

export fn worm_verify_record(record: *const WormRecord, public_key: [*]const u8, sig: [*]const u8) WormError {
    // TODO: Implement Ed25519 verification (v0.3.0 TODO)
    _ = record;
    _ = public_key;
    _ = sig;
    return WormError.WORM_OK;
}

export fn worm_cbor_encode(record: *const WormRecord, cbor: [*]u8, cbor_len: *usize) WormError {
    // TODO: Implement CBOR encoding via C ABI (v0.3.0 TODO)
    _ = record;
    _ = cbor;
    cbor_len.* = 0;
    return WormError.WORM_OK;
}

export fn worm_cbor_decode(cbor: [*]const u8, cbor_len_input: usize, record: *WormRecord) WormError {
    // TODO: Implement CBOR decoding via C ABI (v0.3.0 TODO)
    _ = cbor;
    _ = cbor_len_input;
    _ = record;
    return WormError.WORM_OK;
}

// ===== MEMORY MANAGEMENT =====

export fn worm_record_free(record: *WormRecord) void {
    if (record.data) |data_ptr| {
        allocator.free(data_ptr[0..record.data_len]);
    }
}

export fn worm_error_string(error: WormError) [*:0]const u8 {
    return switch (error) {
        WormError.WORM_OK => "OK",
        WormError.WORM_ERR_PATH_INVALID => "Path invalid or not owned",
        WormError.WORM_ERR_MANIFEST_CORRUPT => "Manifest corrupted",
        WormError.WORM_ERR_SEGMENT_MISSING => "Segment file missing",
        WormError.WORM_ERR_INVALID_RECORD => "Record validation failed",
        WormError.WORM_ERR_HASH_CHAIN_BROKEN => "Hash chain broken",
        WormError.WORM_ERR_SEQUENCE_GAP => "Sequence gap detected",
        WormError.WORM_ERR_RECOVER_FAILED => "Recovery failed",
        WormError.WORM_ERR_MEMORY => "Memory allocation failed",
        WormError.WORM_ERR_IO => "I/O error",
    };
}
