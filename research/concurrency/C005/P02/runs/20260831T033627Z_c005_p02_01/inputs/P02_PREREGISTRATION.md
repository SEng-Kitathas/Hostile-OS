# C005/P02 preregistration — plain shared claim versus atomic claim

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P01 CLOSED PASS

## Question

Once inter-CPU exclusion is required, can two CPUs safely acquire it using a plain shared `if free -> set held` flag, or must the claim transition itself be atomic?

## Two-CPU fixture

Both CPUs begin at a synchronized barrier with lock byte0 and separate `entered_cpu0/entered_cpu1` markers.

## Bad control — plain check/set

The fixture deliberately separates the read and write phases:
1. both CPUs read lock=0 and record `SAW_FREE=1`;
2. a barrier ensures both reads completed;
3. both perform plain `lock=1` and record entry.

Expected: both CPUs believe they acquired the same exclusion (`BAD_ENTERED=02`).

This orchestration is a deterministic witness for the non-atomic check/set race; it is not a probability claim.

## Good witness — atomic claim

Reset lock0. Both CPUs simultaneously attempt `xchg(1, lock)` once from a barrier.

Expected:
- exactly one first claimant receives old0 / enters;
- the other receives old1 / does not enter;
- `GOOD_ENTERED=01`.

## Required controls

- both CPUs explicitly participate in both phases;
- bad phase proves both saw free before either plain store;
- good phase starts from lock0 and same barrier topology;
- clean exit only after AP completion;
- timeout UNKNOWN.

## Ceiling

PASS earns only `INTER_CPU_EXCLUSION_REQUIRES_ATOMIC_CLAIM_TRANSITION` for this tested shared-flag design and x86 `xchg` as one witness. It does not require a lock object, fairness, blocking, or a particular memory model abstraction.
