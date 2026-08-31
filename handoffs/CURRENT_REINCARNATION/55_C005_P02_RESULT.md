# C005/P02 result — plain shared claim versus atomic claim

Status: **CLOSED PASS**
Implementation commit: `4015550`
Controlling run: `P02/runs/20260831T033627Z_c005_p02_01`

Bad deterministic split check/set forced both CPUs to read lock0 before either store. Both recorded free and both entered (`BAD_ENTERED=02`).

Good phase reset lock0 and gave both CPUs one atomic `xchg(1, lock)` attempt without release between attempts. Exactly one received old0 and entered (`GOOD_ENTERED=01`).

Earned: `INTER_CPU_EXCLUSION_REQUIRES_ATOMIC_CLAIM_TRANSITION` for this tested shared-flag design. Plain read-then-store is not an exclusion claim. x86 `xchg` is one witness, not a promoted lock object.
