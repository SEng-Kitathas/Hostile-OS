# H1 BIOS USB read discriminator preregistration 06 — CHS read first — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: READ4 and READ5 physically proved one-sector EDD AH=42 reads of logical LBA1 return carry clear and count 1 but leave physical destination 0x6000 unchanged zero, for both DAP encodings 0000:6000 and 0600:0000.

Question: can the H1 BIOS deliver the same sector through legacy CHS AH=02 when the read occurs before any BIOS disk write?

This discriminator SHALL execute entirely from sector 0 and SHALL:
- preserve BIOS boot drive DL;
- perform no BIOS disk write before the read;
- zero physical 0x6000;
- issue one legacy CHS AH=02 read of cylinder 0, head 0, sector 2 (the first sector after the boot sector, corresponding to physical LBA1 for the prepared image) into ES:BX = 0000:6000;
- capture carry status;
- build one 512-byte forensic sector containing header `H1READ6_CHS_RAW`, status byte, and the first 128 bytes at physical 0x6000;
- only after the read, persist that result to physically proven writable LBA257 using AH=41 + AH=43;
- halt forever.

Only LBA257 may be written. No second-stage execution, graphics transition, internal-disk path, or probe execution.

Interpretation:
- CHS CF=0 with returned bytes matching prepared LBA1 -> use CHS read-before-write for loader and defer all durable writes until resident loader begins.
- CHS CF=1 -> one-sector legacy read itself fails in this presentation.
- CHS CF=0 with zero/unexpected data -> firmware reports success without delivering expected bytes; inspect BIOS logical-drive geometry/device emulation next.
