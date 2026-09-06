# H1 BIOS USB EDD read discriminator preregistration 02 — no redundant support recheck — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Physical result 01 persisted `H1READ_EDD_SUPPORT_FAIL` after an entry breadcrumb that itself had already succeeded through an AH=41 support check followed by AH=43 write to LBA257. Therefore EDD capability was physically proven immediately before the redundant standalone AH=41 gate failed.

This descendant removes only that redundant second AH=41 support probe. It SHALL:
- preserve BIOS boot drive DL;
- write `H1READ2_STAGE1_ENTER` to LBA257 using the existing helper (AH=41 + AH=43);
- immediately issue AH=42 for exactly one sector, LBA1 -> 0000:6000;
- compare the first 8 bytes against the known loader prefix `FA 31 C0 8E D8 8E C0 8E`;
- overwrite LBA257 with `H1READ2_LBA1_MATCH` on exact byte match;
- overwrite LBA257 with `H1READ2_AH42_FAIL` if AH=42 returns carry set;
- overwrite LBA257 with `H1READ2_DATA_MISMATCH` if AH=42 reports success but data differs;
- halt forever.

No additional EDD support probe is permitted between the successful entry breadcrumb and AH=42. Only LBA257 may be written.
