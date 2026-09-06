# Physical H1 BIOS USB read discriminator result 06 — CHS single-sector read — 2026-08-31

Status: **PHYSICAL EVIDENCE / CHS AH=02 CF CLEAR + DESTINATION BUFFER UNCHANGED ZERO**

Prepared image SHA-256: `0c1a08ab84f03b6906330fa8b0706a7bb3e2ceb52ab7ae6c0edb4cae802f62b8`.
Source commit: `c7e837feef643e39a8ec3a2f65bb0d69c327ff44`.

After one physical H1 boot, LBA257 contained a valid `H1READ6_CHS` forensic sector.

Decoded fields:
- CHS AH=02 status byte: `0` (carry clear);
- first 128 bytes captured from physical address `0x6000`: all zero;
- returned data did not match the known LBA1 prefix;
- LBA257 SHA-256: `57d6fdb54ec2d41ef7f1d8de358a976868efc7a1a0cabfe9eb031d438bcb1220`.

Earned interpretation:
- BIOS reports successful one-sector CHS read of cylinder0/head0/sector2;
- the pre-zeroed destination at physical 0x6000 remains unchanged;
- therefore the observed failure mode is not specific to EDD AH=42, multi-sector count, zero-segment DAP encoding, or CHS-vs-EDD API choice;
- both EDD and CHS paths can report success without observable data appearing at the tested low-memory destination.

Next seam: destination-memory semantics / firmware transfer location. A next discriminator should keep the requested sector fixed and vary only the destination region, preferably using a BIOS-conventional buffer below 0x7C00 and separately copying from that buffer after the call, or capture BDA/EBDA/EDD parameter information before selecting the next address. No broader architecture claim is earned yet.
