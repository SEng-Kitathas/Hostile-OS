# C004/P14 result — finite protected authority capacity

Status: **CLOSED PASS**
Implementation commit: `464c0ae`
Controlling run: `P14/runs/20260831T024259Z_c004_p14_01`

With the boundary active, the good two-record table returned F when full and preserved owners A/B. The overwrite-on-full control returned W and changed owner0 from A to C.

Earned: finite authority storage requires explicit exhaustion behavior; silent overwrite loses an existing authorized future. No dynamic allocation is earned.

Run-local inputs 8/8; stage2 874 bytes, SHA `dfff5397d0840ed7e7cb23574dcae7b36b462552dc111f758516973e618f8c2d`.
