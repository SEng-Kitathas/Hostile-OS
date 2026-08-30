# Execution and Release Discipline — R6 Operational Recovery

R1/R2 compressed these duties too far. These are operational recovery statements bound to exact R6/V5 source sections. They are not new doctrine promotion.

### E01 — V7:Experiment rules

Authority: `R6_OPERATIONAL_QUALIFICATION_RULE`

Before a consequential run, name the discriminator; tool work must advance it or preserve evidence.

### E02 — V7:Experiment rules + V5:Execution discipline

Authority: `R6_OPERATIONAL_QUALIFICATION_RULE`

Consequential or durable runs name cwd/interpreter/environment, retain stdout/stderr/exit/completion evidence, and use stable artifact paths.

### E03 — V5:Execution discipline

Authority: `R6_OPERATIONAL_QUALIFICATION_RULE`

Inspect final artifact or state rather than treating command success as the consequence.

### E04 — V5:Execution discipline

Authority: `R6_OPERATIONAL_ADMISSIBILITY_BOUNDARY`

Timeout or ambiguous process state remains UNKNOWN until evidence resolves the result or effects.

### E05 — V7:Action and mutation discipline

Authority: `R6_OPERATIONAL_ADMISSIBILITY_BOUNDARY`

Do not claim saved, written, executed, committed, tested, verified, uploaded, extracted, or promoted without tool/runtime readback.

### E06 — V7:Artifact rules

Authority: `R6_RELEASE_QUALIFICATION_RULE`

Sealed/release artifacts require exact membership/manifest, hashes, clean extraction replay, explicit lineage and assurance ceiling, and exclusion of accidental runtime state.

### E07 — V5:Verifier purity and replay

Authority: `R6_VERIFIER_QUALIFICATION_RULE`

Verification must not silently contaminate the specimen; isolate generated state when needed.

### E08 — V5:Verifier purity and replay

Authority: `R6_VERIFIER_QUALIFICATION_RULE`

Membership completeness and identity of present members are separate checks.

### E09 — V5:Verifier purity and replay

Authority: `R6_VERIFIER_QUALIFICATION_RULE`

Shared mutable declarations between verifier and specification are a common-mode trust boundary unless a distinct witness is added.

### E10 — V5:Continuity

Authority: `R6_CONTINUITY_QUALIFICATION_RULE`

Continuity is as-of a checkpoint and must preserve current state, intent, authority boundaries, evidence, scars, rejected/deferred branches, lineage, known errata, and next discriminator.
