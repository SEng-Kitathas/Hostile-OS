# H1 BIOS USB EDD read discriminator preregistration 04 — raw returned-buffer dump — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: read-first physical discriminator 03 issued AH=42 for one sector at LBA1 before any disk write. BIOS returned carry clear, but the returned bytes at 0000:6000 did not match the known LBA1 prefix.

Question: what exact bytes did the physical BIOS place in the AH=42 destination buffer, and do they correspond to another known sector/address translation?

This discriminator SHALL execute entirely from sector 0 and SHALL:
- preserve BIOS boot drive DL;
- perform no BIOS disk write before AH=42;
- zero 0000:6000 before the read to eliminate stale-memory ambiguity;
- issue AH=42 for one sector, requested LBA1 -> 0000:6000;
- capture whether carry was set;
- build one 512-byte forensic result sector at 0000:5000 containing:
  - ASCII header `H1READ4_RAW`;
  - one status byte: 0 on carry clear, 1 on carry set;
  - the post-call DAP sector-count word;
  - the first 128 bytes from 0000:6000;
- persist that result to physically proven writable LBA257 using the existing AH=41 + AH=43 write helper only after the read has completed;
- halt forever.

Only LBA257 may be written. No second stage, graphics transition, internal-disk path, or probe execution.

Post-read analysis SHALL compare the captured 128-byte prefix against every 512-byte sector in the exact prepared 1 MiB image and report exact matches/offsets if any. No interpretation shall be promoted before this comparison.
