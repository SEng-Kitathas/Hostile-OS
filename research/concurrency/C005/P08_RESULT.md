# C005/P08 result — current at use start versus safe through use completion

Status: **CLOSED PASS**
Implementation commit: `0b44ff8`
Controlling run: `P08/runs/20260831T045617Z_c005_p08_01`

Bad phase: AP validated generation1 and began use; BSP then reclaimed/reused the resource as generation2/value00. AP resumed under its cached entry validation and observed00 (`BAD_USE_VAL=00`).

Good phase: AP atomically registered one in-flight use before reading. BSP's concurrent reclaim attempt deferred while users=1 (`GOOD_RECLAIM_DURING=0`); AP read7E, dropped users to0, and only then did reclaim succeed (`GOOD_RECLAIM_AFTER=1`).

Earned: `CURRENT_AT_USE_START != SAFE_UNTIL_USE_COMPLETES` under concurrent reclaim. In-flight participation must constrain reclaim somehow; no specific lifetime algorithm is prescribed.
