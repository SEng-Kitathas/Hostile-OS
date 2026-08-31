# C005/P13 preregistration — snapshot safety versus reader progress under stalled writer

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P12 CLOSED PASS

## Question

If a version-validated reader correctly refuses snapshots while the writer version is odd, does that safety protocol itself guarantee reader progress when the writer stalls in-progress?

## Stalled-writer fixture

BSP becomes the sole writer: version0->1, writes A33, then deliberately remains stalled before B44/version2. AP performs exactly64 bounded snapshot attempts using the P11 rule.

Expected:
- AP accepts no snapshot (`STALLED_ACCEPT=0`);
- AP records64 retries (`STALLED_RETRIES=40` hex);
- no invalid mixed pair is promoted as accepted.

## Explicit writer completion witness

BSP then completes B44 and version2. AP retries and accepts33/44 (`AFTER_COMPLETE_ACCEPT=1`).

## Ceiling

PASS earns only `SNAPSHOT_SAFETY != READER_PROGRESS`: refusing unstable state can preserve safety while making no progress under a stalled writer. It does not prescribe timeouts, writer recovery, preemption, leases or failure detection.
