# WORM Hash Domain Specification

## Canonical Hash Input

All WORM record hashing uses SHA-256 over a deterministic byte sequence. This is the only source of truth for record identity and previous-link validation.

### Domain Tag

All WORM hashes are prefixed with a 4-byte domain tag to prevent cross-domain hash collisions:

```
0x57 0x4F 0x52 0x4D = "WORM" (ASCII)
```

This tag appears first in every hash input.

### Hash Domain Byte Structure

The hash domain for a WormRecord is constructed as:

```
domain_tag (4 bytes)
|| version (4 bytes, big-endian uint32)
|| stream_id (32 bytes, raw)
|| sequence (8 bytes, big-endian uint64)
|| previous_hash (32 bytes, raw)
|| payload_hash (32 bytes, raw)
|| policy_hash (32 bytes, raw)
|| writer_id (32 bytes, raw)
|| flags (4 bytes, big-endian uint32, Bit 0 only, all others zero)
```

**Total: 4 + 4 + 32 + 8 + 32 + 32 + 32 + 32 + 4 = 180 bytes**

### Byte-Level Specification

| Field | Offset | Length | Encoding |
|-------|--------|--------|----------|
| domain_tag | 0 | 4 | Literal bytes 0x57 0x4F 0x52 0x4D |
| version | 4 | 4 | Big-endian uint32 |
| stream_id | 8 | 32 | Raw bytes (SHA-256 output) |
| sequence | 40 | 8 | Big-endian uint64 |
| previous_hash | 48 | 32 | Raw bytes (SHA-256 output) |
| payload_hash | 80 | 32 | Raw bytes (SHA-256 output) |
| policy_hash | 112 | 32 | Raw bytes (SHA-256 output) |
| writer_id | 144 | 32 | Raw bytes (Ed25519 public key) |
| flags | 176 | 4 | Big-endian uint32, Bit 0 = committed flag, Bits 1-31 = 0 |

### Endianness

All multi-byte fields use **big-endian (network byte order)** encoding. Single bytes use their literal value.

### Hash Output

```
record_hash = SHA-256(hash_domain_bytes)
record_hash (32 bytes)
```

This hash becomes the `previous_hash` field of the next record in the stream (sequence + 1).

### Invariant: Deterministic Hashing

**All implementations produce identical hash for identical record. Non-deterministic hashing is a bug.**

Any deviation from this specification results in stream corruption. Validators will reject records whose `previous_hash` does not match the computed hash of the prior record.

### Concrete Example

**Record (sequence=1):**
- version: 1 → `0x00 0x00 0x00 0x01`
- stream_id: `0xf1 f2 f3 f4 ... (32 bytes)`
- sequence: 1 → `0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01`
- previous_hash: `0xa0 a1 a2 a3 ... (32 bytes)` [hash of genesis record]
- payload_hash: `0xb0 b1 b2 b3 ... (32 bytes)`
- policy_hash: `0xc0 c1 c2 c3 ... (32 bytes)`
- writer_id: `0xd0 d1 d2 d3 ... (32 bytes)`
- flags: 1 (committed) → `0x00 0x00 0x00 0x01`

**Hash domain bytes (hex):**
```
57 4f 52 4d                           (domain_tag "WORM")
00 00 00 01                           (version = 1)
f1 f2 f3 f4 ... (32 bytes)           (stream_id)
00 00 00 00 00 00 00 01              (sequence = 1)
a0 a1 a2 a3 ... (32 bytes)           (previous_hash)
b0 b1 b2 b3 ... (32 bytes)           (payload_hash)
c0 c1 c2 c3 ... (32 bytes)           (policy_hash)
d0 d1 d2 d3 ... (32 bytes)           (writer_id)
00 00 00 01                           (flags = 1)
```

**SHA-256 hash (example hex):**
```
e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff
```

This hash becomes the `previous_hash` of record (sequence=2).

---

## Genesis Record Hash

**Record (sequence=0, genesis):**
- version: 1 → `0x00 0x00 0x00 0x01`
- stream_id: `0xf1 f2 f3 f4 ... (32 bytes)`
- sequence: 0 → `0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00`
- previous_hash: `0x00 0x00 ... 0x00 (32 zero bytes)` [no prior record]
- payload_hash: `0xg0 g1 g2 g3 ... (32 bytes)`
- policy_hash: `0xh0 h1 h2 h3 ... (32 bytes)`
- writer_id: `0xd0 d1 d2 d3 ... (32 bytes)`
- flags: 1 (committed) → `0x00 0x00 0x00 0x01`

**Hash domain bytes (hex):**
```
57 4f 52 4d                           (domain_tag "WORM")
00 00 00 01                           (version = 1)
f1 f2 f3 f4 ... (32 bytes)           (stream_id)
00 00 00 00 00 00 00 00              (sequence = 0)
00 00 00 00 ... 00 (32 zero bytes)  (previous_hash = all zeros)
g0 g1 g2 g3 ... (32 bytes)           (payload_hash)
h0 h1 h2 h3 ... (32 bytes)           (policy_hash)
d0 d1 d2 d3 ... (32 bytes)           (writer_id)
00 00 00 01                           (flags = 1)
```

---

## Implementation Checklist

- [ ] Use SHA-256 (NIST/FIPS standard). No alternative hash algorithms.
- [ ] Construct 180-byte domain string exactly as specified.
- [ ] Use big-endian encoding for all integers.
- [ ] Verify output is 32 bytes (256 bits).
- [ ] Test: hash same record twice, results must be identical.
- [ ] Test: hash of genesis record used as previous_hash in sequence=1 record.
- [ ] Test: change one bit of input, hash must be completely different.
