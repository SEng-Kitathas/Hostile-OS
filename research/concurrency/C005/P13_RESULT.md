# C005/P13 result — snapshot safety versus reader progress under stalled writer

Status: **CLOSED PASS**
Implementation commit: `02de865`
Controlling run: `P13/runs/20260831T052442Z_c005_p13_01`

BSP became the sole writer, moved version0->1, wrote A33, and deliberately stalled before B44/version2. AP performed exactly64 bounded P11-style snapshot attempts. It accepted none (`STALLED_ACCEPT=0`) and recorded64 retries (`STALLED_RETRIES=40` hex), preserving safety but making no progress.

After BSP explicitly completed B44/version2, AP immediately accepted the stable pair33/44.

Earned: `SNAPSHOT_SAFETY != READER_PROGRESS`. Refusing unstable state can preserve safety indefinitely while a writer remains stalled. No timeout, recovery, preemption, lease or failure-detection policy is earned.
