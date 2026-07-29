// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

#ifndef WORM_ABI_H
#define WORM_ABI_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef int32_t WormError;

#define WORM_OK 0
#define WORM_ERR_INVALID_WRITER -1
#define WORM_ERR_INVALID_RECORD -2
#define WORM_ERR_INVALID_BUFFER -3
#define WORM_ERR_INVALID_SIGNATURE -4
#define WORM_ERR_SEQUENCE_MISMATCH -5
#define WORM_ERR_TIMESTAMP_INVALID -6
#define WORM_ERR_HASH_CHAIN_BROKEN -7
#define WORM_ERR_IMMUTABLE_VIOLATION -8
#define WORM_ERR_WRITER_MISMATCH -9
#define WORM_ERR_POLICY_ROLLBACK -10
#define WORM_ERR_CBOR_ENCODE_FAILED -11
#define WORM_ERR_CBOR_DECODE_FAILED -12
#define WORM_ERR_BUFFER_TOO_SMALL -13
#define WORM_ERR_OUT_OF_MEMORY -14
#define WORM_ERR_INVARIANT_VIOLATED -15
#define WORM_ERR_STREAM_NOT_INITIALIZED -16

#define WORM_HASH_SIZE 32
#define WORM_SIGNATURE_SIZE 64
#define WORM_STREAM_ID_SIZE 32
#define WORM_RECEIPT_ID_SIZE 32

typedef struct WormWriter WormWriter;
typedef struct WormRecord WormRecord;

typedef uint8_t Hash256[WORM_HASH_SIZE];
typedef uint8_t Signature[WORM_SIGNATURE_SIZE];
typedef uint8_t StreamId[WORM_STREAM_ID_SIZE];

// Initialize a new writer with given ID
WormWriter* worm_init_writer(const uint8_t writer_id[WORM_HASH_SIZE]);

// Create a new record (uncommitted)
WormRecord* worm_create_record(
    WormWriter *writer,
    const uint8_t stream_id[WORM_STREAM_ID_SIZE],
    const uint8_t payload_hash[WORM_HASH_SIZE]
);

// Append record to local storage (enforces all invariants)
WormError worm_append_local(WormWriter *writer, WormRecord *record);

// Compute hash of a record
WormError worm_hash_record(WormRecord *record, uint8_t out_hash[WORM_HASH_SIZE]);

// Encode record to canonical CBOR
WormError worm_cbor_encode(WormRecord *record, uint8_t *buffer, size_t *len);

// Decode record from CBOR
WormRecord* worm_cbor_decode(const uint8_t *buffer, size_t len);

// Sign record (placeholder for now)
WormError worm_sign_record(WormRecord *record, const uint8_t private_key[WORM_HASH_SIZE]);

// Verify record signature
WormError worm_verify_signature(WormRecord *record, const uint8_t public_key[WORM_HASH_SIZE]);

// Query last sequence number
uint64_t worm_query_sequence(WormWriter *writer);

// Query last hash
WormError worm_query_previous_hash(WormWriter *writer, uint8_t out_hash[WORM_HASH_SIZE]);

// Free allocated object
void worm_free(void *obj);

#ifdef __cplusplus
}
#endif

#endif // WORM_ABI_H
