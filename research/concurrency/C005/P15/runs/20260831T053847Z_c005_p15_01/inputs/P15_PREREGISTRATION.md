# C005/P15 preregistration — recovery authority versus stale-writer future effects

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P14 CLOSED PASS

## Question

Even when a recovery actor has explicit authority to recover a stalled write, is that authority alone enough if the old writer can later resume and issue effects from its pre-recovery writer identity?

## Fixture

Stable pair begins A11/B22, writer epoch1. BSP begins a write under cached epoch1, writes A33, then stalls before B44. AP has explicit `RECOVERY_AUTH=1`.

AP performs an authorized recovery by restoring the last stable pair11/22 and advancing writer epoch1->2. It then allows BSP to resume.

## Bad stale-writer control

BSP resumes without revalidating its cached writer epoch1 and writes its pending B44 effect.

Expected: recovered state is corrupted to11/44 (`BAD_OLD_WRITER_APPLY=W`, `BAD_AFTER_A=11`, `BAD_AFTER_B=44`).

## Good currentness witness

Reset same fixture. AP again performs authorized recovery and advances epoch1->2. BSP resumes but compares its cached writer epoch1 with current epoch2 before applying its pending effect.

Expected: stale writer rejects (`GOOD_OLD_WRITER_APPLY=R`) and recovered pair remains11/22.

## Ceiling

PASS earns only `RECOVERY_AUTHORITY != OLD_WRITER_CURRENTNESS`: a recovery decision must also prevent/reject later effects from the superseded writer if that writer can resume. Epoch/currentness revalidation is one witness. This does not prescribe failure detection, leases, preemption, durable recovery, or a universal fencing-token abstraction.
