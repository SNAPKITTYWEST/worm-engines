#!/bin/bash

# Copyright © 2026 Sovereign Source Foundation. All rights reserved.
# Licensed under Sovereign Source License. Commercial use only.
# See LICENSE for complete terms.

# Gate 4 Phase C: Composite cross-language vector test

set -e

VECTORS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$VECTORS_DIR")")"

echo "WORM Engines — Gate 4 Phase C: Cross-Language Vectors"
echo "====================================================="
echo ""

# Temporary storage for outputs
ZIG_CBOR=""
ZIG_HASH=""
C_CBOR=""
C_HASH=""
OCAML_CBOR=""
OCAML_HASH=""
ERLANG_CBOR=""
ERLANG_HASH=""

# Phase C1: Zig generator
echo "[1/4] Running Zig generator..."
cd "$REPO_ROOT/zig-engine"
if zig build-exe "$VECTORS_DIR/test_vectors.zig" -lc -o "$VECTORS_DIR/zig_test" 2>/dev/null; then
    ZIG_OUTPUT=$("$VECTORS_DIR/zig_test" 2>&1)
    ZIG_CBOR=$(echo "$ZIG_OUTPUT" | grep "^CBOR Hex:" | cut -d' ' -f3-)
    ZIG_HASH=$(echo "$ZIG_OUTPUT" | grep "^Hash Hex:" | cut -d' ' -f3-)
    echo "✓ Zig: CBOR (${#ZIG_CBOR} chars), Hash (${#ZIG_HASH} chars)"
else
    echo "✗ Zig compilation failed"
    exit 1
fi

# Phase C2: C generator
echo "[2/4] Running C test..."
cd "$VECTORS_DIR"
if gcc -I"$REPO_ROOT/abi/include" test_vectors.c -o c_test 2>/dev/null; then
    C_OUTPUT=$(./c_test 2>&1)
    C_CBOR=$(echo "$C_OUTPUT" | grep "^[a-f0-9]*$" | head -1)
    C_HASH=$(echo "$C_OUTPUT" | grep "^[a-f0-9]*$" | tail -1)
    echo "✓ C: CBOR (${#C_CBOR} chars), Hash (${#C_HASH} chars)"
else
    echo "✗ C compilation failed"
    exit 1
fi

# Phase C3: OCaml (scaffold check)
echo "[3/4] Checking OCaml scaffold..."
if [ -f test_vectors_ocaml.ml ]; then
    echo "✓ OCaml: scaffold present (ready for library integration)"
    OCAML_CBOR="(pending)"
    OCAML_HASH="(pending)"
else
    echo "✗ OCaml scaffold missing"
    exit 1
fi

# Phase C4: Erlang (scaffold check)
echo "[4/4] Checking Erlang scaffold..."
if [ -f test_vectors_erlang.erl ]; then
    echo "✓ Erlang: scaffold present (ready for mesh integration)"
    ERLANG_CBOR="(pending)"
    ERLANG_HASH="(pending)"
else
    echo "✗ Erlang scaffold missing"
    exit 1
fi

echo ""
echo "====================================================="
echo "Cross-Language Comparison"
echo "====================================================="
echo ""

# Compare outputs
echo "CBOR Hex:"
echo "  Zig:    ${ZIG_CBOR:0:50}..."
echo "  C:      ${C_CBOR:0:50}..."
echo "  OCaml:  ${OCAML_CBOR}"
echo "  Erlang: ${ERLANG_CBOR}"
echo ""

echo "Hash Hex:"
echo "  Zig:    $ZIG_HASH"
echo "  C:      $C_HASH"
echo "  OCaml:  $OCAML_HASH"
echo "  Erlang: $ERLANG_HASH"
echo ""

# Verify Zig == C
if [ "$ZIG_CBOR" = "$C_CBOR" ]; then
    echo "✓ CBOR Match: Zig == C"
else
    echo "✗ CBOR Mismatch: Zig != C"
    exit 1
fi

if [ "$ZIG_HASH" = "$C_HASH" ]; then
    echo "✓ Hash Match: Zig == C"
else
    echo "✗ Hash Mismatch: Zig != C"
    exit 1
fi

echo ""
echo "====================================================="
echo "Gate 4 Phase C Status"
echo "====================================================="
echo "✓ Zig generator: deterministic CBOR + hash"
echo "✓ C validator: matches Zig byte-for-byte"
echo "⏳ OCaml: scaffold ready (needs CBOR library)"
echo "⏳ Erlang: scaffold ready (needs mesh integration)"
echo ""
echo "✓ PASS: All implemented languages produce identical output"
echo ""
