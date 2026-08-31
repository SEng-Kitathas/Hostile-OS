# C005 — multicore concurrency/coherence re-derivation campaign

Date opened: 2026-08-31 UTC
Status: OPEN / BROAD HSP CAMPAIGN / EXACTLY 20 SCIENTIFIC PASSES MAXIMUM
Architecture posture entering campaign: `INTEGRATED_SHADOW_CANDIDATE`
Trigger: mature-OS blind-comparison residual `MISSING_CAPABILITY_PRESSURE` for concurrency/coherence beyond one-core maskable-IRQ scope.

## Campaign question

When more than one CPU may observe or mutate shared HOSTILE-OS relations concurrently, which additional future-relevant distinctions are actually required beyond the current one-core interrupt-coherence rules?

This campaign does not assume the answer is a Scheduler, mutex, spinlock subsystem, RCU, monitor, critical-section object, memory model, per-CPU structure, or any familiar SMP architecture.

## Broad-domain rule

C005 uses the exact 20-pass campaign form.
- P01 begins with the smallest direct challenge to the currently adopted one-core `cli` protection rule.
- Each next pass follows from the previous discriminator.
- P20 hard-stops C005; no P21.
- No architecture promotion follows automatically.

## Primary pressure reservoir

If earned, later passes may pressure:
- local interrupt masking versus other-CPU exclusion;
- atomic claim/acquire versus plain shared flags;
- state publication versus state ownership;
- stale reads / ordering / visibility;
- progress versus safety;
- lock holder failure/timeout;
- nested or multiple relation interactions;
- shared-resource reclaim while another CPU observes/uses;
- authority revocation while another CPU applies effects;
- interrupt plus second-CPU interaction;
- finite per-CPU/global capacity;
- restart/reconstruction boundaries;
- whole-workload composition.

This is not a pass schedule.

## Enforcement / interpretation rules

- `cli` only masks maskable interrupts on the executing CPU unless evidence proves more.
- A QEMU `-smp 2` result is an emulated multicore witness, not physical-hardware qualification.
- A lock instruction is a mechanism witness, not an architecture noun.
- Harness/AP-startup failures are not coherence failures.
- Timeout/ambiguous CPU progress is `UNKNOWN`.
- Every controlling run snapshots exact inputs before build/execution.
- Bad/weakened controls are retained where practical.

## Campaign success criterion

By P20, either:
1. a bounded multicore coherence grammar survives composition with explicit progress/enforcement assumptions; or
2. C005 closes with a precisely bounded unresolved blocker.

In either case, distinguish safety/coherence from scheduling/fairness/performance.
