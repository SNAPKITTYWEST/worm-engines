# WORM OCaml Policy Engine

Policy compilation, rule evaluation, and governance contracts.

## Overview

Pure OCaml policy engine providing:
- Policy compilation (string → AST → bytecode)
- Rule evaluation with deterministic ordering
- Priority-based rule matching (first match wins)
- No external dependencies
- Fully typed with OCaml type system

## Architecture

### Policy Module (policy.ml)
Core policy types and compilation.
- Predicates: sequence_gte, timestamp_lt, writer_eq, AND, OR, NOT
- Actions: accept, reject, forward, escalate
- Rules: predicate + action + priority
- Compiler: string → policy AST

### Evaluation Module (eval.ml)
Rule evaluation engine.
- Deterministic predicate evaluation
- Priority-ordered rule matching
- First-match-wins semantics
- Pure functions (no side effects)

### CLI Tool (policy_cli.ml)
Command-line interface for policy operations.
- Compile mode: parse policy file to bytecode
- Eval mode: evaluate policy against record

## Core Types

```ocaml
type predicate =
  | Sequence_gte of int64
  | Timestamp_lt of int64
  | Writer_eq of string
  | And of predicate * predicate
  | Or of predicate * predicate
  | Not of predicate

type action =
  | Accept
  | Reject
  | Forward
  | Escalate

type rule = {
  id: string;
  predicate: predicate;
  action: action;
  priority: int;
  description: string;
}

type policy = rule list

type bytecode = {
  rules: rule list;
  rule_count: int;
}
```

## Core Functions

### Compilation
```ocaml
Policy.compile : string -> policy
Policy.to_bytecode : policy -> bytecode
```

Compile a policy string:
```
rule1:sequence_gte(100):accept:10:Accept sequences >= 100
rule2:timestamp_lt(5000):reject:20:Reject old timestamps
```

### Evaluation
```ocaml
Eval.run : bytecode -> record -> action option
Eval.eval_predicate : predicate -> record -> bool
Eval.all_matches : policy -> record -> evaluation_result
```

Evaluate a record:
```ocaml
let record = { sequence = 150L; timestamp = 3000L; writer_id = "alice" }
let action = Eval.run bytecode record
```

### CLI

Compile policy:
```bash
worm-policy --compile --input policy.txt
```

Evaluate policy:
```bash
worm-policy --eval --input policy.txt --record "150,3000,alice"
```

## Build

Compile library and CLI:
```bash
dune build
```

Build only library:
```bash
dune build lib/worm_policy.a
```

## Test

Run all tests:
```bash
dune test
```

## Files

```
ocaml-policy/
├── dune-project
├── dune
├── lib/
│   ├── policy.ml
│   ├── policy.mli
│   ├── eval.ml
│   ├── eval.mli
│   └── dune
├── bin/
│   ├── policy_cli.ml
│   └── dune
├── test/
│   ├── test_policy.ml
│   └── dune
└── README.md
```

## Integration

Policy engine sits between:
- **Below**: Ada SPARK control plane (validates records)
- **Erlang Mesh**: Policies govern cluster consensus rules
- **Above**: Language bindings consume policy decisions

All records validated by SPARK before policy evaluation.
