# H1 BIOS USB write discriminator preregistration 02 — exact EDD LBA256 — 2026-08-31

Status: **PREREGISTERED / BUILD PENDING**

Trigger: physical discriminator 01 proved INT13 AH=43 EDD persistence at LBA257 while CHS target LBA256 remained zero. The durable logger's first record uses EDD to LBA256, so exact address equivalence remains unearned.

This discriminator SHALL execute entirely from sector 0 and SHALL:
- preserve BIOS boot drive DL;
- gate on INT13 AH=41 EDD support exactly as the durable logger does;
- build one 512-byte sentinel sector containing `H1EDD256_WRITE_OK`;
- issue exactly one INT13 AH=43 write to LBA256 using a 16-byte DAP;
- halt forever.

It SHALL NOT:
- issue CHS writes;
- load a second stage;
- change video mode;
- write any LBA other than 256;
- touch internal disks or any non-boot device.

QEMU IDE/EDD qualification SHALL require:
- LBA256 begins `H1EDD256_WRITE_OK`;
- no other sector changes.

Physical interpretation:
- sentinel persists -> LBA256 EDD writes work; durable logger fault lies after/beside raw BIOS write capability.
- sentinel absent -> the logger's first-sector address itself is the discriminator; relocate journal start and requalify before another full probe run.
