# H1 BIOS USB EDD read discriminator preregistration — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: physical sector-0 breadcrumbs proved EDD writes to LBA257 persist, while both the prior CHS AH=02 loader read and the repaired 8-sector EDD AH=42 loader read failed to reach their post-load breadcrumb.

Question: can H1 BIOS perform a one-sector EDD AH=42 read from LBA1 on this boot SanDisk?

This discriminator SHALL execute entirely from sector 0. It SHALL:
- preserve BIOS boot drive DL;
- write `H1READ_STAGE1_ENTER` to LBA257 via EDD AH=43;
- verify EDD support via AH=41;
- issue one AH=42 read of exactly one sector, LBA1, into 0000:6000;
- compare the first 8 bytes against the known loader prefix `FA 31 C0 8E D8 8E C0 8E`;
- only if the bytes match, overwrite LBA257 with `H1READ_LBA1_MATCH`;
- if the AH=42 call returns carry set, overwrite LBA257 with `H1READ_AH42_FAIL`;
- if AH=42 returns success but bytes do not match, overwrite LBA257 with `H1READ_DATA_MISMATCH`;
- halt forever.

Only LBA257 on the BIOS-selected boot device may be written. No second stage, graphics mode, internal disk, or probe execution.

Interpretation:
- `H1READ_LBA1_MATCH` -> one-sector EDD read works; prior 8-sector transfer size/count is the likely failure surface.
- `H1READ_AH42_FAIL` -> AH=42 read itself is rejected on this physical presentation.
- `H1READ_DATA_MISMATCH` -> BIOS claims success but returns unexpected data/address translation.
- `H1READ_STAGE1_ENTER` only -> failure before outcome breadcrumb; inspect support gate/control flow.
