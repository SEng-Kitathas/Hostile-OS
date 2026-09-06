# H1 BIOS USB read discriminator 06 qualification result — CHS single-sector read — 2026-08-31

Status: **QUALIFIED FOR EDD-CAPABLE H1 TRANSPORT / PHYSICAL TEST PENDING**

Image SHA-256: `0c1a08ab84f03b6906330fa8b0706a7bb3e2ceb52ab7ae6c0edb4cae802f62b8`.
Boot-sector SHA-256: `20ee0644605d366a827fafab7e1e54ed0c961085dbd8fc428ef6ea7da8b14052`.

The discriminator performs a one-sector legacy CHS AH=02 read of cylinder0/head0/sector2 into physical 0x6000, then persists the read status and returned 128-byte prefix to LBA257 using EDD AH=43.

QEMU IDE/EDD presentation:
- CHS AH=02 read status: carry clear;
- returned 128 bytes exactly match prepared LBA1;
- only LBA257 changed;
- qualification: PASS.

QEMU floppy presentation:
- no forensic sector persisted because the result path intentionally uses EDD AH=43, which is unavailable under that floppy presentation;
- this does not qualify or disqualify the CHS read itself and is not the physical target contract.

Physical H1 already has independently verified EDD AH=43 persistence at LBA257, so the admitted qualification target for READ6 is the mixed path: CHS single-sector read + EDD outcome write on an EDD-capable boot device.
