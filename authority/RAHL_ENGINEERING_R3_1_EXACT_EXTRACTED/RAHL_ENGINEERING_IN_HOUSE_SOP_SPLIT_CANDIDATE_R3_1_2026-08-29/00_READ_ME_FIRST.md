# Rahl Engineering In-House SOP Split Candidate — R3.1

Date: 2026-08-29
Status: `SHADOW_USE_CANDIDATE`
Replacement ready: `false`
Candidate authority: `COMPRESSION_ONLY_INHERITS_NO_NEW_AUTHORITY`
Parent authority: `R6`
Parent SHA-256: `69721b7b6c4b8c04d5377f1b7c0afa044530a6352496c7cb564f4cb4ef2df257`
Foundation promotion: `false`
Assurance ceiling: `STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY`

R1 and R2 are rejected as replacement candidates. R1 flattened authority and its verifier missed its own rejection criteria. R2 repaired several structural checks but still flattened all rules into one candidate authority class and did not bind rule bodies.

R3 changes the design rather than polishing R2:

1. The engineering surface carries the exact V5/R6 statement classes instead of making all rules peers.
2. Source body and source class are both bound to embedded exact ancestry.
3. Current active R5+R6 scars are recoverable at cold start.
4. Execution/release discipline is explicit again.
5. Internal research governance remains in-house only.
6. The substrate profile is a dormant activation schema, not a permanently active empty surface.
7. Named machinery/modes are preserved with demoted process-only authority rather than silently retired or resumed.

The historical churn falsification did **not** support the claim that model/substrate releases were the main historical SOP churn driver. The split is retained because the surfaces carry different authority/currentness rules, not because that causal story was proven.

`SAME_SURFACE != SAME_AUTHORITY`
`FALLBACK_AUTHORITY != COLD_START_RECOVERABILITY`
`SCAR_RECORDED != SCAR_EMBODIED`
