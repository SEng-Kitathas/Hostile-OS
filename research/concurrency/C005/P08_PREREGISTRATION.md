# C005/P08 preregistration — current at use start versus safe through use completion

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P07 CLOSED PASS

## Question

If a CPU validates a resource relation as current and then begins using it, may another CPU reclaim/reuse that resource before the first use completes merely because the original relation was current at entry?

## Bad fixture

- resource generation1/value7E;
- AP validates generation1 and marks that it has begun a use, then pauses before reading the value;
- BSP ignores the in-flight use, reclaims/reuses resource: generation2/value00;
- AP resumes using its cached entry validation.

Expected: AP observes value00 (`BAD_USE_VAL=00`), proving entry validation alone did not preserve the future it needed.

## Good witness

Reset generation1/value7E. AP atomically increments an in-flight use count before reading. BSP attempts reclaim while count1 and must defer (`GOOD_RECLAIM_DURING=0`). AP reads7E and decrements the use count. BSP then reclaims successfully (`GOOD_RECLAIM_AFTER=1`).

## Ceiling

PASS earns only `CURRENT_AT_USE_START != SAFE_UNTIL_USE_COMPLETES` when concurrent reclaim is possible, and that in-flight participation must constrain reclaim somehow. It does not prescribe reference counting, hazards, epochs, RCU, locks or a universal lifetime primitive.
