# C005/P14 result — retry budget versus recovery authority

Status: **CLOSED PASS**
Implementation commit: `46c3855`
Controlling run: `P14/runs/20260831T053118Z_c005_p14_01`

BSP stalled as sole writer at version1/A33/B22. AP performed64 safe retries. Bad AP then treated budget exhaustion as authority to force version1->2 and accepted the unfinished pair as stable (`BAD_FORCE=1`, `BAD_ACCEPT=1`, `BAD_MIXED=1`).

Good AP exhausted the same64 retries but did not mutate writer/version state (`GOOD_FORCE=0`, `GOOD_ACCEPT_BEFORE=0`). Only after BSP explicitly completed B44/version2 did AP accept33/44.

Earned: `WAIT_BUDGET_EXHAUSTED != RECOVERY_AUTHORITY`. Retry/time budget may inform policy but does not prove writer death or make forced repair safe.
