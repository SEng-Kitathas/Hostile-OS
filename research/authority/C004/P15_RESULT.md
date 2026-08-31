# C004/P15 result — explicit authority-record initialization on reuse

Status: **CLOSED PASS**
Implementation commit: `a28e612`
Controlling run: `P15/runs/20260831T024415Z_c004_p15_01`

Good protected reuse cleared authority-bearing state, advanced gen1->2, assigned C READ-only (`01`), and C WRITE returned U with X7E. Bad reuse advanced the same generation but changed only owner, leaving old WRITE rights02; C WRITE returned W and changed X55.

Earned: `AUTHORITY_CURRENTNESS` does not replace explicit initialization of authority-bearing state on reuse.

Run-local inputs 8/8; stage2 1098 bytes, SHA `37b9df0e937354d736b56cd80c1908e07f17cb449f9b033d1efd70c3aed2e640`.
