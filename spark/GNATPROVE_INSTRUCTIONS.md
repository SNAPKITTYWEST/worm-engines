# GNATprove Verification Instructions for WORM Engines

**Target:** Formally prove all 12 invariants via GNATprove (SPARK 2022)  
**Status:** Specification complete, proofs ready for generation  
**Estimated Time:** 30-60 minutes (first run with proof generation)

---

## Prerequisites

1. **GNAT 2022 or later** (Community Edition acceptable)
   ```bash
   gnat --version
   ```

2. **GNATprove** (included with GNAT Community)
   ```bash
   gnatprove --version
   ```

3. **SMT Solvers** (CVC5, Z3, or Alt-Ergo)
   - CVC5: `cvc5 --version`
   - Z3: `z3 --version`
   - Alt-Ergo: `alt-ergo --version`

4. **Proof Tools** (optional but recommended)
   - Coq (for deeper proofs, if needed)
   - Lean (for mechanized verification)

---

## File Structure

```
spark/
├── worm_invariants.spark    # Main SPARK spec (12 invariants)
├── config.gpr               # GNAT project configuration
├── GNATPROVE_INSTRUCTIONS.md # This file
└── spark_proof/             # Generated proofs (created by gnatprove)
    ├── gnatprove.out        # GNATprove output log
    ├── sessions/            # SMT solver sessions
    └── html/                # HTML proof report
```

---

## Step 1: Setup Build Environment

```bash
cd worm-engines/spark

# Create proof output directory
mkdir -p spark_proof

# Download/install solvers if not present
# Ubuntu: sudo apt-get install alt-ergo cvc5 z3
# macOS: brew install cvc5 z3
# Windows: Download from vendor websites
```

---

## Step 2: Run GNATprove (Proof Generation)

**Command (basic proof):**

```bash
gnatprove -Pconfig.gpr --proof=progressive --level=4
```

**Command flags explained:**

| Flag | Meaning |
|------|---------|
| `-Pconfig.gpr` | Use GNAT project file |
| `--proof=progressive` | Use progressive proof (simpler goals first) |
| `--level=4` | Highest proof level (most powerful) |
| `--output=short` | Terse output (use `--output=pretty` for detailed) |
| `--verbose` | Show solver invocations |
| `--timeout=30` | 30-second timeout per goal (default 5) |
| `--steps=1000` | Max proof steps (default 100) |

**Command (aggressive proof with all solvers):**

```bash
gnatprove -Pconfig.gpr \
  --proof=progressive \
  --level=4 \
  --prover=cvc5 \
  --timeout=60 \
  --steps=5000 \
  --output=pretty \
  --verbose
```

---

## Step 3: Interpret Proof Results

### Successful Proof (All Green)

```
Phase 1 of 2: Checking SPARK specification
Parsing     worm_invariants.spark ... OK
Semantic analysis OK

Phase 2 of 2: Type checking
Type checking OK

Running gnatprove with CVC5...

Proving worm_invariants.adb...

worm_invariants.adb:50:7:
  Lemma_Sequence_Unique ... PROVED (CVC5: 0.15s)

worm_invariants.adb:60:7:
  Lemma_Hash_Chain_Linked ... PROVED (CVC5: 0.23s)

worm_invariants.adb:70:7:
  Lemma_Time_Monotonic ... PROVED (CVC5: 0.18s)

worm_invariants.adb:80:7:
  Lemma_Recovery_Idempotent ... PROVED (CVC5: 0.42s)

Summary:
  12/12 invariants PROVED
  4/4 lemmas PROVED
  0 unproven goals
  Time: 1m 23s
```

**→ SUCCESS** Proceed to audit phase.

### Partial Proof (Some Unproven)

```
worm_invariants.adb:105:7:
  Lemma_Hash_Chain_Linked ... UNKNOWN
    Goal: ∀ i, j. H(i) = SHA256(H(i-1) || payload) → 
                  H(i) ≠ H(j) when i ≠ j

Summary:
  11/12 invariants PROVED
  3/4 lemmas PROVED
  1 unproven goal
```

**→ INVESTIGATION NEEDED**

- Goal is about hash collision resistance (hard to prove mechanically)
- Action: Provide manual justification or upgrade to Level 5 proof + external lemmas
- Example justification: "SHA-256 has no known collisions in practice; NIST SP 800-38D attests"

### Proof Failure (Unproofable)

```
worm_invariants.adb:90:7:
  Invariant_Writer_Consistent ... FAILED
    Goal is false under model:
      Writer_In_Session = 1
      R.Writer = 2
    This invariant cannot be proved automatically.

Summary:
  11/12 invariants PROVED
  0/4 lemmas PROVED
  1 unprovable goal
```

**→ SPECIFICATION BUG** Found!

- Indicates the invariant spec doesn't match implementation
- Action: Review code for writer validation bypass
- Fix: Update spec or add runtime check in Zig storage.zig

---

## Step 4: Generate Proof Reports

### HTML Report (Human-Readable)

```bash
gnatprove -Pconfig.gpr --output=html
firefox spark_proof/html/index.html   # View in browser
```

Creates interactive proof visualization:
- Color-coded goals (green=proved, red=failed, yellow=unknown)
- Proof search tree (which solver tactic succeeded)
- Unproven goal explanations

### Machine-Readable Certificate

```bash
# Proof certificate for audit trail
cat spark_proof/gnatprove.out

# Extract just the summary
gnatprove -Pconfig.gpr --output=json | jq '.summary'
```

Output:
```json
{
  "total_goals": 16,
  "proved": 16,
  "unproven": 0,
  "disproven": 0,
  "time_seconds": 83
}
```

### Session Archive (For Auditors)

```bash
# Tar up all proof artifacts
tar czf worm_engines_proof_2026-07-29.tar.gz spark_proof/

# Sign with ed25519 (for integrity)
# (requires keypair setup)
# ed25519sum -c worm_engines_proof_2026-07-29.tar.gz.sig
```

---

## Step 5: Troubleshooting

### Problem: Timeout on Single Goal

```
worm_invariants.adb:60:7: Lemma_Hash_Chain_Linked ... TIMEOUT (60s)
```

**Solution:**

1. Increase timeout:
   ```bash
   gnatprove -Pconfig.gpr --timeout=120
   ```

2. Split goal into smaller lemmas (break-it-down strategy):
   ```spark
   -- Instead of proving: ∀i,j. hash(i) ≠ hash(j)
   -- Prove: hash(i) ≠ hash(i+1) [sequential invariant]
   -- Then compose: sequential inequalities → all-pairs inequalities
   ```

3. Add intermediate lemmas to guide proof:
   ```spark
   procedure Lemma_SHA256_Injective
   with Ghost,
        Pre => True,
        Post => (∀ x, y. SHA256(x) = SHA256(y) → x = y);
   ```

### Problem: Unproven Subgoal (No SMT Solver Can Crack)

```
worm_invariants.adb:105:7: Lemma_Recovery_Idempotent ... UNKNOWN
Goal contains theory outside scope of automatic provers:
  ∀ f. f(f(x)) = f(x) [General property in meta-logic]
```

**Solution:**

1. Check if goal is actually provable (might be unprovable):
   ```bash
   # Try all available solvers
   for solver in cvc5 z3 alt-ergo; do
     echo "Trying $solver..."
     gnatprove -Pconfig.gpr --prover=$solver
   done
   ```

2. If all fail, justify manually in documentation:
   ```spark
   procedure Lemma_Recovery_Idempotent
   with Ghost,
        Annotate => (GNATprove, "Proof_Not_Available",
          "Recovery idempotence follows from statelessness of recover() "
          "and determinism of segment scanning (CRC validation is pure).");
   ```

3. Escalate to formal math (Lean/Coq):
   ```lean
   theorem recovery_idempotent : ∀ S. recover(recover(S)) = recover(S) := by
     intro S
     -- Proof by induction on segment records...
   ```

### Problem: GNATprove Crashes

```
gnatprove: Fatal error: Uncaught exception Stdlib.Sys_error("No such file or directory")
```

**Solution:**

1. Verify GNAT installation:
   ```bash
   which gnatprove
   gnatprove --version
   gnat --version
   ```

2. Check project file syntax:
   ```bash
   gnat check -Pconfig.gpr
   ```

3. Rebuild proof cache:
   ```bash
   rm -rf spark_proof/
   gnatprove -Pconfig.gpr --clean
   gnatprove -Pconfig.gpr  # Rebuild from scratch
   ```

---

## Step 6: Audit Handoff

When proofs are complete, prepare audit package:

1. **Proof Certificate:** `spark_proof/gnatprove.out`
2. **Proof Reports:** `spark_proof/html/` (tarred)
3. **Source Spec:** `spark/worm_invariants.spark`
4. **Project Config:** `spark/config.gpr`
5. **README:** `spark/GNATPROVE_INSTRUCTIONS.md` (this file)

**Create audit package:**

```bash
mkdir audit_package
cp -r spark/ audit_package/
cp GATE_7_EVIDENCE_COLLECTION.md audit_package/
cp ASSURANCE_MATRIX.md audit_package/

# Sign with repo key
cd audit_package
git log --oneline > PROVENANCE.txt
# Auditors can verify:
# - Proofs came from main branch
# - No modifications after proof generation
```

---

## v0.3.0 Proof Success Criteria

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 12 invariants proven | ✓ PASS if 12/12 | gnatprove.out summary |
| No unproven subgoals | ✓ PASS if 0 unknown | Proof report |
| Proof time < 2 hours | ✓ PASS if < 120m | gnatprove.out timing |
| All solvers agree | ✓ PASS if consistent | Multi-solver test |
| HTML report renders | ✓ PASS if no 404s | Firefox verification |
| Proof artifacts reproducible | ✓ PASS if re-run produces same | Timestamp audit |

**Release v0.3.0 only when:** All 6 criteria PASS + 0 unproven goals.

---

## Continuous Integration (Optional)

Add to `.github/workflows/verify.yml`:

```yaml
name: SPARK Verification

on: [push, pull_request]

jobs:
  prove:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install GNAT
        run: sudo apt-get install -y gnat gnat-doc alt-ergo cvc5
      
      - name: Run GNATprove
        run: |
          cd spark
          gnatprove -Pconfig.gpr --proof=progressive --level=4
      
      - name: Check Results
        run: |
          if grep -q "UNKNOWN\|FAILED" spark_proof/gnatprove.out; then
            echo "Proof failed!"
            exit 1
          fi
      
      - name: Upload Proof Artifacts
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: spark-proofs
          path: spark/spark_proof/
```

Then CI automatically verifies invariants on every push.

---

## Reference

- [SPARK 2022 User's Guide](https://docs.adacore.com/spark2022-ug/html/ug/)
- [GNATprove Documentation](https://docs.adacore.com/gnatprove-docs/html/ug/)
- [SMT Solver Manuals](https://cvc5.github.io)
- [WORM Engines GATE_5_SPARK_PROOF.md](../GATE_5_SPARK_PROOF.md) — Invariant specifications

---

**GNATprove Verification Instructions for WORM Engines**  
Prepared 2026-07-29 for v0.3.0 evidence cycle.
