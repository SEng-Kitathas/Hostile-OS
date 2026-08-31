# C005/P15 result — recovery authority versus stale-writer future effects

Status: **CLOSED PASS**
Implementation commit: `cd417de`
Controlling run: `P15/runs/20260831T053847Z_c005_p15_01`

AP had explicit recovery authority, restored the last stable pair11/22, and advanced writer epoch1->2. Bad resumed BSP ignored its cached writer epoch1 and applied pending B44, corrupting the recovered state to11/44 (`BAD_OLD_WRITER_APPLY=W`).

Good resumed BSP revalidated cached epoch1 against current epoch2, rejected as stale (`GOOD_OLD_WRITER_APPLY=R`), and preserved11/22.

Earned: `RECOVERY_AUTHORITY != OLD_WRITER_CURRENTNESS`. If a superseded writer can resume, recovery must also make/reject that writer's later effects as non-current somehow. Epoch revalidation is one witness, not a universal fencing abstraction.
