# C004/P03 result — delegation attenuation

Status: **CLOSED PASS**
Implementation commit: `28536f3`
Controlling run: `P03/runs/20260831T022711Z_c004_p03_01`

Observed: good delegation from READ-only B granted C rights `01`; C read W/7E and write U with X preserved. Bad delegation copied requested rights `03`; C write W changed X to55.

Earned at bounded cooperative-API scope:

`DELEGATED_AUTHORITY <= DELEGATOR_CURRENT_AUTHORITY` is future-relevant.

No capability tree/object or hardware enforcement is earned.

Run-local inputs 8/8; stage2 567 bytes, SHA `e00645177448f3a0ce476b993f7f5ae00bcea13841ad1ee46d84f66b0fa706ba`.
