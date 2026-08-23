# LOCKER Sovereign Node Key — Production Authorization

To deploy LOCKER in production you must hold a provisioned Sovereign Node Key.

A **Sovereign Node Key** is an ML-DSA-44 keypair + operator-signed authorization
record that grants production deployment rights. The LOCKER authority signs the
authorization. A node cannot self-authorize.

ML-DSA-44 (CRYSTALS-Dilithium, NIST FIPS 204) — post-quantum, Shor-resistant.
Ed25519 is broken by Shor's algorithm. Every node key is ML-DSA-44 from day one.

---

## What a Node Key Grants

A provisioned Sovereign Node Key authorizes a specific node to:

- ✅ Run LOCKER in production (append, seal, verify)
- ✅ Issue ML-DSA-44 sealed records to the WORM chain
- ✅ Deploy the ERE gate in production pipelines
- ✅ Access the LOCKER commercial API

---

## Commercial Tiers

| Tier | Price | What You Get |
|------|-------|--------------|
| **Individual Node** | $250–$500 | One production node (one workstation/server) |
| **Commercial Team** | $12,000–$25,000/yr | Unlimited nodes within your organization |
| **Enterprise** | $50,000–$150,000+/yr | Custom deployment, audits, SLA, white-label |

---

## How to Get a Node Key

**Step 1 — Request Access**

Contact: jessica@collectivekitty.com  
Include: name/org, use case, tier, deployment requirements

**Step 2 — Approval** (1–3 business days)

**Step 3 — Generate your ML-DSA-44 keypair**

```bash
# Using dilithium-py (pip install dilithium-py)
python3 - << 'EOF'
from dilithium_py.dilithium import Dilithium2
pk, sk = Dilithium2.keygen()
open("node_pk.bin","wb").write(pk)
open("node_sk.bin","wb").write(sk)
print("Public key:", pk.hex()[:32], "... (1312 bytes)")
print("Private key written to node_sk.bin (keep secret)")
EOF
```

Send your **public key hex** (`node_pk.bin.hex()`) in the request email.

**Step 4 — Receive signed node certificate**

We register your key in the Bifrost WORM ledger and return:
- `sovereign/authorization.json` — signed authorization record
- `sovereign/mldsa_authority.pub` — LOCKER authority public key

**Step 5 — Verify your node**

```bash
python3 scripts/verify-node-pq
```

Expected output:
```
========================================
STATUS: NODE AUTHORIZED (ML-DSA-44)
========================================
```

---

## Node Key Security

- **Never share** `node_sk.bin` — it authorizes production writes
- **Back up** `node_sk.bin` offline — loss requires re-provisioning
- **Key rotation** — contact jessica@collectivekitty.com
- **Revocation** — immediate on request; recorded in WORM ledger

---

## Prior Art & License

LOCKER node authorization is a protected invention.  
See [DEFENSIVE_PUBLICATION.md](DEFENSIVE_PUBLICATION.md) — Invention 1 (ML-DSA-44 WORM sealing).

**Authors:** Ahmad Ali Parr, Jessica L. Williams / SNAPKITTYWEST  
Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust
