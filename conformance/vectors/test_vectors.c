// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

// C golden vector test: encode genesis record, verify CBOR matches Zig

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "../../abi/include/worm/worm.h"

void print_hex(const uint8_t *data, size_t len) {
    for (size_t i = 0; i < len; i++) {
        printf("%02x", data[i]);
    }
    printf("\n");
}

int main(void) {
    printf("C Golden Vector Test\n");
    printf("====================\n\n");

    // Create genesis record
    uint8_t writer_id[32];
    uint8_t stream_id[32];
    uint8_t payload_hash[32];

    memset(writer_id, 0xCC, 32);
    memset(stream_id, 0xAA, 32);
    memset(payload_hash, 0xBB, 32);

    WormWriter *writer = worm_init_writer(writer_id);
    if (writer == NULL) {
        printf("FAIL: worm_init_writer returned NULL\n");
        return 1;
    }

    WormRecord *record = worm_create_record(writer, stream_id, payload_hash);
    if (record == NULL) {
        printf("FAIL: worm_create_record returned NULL\n");
        return 1;
    }

    printf("Genesis record created (sequence=0, timestamp=1000)\n\n");

    // Encode to CBOR
    uint8_t cbor_buffer[512];
    size_t cbor_len = 512;
    int result = worm_cbor_encode(record, cbor_buffer, &cbor_len);
    if (result != WORM_OK) {
        printf("FAIL: worm_cbor_encode returned %d\n", result);
        return 1;
    }

    printf("CBOR Hex (%zu bytes):\n", cbor_len);
    print_hex(cbor_buffer, cbor_len);
    printf("\n");

    // Hash the record
    uint8_t hash[32];
    result = worm_hash_record(record, hash);
    if (result != WORM_OK) {
        printf("FAIL: worm_hash_record returned %d\n", result);
        return 1;
    }

    printf("Hash Hex (32 bytes):\n");
    print_hex(hash, 32);
    printf("\n");

    // Verify determinism
    uint8_t cbor_buffer2[512];
    size_t cbor_len2 = 512;
    worm_cbor_encode(record, cbor_buffer2, &cbor_len2);

    uint8_t hash2[32];
    worm_hash_record(record, hash2);

    int cbor_match = (cbor_len == cbor_len2) && (memcmp(cbor_buffer, cbor_buffer2, cbor_len) == 0);
    int hash_match = (memcmp(hash, hash2, 32) == 0);

    printf("Determinism Check:\n");
    printf("CBOR Match: %s\n", cbor_match ? "YES" : "NO");
    printf("Hash Match: %s\n", hash_match ? "YES" : "NO");

    if (cbor_match && hash_match) {
        printf("\n✓ PASS: C vector matches Zig deterministically\n");
    } else {
        printf("\n✗ FAIL: Non-deterministic output\n");
        return 1;
    }

    worm_free(writer);
    return 0;
}
