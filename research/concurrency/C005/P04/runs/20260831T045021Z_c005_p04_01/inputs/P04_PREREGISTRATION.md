# C005/P04 preregistration — shared update versus atomic update transition

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P03 CLOSED PASS

## Question

If two CPUs both intend to advance one shared scalar state exactly once, is plain read/modify/write sufficient, or must the update transition itself be atomic?

## Two-CPU fixture

Shared counter begins00. BSP and AP each intend `counter += 1` once.

## Bad deterministic split RMW

1. both CPUs read counter00 into private registers;
2. barrier proves both reads completed;
3. both independently increment their private value to01;
4. both plain-store01.

Expected: both report participation but final counter is01, losing one intended update (`BAD_FINAL=01`, `BAD_INTENTS=02`).

## Good witness

Reset counter00. From a common barrier each CPU performs exactly one atomic `lock xadd` of1.

Expected: both intents are preserved and final counter02 (`GOOD_FINAL=02`, `GOOD_INTENTS=02`).

## Ceiling

PASS earns only `SHARED_READ_MODIFY_WRITE != ATOMIC_UPDATE_TRANSITION` for this tested shared scalar on x86 SMP. It does not prescribe counters, mutexes, schedulers, fairness or a universal synchronization API.
