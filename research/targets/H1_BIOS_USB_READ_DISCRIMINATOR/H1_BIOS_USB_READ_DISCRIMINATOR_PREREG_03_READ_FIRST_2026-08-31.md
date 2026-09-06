# H1 BIOS USB EDD read discriminator preregistration 03 — read first, write outcome after — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: physical discriminator 02 proved a one-sector AH=42 read of LBA1 returns carry set when issued immediately after a successful AH=41 + AH=43 breadcrumb write to LBA257.

Question: does AH=42 read work when no BIOS disk write has occurred earlier in the boot-sector execution?

This discriminator SHALL execute entirely from sector 0. It SHALL:
- preserve BIOS boot drive DL;
- perform no BIOS disk write before the read attempt;
- issue AH=42 for exactly one sector, LBA1 -> 0000:6000;
- compare the first 8 bytes against the known loader prefix `FA 31 C0 8E D8 8E C0 8E`;
- after the read outcome is known, persist exactly one outcome to LBA257 using the already-proven AH=41 + AH=43 helper:
  - `H1READ3_LBA1_MATCH` on exact byte match;
  - `H1READ3_AH42_FAIL` if AH=42 returns carry set;
  - `H1READ3_DATA_MISMATCH` if AH=42 returns success but bytes differ;
- halt forever.

Only LBA257 may be written. No second stage, graphics change, internal-disk path, or probe execution.

Interpretation:
- MATCH -> prior AH=43 write perturbs subsequent AH=42 reads on H1; reorder boot loader to read first, then journal writes only after loader execution begins.
- AH42_FAIL -> runtime AH=42 read itself is unusable on this H1 USB presentation, even before any write.
- DATA_MISMATCH -> BIOS reports success but returns unexpected data/addressing.
