# Physical H1 BIOS USB EDD read discriminator result 03 — read first — 2026-08-31

Status: **PHYSICAL EVIDENCE / AH=42 RETURNS SUCCESS WITH DATA MISMATCH**

Prepared image SHA-256: `4ccd233a012cefaa011adc2bfa5486e3f839d96e84a357ffa588b404958c4c7a`.

After one physical H1 boot, elevated raw readback of LBA257 contained exactly:

`H1READ3_DATA_MISMATCH\r\n`

LBA257 SHA-256: `eb3fa12f925423eb942dd42287ef350900202f3ce0b1c5aaf0b5793d54b0622c`.

Earned interpretation:
- AH=42 was issued before any BIOS disk write;
- AH=42 returned carry clear;
- bytes returned at 0000:6000 did not match the known LBA1 prefix `FA 31 C0 8E D8 8E C0 8E`;
- therefore the physical BIOS read path is not simply rejecting AH=42; it reports success while delivering unexpected data/addressing.

Next discriminator SHALL persist the first returned bytes from 0000:6000, plus read-status metadata, to physically proven writable LBA257 for direct forensic comparison against known sectors in the prepared image.
