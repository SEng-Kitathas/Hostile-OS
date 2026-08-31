# C005/P19 preregistration — bounded whole-workload concurrency composition

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P18 CLOSED PASS

## Question

Can the main C005 distinctions compose in one two-CPU workload without contradiction or requiring a Scheduler/lock-manager/RCU object bundle?

## Fixture / required sequence

Two QEMU CPUs participate. Shared coupled pair begins11/22. Separate resource value begins7E. AP is the active writer/user/executor; BSP is observer/reclaimer/revoker.

1. AP atomically claims writer exclusion, marks version odd, writes A33, then pauses.
2. BSP attempts versioned read during odd version and records a retry.
3. AP writes B44, marks version even, releases writer exclusion.
4. BSP retries and accepts stable33/44.
5. AP atomically registers one in-flight use (`users=1`) before touching resource value7E.
6. BSP attempts reclaim while users1 and must defer.
7. AP records delayed WRITE55 as accepted under authority generation1/WRITE.
8. BSP revokes WRITE and advances authority generation1->2 before allowing application.
9. AP effect-time revalidation rejects delayed write (`U`), preserving value7E.
10. AP ends its in-flight use (`users=0`).
11. BSP reclaim now succeeds.
12. clean completion by both CPUs.

## Required outcomes

- `READ_RETRY=1`, then `READ_ACCEPT=1`, A33/B44;
- `USERS_DURING=01`, `RECLAIM_DURING=0`;
- `AUTH_REVOKE_GEN=02`;
- `DELAYED_APPLY=U`, `VALUE_AFTER=7E`;
- `USERS_AFTER=00`, `RECLAIM_AFTER=1`;
- both CPUs complete.

## Ceiling

PASS shows bounded composition of writer exclusion, publication/snapshot validation, in-flight lifetime protection, authority revalidation and reclaim ordering under one two-CPU workload. It does not establish completeness, optimality, fairness, physical-hardware behavior, SMP scheduling, or final architecture.
