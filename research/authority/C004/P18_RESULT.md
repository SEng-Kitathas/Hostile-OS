# C004/P18 result — authority currentness across restart

Status: **CLOSED PASS**
Implementation baseline commit: `4e6f559`
Harness Amendment A commit: `fbc8227`
Controlling run: `P18/runs/20260831T031730Z_c004_p18_01`

Boot1 wrote durable grant meaning A+READ+X/value7E plus historical authority handle slot0/gen1/epoch1, then exited33. Boot2 was a fresh QEMU process on the same disk with no host write between boots and ran read-only.

Good reconstruction advanced authority epoch1->2, rebuilt slot0/gen1/epoch2, rejected the historical epoch1 handle (`GOOD_OLD=R`), and accepted the fresh handle (`GOOD_FRESH=W`, value7E). Bad control retained epoch1 and the historical handle aliased the reconstructed grant (`BAD_OLD=W`). The ring3 bypass attempt still hit #GP.

Earned: reusable authority handles require restart currentness when a fresh runtime can reuse slot+generation. Durable grant meaning does not make old runtime authority handles current.

No universal persistent credential/grant store is earned.
