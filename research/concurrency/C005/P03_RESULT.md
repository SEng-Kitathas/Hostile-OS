# C005/P03 result — publication indicator versus published payload

Status: **CLOSED PASS**
Implementation commit: `2f8d796`
Controlling run: `P03/runs/20260831T044845Z_c005_p03_01`

Two QEMU x86 CPUs participated. In the bad phase BSP wrote `ready=1`, held a finite window, then wrote payload55. AP observed ready1 while payload remained7E (`BAD_SEEN=7E`); writer later completed to55 (`BAD_FINAL=55`).

In the good phase BSP wrote payload55 before ready1. AP's first payload read after observing ready1 was55 (`GOOD_SEEN=55`, `GOOD_FINAL=55`).

Earned: `PUBLICATION_INDICATOR != PUBLISHED_PAYLOAD`; publication order is future-relevant. This is a bounded protocol result, not a complete cross-architecture memory-model claim.
