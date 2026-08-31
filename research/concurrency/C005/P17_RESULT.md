# C005/P17 result — same bounded version value versus same snapshot epoch

Status: **CLOSED PASS**
Implementation commit: `0d6d1a1`
Controlling run: `P17/runs/20260831T054130Z_c005_p17_01`

AP snapshotted version00/A11. BSP performed exactly128 complete writes, returning the 8-bit version to00 while final state became33/44. The stale reader saw pre00==post00 and accepted cross-era A11/B44 (`BAD_CROSS_ERA=1`).

Good phase extended currentness with an epoch advanced on low-version wrap. After128 writes packed state was0100, so stale packed0000 rejected and a fresh snapshot accepted33/44.

Earned: `SAME_BOUNDED_VERSION_VALUE != SAME_SNAPSHOT_EPOCH` once wrap is reachable. Epoch extension is one witness; no universal width/timestamp scheme is prescribed.
