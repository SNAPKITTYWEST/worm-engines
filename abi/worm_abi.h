// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License + Business Source License 1.1.
// Change Date: December 31, 2027 — after which, licensed under AGPL-3.0-only.
// See LICENSE for complete terms.

#ifndef WORM_ABI_H
#define WORM_ABI_H

#include <stdint.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef int32_t ErrorCode;

#define WORM_OK                          0
#define WORM_ERR_INVALID_WRITER          -1
#define WORM_ERR_INVALID_RECORD          -2
#define WORM_ERR_INVALID_BUFFER          -3
#define WORM_ERR_INVALID_SIGNATURE       -4
#define WORM_ERR_SEQUENCE_MISMATCH       -5
#define WORM_ERR_TIMESTAMP_INVALID       -6
#define WORM_ERR_HASH_CHAIN_BROKEN       -7
#define WORM_ERR_IMMUTABLE_VIOLATION     -8
#define WORM_ERR_WRITER_MISMATCH         -9
#define WORM_ERR_POLICY_ROLLBACK         -10
#define WORM_ERR_CBOR_ENCODE_FAILED      -11
#define WORM_ERR_CBOR_DECODE_FAILED      -12
#define WORM_ERR_BUFFER_TOO_SMALL        -13
#define WORM_ERR_OUT_OF_MEMORY           -14
#define WORM_ERR_INVARIANT_VIOLATED      -15
#define WORM_ERR_STREAM_NOT_INITIALIZED  -16

typedef uint8_t Hash256[32];
typedef uint8_t Signature[64];
typedef uint8_t PublicKey[32];
typedef uint8_t PrivateKey[32];
typedef uint8_t StreamId[32];
typedef uint8_t ReceiptId[32];

#define WORM_RECORD_CBOR_MAX_SIZE 512

typedef struct WormWriter WormWriter;
typedef struct WormRecord WormRecord;

extern WormWriter* worm_init_writer(const PublicKey writer_id);

extern WormRecord* worm_create_record(
    WormWriter *writer,
    const StreamId stream_id,
    const Hash256 payload_hash
);

extern ErrorCode worm_append_local(
    WormWriter *writer,
    WormRecord *record
);

extern Hash256 worm_hash_record(WormRecord *record);

extern ErrorCode worm_cbor_encode(
    WormRecord *record,
    uint8_t *buffer,
    size_t *len
);

extern WormRecord* worm_cbor_decode(
    const uint8_t *buffer,
    size_t len
);

extern ErrorCode worm_sign_record(
    WormRecord *record,
    const PrivateKey private_key
);

extern ErrorCode worm_verify_signature(
    WormRecord *record,
    const PublicKey public_key
);

extern uint64_t worm_query_sequence(WormWriter *writer);

extern Hash256 worm_query_previous_hash(WormWriter *writer);

extern void worm_free(void *obj);

#define WORM_SIZEOF_HASH256       32
#define WORM_SIZEOF_SIGNATURE     64
#define WORM_SIZEOF_PUBLIC_KEY    32
#define WORM_SIZEOF_PRIVATE_KEY   32
#define WORM_SIZEOF_STREAM_ID     32
#define WORM_SIZEOF_RECEIPT_ID    32

#define WORM_HASH_DOMAIN_TAG      0x574F524D

#ifdef __cplusplus
}
#endif

#endif
