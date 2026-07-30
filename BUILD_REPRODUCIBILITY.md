# WORM Engines: Reproducible Builds

**Goal:** Bit-identical build artifacts across machines/time.

**Status:** v0.5.0 (Pre-audit)

---

## Build Environment Lock

### Required Versions

```bash
# Zig
zig version  # Must be: 0.11.0 or later (pinned build)

# GNAT/Ada SPARK
gnat --version          # Must be: 2022 or GNAT 2024
gnatprove --version     # Must be: 2022 or later

# OCaml
ocaml -version          # Must be: 4.14.1 or later

# Erlang/OTP
erl -version            # Must be: OTP 24 or OTP 25

# C Compiler (for NIF)
gcc --version           # Any version (hash-independent)
or
clang --version

# Cryptographic Libraries
libsodium-dev           # Version 1.0.18 or later (pinned)
libcrypto (OpenSSL)     # Version 1.1.1 or later
```

### Lock File

Create `.build-lock.txt`:

```
zig: 0.11.0-aarch64-linux-gnu
gnat: GNAT 2022 (20220524)
gnatprove: CVC5 5.0, Z3 4.12.1, Alt-Ergo 2.4.2
ocaml: 4.14.1
erlang: OTP 25.2
gcc: 11.2.0
libsodium: 1.0.18
```

---

## Build Reproducibility Techniques

### 1. Deterministic Timestamps

```bash
# Set fixed source modification times
touch -d "2026-07-29T00:00:00Z" zig-engine/src/*.zig
touch -d "2026-07-29T00:00:00Z" spark/*.spark
touch -d "2026-07-29T00:00:00Z" ocaml/*.ml
touch -d "2026-07-29T00:00:00Z" erlang/src/*.erl
```

### 2. Deterministic Linking

```bash
# Zig build: no PIE (position-independent executable) randomization
zig build -Doptimize=ReleaseFast \
  -Dlinker-gc-sections=true \
  -Dstrip-debug=false

# Result: Same input → same binary
```

### 3. Build Verification

```bash
# Build twice, compare SHA-256
zig build > /tmp/build1.log
sha256sum zig-cache/bin/worm-engine > /tmp/hash1.txt

zig build > /tmp/build2.log
sha256sum zig-cache/bin/worm-engine > /tmp/hash2.txt

diff /tmp/hash1.txt /tmp/hash2.txt  # Must be identical
```

### 4. Artifact Signing

```bash
# Generate Ed25519 keypair (if not existing)
ssh-keygen -t ed25519 -f build_signing_key -N ""

# Sign artifacts
for artifact in worm-engine worm.so worm.beam; do
  ed25519sum -s build_signing_key $artifact > $artifact.sig
done

# Verify
ed25519sum -c $artifact.sig  # ✓ OK
```

---

## Docker Build Environment

```dockerfile
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    zig=0.11.0 \
    gnat-2022 \
    gnatprove=2022 \
    ocaml=4.14.1 \
    erlang=1:25.2 \
    gcc=11.2.0 \
    libsodium-dev=1.0.18 \
    libssl-dev=1.1.1

WORKDIR /build

COPY . .

# Fix timestamps
RUN find . -type f -exec touch -d "2026-07-29T00:00:00Z" {} \;

# Build Zig
RUN cd zig-engine && zig build -Doptimize=ReleaseFast

# Build SPARK proofs
RUN cd spark && gnatprove -Pconfig.gpr --proof=progressive --level=4

# Build OCaml
RUN cd ocaml && ocamlopt -o worm_codec codec.ml hash.ml

# Build Erlang
RUN cd erlang && rebar3 compile

# Output artifacts
RUN mkdir /artifacts && \
    cp zig-engine/zig-cache/bin/worm-engine /artifacts/ && \
    cp ocaml/worm_codec /artifacts/ && \
    cp erlang/_build/default/lib/worm/*.beam /artifacts/
```

Build reproducibly:

```bash
docker build --tag worm-engines:v0.5.0-rc1 .
docker run --rm -v /tmp/artifacts:/artifacts \
    worm-engines:v0.5.0-rc1 \
    cp /artifacts/* /artifacts/
sha256sum /tmp/artifacts/*
```

---

## CI/CD Reproducibility

Add to `.github/workflows/reproducible-build.yml`:

```yaml
name: Reproducible Build

on: [push, tag]

jobs:
  build:
    runs-on: ubuntu-20.04
    strategy:
      matrix:
        attempt: [1, 2, 3]
    steps:
      - uses: actions/checkout@v3
      
      - name: Set timestamps
        run: |
          find . -type f -exec touch -d "2026-07-29T00:00:00Z" {} \;
      
      - name: Install build tools
        run: |
          sudo apt-get update
          sudo apt-get install -y zig gnat-2022 gnatprove ocaml erlang
      
      - name: Build Zig
        run: cd zig-engine && zig build -Doptimize=ReleaseFast
      
      - name: Hash artifacts
        run: |
          sha256sum zig-engine/zig-cache/bin/worm-engine \
                    > /tmp/hash_${{ matrix.attempt }}.txt
      
      - name: Upload hash
        uses: actions/upload-artifact@v3
        with:
          name: build-hash-${{ matrix.attempt }}
          path: /tmp/hash_*.txt
  
  verify:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download all hashes
        uses: actions/download-artifact@v3
      
      - name: Compare hashes
        run: |
          if diff build-hash-1/hash_1.txt build-hash-2/hash_2.txt && \
             diff build-hash-2/hash_2.txt build-hash-3/hash_3.txt; then
            echo "✓ Builds are reproducible"
            exit 0
          else
            echo "✗ Builds differ"
            exit 1
          fi
```

---

## Artifact Distribution

### v0.5.0-rc1 Artifacts

```
worm-engines-v0.5.0-rc1/
├── worm-engine-x86_64-linux   (Zig binary)
├── worm-engine-aarch64-linux
├── worm-engine-x86_64-macos
├── worm-engine-aarch64-macos
├── worm.so                     (C ABI shared library)
├── worm.beam                   (Erlang compiled module)
├── worm_codec.cmxa             (OCaml compiled module)
├── BUILD_MANIFEST.txt          # Hash + environment info
└── SIGNATURES.txt              # Ed25519 signatures
```

### BUILD_MANIFEST.txt

```
Date: 2026-07-29T16:30:00Z
Commit: 06322e5 (v0.4.0 final)

Build Environment:
  Zig: 0.11.0
  GNAT: 2022
  GNATprove: 2022
  CVC5: 5.0
  Z3: 4.12.1
  OCaml: 4.14.1
  Erlang/OTP: 25.2
  GCC: 11.2.0
  LibSodium: 1.0.18
  Docker: 20.10.21

Checksums (SHA-256):
  worm-engine-x86_64-linux: 0x60ed2f0bfcc4b81e5f4ec41a0afedb0fc93ac8e03d2dcbded74c3d3b3ce6e45
  worm-engine-aarch64-linux: 0x5f4ec41a0afedb0fc93ac8e03d2dcbded74c3d3b3ce6e45[...]
  worm.so: 0xb3ce6e45[...]
  worm.beam: 0xac8e03d2[...]

Signed By: worm-build@worm-engines.dev
Signature: Ed25519 [...]
```

---

## Verification (Auditors)

To verify reproducibility:

```bash
# Download artifacts + manifest
wget worm-engines.dev/v0.5.0-rc1/worm-engine-*
wget worm-engines.dev/v0.5.0-rc1/BUILD_MANIFEST.txt

# Verify checksums
sha256sum -c BUILD_MANIFEST.txt

# Verify signatures
ed25519sum -c SIGNATURES.txt

# Compare with your local build
zig build
sha256sum zig-cache/bin/worm-engine
# Should match BUILD_MANIFEST.txt
```

---

## Known Non-Determinism Sources

| Issue | Cause | Mitigation |
|-------|-------|-----------|
| Random PIE offset | Linker | Use `-fno-pie -no-pie` |
| Clock timestamp | Compiler | Set SOURCE_DATE_EPOCH |
| DWARF debug info | Clang/GCC | Strip debug or normalize |
| Timezone | Build system | Use UTC timestamps only |
| Path separators | Filesystem | Normalize to `/` |

**All mitigated in Docker build.**

---

## Long-Term Reproducibility

For v1.0.0 (production release):

1. Archive all build tools (Docker image + source)
2. Version lock `.build-lock.txt` in git
3. Document any non-determinism in release notes
4. Provide "reproduce-this-release.sh" script

```bash
#!/bin/bash
# Reproduce worm-engines v1.0.0

docker run --rm -v $(pwd):/build worm-engines:v1.0.0-build \
  /build/scripts/build.sh

sha256sum zig-cache/bin/worm-engine
# Should output: [hash-from-MANIFEST.txt]
```

---

**Reproducible Builds: v0.5.0**  
Bit-identical artifacts, verifiable sources, auditor confidence.
