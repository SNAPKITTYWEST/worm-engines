# WORM Protocol Specification

## Overview

WORM protocol is a **fixed, non-negotiated wire format** for transmitting WormRecords between engines. No handshaking. No capability negotiation. No version probing.

A sender writes records. A receiver reads records. That is all.

## Transport

- **Connection Type:** Unix domain socket (preferred) or TCP socket
- **Connection Direction:** Sender → Receiver (unidirectional)
- **Connection Establishment:** Sender connects, writes records until completion, closes cleanly
- **Multiplexing:** Not supported. One logical stream per connection.
- **Timeouts:** 30 seconds (default, configurable per deployment)

## Frame Format

Each WormRecord is transmitted as:

```
[4-byte big-endian length] [CBOR-encoded WormRecord bytes]
```

### Length Field

- **Size:** 4 bytes
- **Encoding:** Big-endian (network byte order) unsigned 32-bit integer
- **Value:** The exact byte count of the CBOR payload that follows (not including the 4-byte length field itself)
- **Range:** 0 to 4,294,967,295 bytes per frame

### Payload

- **Format:** CBOR binary (RFC 7049)
- **Encoding:** Canonical CBOR (RFC 7049, deterministic encoding)
- **Streaming:** None. Use definite-length encoding for all CBOR types (no indefinite-length arrays, maps, or strings)
- **No compression**
- **No framing overhead** other than the 4-byte length prefix

### Frame Example (Conceptual)

```
Wire data (hex):
00 00 01 2c           <- length field (300 bytes)
a7 18 01 ...          <- CBOR: map with 11 fields, version: 1, ...
... (300 bytes total) <- complete CBOR-encoded WormRecord
```

Breakdown:
- `00 00 01 2c` = big-endian 300 (0x012c)
- Next 300 bytes = CBOR data

## Connection Lifecycle

### 1. Connection Establishment

```
Sender initiates connection to Receiver
(Unix socket: /tmp/worm-engine.sock or Receiver-provided path)
(TCP: Receiver-provided host:port)
Connection established and ready
```

No negotiation. No exchange of capabilities. Immediate readiness.

### 2. Record Transmission

```
Sender writes: [length][record_0_cbor]
Receiver reads: [length][record_0_cbor]
Receiver validates and stores record_0

Sender writes: [length][record_1_cbor]
Receiver reads: [length][record_1_cbor]
Receiver validates and stores record_1

(repeat for all records in batch)
```

Each record frame is independent. Receiver validates on arrival.

### 3. Connection Termination

Sender closes connection after all records transmitted. Receiver detects EOF and finalizes stream.

Optional: Either side may force close on timeout (30s default).

## Timeout Semantics

- **Read Timeout:** Receiver waiting for length field, no bytes arrive within 30s → close connection, treat as error
- **Write Timeout:** Sender attempting to write, socket buffer full for 30s → close connection, treat as error
- **Idleness Timeout:** After successful record transmission, if no new length field arrives within 30s → Receiver may close (optional, depends on deployment)

## Invariants

### No Negotiation

This is not a negotiated protocol. It is a fixed format. No "Hello" messages, no version probes, no "I support feature X" exchanges.

If a sender and receiver disagree on this protocol, one of them is broken.

### Deterministic Serialization

Every sender encoding the same WormRecord MUST produce byte-for-byte identical CBOR. This is guaranteed by canonical CBOR encoding rules (RFC 7049, Section 3.9).

If two senders produce different CBOR for the same record, one of them is broken.

### No Variable-Length Encoding for Length Field

The 4-byte length is **always** present, **always** big-endian, **always** exactly 4 bytes. No CBOR-style variable-length integers for the frame length.

Why: To allow receivers to read the length field without knowing the payload size first (obvious, but stated for clarity).

### Defragmentation Not Supported

Sender writes complete frame (length + CBOR). Receiver reads complete frame. No partial frames, no reassembly logic.

If a TCP packet boundary splits a frame, that is fine. The receiver reads until the full frame arrives, regardless of packet boundaries.

## Example Wire Trace

Assume two records being sent:

**Record 0 (genesis, sequence=0):**
```
CBOR bytes (hex): a7 18 01 58 20 f1 f2 ... [total 140 bytes]
```

Frame:
```
00 00 00 8c           <- length = 140 bytes (0x8c)
a7 18 01 58 20 f1 f2 ... [140 bytes total CBOR]
```

**Record 1 (sequence=1):**
```
CBOR bytes (hex): a7 18 01 58 20 e1 e2 ... [total 140 bytes]
```

Frame:
```
00 00 00 8c           <- length = 140 bytes
a7 18 01 58 20 e1 e2 ... [140 bytes total CBOR]
```

**Total wire data (hex):**
```
00 00 00 8c a7 18 01 58 20 f1 f2 ... [140 bytes]
00 00 00 8c a7 18 01 58 20 e1 e2 ... [140 bytes]
```

Receiver reads:
1. Read 4 bytes: `00 00 00 8c` → length = 140
2. Read 140 bytes: `a7 18 01 ...` → Record 0
3. Decode CBOR, validate, store
4. Read 4 bytes: `00 00 00 8c` → length = 140
5. Read 140 bytes: `a7 18 01 ...` → Record 1
6. Decode CBOR, validate, store
7. Read 4 bytes: EOF → connection closed, finalize

## Error Handling

### Sender-Side Errors

- Record validation fails before transmission → do not send frame, return error to caller
- Socket write fails → close connection, return error to caller
- Timeout during write → close connection, return error to caller

### Receiver-Side Errors

- Socket read times out → close connection, log error, do not finalize stream
- Length field invalid (e.g., 0 bytes) → close connection, log error
- CBOR decoding fails → log error, close connection
- Record validation fails (bad signature, bad sequence) → log error, close connection

No retry logic. Connection is one-shot. If anything fails, sender and receiver must re-establish and re-transmit.

## Deployment Notes

### Unix Socket

Preferred for same-machine communication:

```
Receiver binds to /tmp/worm-engine.sock (or custom path)
Sender connects to /tmp/worm-engine.sock
```

Cleanup: Receiver deletes socket file on shutdown.

### TCP Socket

For remote communication:

```
Receiver binds to 0.0.0.0:9999 (or custom port)
Sender connects to receiver-host:9999
```

No TLS in this spec. Security via network topology (private network, firewall rules, VPN).

---

## Summary Table

| Aspect | Specification |
|--------|---------------|
| Framing | 4-byte big-endian length + CBOR |
| Length Encoding | Big-endian unsigned 32-bit |
| CBOR Encoding | Canonical (RFC 7049 deterministic) |
| Streaming | Definite-length only, no indefinite encoding |
| Negotiation | None. Fixed protocol. |
| Timeouts | 30s default (configurable) |
| Transport | Unix socket or TCP |
| Direction | Unidirectional (Sender → Receiver) |
| Per-Connection Streams | 1 logical stream per connection |
| Retry Logic | None. Re-establish connection to retry. |
| Error Recovery | None. Close and reconnect. |
| Multiplexing | Not supported |
| Compression | Not supported |

---

## Conformance Testing

Implementations must pass:

1. **Frame Structure Test:** Send valid record, receiver parses length correctly and decodes CBOR
2. **Byte Fidelity Test:** Send identical record from two independent senders, wire bytes are identical
3. **Timeout Test:** Connection idle for 30s, receiver closes gracefully
4. **Malformed Frame Test:** Send invalid length field, receiver closes connection
5. **Invalid CBOR Test:** Send garbage payload, receiver closes connection
6. **Long Record Test:** Send record with payload > 1MB, receiver handles without truncation
7. **Rapid Records Test:** Send 1000 records in succession, receiver processes all without loss
8. **Connection Reuse Test:** Send batch, close, re-open, send another batch; both batches processed correctly
