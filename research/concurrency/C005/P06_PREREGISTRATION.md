# C005/P06 preregistration — exclusion safety versus progress

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P05 CLOSED PASS

## Question

If atomic exclusion prevents double ownership, does that by itself guarantee another CPU can eventually make progress when the current holder stops/refrains from releasing?

## Fixture

AP atomically acquires one shared claim and then deliberately waits without releasing. BSP performs a bounded number of atomic acquisition attempts.

## Stalled-holder phase

Expected:
- AP owns claim;
- BSP never also owns it (`DOUBLE_OWNER=0`);
- BSP bounded attempts do not acquire (`STALLED_PROGRESS=0`).

This is a safety success and progress failure, not a timeout ambiguity because the fixture deliberately holds the claim and bounds the attempts.

## Explicit release/handoff witness

BSP then raises a release-request byte. AP responds by explicitly releasing the claim. BSP retries and acquires successfully (`AFTER_RELEASE_PROGRESS=1`).

## Ceiling

PASS earns only `EXCLUSION_SAFETY != PROGRESS` and that some release/handoff/recovery condition is separately required if progress must survive a stalled holder. It does not prescribe fairness, preemption, leases, failure detectors, scheduler policy or safe forced lock stealing.
