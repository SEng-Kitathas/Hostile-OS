# C005/P14 preregistration — retry budget versus recovery authority

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P13 CLOSED PASS

## Question

After a reader has retried a bounded number of times against a stalled odd writer version, does elapsed retry/time budget itself authorize the reader to repair/clear the writer state?

## Bad forced-repair fixture

BSP becomes sole writer: version0->1, writes A33, then deliberately stalls before B44/version2. AP performs64 safe retries, then treats budget exhaustion as permission to force version1->2 without writer completion.

AP then performs its normal version-validated snapshot.

Expected: forced even state causes AP to accept mixed A33/B22 as stable (`BAD_FORCE=1`, `BAD_ACCEPT=1`, `BAD_MIXED=1`).

## Good witness

Reset. BSP again stalls at version1/A33/B22. AP performs64 retries but does **not** mutate writer/version state (`GOOD_FORCE=0`, `GOOD_ACCEPT_BEFORE=0`). BSP explicitly completes B44/version2, after which AP accepts33/44 (`GOOD_ACCEPT_AFTER=1`).

## Ceiling

PASS earns only `WAIT_BUDGET_EXHAUSTED != RECOVERY_AUTHORITY`. Timeout/retry count may inform policy but cannot by itself prove a writer is dead or make forced state repair safe. No failure detector, lease, preemption or recovery protocol is prescribed.
