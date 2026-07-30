/* WORM Engines C ABI
 * Stable C interface for cross-language integration (Erlang/OCaml/Python/etc.)
 * All functions deterministic and memory-safe.
 *
 * Copyright © 2026 Sovereign Source Foundation. All rights reserved.
 * Licensed under Business Source License 1.1.
 */

#ifndef WORM_H
#define WORM_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ===== OPAQUE TYPES ===== */

typedef struct worm_ledger worm_ledger_t;
typedef struct worm_record worm_record_t;

/* ===== ERROR CODES ===== */

typedef enum {
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
} worm_error_t;

/* ===== RECORD STRUCTURE ===== */

typedef struct {
  uint64_t sequence;
  uint64_t timestamp;
  uint8_t writer_id[32];
  uint8_t previous_hash[32];
  uint8_t *data;
  size_t data_len;
  uint32_t checksum;
} worm_record_t;

/* ===== LEDGER LIFECYCLE ===== */

/**
 * worm_ledger_create - Create a new ledger (fails if path exists)
 * @path: Directory path for ledger storage
 * @ledger: Output pointer to ledger handle
 * @return: WORM_OK on success, error code on failure
 *
 * Initializes a fresh ledger with empty segments and manifest.
 */
worm_error_t worm_ledger_create(const char *path, worm_ledger_t **ledger);

/**
 * worm_ledger_open - Open existing ledger and recover if needed
 * @path: Directory path for ledger storage
 * @ledger: Output pointer to ledger handle
 * @return: WORM_OK on success, error code on failure
 *
 * Opens ledger and runs deterministic recovery if manifest is missing/corrupt.
 */
worm_error_t worm_ledger_open(const char *path, worm_ledger_t **ledger);

/**
 * worm_ledger_open_or_create - Open ledger or create if missing
 * @path: Directory path for ledger storage
 * @ledger: Output pointer to ledger handle
 * @return: WORM_OK on success, error code on failure
 */
worm_error_t worm_ledger_open_or_create(const char *path, worm_ledger_t **ledger);

/**
 * worm_ledger_recover - Manually trigger recovery
 * @ledger: Ledger handle
 * @return: WORM_OK on success, error code on failure
 *
 * Scans segment file, validates CRC, rebuilds manifest.
 * Safe to call multiple times (idempotent).
 */
worm_error_t worm_ledger_recover(worm_ledger_t *ledger);

/**
 * worm_ledger_close - Close ledger and free resources
 * @ledger: Ledger handle
 */
void worm_ledger_close(worm_ledger_t *ledger);

/* ===== RECORD OPERATIONS ===== */

/**
 * worm_ledger_append - Append record to ledger
 * @ledger: Ledger handle
 * @record: Record to append (must pass validation)
 * @return: WORM_OK on success, error code on failure
 *
 * Validates record against all 12 invariants, then durably appends.
 * All writes are atomic: written to disk or not at all.
 */
worm_error_t worm_ledger_append(worm_ledger_t *ledger, const worm_record_t *record);

/**
 * worm_ledger_query_sequence - Get current sequence number
 * @ledger: Ledger handle
 * @sequence: Output sequence number
 * @return: WORM_OK on success
 */
worm_error_t worm_ledger_query_sequence(worm_ledger_t *ledger, uint64_t *sequence);

/**
 * worm_ledger_query_hash - Get current head hash
 * @ledger: Ledger handle
 * @hash: Output buffer (must be 32 bytes)
 * @return: WORM_OK on success
 */
worm_error_t worm_ledger_query_hash(worm_ledger_t *ledger, uint8_t hash[32]);

/**
 * worm_ledger_validate_record - Validate record before append
 * @ledger: Ledger handle
 * @record: Record to validate
 * @return: WORM_OK if valid, error code if invalid
 *
 * Checks all 12 invariants without appending.
 * Useful for policy engines or batch validation.
 */
worm_error_t worm_ledger_validate_record(worm_ledger_t *ledger, const worm_record_t *record);

/* ===== CRYPTOGRAPHY ===== */

/**
 * worm_sha256 - Compute SHA-256 hash (NIST FIPS 180-4)
 * @data: Input data
 * @data_len: Input length
 * @hash: Output buffer (must be 32 bytes)
 * @return: WORM_OK on success
 *
 * Deterministic SHA-256. Same input always produces same output.
 */
worm_error_t worm_sha256(const uint8_t *data, size_t data_len, uint8_t hash[32]);

/**
 * worm_crc32 - Compute CRC-32 (IEEE 802.3)
 * @data: Input data
 * @data_len: Input length
 * @crc: Output CRC value
 * @return: WORM_OK on success
 *
 * Detects single-bit and burst errors up to 32 bits.
 */
worm_error_t worm_crc32(const uint8_t *data, size_t data_len, uint32_t *crc);

/**
 * worm_sign_record - Sign record with Ed25519 private key
 * @record: Record to sign
 * @private_key: Ed25519 private key (32 bytes)
 * @signature: Output buffer (must be 64 bytes)
 * @return: WORM_OK on success
 *
 * Signs record hash (SHA-256) with Ed25519.
 * Signature is deterministic: same key always produces same signature.
 */
worm_error_t worm_sign_record(const worm_record_t *record, const uint8_t private_key[32], uint8_t signature[64]);

/**
 * worm_verify_record - Verify Ed25519 signature
 * @record: Record to verify
 * @public_key: Ed25519 public key (32 bytes)
 * @signature: Signature (64 bytes)
 * @return: WORM_OK if valid, error code if invalid
 */
worm_error_t worm_verify_record(const worm_record_t *record, const uint8_t public_key[32], const uint8_t signature[64]);

/* ===== CBOR CODEC ===== */

/**
 * worm_cbor_encode - Encode record to CBOR
 * @record: Record to encode
 * @cbor: Output buffer (at least 1024 bytes)
 * @cbor_len: Output length
 * @return: WORM_OK on success
 *
 * Deterministic CBOR encoding. Same record always produces same bytes.
 * Uses canonical CBOR (sorted keys, compact representation).
 */
worm_error_t worm_cbor_encode(const worm_record_t *record, uint8_t *cbor, size_t *cbor_len);

/**
 * worm_cbor_decode - Decode CBOR to record
 * @cbor: Input CBOR bytes
 * @cbor_len: Input length
 * @record: Output record
 * @return: WORM_OK on success
 */
worm_error_t worm_cbor_decode(const uint8_t *cbor, size_t cbor_len, worm_record_t *record);

/* ===== MEMORY MANAGEMENT ===== */

/**
 * worm_record_free - Free record allocated by C ABI
 * @record: Record pointer to free
 *
 * Call this for records allocated by C ABI functions.
 * Records passed to worm_ledger_append are not freed by the ABI.
 */
void worm_record_free(worm_record_t *record);

/**
 * worm_error_string - Get human-readable error message
 * @error: Error code
 * @return: Error message string
 */
const char *worm_error_string(worm_error_t error);

#ifdef __cplusplus
}
#endif

#endif /* WORM_H */
