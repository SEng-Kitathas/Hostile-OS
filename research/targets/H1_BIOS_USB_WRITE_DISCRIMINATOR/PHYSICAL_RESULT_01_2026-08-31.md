# Physical H1 BIOS USB write discriminator result 01 — 2026-08-31

Status: **PHYSICAL EVIDENCE / EDD WRITE PERSISTS / CHS WRITE DOES NOT**

SanDisk identity at readback:
- model: SanDisk Extreme Pro
- serial: 0FDC87754321
- size: 128043712512 bytes
- physical device at readback: `\\.\PhysicalDrive3`

Prepared discriminator image SHA-256: `40ea96888aeeb7ca14e038251c2119e4708f4f939737f4fda95d2fad8a6df6df`.

After one H1 boot:

- LBA256 (CHS target): 512 bytes all-zero; SHA-256 `076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560`; `H1CHS_WRITE_OK` absent.
- LBA257 (EDD target): begins ASCII `H1EDD_WRITE_OK\r\n`; 16 non-zero bytes; SHA-256 `9b98d1bcdd26496175a9d93f4440fa76e9bcb5d8e0558d9c5b6cccea4d531fe4`.

Interpretation earned:
- H1 firmware executed the sector-0 discriminator far enough to pass the EDD support gate and complete an INT13 AH=43 write to the boot SanDisk.
- CHS AH=03 persistence to the intended LBA256 did not occur.
- Therefore the durable logger's all-zero result cannot be explained by a blanket BIOS prohibition on boot-device writes.

Open seam:
- the durable logger's first EDD journal target is LBA256, while this discriminator proved EDD persistence only at LBA257. Test exact EDD write to LBA256 before attributing failure to later logger execution.
