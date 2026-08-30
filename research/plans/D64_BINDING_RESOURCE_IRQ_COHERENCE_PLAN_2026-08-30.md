# D64 Binding/Resource IRQ Coherence Plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent coherence evidence:** C003/P14 real IRQ two-field coherence
**Parent relation evidence:** D64/RB02 CLOSED PASS
**Parent lifecycle/currentness:** ARB01 + RR01 CLOSED PASS / adopted shadow rules
**Experiment preregistration:** not created by this document
**Architecture promotion:** none

## Problem

RB02 publishes one new binding/resource relation through several coupled writes:

1. resource generation/currentness advance;
2. resource identity/value initialization;
3. resource live count becomes 1;
4. binding generation advances;
5. binding resource reference is published last.

Detach performs the reverse lifetime transition:

1. binding reference is withdrawn;
2. resource live count is decremented;
3. if live count reaches zero, resource identity/value are reclaimed.

RB02/ARB01/RR01 executed these transitions with maskable interrupts disabled. That preserves the witness but does not show what a real asynchronous observer sees if IRQ0 is allowed inside the coupled write sequence.

C003/P14 already showed the general failure class: a real IRQ observer can see a torn multi-field transition when the IRQ is enabled after only the first write, and masking across the coupled writes can be sufficient on the tested single-core QEMU slice.

The next discriminator should replay that pressure on the actual D64 binding/resource relation.

## Observer invariant

Use activity0 / binding0 / resource0 only for the runtime path, while retaining the full D64 arrays/capacities.

The IRQ observer snapshots:

- `binding_resource_plus1[0]`;
- `resource_identity[0]`;
- `resource_live_count[0]` as 16-bit word.

For the one-binding/one-resource slice, coherent externally visible states are:

### Empty

- binding ref = 0;
- resource identity = 0;
- live count = 0.

### Live

- binding ref = 1 (`resource slot0 + 1`);
- resource identity = `0x51`;
- live count = 1.

The key forbidden mixed state is:

### Orphan/mixed

- binding ref = 0;
- resource identity = `0x51`;
- live count = 1.

This means the resource lifetime state claims one live binding while no binding reference is published.

## Runtime path A — intentionally unprotected bind publication

Start empty.

1. mask IRQs / clear IF;
2. program PIT0 using the already-qualified real-QEMU IRQ pattern;
3. initialize resource generation/identity/value/live count for X;
4. **before binding reference publication**, unmask IRQ0 and execute `STI; HLT` until handler runs;
5. handler snapshots the mixed state;
6. return with IF cleared;
7. advance binding generation and publish binding ref;
8. final post state must be coherent live.

Required IRQ snapshot:

- bind `00`;
- resource identity `51`;
- live count `0001`.

Required final state:

- bind `01`;
- resource identity `51`;
- live count `0001`.

This is the negative control.

## Runtime path B — protected bind publication

Start empty.

1. mask IRQs / clear IF;
2. program PIT0;
3. perform the complete resource + binding publication while IRQ0 cannot run;
4. only after binding ref is published, unmask IRQ0 and `STI; HLT`;
5. handler must observe coherent live state.

Required IRQ snapshot:

- bind `01`;
- resource identity `51`;
- live count `0001`.

The protected region should contain only the coupled currentness/lifetime/publication writes, not unrelated scan/print/evaluator work.

## Runtime path C — intentionally unprotected final detach

Start coherent live X.

1. mask IRQs / clear IF;
2. program PIT0;
3. withdraw binding ref (`01 -> 00`);
4. **before live-count decrement/reclaim**, unmask IRQ0 and `STI; HLT`;
5. handler snapshots orphan/mixed state;
6. return with IF cleared;
7. decrement live count to zero and reclaim resource identity/value;
8. final post state must be coherent empty.

Required IRQ snapshot:

- bind `00`;
- resource identity `51`;
- live count `0001`.

Required final state:

- bind `00`;
- resource identity `00`;
- live count `0000`.

## Runtime path D — protected final detach

Start coherent live X.

1. mask IRQs / clear IF;
2. program PIT0;
3. withdraw binding ref, decrement live count, and reclaim resource identity/value while IRQ0 cannot run;
4. only then unmask IRQ0 and `STI; HLT`;
5. handler must observe coherent empty state.

Required IRQ snapshot:

- bind `00`;
- resource identity `00`;
- live count `0000`.

## Same-observer rule

All four paths must use the same IRQ0 handler and the same three snapshot fields.

The handler must be read-only with respect to the tested relation fields. It may only:

- copy the three fields into snapshot storage;
- mark `irq_seen`;
- acknowledge PIC EOI;
- restore registers / `iret`.

It must not repair, reorder, publish, detach, or otherwise mutate the relation.

## Exact required matrix for future preregistration

```text
S1_8K_OK
BAD_BIND_IRQ_BIND=00
BAD_BIND_IRQ_RID=51
BAD_BIND_IRQ_LIVE=0001
BAD_BIND_POST_BIND=01
BAD_BIND_POST_RID=51
BAD_BIND_POST_LIVE=0001
GOOD_BIND_IRQ_BIND=01
GOOD_BIND_IRQ_RID=51
GOOD_BIND_IRQ_LIVE=0001
BAD_DETACH_IRQ_BIND=00
BAD_DETACH_IRQ_RID=51
BAD_DETACH_IRQ_LIVE=0001
BAD_DETACH_POST_BIND=00
BAD_DETACH_POST_RID=00
BAD_DETACH_POST_LIVE=0000
GOOD_DETACH_IRQ_BIND=00
GOOD_DETACH_IRQ_RID=00
GOOD_DETACH_IRQ_LIVE=0000
DONE
```

## Coherence mechanism candidate

For the current single-core / maskable-interrupt target, the smallest candidate remains local IRQ masking around the coupled publication/detach write region.

No global lock, transaction manager, scheduler, or historical File primitive is earned merely by this requirement.

The good paths should use the same write order as RB02:

### Bind publication order

- resource generation;
- resource identity;
- resource value;
- live count = 1;
- binding generation;
- binding ref publication.

### Detach order

- binding ref withdrawal;
- live-count decrement;
- reclaim identity/value at zero.

## Cost measurement

The eventual preregistration must require static measurement of the protected mutation region.

At minimum report:

- source-level instruction count from protected-bind region begin to end;
- source-level instruction count from protected-detach region begin to end;
- number of protected memory writes;
- QEMU wall time as harness data only.

Do not translate these counts into physical interrupt latency without physical timing evidence.

## Why a full generic bind scan is not inside the protected region

Binding/resource capacity scans and handle validation can occur before the publication point while no mutation has happened.

The atomicity requirement begins only when the relation starts changing.

Keeping scans outside the masked region is both smaller and a better Pareto choice under the current single-core target.

If later evidence shows a scan result can become stale under another concurrent mutation source, that is a separate concurrency model not covered by this IRQ-only discriminator.

## Evidence envelope

Use the qualified 8 KiB stage-2 loader.

Retain full D64 arrays:

- 64 activities;
- 1,280 binding cells;
- 64 resources with 16-bit live count.

Only slot/cell0 participates in the dynamic IRQ paths, but the representation remains the current D64 one.

## Authority ceiling

A passing discriminator may establish only that masking IRQ0 across the tested coupled binding/resource mutation is sufficient to prevent this one real IRQ observer from seeing the preregistered mixed state on one-core QEMU.

It would not establish:

- general atomicity or linearizability;
- SMP/NMI/DMA coherence;
- lock-free or wait-free behavior;
- physical interrupt-latency bounds;
- general transactions;
- live rekey;
- persistence/durability;
- final architecture;
- R3.1/R6 authority change.

## Disposition

`D64_BINDING_RESOURCE_IRQ_PLAN_READY / SAME_IRQ0_OBSERVER / BAD_BIND_AND_DETACH_MIXED_STATE_CONTROLS / LOCAL_IRQ_MASKING_CANDIDATE / PROTECTED_REGION_COST_REQUIRED / NO_EXPERIMENT_YET`
