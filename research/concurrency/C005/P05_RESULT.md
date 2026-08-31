# C005/P05 result — same free value versus same acquisition opportunity

Status: **CLOSED PASS**
Implementation commit: `4174095`
Controlling run: `P05/runs/20260831T045210Z_c005_p05_01`

BSP snapshotted free0. AP then acquired and released, returning the held byte to0. Bad claimant validated only that visible byte and accepted the stale pre-cycle opportunity (`BAD_STALE_ACCEPT=1`).

Good packed state started epoch0/held0. AP's ownership cycle ended epoch1/held0. Atomic compare/exchange against stale0000 failed (`GOOD_STALE_ACCEPT=0`), while a fresh0100 claimant succeeded (`GOOD_FRESH_ACCEPT=1`).

Earned: `SAME_VISIBLE_FREE_VALUE != SAME_CURRENT_ACQUISITION_OPPORTUNITY` when reusable ownership can cycle between observation and claim. Version/epoch-in-comparison is one witness, not a universal lock type.
