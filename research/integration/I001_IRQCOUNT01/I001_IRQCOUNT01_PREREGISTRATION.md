# I001/IRQCOUNT01 preregistration — real IRQ0 event-count semantic discriminator

Date: 2026-08-30
Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent seam: I001 long-replay `IRQ_EVENT=1` versus `IRQ_EVENT=2`
Architecture posture entering test: `INTEGRATED_SHADOW_CANDIDATE`

## Question

Does the I001 wake/progress consequence require **exactly one** IRQ0 event, or does it require only:

1. at least one real IRQ0 event, and
2. a current/coherent wait relation when the IRQ is observed?

The historical I001 evaluator requires literal `IRQ_EVENT=1`. A 3304-cycle replay later produced 660 I001 red evaluations where both QEMU boots completed exit33 and static closure passed, but the trace contained `IRQ_EVENT=2`. This experiment does not rewrite or recolor that historical evaluator. It creates a new discriminator for the semantic meaning of the count.

## Competing hypotheses

### H1 — exact count is load-bearing
If exactly one IRQ is part of the required mechanism/consequence, then a two-IRQ case must fail or produce a different wake/progress consequence even when the wait relation remains current.

### H2 — positive event plus current relation is load-bearing
If the count is incidental timing telemetry, then one real IRQ and two real IRQs should produce the same accepted wake/progress consequence when the wait relation is current. A two-IRQ case with an invalid wait relation must still reject.

## Fixture

One freestanding 16-bit x86 guest under QEMU TCG with:
- 512-byte stage-1 boot loader;
- fixed 4096-byte stage-2 extent;
- real PIT/PIC IRQ0;
- one explicit wait relation containing generation, continuation, waiting, wake, and progress state;
- no host synthesis of guest debug output.

The guest runs three phases in one boot.

### Phase A — ONE

Prepare a valid wait relation:
- current generation = 1;
- wait generation = 1;
- continuation = 2;
- waiting = 1;
- progress = 0.

Program IRQ0 and configure the handler to mask IRQ0 after the first observed IRQ. Wait through `HLT` until event count reaches 1.

Required output:
- `ONE_EVENT=1`
- `ONE_REL=1`
- semantic gate accepts (`ONE_SEM=W`)
- wake becomes 1
- progress remains 0 until explicit application
- explicit application produces progress 2
- exact-one control accepts (`ONE_EXACT=W`).

### Phase B — MULTI

Reset to the same valid wait relation and zero event/wake/progress state.

Program IRQ0 and configure the handler to leave IRQ0 enabled after the first IRQ and mask it only after the second. Wait through real `HLT` wakeups until event count reaches 2.

Required output:
- `MULTI_EVENT=2`
- `MULTI_REL=1`
- semantic gate accepts (`MULTI_SEM=W`)
- wake becomes 1
- progress remains 0 until explicit application
- explicit application produces progress 2
- exact-one control rejects (`MULTI_EXACT=R`).

### Phase C — BADREL

Reset event/wake/progress state and deliberately make the wait relation stale by setting current generation = 1 and wait generation = 2. Keep continuation/waiting otherwise identical. Again require two real IRQ0 observations.

Required output:
- `BADREL_EVENT=2`
- `BADREL_REL=0`
- semantic gate rejects (`BADREL_SEM=R`)
- wake remains 0
- progress remains 0.

This is the negative control preventing `event_count > 0` alone from being treated as sufficient.

## Mechanism requirements

The IRQ0 handler SHALL:
- increment a guest-owned event counter on each real IRQ0 entry;
- recompute a relation-valid flag from current generation, wait generation, continuation, and waiting state;
- issue PIC EOI;
- mask IRQ0 only when the configured per-phase stop count has been reached.

The semantic gate SHALL test:
- event count is nonzero;
- relation-valid flag is 1;

and SHALL NOT require event count to equal 1.

The exact-count negative/control gate SHALL require event count to equal 1.

Wake and progress application SHALL remain separate operations.

## Pass matrix

The experiment is PASS only if all are true:

1. QEMU scientific status is `COMPLETED` and exit code is 33.
2. Stage 1 is exactly 512 bytes with `55 aa` signature.
3. Stage 2 fits the fixed 4096-byte envelope.
4. Debug trace exactly matches the preregistered labels/order/values.
5. ONE reaches exactly one real IRQ and valid relation; semantic and exact-one gates accept; explicit application reaches progress 2.
6. MULTI reaches exactly two real IRQs and the same valid relation; semantic gate accepts and explicit application reaches progress 2; exact-one gate rejects.
7. BADREL reaches exactly two real IRQs but relation-valid is 0; semantic gate rejects; wake/progress remain 0.
8. Static/source closure verifies the handler owns the event increments and threshold masking, the semantic gate uses nonzero-event + relation-valid predicates, the exact-one gate separately compares against 1, and BADREL is created by a generation mismatch.
9. Run-local controlling-input snapshots exist before build and execution; the build uses those snapshots; original inputs are unchanged through run closure.
10. Independent audit verifies receipt/evaluator/static/source/artifact consistency.

## Interpretation rules

### If PASS

At this tested one-core real-IRQ0 scope, exact event cardinality `1` is not load-bearing for the tested wake/progress consequence. The earned rule becomes:

> one or more observed IRQ0 events can satisfy the event side of the gate, but current/coherent wait relation state remains required.

This would classify the 660 long-replay `IRQ_EVENT=2` reds as historical **exact-evaluator overbinding** for this consequence, not mechanism failures, provided their other sealed closure evidence remains as already recorded.

It SHALL NOT retroactively edit the historical I001 evaluator or erase its red runs.

### If MULTI changes wake/progress consequence

Exact count, timing, or unmodeled repeated-event behavior remains potentially load-bearing. No evaluator relaxation is earned.

### If BADREL accepts

The proposed positive-event semantic gate is too weak. No evaluator relaxation is earned.

## Authority ceiling

Even a PASS does not establish:
- arbitrary interrupt multiplicity;
- interrupt coalescing/loss semantics;
- SMP/NMI/DMA behavior;
- weak-memory ordering;
- production interrupt policy;
- physical-hardware proof;
- final architecture promotion.

It decides only the I001 exact-one versus positive-event/current-relation seam at the tested real IRQ0 scope.

## Preservation rule

Historical I001 source, evaluator, result, and long-replay failures remain unchanged. This experiment lives under a new `I001_IRQCOUNT01` lineage and may only supersede the **interpretation of the exact event-count field**, not the historical evidence record.
