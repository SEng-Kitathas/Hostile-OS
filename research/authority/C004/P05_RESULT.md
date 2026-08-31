# C004/P05 result — stale authority after authority-slot reuse

Status: **CLOSED PASS**
Implementation commit: `bc74e4e`
Controlling run: `P05/runs/20260831T023004Z_c004_p05_01`

Observed: B's stale authority `(slot0,gen1)` returned U and preserved X=7E after slot0 was reused for C/gen2/WRITE; C fresh gen2 wrote55; slot-only bad control let stale B use the reused slot and write55.

Earned at bounded mediated scope:

`AUTHORITY_SLOT_LOCATION != AUTHORITY_IDENTITY/CURRENTNESS`.

This still does not establish actual protection from arbitrary machine code.

Run-local inputs 8/8; stage2 437 bytes, SHA `4ff86fbad5ef0b8fec6d723447ec9ae1631c457e3199d91471341852c8c5cea2`.
