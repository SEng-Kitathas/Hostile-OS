# C004/P07 result — first actual privilege enforcement boundary

Status: **CLOSED PASS**
Implementation commit: `9445b90`
Controlling run: `P07/runs/20260831T023342Z_c004_p07_01`

Exact result:
```text
GP_SEEN=1
RESOURCE_AFTER=7E
MEDIATED_GATE=1
```

Ring3 code attempted to load the ring0 writable data selector and faulted through the intended #GP path. Ring0 observed the protected resource unchanged at7E. The resumed ring3 code then crossed an explicit DPL3 interrupt gate back to trusted code, which exited normally.

Earned:

`UNTRUSTED_MUTATION_REQUIRES_A_NON_BYPASSABLE_ENFORCEMENT_BOUNDARY` for this fixture, and x86 privilege separation is one working witness.

This does **not** promote x86 rings/segmentation/TSS/IDT into HOSTILE-OS architecture. It establishes the enforcement consequence P06 proved software-only checks lacked.

Run-local inputs 8/8; stage2 606 bytes, SHA `d69eb1ec6b86cc53a039794a585c8e571803928a859342c577af6b40f96ffffa`.
