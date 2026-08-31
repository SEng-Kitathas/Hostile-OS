# C004/P08 result — operation-specific authority across enforcement boundary

Status: **CLOSED PASS**
Implementation commit: `4052781`
Controlling run: `P08/runs/20260831T023609Z_c004_p08_01`

Protected-mode boundary remained active (`GP_SEEN=1`). Ring3 B received mediated READ W/7E; mediated WRITE returned U and preserved X=7E; a separate binary-allow mediator accepted WRITE and changed X=55.

Earned:

`NON_BYPASSABLE_MEDIATION != OPERATION_SPECIFIC_AUTHORITY`.

Both are independently required for this bounded untrusted-caller fixture.

Run-local inputs 8/8; stage2 880 bytes, SHA `473da0a15735bfec656c4c562a5f9f49f12daf1970303c551f23b38303812d04`.
