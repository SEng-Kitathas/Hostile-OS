# C005/P10 preregistration — real IRQ observation versus concurrent second-CPU mutation

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P09 CLOSED PASS
Cross-domain parents: D64_IRQ01 / current d64_reference_v2 IRQ0 transport, C005/P01 inter-CPU exclusion

## Question

Do one-core IRQ exclusion and inter-CPU exclusion automatically compose, or must an IRQ observer and a second-CPU mutator participate in one shared coherence boundary for coupled state?

## Two-CPU + real IRQ0 fixture

Coupled bytes start A=11/B=22 and target A=33/B=44. AP performs the mutation. BSP receives real PIT IRQ0 through the legacy PIC vector8 path.

## Bad phase

AP writes A=33 and deliberately pauses before B=44. BSP arms/unmasks PIT after AP reports A written. IRQ handler reads A/B without the inter-CPU exclusion.

Expected: handler observes mixed33/22 (`BAD_MIXED=1`) and AP later completes33/44.

## Good phase

Reset pair. AP atomically acquires shared exclusion, marks `holding=1`, writes A=33, holds a deliberate window, writes B=44, then releases. BSP arms PIT after A-written signal. Handler records whether it entered while AP reported holding, then atomically acquires the same exclusion before reading A/B.

Required: real IRQ occurs; handler entered during AP holding (`GOOD_IRQ_SAW_HOLDING=1`); after acquiring shared exclusion it observes no mixed pair and sees final33/44.

## Ceiling

PASS earns only that IRQ observer and concurrent CPU mutation must share a coherence protocol when they touch the same coupled relation. x86 `xchg` + PIC/PIT are witnesses, not universal architecture. No SMP scheduler, interrupt-thread model or physical-hardware timing guarantee is earned.
