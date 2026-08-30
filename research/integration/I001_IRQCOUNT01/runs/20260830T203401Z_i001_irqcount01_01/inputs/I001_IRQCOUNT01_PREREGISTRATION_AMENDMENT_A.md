# I001/IRQCOUNT01 preregistration amendment A — deterministic second real IRQ0

Date: 2026-08-30
Status: VISIBLE FIXTURE AMENDMENT AFTER FAILED ATTEMPT, BEFORE RERUN
Parent preregistration: `I001_IRQCOUNT01_PREREGISTRATION.md`
Failed attempt: `runs/20260830T203047Z_i001_irqcount01_01`

## Why this amendment exists

The first execution-capable attempt reached QEMU and completed the entire ONE phase exactly as preregistered, then timed out in MULTI after the first event.

Inspection showed the PIT command used by I001 and this fixture is `0x30`: channel 0, low/high byte access, **mode 0 (interrupt on terminal count / one-shot)**. Leaving IRQ0 unmasked after the first event therefore does not itself create a second PIT event. The original MULTI implementation incorrectly assumed repeated events would continue without rearming the one-shot timer.

This is a fixture defect. It does not support either H1 or H2 because the required two-event discriminator was never produced.

## Amendment

The hypotheses, pass matrix, semantic gate, exact-one control, BADREL negative control, and authority ceiling remain unchanged.

For phases requiring two real IRQ0 observations (MULTI and BADREL), after the first observed IRQ returns and the guest confirms `event_generation < stop_after`, the fixture SHALL:

1. keep interrupts disabled while preparing the next event;
2. reprogram/rearm the same PIT channel 0 mode-0 one-shot using the same divisor;
3. unmask IRQ0;
4. execute `STI` and return to `HLT`;
5. accept the second IRQ0 only through the same installed real IRQ0 handler.

The handler still owns the event-count increment and masks IRQ0 when `event_generation >= stop_after`.

## Additional static requirement

Static closure SHALL verify that `run_irq_phase` contains a PIT rearm path after a sub-threshold event count, so a two-event phase cannot pass by synthesizing or directly incrementing the event counter.

## What is not changed

- No historical I001 source/evaluator is edited.
- `IRQ_EVENT=2` is not synthesized by the host.
- The guest does not directly set `event_generation=2`.
- ONE still receives one real IRQ0.
- MULTI and BADREL still receive exactly two real IRQ0 handler entries.
- The science question remains exact-one versus positive-event/current-relation semantics.
