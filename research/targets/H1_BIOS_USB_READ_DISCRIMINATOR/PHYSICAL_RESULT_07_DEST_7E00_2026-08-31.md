# Physical H1 BIOS USB read discriminator result 07 — destination 0x7E00 — 2026-08-31

Status: **PHYSICAL EVIDENCE / CHS CF CLEAR + DESTINATION 0x7E00 UNCHANGED ZERO**

Prepared image SHA-256: `fbf4ebc6fb1ef12f5eb7076191dc224ffe50aa5d74e3ad344bc861be63a0d7ff`.

After one physical H1 boot, LBA257 contained a valid `H1READ7_7E00` forensic sector.

Decoded fields:
- CHS AH=02 status byte: `0` (carry clear);
- first 128 bytes captured from physical address `0x7E00`: all zero;
- returned data did not match the known byte-512 LBA1 prefix;
- LBA257 SHA-256: `e201f5b47b248c2e06bd14c1d68a92c88d87cbb641bc823dcc1a1c8d8ef5a6d3`.

Earned interpretation:
- moving the destination from physical 0x6000 to the conventional post-boot address 0x7E00 does not restore observable read data;
- destination-region choice among the tested low-memory windows is therefore not sufficient to explain the failure.

Open seam: firmware logical-sector mapping/stride. Both EDD LBA1 and CHS sector2 have reported success while returning zero from images where byte offset 512 is nonzero and later regions are mostly zero. A larger logical-sector stride (for example 1024/2048/4096 bytes) could explain the observations without requiring a failed BIOS transfer. Next discriminator should place distinct signatures at candidate byte offsets and read logical sector 1 once.
