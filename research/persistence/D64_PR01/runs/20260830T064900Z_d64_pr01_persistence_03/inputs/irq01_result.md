# D64 / IRQ01 — binding/resource coherence under real IRQ0 result

**Disposition:** PASS / BOUNDED REAL-IRQ COHERENCE EARNED
**Controlling preregistration:** `0c14b605e6b29c4767d9fbf6a03e5ee1bcd4b36f`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Question

Can a real QEMU IRQ0 observer see the preregistered orphan/mixed D64 binding/resource state if IRQ0 is admitted inside bind publication or final detach, while one six-instruction masked region prevents that observer from accepting the same mixed state?

## Controlling run

Run:

`20260830T060500Z_d64_irq01_coherence_01`

QEMU:

- PID: `14588`
- started: `2026-08-30T06:05:07.740363+00:00`
- ended: `2026-08-30T06:05:08.073374+00:00`
- status: `COMPLETED`
- exit: `33`
- wall time: `332.994 ms` as harness data only

Evaluator: PASS / exit 0.
Static closure: PASS / 16 literal-boolean checks true.
Independent closure: PASS / 14 independent checks true.

## Exact guest trace

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

## Observed consequence

### Unprotected bind publication

The bad bind path initialized the resource record and set live count `0001`, then admitted IRQ0 before publishing the binding reference.

The real IRQ0 handler observed:

- binding ref: `00`
- resource identity: `51`
- live count: `0001`

That is exactly the preregistered forbidden orphan/mixed state: lifetime claims one live binding while no binding reference is yet visible.

After IRQ return, the path completed publication and the final state became coherent live:

- binding ref `01`
- resource identity `51`
- live count `0001`

### Protected bind publication

The good bind path kept IRQ0 masked across the exact six-instruction publication region and admitted IRQ0 only afterward.

The real IRQ0 handler observed only coherent live state:

- binding ref `01`
- resource identity `51`
- live count `0001`

Static measurement:

- protected bind instructions: `6`
- protected bind tested-memory writes: `6`

### Unprotected final detach

The bad detach path cleared the binding reference and then admitted IRQ0 before decrementing/reclaiming resource lifetime.

The same real IRQ0 handler again observed the forbidden state:

- binding ref `00`
- resource identity `51`
- live count `0001`

After IRQ return the path completed final detach/reclaim and reached coherent empty state:

- binding ref `00`
- resource identity `00`
- live count `0000`

### Protected final detach

The good detach path kept IRQ0 masked across its exact six-instruction final-detach region and admitted IRQ0 only after the region.

The handler observed coherent empty state:

- binding ref `00`
- resource identity `00`
- live count `0000`

Static measurement:

- protected detach instructions: `6`
- protected detach tested-memory writes: `4`

## Representation / envelope readback

The witness retained the full D64 static relation sizes:

- activity capacity: `64`
- binding cells: `1,280`
- resource capacity: `64`
- 16-bit resource live-count storage

Built readback:

- stage-2 raw bytes: `4,773`
- qualified stage-2 extent: `8,192`
- remaining stage-2 headroom: `3,419` bytes
- named runtime-state bytes: `3,615`
- PIT divisor: `4,096`

Only binding cell0/resource0 participated dynamically, but the full D64 arrays were linked and statically checked.

## Static/source closure

All 16 checker fields were literal JSON booleans and all were true:

1. exact D64 arrays;
2. real IRQ0 plumbing;
3. one read-only IRQ observer;
4. bad bind cut order;
5. good bind exact `6/6` region;
6. good-bind IRQ after protected region;
7. bad detach cut order;
8. good detach exact `6/4` region;
9. good-detach IRQ after protected region;
10. snapshot storage separated from tested relation state;
11. same tested arrays across good/bad paths;
12. bad paths explicitly complete final post-state;
13. protected-region measurements exact;
14. input-manifest/receipt source closure;
15. host does not mutate guest tested state or synthesize debug output;
16. all check values are literal booleans.

## Provenance closure

Input-manifest SHA-256:

`f27bea6f07c8a4c9a2374df795b0db04cf2cdf3ad180c8740a80fa31e8665cb9`

Receipt SHA-256:

`e48ec6cfbb8e24fcf97168b270102cb6309becf28ca9e72b4080e9a2f62eb6ea`

Independent audit SHA-256:

`c4cea44c703a285ddeee584921718860ef9a47004319aba85f0f08a056ffb9df`

Key source hashes:

- stage2.S: `659915c89959f1eaa6bb8dd921b03bd28c5d0e35906cef0dcd28ba3cfac6fc37`
- stage2.ld: `3767bc633ad65f9b37fb09f3bb4f7ae0aba8f2e1680621402adc612d5a70307f`
- launcher: `dc5d922d6012cfe4b224a2a64df548595ada16a860c10a638f1cba6b59b036e8`
- evaluator: `5f0eb234df99bc39ae8fe1ed1581fb2bd2be45776c2a74555878600ca23c0bb9`
- static checker: `b6388e69d85692a868586253448ff14069936c1a5a47b468184601f4a2956229`

Key artifact hashes:

- stage2.raw.bin: `d51ed68e35bc64471a06d36db49d8553cb664cb97f3f1b853864bdd746a1d82e`
- debugcon.txt: `dd44407c4980be511f095d6c6bf7f02411c599add8db724ea3f10983a4b7dcf0`
- evaluation.json: `eadb9d12c64bd159a164f4c55ff7d1b6b10b83971c6b2ef46f37e1e5b49d4875`
- static_closure.json: `e9f56af5c9156f7cf20403cd7685bd16a67b75c45aebbf07e928ee505226d1dc`

The independent audit additionally verified exact preregistration lineage, QEMU exit33, evaluator/static pass, stage-2 fit, runtime-state size, capacities, protected-region costs, PIT divisor, and run-local snapshot/source agreement.

## What IRQ01 earns

At the tested one-core real-mode QEMU boundary:

> coupled binding/resource publication and final detach must be treated as one IRQ-coherent mutation region for the tested observer. Allowing real IRQ0 between the coupled writes exposes the preregistered orphan/mixed state. Keeping IRQ0 masked across the six-instruction region prevents that observer from accepting the mixed state and yields only coherent pre/post observations.

This is direct mechanism evidence, not merely a source-order argument.

## Authority ceiling / nonclaims

IRQ01 does not establish:

- general atomicity or linearizability;
- SMP coherence;
- NMI or DMA coherence;
- weak-memory ordering;
- physical interrupt-latency bounds;
- lock-free or wait-free behavior;
- transaction semantics;
- persistence/durability;
- arbitrary binding/resource operations;
- final/canonical/production architecture;
- any R3.1/R6 authority change.

## Next seam

If IRQ01 is adopted after close review, the immediate one-core maskable-IRQ coherence gap for this bind/detach slice is resolved. The next pressure should not widen by momentum. Reconcile the interrupt-off cost against the current size/power/Pareto posture and then choose among remaining higher-risk seams: quiescent-rekey availability, expanded relation persistence, or stronger hardware/concurrency boundaries.

## Disposition

`D64_IRQ01_PASS / REAL_IRQ0_ORPHAN_STATE_OBSERVED_WHEN_UNPROTECTED / SIX_INSTRUCTION_BIND_REGION_6_WRITES_EARNED / SIX_INSTRUCTION_DETACH_REGION_4_WRITES_EARNED / PROTECTED_OBSERVER_SEES_ONLY_COHERENT_STATE / NO_GENERAL_ATOMICITY_PROMOTION`
