# C005/P07 result — independently safe exclusions versus composable progress

Status: **CLOSED PASS**
Implementation commit: `cbe0aa9`
Controlling run: `P07/runs/20260831T045455Z_c005_p07_01`

Bad phase forced BSP to own A and AP to own B, then each made bounded atomic attempts for the other's claim while retaining its first. Neither second acquisition succeeded and both remained blocked (`BAD_BOTH_BLOCKED=1`) without violating exclusion safety.

Good phase reset both claims and started both CPUs under the same A->B order. One completed and released, then the other completed (`GOOD_BSP_COMPLETE=1`, `GOOD_AP_COMPLETE=1`).

Earned: `INDEPENDENT_EXCLUSION_SAFETY != COMPOSABLE_PROGRESS`. Consistent acquisition order is one witness for this two-claim case; no hierarchy/scheduler/deadlock subsystem is prescribed.
