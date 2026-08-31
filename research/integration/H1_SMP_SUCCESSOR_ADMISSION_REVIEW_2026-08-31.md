# H1 SMP successor admission review — 2026-08-31

Status: **SELECTED_SUCCESSOR_CANDIDATE / CANDIDATE B**
Scope: post-C005 H1 research embodiment only
Does not mean: final architecture, release, production readiness, physical H1 qualification, general multicore policy.

## Inputs

- C005 CLOSED20/20 hard stop.
- `d64_reference_v2` current integrated research body before SMP convergence.
- H1-SMP-MIN01 AP bring-up PASS.
- H1-SMP-MIN02 Candidate A whole-operation gate PASS.
- H1-SMP-MIN03 Candidate B single-writer owner + explicit mailbox PASS.

## Required immediate capability

For H1, bring up the second E2-1800 core and permit both cores to participate without concurrent relation operations violating the already-earned relation/currentness/lifetime rules.

The immediate capability does **not** require both CPUs to mutate the relation body directly, fairness, stalled-owner recovery, arbitrary core count, untrusted user callers, or a general IPC subsystem.

## Measured candidates

| Surface | MIN01 transport only | Candidate A / MIN02 | Candidate B / MIN03 |
|---|---:|---:|---:|
| linked stage2 memory | 7811 | 8189 | 8089 |
| headroom in8192 | 381 | 3 | 103 |
| raw stage2 | 4216 | 4594 | 4494 |
| implementation scratch used | 50 | 60 | 62 |
| named semantic state | 3467 | 3467 | 3467 |
| S-mode relation mutation | none | BSP/AP direct behind whole-op gate | BSP only |
| coordination | AP-ready | atomic gate | ordered request/result mailbox |
| progress dependency | AP startup | current gate holder | BSP relation owner |
| QEMU H1 S/C | PASS | PASS | PASS |
| Bochs C/restart/faults | PASS | PASS | PASS |

## Candidate A adjudication

Candidate A has the simplest direct-caller story: both trusted callers may invoke the existing relation API if argument preparation, call and result capture are serialized by one atomic gate.

Its current reviewer embodiment, however, consumes8189/8192 bytes and leaves3 bytes of envelope headroom. That is an unnecessarily brittle fit for the first physical target, where firmware/chipset reality may still demand small target-specific corrections.

Candidate A remains a valid alternate if direct multicore relation mutation becomes a required capability or if later representation compression materially changes the footprint comparison.

## Candidate B adjudication

Candidate B preserves the current single-writer relation internals. The AP never touches legacy relation scratch and never calls the relation mutation function. It publishes an explicit payload before request; BSP alone copies the request into existing scratch, performs the unchanged operation, stores result, then publishes completion.

Relative to Candidate A it:
- saves100 linked bytes;
- restores headroom from3 to103 bytes;
- costs only2 additional implementation-scratch bytes;
- keeps named semantic state unchanged;
- preserves all tested H1 QEMU and Bochs regressions;
- avoids introducing a relation-wide atomic gate into the body.

Its explicit cost is central progress dependency: AP relation progress depends on BSP servicing the request. C005 already distinguishes safety from progress; this review accepts that availability ceiling because stalled-owner recovery is **not** part of the immediate H1 capability.

## Candidate C disposition

Candidate C (per-CPU scratch + narrow relation gate) is **DEFERRED / NOT DISPROVEN**.

It would admit a stronger capability — direct multicore relation callers with narrower serialization — than H1 currently requires, while introducing larger call-interface refactoring and per-CPU representation burden. Under the project rule that capability must earn its representation cost, Candidate C is not priced before physical H1 unless a concrete workload requires that stronger capability or Candidate B's owner dependency becomes a measured blocker.

## Decision

**Select Candidate B as the successor-body candidate for H1.**

This selection authorizes creation of a new immutable-lineage research body `os/research_only/d64_reference_v3/`. It does not authorize rewriting v2 or declaring v3 current before v3 passes its own isolated build/run/verify admission gate.

## v3 admission gate

A v3 package may become `CURRENT_RESEARCH_REFERENCE` only after:
1. it is self-contained under `os/research_only/d64_reference_v3/` and uses no research/continuity/handoff files at build/run time;
2. exact build reports named semantic state3467 and linked stage2 <=8192;
3. exact H1 QEMU S trace proves BSP00/AP01 and mailbox-owner relation result `WW11`;
4. existing core+IRQ trace is exact;
5. restart two-boot and five faulted-media semantics/invariants remain exact;
6. package verifier passes from its own outputs;
7. exact source/body hashes and burden delta are recorded;
8. v2 and I001 remain preserved as prior lineage.

## Reopen triggers

Reopen A/B/C selection if any of these becomes required or observed:
- physical H1 exposes Candidate-B-specific failure;
- BSP owner service becomes a measured progress/latency blocker;
- a workload requires direct relation mutation from more than one CPU;
- stronger availability requires owner failure recovery;
- representation compression makes Candidate A or C strictly better;
- more than two CPUs become an admitted target capability.
