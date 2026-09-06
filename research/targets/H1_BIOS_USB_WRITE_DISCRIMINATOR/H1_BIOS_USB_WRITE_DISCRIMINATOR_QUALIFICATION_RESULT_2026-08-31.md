# H1 BIOS USB write discriminator qualification result — 2026-08-31

Status: **QUALIFIED EMULATOR DISCRIMINATOR / PHYSICAL RETEST PENDING**

Initial 1 MiB image SHA-256: `40ea96888aeeb7ca14e038251c2119e4708f4f939737f4fda95d2fad8a6df6df`.
Boot-sector SHA-256: `53528179070d4595b021b964b34c25d8a17f01927d486665dcf57486e81e93ad`.

QEMU floppy/CHS qualification:
- only LBA 256 changed;
- LBA 256 begins `H1CHS_WRITE_OK`;
- LBA 257 remained zero;
- no byte outside LBA 256 changed.

QEMU IDE/EDD qualification:
- only LBAs 256 and 257 changed;
- LBA 256 begins `H1CHS_WRITE_OK`;
- LBA 257 begins `H1EDD_WRITE_OK`;
- no byte outside LBAs 256/257 changed.

The discriminator executes entirely from sector 0, performs no secondary-stage load and no video-mode switch, and halts after the two bounded write attempts.
