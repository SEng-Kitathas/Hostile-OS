# Donor Lock and Contamination Ledger

## Primary donor lock

### D1 - Linux 0.01

Canonical public source identity:
- URL: `https://www.kernel.org/pub/linux/kernel/Historic/linux-0.01.tar.gz`
- SHA-256: `24454f830cdb571e2c4ad15481119c43b3cafd48dd869a9b2945d1036d1dc68d`
- Hash source: kernel.org signed `sha256sums.asc`.

Role: embryonic Unix-like kernel donor. It exposes a small early architecture before decades of Linux institutional/compatibility accumulation.

### D2 - FreeDOS kernel

Canonical repository identity for first scar-rich donor snapshot:
- official repository: `FDOS/kernel`
- release tag: `ke2046`
- annotated tag object: `c0ba189e62ebaf15fbcc7a4076b37d57c6e6b98d`
- commit: `5ffb5502d39a10a30f5b8a9e8beeba0bf30245d3`
- tag date: 2026-06-30.

Role: mature DOS-compatible kernel donor carrying compatibility pressure, directness, and long-lived behavioral scars.

**Authority ceiling:** Linux tarball and FreeDOS repository identities are externally verified, but donor bytes were not successfully materialized inside this ChatGPT container. No source-level scientific Pass 1 is claimed in this package. The included durable fetch/lock script is the next required machine-side operation.

## Why current FreeDOS rather than pretending an early FreeDOS release is equivalent

The first experiment wants deliberately asymmetric witnesses:
- Linux 0.01: embryonic, historically small, pre-accumulation.
- FreeDOS current scar-rich kernel: mature compatibility organism.

An early FreeDOS genealogy may later be added as a third historical control if a discriminator requires it. It is not silently substituted for the scar-rich donor.

## Contamination classes

`C0` - no known internal ancestry; candidate may support genuine external convergence.  
`C1` - high-level personal intuition existed, but current mechanism detail not known/recalled.  
`C2` - explicit mechanism existed in old project; any rediscovery is ancestry-contaminated.  
`C3` - old implementation/spec exists; direct reuse requires explicit donor transfer and cannot count as re-derivation.  
`C4` - rejected/failed mechanism; resurrection requires new discriminator addressing the original failure.

## Initial contamination ledger

| Hypothesis / mechanism | Class | Prior ancestry | Rule |
|---|---:|---|---|
| ECS-like OS state representation | C3 | Holonic OS/Holonix/FtD/Cardinal | Treat as hypothesis; do not call independent rediscovery. |
| Role derived from capability | C3 | FtD, Microseed, CIC | Re-derive under OS requirements. |
| Recursive holons / logical organs | C3 | FtD, Holonix, KarnOS | May supply test cases; no architecture authority. |
| Schedulerless coordination | C3 | KarnOS stigmergic scheduling | Must beat explicit scheduler candidates; convergence is contaminated. |
| Explicit ECS scheduler | C3 | Holonix/Aedifex | Contrary ancestral candidate; not default. |
| Probe hardware then choose implementation | C3 | KarnOS/CIC | Candidate process; re-derive against actual hardware. |
| Append-only event/evidence lineage | C3 | CIL/CIC/Aedifex/Forge | Purpose and retention economics must be re-earned. |
| Capability/security object model | C2/C3 | Holonix/FtD/CIC | Re-derive exact authority primitive. |
| Co-use-driven layout | C2/C3 | Ergo/KarnOS/Rust ECS audit | Measure first; conceptual layout may win sometimes. |
| Build-time expensive optimization, cheap runtime | C2/C3 | Ergo/Chainwraith | Candidate Pareto move. |
| Ternary UNKNOWN state | C3 | FtD/TQ2/TRCH/Microseed | Use only where semantics are truly three-valued. |
| Constitution/expression/phenotype separation | C3 | Aedifex/CIC/Microseed | Process/governance transfer allowed; OS mapping re-derived. |
| Direct-hardware-first OS | C3 | 2024-25 ancestral OS project | Historical intent, not evidence. |

## Sealed external comparison vault for early campaigns

Until a campaign discriminator requires them, do not use modern Windows NT, modern Linux, BSD, Plan 9, seL4, QNX, Fuchsia, Redox, SerenityOS, Haiku, capability OSs, unikernels, or contemporary microkernel designs as solution donors.

They may be used for **external validation after a candidate stabilizes**, or earlier only if the live discriminator cannot be answered by D1/D2 and the Attention Reservoir promotes the need.

This prevents modern solution leakage while preserving the ability to research when ignorance becomes more expensive than contamination.
