# Physical H1 BIOS USB EDD read discriminator result 04 — raw buffer dump — 2026-08-31

Status: **PHYSICAL EVIDENCE / AH=42 CF CLEAR + COUNT 1 + DESTINATION BUFFER UNCHANGED ZERO**

Prepared image SHA-256: `7b342f3ded51e01b89ce2e838467bc94bee3d35806cb40b1b3ec34f12d297398`.

After one physical H1 boot, LBA257 contained a valid `H1READ4_RAW` forensic sector.

Decoded fields:
- AH=42 status byte: `0` (carry clear);
- post-call DAP sector count: `1`;
- first 128 bytes captured from physical address `0x6000`: all zero;
- returned 128-byte payload did not match LBA1 and did not provide evidence of a unique alternate sector translation.

LBA257 SHA-256: `f5880e611dbea7b4767a362283f38acaeecdf46b619a0124a663d8cb27c4249f`.

Earned interpretation:
- BIOS reports successful one-sector AH=42 transfer and leaves DAP count at one;
- the destination sample remains exactly as pre-zeroed;
- therefore physical H1 did not place observable data at destination encoded as `0000:6000` despite reporting success.

Next discriminator changes only DAP destination encoding from `0000:6000` to equivalent `0600:0000` while keeping physical address 0x6000, LBA1, one-sector count, and read-before-write order unchanged.
