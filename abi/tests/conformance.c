// Copyright © 2026 Sovereign Source Foundation. All rights reserved.
// Licensed under Sovereign Source License. Commercial use only.
// See LICENSE for complete terms.

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "../include/worm/worm.h"

int main(void) {
    printf("WORM C ABI Conformance Test\n");
    printf("===========================\n\n");

    // Test 1: Initialize writer
    printf("Test 1: worm_init_writer\n");
    uint8_t writer_id[32];
    memset(writer_id, 0x42, 32);
    WormWriter *writer = worm_init_writer(writer_id);
    if (writer == NULL) {
        printf("FAIL: worm_init_writer returned NULL\n");
        return 1;
    }
    printf("PASS: Writer initialized\n\n");

    // Test 2: Create record
    printf("Test 2: worm_create_record\n");
    uint8_t stream_id[32];
    uint8_t payload_hash[32];
    memset(stream_id, 0xAA, 32);
    memset(payload_hash, 0xBB, 32);
    WormRecord *record = worm_create_record(writer, stream_id, payload_hash);
    if (record == NULL) {
        printf("FAIL: worm_create_record returned NULL\n");
        return 1;
    }
    printf("PASS: Record created\n\n");

    // Test 3: Append local
    printf("Test 3: worm_append_local\n");
    int result = worm_append_local(writer, record);
    if (result != WORM_OK) {
        printf("FAIL: worm_append_local returned %d\n", result);
        return 1;
    }
    printf("PASS: Record appended\n\n");

    // Test 4: Query sequence
    printf("Test 4: worm_query_sequence\n");
    uint64_t sequence = worm_query_sequence(writer);
    printf("Sequence: %lu\n", sequence);
    if (sequence != 0) {
        printf("FAIL: Expected sequence 0, got %lu\n", sequence);
        return 1;
    }
    printf("PASS: Sequence correct\n\n");

    // Test 5: Query hash
    printf("Test 5: worm_query_previous_hash\n");
    uint8_t hash_out[32];
    result = worm_query_previous_hash(writer, hash_out);
    if (result != WORM_OK) {
        printf("FAIL: worm_query_previous_hash returned %d\n", result);
        return 1;
    }
    printf("PASS: Hash retrieved\n\n");

    // Test 6: Hash record
    printf("Test 6: worm_hash_record\n");
    uint8_t record_hash[32];
    result = worm_hash_record(record, record_hash);
    if (result != WORM_OK) {
        printf("FAIL: worm_hash_record returned %d\n", result);
        return 1;
    }
    printf("PASS: Record hash computed\n\n");

    // Test 7: CBOR encode
    printf("Test 7: worm_cbor_encode\n");
    uint8_t cbor_buffer[512];
    size_t cbor_len = 512;
    result = worm_cbor_encode(record, cbor_buffer, &cbor_len);
    if (result != WORM_OK) {
        printf("FAIL: worm_cbor_encode returned %d\n", result);
        return 1;
    }
    printf("PASS: Record encoded to CBOR (length: %zu)\n\n", cbor_len);

    // Test 8: Free resources
    printf("Test 8: worm_free\n");
    worm_free(writer);
    printf("PASS: Resources freed\n\n");

    printf("===========================\n");
    printf("All 8 tests PASSED\n");
    return 0;
}
