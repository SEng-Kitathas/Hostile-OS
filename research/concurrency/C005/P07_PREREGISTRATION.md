# C005/P07 preregistration — independently safe exclusions versus composable progress

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P06 CLOSED PASS

## Question

If two separate claims each provide correct atomic exclusion, do they automatically compose without progress failure when two CPUs need both?

## Bad deterministic circular-wait fixture

- claims A and B start free;
- BSP atomically acquires A;
- AP atomically acquires B;
- barrier proves both first claims are held;
- BSP performs bounded attempts to acquire B while retaining A;
- AP performs bounded attempts to acquire A while retaining B.

Expected: neither second acquisition succeeds, no claim has two owners, and `BAD_BOTH_BLOCKED=1`.

## Good ordering witness

Reset both claims. Both CPUs obey one shared acquisition order A then B. Fixture serializes only enough to make completion deterministic; each CPU must successfully acquire A then B and release both. Expected `GOOD_BSP_COMPLETE=1`, `GOOD_AP_COMPLETE=1`.

## Ceiling

PASS earns only `INDEPENDENT_EXCLUSION_SAFETY != COMPOSABLE_PROGRESS` and shows consistent acquisition order as one working witness for this two-claim case. It does not prescribe a lock hierarchy subsystem, scheduler, fairness, blocking primitive or universal deadlock policy.
