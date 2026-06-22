# X-39MATRIX Security Policy

**Sovereign Topos Protocol** · Effective 2026-06-22 · Version 1.0

We take the security of X-39MATRIX seriously and welcome responsible disclosure of vulnerabilities.

## Reporting a Vulnerability

If you have discovered a security vulnerability in any X-39MATRIX component, please report it to us privately:

### Preferred: HackenProof (public bounty)
- **Platform**: https://hackenproof.com/programs/x39matrix
- **Rewards**: USD 100 – USD 50,000 per finding (see severity matrix)
- **Payment**: Bitcoin Lightning, on-chain BTC, USDC, or wire transfer

### Alternative: PGP-encrypted email
- **Email**: security@x39matrix.org
- **PGP Fingerprint**: `C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8`
- **Public key**: https://x39matrix.org/pgp/sovereign-operator.asc

### Alternative: GitHub Security Advisories
- **Private reporting**: https://github.com/x39matrix/x39matrix/security/advisories/new

## In Scope

All 11 production canisters on Internet Computer mainnet:

| Layer | Canister ID | Lang |
|-------|-------------|------|
| HUB Ω | `arn4r-lqaaa-aaaao-baxwq-cai` | Rust |
| L1    | `b4dy7-eyaaa-aaaao-baxra-cai` | Motoko |
| L2    | `b3c6l-jaaaa-aaaao-baxrq-cai` | Motoko |
| L3    | `akiau-riaaa-aaaao-baxua-cai` | Motoko |
| L4    | `anjga-4qaaa-aaaao-baxuq-cai` | Motoko |
| L5    | `s4zl3-eiaaa-aaaao-bay3a-cai` | Motoko |
| L6    | `adlli-haaaa-aaaao-baxvq-cai` | Motoko |
| L7    | `awm2f-giaaa-aaaao-baxwa-cai` | Rust |
| L8    | `bsbvx-7iaaa-aaaao-baxqa-cai` | Motoko |
| FRONT | `bvatd-sqaaa-aaaao-baxqq-cai` | Assets |
| DASH  | `nsy7t-jiaaa-aaaau-agwra-cai` | Assets |

Plus:
- Web domains: `x39matrix.org`, `www.x39matrix.org`, `evidences.x39matrix.org`
- Lightning proxy: `pay.x39matrix.org`
- GitHub canonical repository

## Out of Scope

- ICP boundary nodes (managed by DFINITY) — report to DFINITY directly
- Bitcoin Core protocol — report to Bitcoin Core security
- Third-party libraries upstream — report upstream first
- Social engineering or physical attacks against the operator
- DoS without code-execution PoC
- Archived/backup repositories

## Response Process

1. **Acknowledgment**: < 24 hours
2. **Triage**: < 72 hours
3. **Remediation**: 7-30 days (immediate for Critical)
4. **Researcher re-test**: invited
5. **Payout**: via researcher's preferred method
6. **Coordinated public disclosure**: after fix deployed

## Safe Harbor

By participating, you agree to act in good faith. We will not pursue civil or criminal action for security research conducted within scope and following this policy.

We commit to:
- Acknowledging your work
- Not taking legal action against good-faith research
- Working with you on coordinated disclosure
- Naming you (or anonymizing by request) in our Hall of Fame
- Anchoring the advisory + your contribution in Bitcoin mainnet

## Hall of Fame

https://x39matrix.org/hall-of-fame (Bitcoin-anchored)

---

**Full Bug Bounty Program**: https://x39matrix.org/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf

Document version 1.0, effective 2026-06-22, BTC-anchored.
