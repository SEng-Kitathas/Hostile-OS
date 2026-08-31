# C005/P04 result — shared update versus atomic update transition

Status: **CLOSED PASS**
Implementation commit: `b80ea2e`
Controlling run: `P04/runs/20260831T045021Z_c005_p04_01`

Both CPUs first read shared counter00 before either bad-phase store. Both intended one increment (`BAD_INTENTS=02`) but split read/modify/write ended at01 (`BAD_FINAL=01`).

After reset, each CPU performed exactly one atomic `lock xadd` of1. Both intents survived (`GOOD_INTENTS=02`, `GOOD_FINAL=02`).

Earned: `SHARED_READ_MODIFY_WRITE != ATOMIC_UPDATE_TRANSITION` for this tested x86 SMP shared scalar. Atomicity is required at the update transition; no universal counter/lock/scheduler abstraction is earned.
