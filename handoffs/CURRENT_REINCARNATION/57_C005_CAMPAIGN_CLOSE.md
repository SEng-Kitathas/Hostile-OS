# C005 campaign close — multicore concurrency/coherence re-derivation

Date closed: 2026-08-31 UTC
Status: **CLOSED 20/20 / HARD STOP OBEYED**
Architecture posture: remains `INTEGRATED_SHADOW_CANDIDATE`
Architecture promotion: **NONE AUTOMATIC**
P21: **FORBIDDEN / NOT CREATED**

## Campaign question

When more than one CPU may observe or mutate shared HOSTILE-OS relations concurrently, which additional future-relevant distinctions are required beyond the previously earned one-core interrupt-coherence rules?

## 20-pass result

C005 closed all twenty passes. It began by showing BSP-local `cli` does not protect against another CPU and ended with a target-shaped H1-QEMU adversarial release-provenance challenge.

### Earned bounded grammar

1. **local interrupt exclusion != inter-CPU exclusion** — P01;
2. **inter-CPU exclusion needs an atomic claim transition for the tested shared-flag design** — P02;
3. **publication indicator != published payload; publication order is future-relevant** — P03;
4. **shared read/modify/write != atomic update transition** — P04;
5. **same visible free value != same current acquisition opportunity after reuse cycles** — P05;
6. **exclusion safety != progress under a stalled holder** — P06;
7. **independent exclusion safety != composable progress across multiple claims** — P07;
8. **current at use start != safe until use completion when concurrent reclaim is possible** — P08;
9. **C004 effect-time authority revalidation survives actual two-CPU revocation pressure** — P09;
10. **IRQ coherence and inter-CPU coherence must share a protocol when they touch one coupled relation** — P10;
11. **read-only observers may avoid exclusive ownership when overlapping writes are detectable and retried** — P11;
12. **that versioned-reader scheme separately requires a single-writer condition under multiple writers** — P12;
13. **snapshot safety != reader progress under a stalled writer** — P13;
14. **retry/wait budget exhaustion != recovery authority** — P14;
15. **recovery authority != old-writer currentness; superseded writer effects must become stale/rejectable** — P15;
16. **bounded participation wrap != no users; overflow/exhaustion must be explicit when zero authorizes reclaim** — P16;
17. **same bounded version value != same snapshot epoch once wrap is reachable** — P17;
18. **durable resource meaning != durable runtime concurrency ownership across restart** — P18;
19. **the main concurrency grammar composes under one bounded two-CPU workload** — P19;
20. **claimed owner identity != trusted release provenance** — P20 hard stop.

### Working compression

A useful current compression is:

`trusted participant provenance + atomic/current transition state + publication/lifetime/recovery protocol -> coherent shared effect`

This is working vocabulary, not constitutional primitive ontology.

## What C005 disproved at tested scope

- local `cli` is sufficient for SMP shared-state coherence — false;
- plain read-then-store can safely claim inter-CPU exclusion — false;
- a ready flag alone proves its payload is already published — false;
- plain split read/modify/write preserves concurrent update intent — false;
- a reused free byte is necessarily the same ownership opportunity — false;
- safe exclusion automatically guarantees progress — false;
- independently safe claims automatically compose without circular wait — false;
- validation at use entry protects an in-flight use from later concurrent reclaim — false;
- IRQ-only and CPU-only coherence rules compose automatically — false;
- odd/even versioning alone supports multiple concurrent writers — false;
- a correct retry loop guarantees progress if the writer stalls — false;
- a retry/time budget creates authority to repair shared state — false;
- recovery authority alone prevents a superseded writer from later corrupting recovered state — false;
- bounded count/version wrap may safely alias zero/old token semantics — false;
- runtime held/users state should be blindly reconstructed from durable bytes after fresh boot — false;
- an untrusted claimed owner ID may authorize release — false.

## Mechanism witnesses versus architecture

C005 used x86 atomic instructions, local APIC IDs, INIT/SIPI, PIT/PIC IRQ0, and QEMU TCG. These are enforcement/observation witnesses. They do not become universal HOSTILE-OS architecture by campaign momentum.

The campaign earns responsibilities: atomic/current transitions where futures differ, trusted provenance where ownership/release matters, explicit progress/recovery ceilings, bounded-state exhaustion/wrap handling, safe lifetime participation, and fresh reconstruction of runtime concurrency state.

## Process / lineage scars retained

- P01 first attempt failed before the discriminator because 16-bit absolute LAPIC MMIO addressing truncated addresses; Amendment A corrected transport only.
- P12 first attempt reached the intended bad semantic state but a debug print clobbered the derived bit; reporting-only Amendment A fixed the trace and the controlling rerun passed.
- P14 had a post-closure source mutation at commit `ef6bf67`; the controlling result remains bound to `46c3855`. The later source variant produced the same PASS trace and is admitted only as non-controlling reproduction; live P14 source was restored to the controlling snapshot at `095c132`.
- A temporary ngrok/server outage interrupted P15 pre-seal qualification; no P15 science ran during the outage. Recovery re-read canonical state before resuming.

No UNKNOWN/red/non-controlling evidence was recolored or deleted.

## What is not earned

C005 does not establish:
- arbitrary CPU counts;
- physical H1 SMP behavior;
- cross-architecture weak-memory rules;
- DMA/IOMMU/NMI/SMI coherence;
- fairness, starvation freedom, lock-free/wait-free progress;
- a scheduler or blocking architecture;
- a universal lock/reference-count/RCU/seqlock/fencing-token abstraction;
- production timing/latency bounds;
- complete system security;
- final architecture.

## Campaign disposition

`C005 = CLOSED 20/20`.

The broad mature-OS comparison pressure “concurrency/coherence beyond one-core maskable IRQ scope” is no longer unstructured. It now has a bounded earned grammar and explicit ceilings.

No architecture promotion follows automatically. The next lawful work is mandatory post-campaign reconciliation and representation/Pareto convergence against the current research body and H1 target, not C005/P21 and not a reflexive new campaign.
