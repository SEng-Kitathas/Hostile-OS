# C005/P11 preregistration — unchecked snapshot versus version-validated snapshot

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P10 CLOSED PASS

## Question

Can a read-only CPU observe a coupled two-byte state safely without taking the writer's exclusion if it validates that no write overlapped its snapshot?

## Fixture

Coupled bytes begin A=11/B=22 and final33/44. Writer owns one version byte. Even means quiescent; odd means write in progress. Writer changes version0->1, writes A33, pauses, writes B44, then version1->2.

## Bad read

AP reads A while writer is between A and B, waits for writer completion signal, then reads B. No version validation. Expected snapshot33/44 is internally from different moments; fixture records `BAD_CROSSED=1` and accepts the snapshot as if coherent.

## Good read

Reset. AP performs:
1. read version before;
2. if odd, retry;
3. read A/B;
4. read version after;
5. accept only if versions equal and even.

Writer again performs version0->1, A33, pause, B44, version1->2. Fixture forces at least one overlapping attempt before completion, so a retry must occur. Expected accepted pair33/44 with `GOOD_RETRY=1`, `GOOD_ACCEPT=1`.

## Ceiling

PASS earns only that a read-only observer may avoid exclusive ownership if it can detect overlapping writes and retry until a stable versioned snapshot is observed. It does not prescribe a seqlock, universal version width, lock-free progress, or multi-writer safety.
