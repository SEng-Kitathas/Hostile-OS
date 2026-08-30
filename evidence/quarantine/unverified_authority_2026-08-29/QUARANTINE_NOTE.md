# Unverified authority mutation quarantine

Date: 2026-08-29
Disposition: QUARANTINED / NOT ACTIVE AUTHORITY

## Preserved artifact
- Original working-tree path: `authority/R3_1_PROMOTION_ADJUDICATION_2026-08-29.md`
- Quarantine copy: `evidence/quarantine/unverified_authority_2026-08-29/R3_1_PROMOTION_ADJUDICATION_2026-08-29.md`
- SHA-256: `d457920de843216ca5a28b839d952ee7794d3e6d88fa5f8f9829a4062385ecc7`
- Original mtime observed: `2026-08-29T19:42:50.4036742Z`

## Provenance finding
PCMMAD execution journals contain later observations of this path/text, but the audit did not recover a verified write command or actor identity for the mutation. Observability after creation is not provenance of creation.

## Authority handling
The concurrent edit also appended a promotion-gate note to `authority/ADOPTION_STATE.md` claiming the R3.1 shadow-use blocker was satisfied for successor consideration while keeping R3.1 itself `SHADOW_USE_CANDIDATE`, `replacement_ready=false`, and R6 as parent authority.

Because the mutation's origin is unverified, neither the adjudication file nor the adoption-state delta is admitted to active authority. The tracked `ADOPTION_STATE.md` is restored to the last committed authority baseline. The exact adjudication bytes are preserved here as controlled evidence.

No R3.1 replacement/foundation promotion is performed by this quarantine action.
