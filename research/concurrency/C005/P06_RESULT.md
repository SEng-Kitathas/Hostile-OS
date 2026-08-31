# C005/P06 result — exclusion safety versus progress

Status: **CLOSED PASS**
Implementation commit: `33f2d1d`
Controlling run: `P06/runs/20260831T045328Z_c005_p06_01`

AP atomically acquired the shared claim and deliberately withheld release. BSP performed64 bounded atomic acquisition attempts. No double ownership occurred (`DOUBLE_OWNER=0`) but BSP made no progress (`STALLED_PROGRESS=0`). After BSP explicitly requested release, AP released and BSP acquired (`AFTER_RELEASE_PROGRESS=1`).

Earned: `EXCLUSION_SAFETY != PROGRESS`. A safe exclusive claim does not itself guarantee progress when the holder stalls; some release/handoff/recovery condition is separately required if that future matters. No fairness/preemption/lease/forced-steal policy is earned.
