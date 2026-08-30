# D64 / IRQ01 — binding/resource coherence under real IRQ0 preregistration

**Mode:** BUILD-COMMIT
**Parent plan:** `research/plans/D64_BINDING_RESOURCE_IRQ_COHERENCE_PLAN_2026-08-30.md`
**Parent coherence evidence:** C003/P14 CLOSED PASS
**Parent relation evidence:** D64/RB02 CLOSED PASS
**Parent lifecycle/currentness:** D64/ARB01 + RR01 CLOSED PASS / adopted D64 shadow rules
**Evidence envelope:** qualified fixed 8 KiB stage 2
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can one real QEMU IRQ0 observer see an orphan/mixed D64 binding/resource state if IRQ0 is enabled inside bind publication or final detach, while masking IRQ0 across the same coupled writes prevents the observer from accepting that mixed state?

## Fixed representation

Retain the D64 static representation and capacities:

- `ACTIVITY_CAP = 64`;
- `BINDINGS_PER_ACTIVITY = 20`;
- `BINDING_CELL_COUNT = 1280`;
- `RESOURCE_CAP = 64`;
- eleven 64-entry activity arrays;
- `binding_resource_plus1[1280]`;
- `binding_generation[1280]`;
- `resource_identity[64]`;
- `resource_generation[64]`;
- `resource_value[64]`;
- `resource_live_count[64]` as 16-bit unsigned words.

Only binding cell0/resource0 participate dynamically, but the full representation must be linked into the witness.

## Real IRQ source and observer

Use the already-qualified QEMU virtual PIT/PIC IRQ0 pattern from C003/P14:

- install IRQ0 handler at IVT vector 8 (`0x20..0x23`);
- mask all IRQs while preparing each path;
- program PIT channel0;
- unmask only IRQ0 (`PIC master mask = 0xFE`);
- use `STI; HLT` until the same IRQ0 handler records one observation;
- acknowledge PIC EOI and `iret`.

The IRQ0 handler snapshots only:

1. `binding_resource_plus1[0]`;
2. `resource_identity[0]`;
3. `resource_live_count[0]` as a 16-bit word;
4. `irq_seen`.

The handler may not write any tested binding/resource field.

## Coherent and forbidden states

### Empty

- binding ref `00`;
- resource identity `00`;
- live count `0000`.

### Live X

- binding ref `01` (resource slot0 + 1);
- resource identity `51`;
- live count `0001`.

### Forbidden orphan/mixed state

- binding ref `00`;
- resource identity `51`;
- live count `0001`.

For this one-binding slice, the forbidden state means resource lifetime claims one live binding while no binding reference is published.

## Path A — intentionally unprotected bind publication

Start empty with resource generation0 / binding generation0.

1. mask IRQs and program PIT;
2. perform bind prefix in RB02 order:
   - increment resource generation;
   - set resource identity `51`;
   - set resource value `7E`;
   - set live count `0001`;
3. unmask IRQ0 and execute `STI; HLT` before binding publication;
4. handler must snapshot orphan/mixed state `00 / 51 / 0001`;
5. return with IF cleared;
6. increment binding generation;
7. publish binding ref `01`;
8. final state must be coherent live `01 / 51 / 0001`.

This is the bind negative control.

## Path B — protected bind publication

Start empty.

1. mask IRQs and program PIT;
2. inside one labeled protected mutation region perform exactly these six instructions in order:
   1. `incb resource_generation`
   2. write resource identity `51`
   3. write resource value `7E`
   4. write live count `0001`
   5. `incb binding_generation`
   6. publish binding ref `01`
3. only after the region ends, unmask IRQ0 and execute `STI; HLT`;
4. handler must observe coherent live `01 / 51 / 0001`.

Static closure must report:

- protected bind instruction count = `6`;
- protected bind memory-write count = `6`.

## Path C — intentionally unprotected final detach

Start coherent live X with binding generation1, resource generation1, live count1.

1. mask IRQs and program PIT;
2. withdraw binding ref `01 -> 00`;
3. unmask IRQ0 and execute `STI; HLT` before lifetime decrement/reclaim;
4. handler must snapshot orphan/mixed state `00 / 51 / 0001`;
5. return with IF cleared;
6. decrement live count to zero;
7. confirm zero through the same final-detach branch shape;
8. clear resource identity/value;
9. final state must be coherent empty `00 / 00 / 0000`.

This is the detach negative control.

## Path D — protected final detach

Start coherent live X.

1. mask IRQs and program PIT;
2. inside one labeled protected mutation region perform exactly these six instructions in order:
   1. clear binding ref;
   2. decrement live count;
   3. compare live count with zero;
   4. conditional branch over reclaim if nonzero;
   5. clear resource identity;
   6. clear resource value;
3. for this one-binding fixture the branch must fall through to reclaim;
4. only after the region ends, unmask IRQ0 and execute `STI; HLT`;
5. handler must observe coherent empty `00 / 00 / 0000`.

Static closure must report:

- protected detach instruction count = `6`;
- protected detach memory-write count = `4` (binding ref, live-count decrement, identity clear, value clear).

## Exact required debug matrix

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

Evaluator must require exact line order and values.

## Static/source closure requirements

Every checker field under `checks` must be literal JSON boolean. Verify at least:

1. exact D64 capacities and full arrays, including 128-byte resource live-count storage;
2. IRQ0 IVT installation, PIT programming, PIC mask/unmask, EOI, and `iret` exist;
3. one common IRQ0 handler reads binding0/resource-id0/live-count0 and does not write tested fields;
4. bad bind prefix initializes resource generation/identity/value/live count before unmask/`STI;HLT`, with binding generation/ref publication after the IRQ observation;
5. good bind protected region is exactly six source instructions and six tested memory writes in preregistered order;
6. IRQ0 unmask/`STI;HLT` occurs only after good bind protected region;
7. bad detach clears binding ref before unmask/`STI;HLT`, with live-count decrement/reclaim after IRQ observation;
8. good detach protected region is exactly six source instructions with four tested memory writes in preregistered order;
9. IRQ0 unmask/`STI;HLT` occurs only after good detach protected region;
10. handler snapshot storage is separate from tested relation storage;
11. good/bad paths use the same tested binding/resource arrays and same observer;
12. final bad-path post states are explicitly completed after IRQ observation;
13. protected-region instruction/write counts are emitted in static measurements as 6/6 bind and 6/4 detach;
14. run-local input snapshot/receipt source closure holds;
15. host launcher/evaluator/checker does not mutate guest tested relation state or synthesize debug output;
16. all checks are literal JSON booleans.

## Measurements required

Receipt/result must record:

- stage-2 raw bytes / 8 KiB fit;
- named runtime-state bytes;
- D64 capacities;
- protected bind instruction/write counts `6 / 6`;
- protected detach instruction/write counts `6 / 4`;
- PIT divisor;
- QEMU wall time as harness data only;
- input-manifest and exact source/artifact hashes.

## Success criterion

IRQ01 passes only if one controlling run:

- has complete pre-build run-local input snapshot/manifest;
- fits the qualified 8 KiB stage-2 extent;
- QEMU completes exit33;
- exact debug matrix matches;
- evaluator exits0;
- all static checks are literal boolean true;
- independent closure verifies manifest/source/receipt lineage and measurements;
- engineering scars remain visible.

## Authority ceiling

A passing IRQ01 may establish only:

> on one-core real-mode QEMU with maskable IRQ0, the tested binding/resource publication and final-detach writes must be treated as one IRQ-coherent region for this observer; allowing IRQ0 inside the region exposes the preregistered orphan/mixed state, while masking across the six-instruction region prevents that observation.

It does not establish:

- general atomicity/linearizability;
- SMP/NMI/DMA coherence;
- physical interrupt-latency bounds;
- lock-free or wait-free behavior;
- transactions;
- persistence/durability;
- final architecture;
- R3.1/R6 authority change.
