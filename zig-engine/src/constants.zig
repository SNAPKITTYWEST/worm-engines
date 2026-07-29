// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License + Business Source License 1.1.
// Change Date: December 31, 2027 — after which, licensed under AGPL-3.0-only.
// See LICENSE for complete terms.

const std = @import("std");

pub const MAX_SEGMENT_SIZE = 64 * 1024 * 1024;
pub const METADATA_VERSION = 1;
pub const CHECKSUM_SIZE = 4;
pub const LENGTH_PREFIX_SIZE = 4;
pub const HASH_SIZE = 32;
pub const SIGNATURE_SIZE = 64;
pub const RECORD_VERSION = 1;

pub const segment_filename_fmt = "segment-{:0>8}.log";
pub const manifest_filename = "MANIFEST";
pub const manifest_tmp_filename = "MANIFEST.tmp";
pub const ledger_base_path = ".worm/ledger";

pub const RecordFlags = struct {
    pub const UNCOMMITTED: u32 = 0;
    pub const COMMITTED: u32 = 1;
    pub const STREAM_EXHAUSTED: u32 = 2;
};

pub const ErrorCode = enum {
    ok,
    invalid_writer,
    invalid_record,
    sequence_mismatch,
    timestamp_invalid,
    hash_chain_broken,
    immutable_violation,
    writer_mismatch,
    policy_rollback,
    invalid_signature,
    invariant_violated,
    stream_not_initialized,
    io_error,
    corrupt_record,
    manifest_corrupt,
    sequence_overflow,
};
