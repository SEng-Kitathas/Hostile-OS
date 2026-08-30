# HOSTILE-OS Architecture Promotion Review — 2026-08-30

**Mode:** AUDIT / PROMOTION REVIEW
**Role:** R1 Conservative Auditor
**Evidence base:** C001, C002, C003, POST-C003/R01, I001, current continuity and authority state
**R3.1/R6 SOP authority effect:** NONE

## Question

What is the strongest HOSTILE-OS architecture posture actually earned after I001, without turning a bounded integrated success into a final-architecture claim?

## Decision

**PROMOTE HOSTILE-OS RESEARCH ARCHITECTURE POSTURE TO:**

`INTEGRATED_SHADOW_CANDIDATE`

This is a deliberately narrow promotion.

It means:

- the relation/state model embodied by the surviving C001->C002->C003->R01->I001 lineage is now the **incumbent integrated research architecture candidate** for HOSTILE-OS;
- it is strong enough to guide the next design and embodiment work unless later evidence demotes it;
- it outranks abandoned or purely speculative architecture branches as the current research baseline;
- it remains a shadow candidate, not a final architecture, canonical replacement, production design, or universal OS theory.

This review does **not** make R3.1 replacement-ready, change R6 authority, or promote the engineering/research SOP. HOSTILE-OS architecture posture and R3.1/R6 workflow authority are separate planes.

## Why the prior `NO ARCHITECTURE PROMOTION` posture is now too weak

Before I001, the conservative blocker was clear: the project had strong bounded slices and P20 partial composition, but no single freestanding executable carried the main responsibility families together.

I001 removed that blocker at bounded scope.

One freestanding 2,478-byte stage-2 payload, across two distinct fresh QEMU processes, now carries in one state model:

- finite two-slot activity capacity and explicit full behavior;
- parent/child lineage and generation-qualified wait targeting;
- explicit continuation identity;
- missing-operation status without progress/continuation mutation;
- real virtual-hardware IRQ0 consequence and explicit idle;
- completion recording separate from wake matching;
- wake separate from progress application;
- later B progress after local failure;
- release/reuse with explicit initialization and generation advance;
- checked stale-handle rejection plus address-only retarget negative control;
- R01-style spanning-reader flag/version controls;
- shared-backing lifetime and final reclaim;
- explicit little-endian durable serialization;
- clean persistence across two fresh QEMU processes;
- pre-rebind rejection and explicit rebind;
- prior-boot token rejection using runtime epoch despite intentional slot/generation reuse;
- fail-closed finite generation exhaustion;
- integrated negative controls for wake/apply collapse, global failure poisoning, and overwrite-on-full.

The evaluator, static/source closure, durable-sector inspection, process-order audit, and independent cross-check all passed on the controlling run.

The architecture family is therefore no longer merely a set of isolated distinctions. It has a real integrated embodiment under a preregistered workload.

Keeping the architecture posture at plain `NONE` would now hide earned evidence rather than preserve caution.

## Why promotion stops at `INTEGRATED_SHADOW_CANDIDATE`

I001 is strong integration evidence, but its boundaries are still narrow and visible.

### 1. Capacity and lifetime policy are experiment-sized

I001 uses:

- exactly two activity slots;
- 8-bit generations;
- 8-bit runtime epochs;
- fail-closed `G` before zero-wrap;
- main-path generations only 1 and 2.

The fail-closed rule is real and better than silent wrap, but the project has not yet earned a production reuse horizon, width, rekey process, or exhaustion-recovery policy.

This blocks a production/canonical claim. It does not block shadow-candidate status.

### 2. Platform boundary is still partly firmware-shaped

I001 uses BIOS INT 13h for stage loading and durable transport.

Attempt 1 exposed a real interaction: guest IRQ0/PIC takeover followed by later BIOS transport caused BIOS to report failure even though durable bytes reached disk. Restoring the saved firmware-visible IRQ0 vector and PIC masks before BIOS reuse repaired the run.

That is valuable evidence, but it leaves a target choice unresolved:

- either firmware services remain an explicit borrowed platform boundary, with ownership/restore discipline;
- or the mature target stops reusing BIOS after taking control and owns its device transport directly.

Until that target boundary is chosen, the current design should remain shadow rather than canonical.

### 3. Hardware evidence is virtual, not physical

The project has real QEMU virtual-hardware IRQ/PIT/PIC consequences and real binary execution, but no physical-hardware result.

Physical hardware is not automatically required to keep doing research, and it should not become ritual proof. It is, however, a blocker for claims about physical-device timing, firmware quirks, or hardware portability.

### 4. Concurrency envelope is narrow

The earned coherence mechanisms cover:

- one real-mode uniprocessor QEMU environment;
- maskable IRQ0;
- bounded critical regions;
- version/change checks around one spanning-reader model.

They do not establish SMP, NMI, DMA, weak-memory ordering, general lock-free behavior, or universal linearizability.

These are blockers only if the target architecture claims those environments.

### 5. Persistence is clean-restart persistence

The project has not earned crash/partial-write/torn-write recovery.

This is **not automatically a defect** and must not be smuggled in as an inherited requirement. C002 explicitly did not earn crash/partial-write recovery.

It becomes a promotion blocker only if the intended target requires durable correctness across interrupted writes or power loss.

### 6. Workload remains fixed and handcrafted

I001 is a real integrated workload, but still one bounded workload with fixed identities, fixed capacity, fixed serialization, one IRQ source, and one durable record.

That is enough for an integrated research candidate. It is not enough for arbitrary-workload or general-purpose claims.

### 7. Failed-run source provenance has a process scar

I001 attempts 1 and 2 preserved binaries, objects, traces, and one receipt, but did not snapshot exact source inputs into each run directory before execution.

The final controlling run has exact source closure, so the scientific success stands. But future experimental infrastructure should fix this before another mutation-heavy campaign.

This is an assurance-process debt, not an architecture disproof.

## Repeated distinctions strong enough to treat as incumbent design rules

The following are no longer one-off ideas. They survived multiple independent pressures and integration:

### A. Selection / notification / application separation

The project repeatedly showed that choosing, waking, or reporting success is not the same as applying progress.

Incumbent rule:

> Keep decision/eligibility, notification/wake, and state application separate unless a later discriminator proves their fusion harmless for the target case.

### B. Currentness is part of identity when storage or time can reuse names

Index, address, or durable identity alone is often insufficient once compaction, reuse, restart, or spanning reads exist.

Incumbent rule:

> Bind runtime use to the minimum currentness information needed by the actual reuse horizon: identity plus generation/version/epoch where the tested failure shape requires it.

Do not generalize this into "always add versions everywhere."

### C. Failure should remain local unless a global consequence is explicitly earned

Missing operation, full capacity, stale handle, and finite-generation exhaustion all have bounded explicit outcomes.

Incumbent rule:

> Prefer local explicit status and preserved unrelated progress over a global poison mechanism unless the workload truly requires global failure.

### D. Lifetime and reuse are behavior, not cleanup details

Backing live count, slot generation, explicit field initialization, and volatile restart binding all affect correctness.

Incumbent rule:

> Treat reuse, currentness, and lifetime transitions as load-bearing state changes with explicit rules.

### E. Platform ownership boundaries must be explicit

I001's IRQ/PIC -> BIOS scar showed that borrowed firmware behavior can depend on state the guest has taken over.

Incumbent rule:

> When HOSTILE-OS borrows firmware/platform services, record which machine state that service expects and either restore it before reuse or stop borrowing the service.

### F. Historical subsystem nouns remain optional descriptions, not primitives

The integrated workload did not require Process, Scheduler, File, Manager, or Service objects as primitive architecture species.

Incumbent rule:

> Do not introduce those nouns as primitives merely because historical systems use them. Add a new primitive only when a consequence cannot be expressed cleanly by the earned state/relations at acceptable Pareto cost.

This rule does not ban those abstractions forever. It keeps their burden of proof intact.

## What `INTEGRATED_SHADOW_CANDIDATE` is allowed to do

The posture may:

- serve as the default architecture baseline for HOSTILE-OS design discussions;
- guide new freestanding implementations and experiments;
- define the current incumbent relation/state vocabulary;
- reject unearned reintroduction of historical subsystem primitives;
- be compared against new branches on explicit Pareto and evidence grounds;
- accumulate implementation descendants without pretending each descendant is canon.

It may not:

- call itself final, canonical, production-ready, replacement-ready, or universally minimal;
- claim arbitrary workload support;
- claim physical-hardware proof;
- claim general memory/capability safety;
- claim SMP/NMI/DMA correctness;
- claim crash-consistent persistence;
- claim that Process/Scheduler/File-style abstractions are universally wrong;
- alter R3.1/R6 authority;
- erase C002 source-recovery uncertainty or I001 failed-run provenance scars.

## Demotion triggers

Demote `INTEGRATED_SHADOW_CANDIDATE` if any later verified evidence shows one of the following:

1. an I001 load-bearing consequence depended on a harness action or hidden host mutation not represented in the current evidence;
2. independent replay of the controlling source/artifacts fails under the same qualified environment without an explained environment change;
3. a required responsibility cannot compose without introducing a materially different primitive/state species and the old model can no longer express the target workload cleanly;
4. the candidate's currentness/lifetime policy causes silent alias or stale-retarget behavior inside the declared target lifetime;
5. platform-boundary restoration proves insufficient or contradictory under the target firmware/device model;
6. a simpler competing architecture achieves the same required consequences with a clearly better Pareto vector and equal or stronger assurance;
7. source/provenance integrity for a load-bearing controlling result is invalidated.

## What is not a demotion trigger by itself

Do not demote merely because:

- a mature implementation later introduces descriptive modules or convenience APIs named process/file/scheduler;
- capacity must grow beyond two slots;
- a generation field must widen;
- BIOS is replaced by native device transport;
- the evidence envelope grows beyond 4 KiB;
- physical hardware requires platform-specific adaptation;
- an implementation needs better tooling or debugging surfaces.

Those may be normal embodiment changes if the underlying responsibilities and distinctions survive.

## R3.1 / R6 authority review

No change.

I001 tests HOSTILE-OS mechanism and the lab's ability to preserve preregistration, scars, bounded claims, readback, and integration pressure. It does not provide a broad enough R3.1-vs-R6 decision-equivalence corpus to make `replacement_ready=true`.

Therefore:

- R3.1 status remains `SHADOW_USE_CANDIDATE`;
- `replacement_ready=false`;
- R6 remains parent authority;
- foundation promotion remains false.

## Need for another build experiment

**No immediate new experiment is required to justify the shadow-candidate promotion.**

The next highest-value work is design clarification, not another pass count:

1. define the intended post-boot platform boundary: borrowed BIOS services versus owned native transport;
2. define the intended target workload/capacity envelope;
3. choose whether finite generation exhaustion is acceptable fail-closed behavior, or whether the target needs rekey/epoch rollover;
4. repair run-source snapshot discipline in the harness before any next experiment;
5. only then choose a new discriminator that attacks a real target seam.

Building another toy merely to increase evidence count would lower signal.

## Promotion result

`HOSTILE_OS_ARCHITECTURE = INTEGRATED_SHADOW_CANDIDATE`

`FINAL_ARCHITECTURE = false`

`PRODUCTION_READY = false`

`REPLACEMENT_READY = false`

`R3_1_AUTHORITY_CHANGE = none`

`R6_PARENT_CHANGE = none`

`NEXT_PHASE = target-boundary and capacity/lifetime design clarification before further experimentation`
