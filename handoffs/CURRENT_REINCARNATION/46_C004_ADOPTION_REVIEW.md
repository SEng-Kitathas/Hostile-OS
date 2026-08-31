# C004 adoption review — authority/protection grammar

Date: 2026-08-31 UTC
Status: **ADOPT SHADOW RULES / NO FINAL ARCHITECTURE PROMOTION**
Campaign: C004 CLOSED 20/20

## Adopted shadow rules

At the tested C004 scopes, the incumbent authority/protection grammar SHALL preserve:

- trusted caller provenance distinct from untrusted caller claims;
- authority/applicability distinct from resource currentness;
- operation-specific rights rather than one universal allow bit;
- non-amplifying delegation/attenuation;
- independent authority currentness/revocation;
- checked reusable authority identity/currentness rather than slot location;
- explicit finite-capacity failure;
- explicit initialization of authority-bearing state on reuse;
- authority lifetime separate from resource lifetime;
- effect-time authority revalidation when revocation can intervene after request acceptance;
- restart authority epoch/currentness when durable grant meaning reconstructs a fresh runtime namespace;
- local unauthorized failure where unrelated valid futures remain possible;
- a non-bypassable enforcement boundary for actually untrusted code;
- privileged mediation for effects, such as direct I/O, that untrusted code could otherwise issue outside software checks.

Working compression:

`protected caller provenance + checked authority relation + operation + currentness -> mediated effect`

These are working relations, not constitutional object nouns.

## Embodiment consequence

`os/research_only/d64_reference_v2/` remains CURRENT_RESEARCH_REFERENCE for the pre-C004 adopted D64-era body, but it is now **scientifically behind the authority/protection shadow**.

Do not silently retrofit C004 into the remaining752-byte v2 headroom. A separate representation/Pareto convergence review is required before any new research body or loader-envelope enlargement.

## Promotion ceiling

This review does not establish final architecture, complete security, production readiness, or a release ABI.

The x86 ring/TSS/interrupt-gate mechanisms used by C004 remain enforcement witnesses, not mandatory cross-target architecture.
