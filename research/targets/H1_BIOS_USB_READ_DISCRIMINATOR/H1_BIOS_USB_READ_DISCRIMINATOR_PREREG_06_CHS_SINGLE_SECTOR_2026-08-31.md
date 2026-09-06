# H1 BIOS USB read discriminator preregistration 06 — CHS single-sector read — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: READ4 and READ5 both physically observed AH=42 return carry clear with post-call count 1 while leaving physical destination 0x6000 all-zero. Equivalent DAP encodings `0000:6000` and `0600:0000` produced the same result.

Question: can H1 firmware actually deliver one boot-device sector through legacy CHS AH=02 when the transfer is reduced to a single sector?

This discriminator SHALL execute entirely from sector 0. It SHALL:
- preserve BIOS boot drive DL;
- perform no disk write before the read;
- zero physical destination 0x6000;
- issue exactly one INT13 AH=02 read of cylinder 0, head 0, sector 2 (the sector immediately after the boot sector, corresponding to LBA1 under the boot geometry used by the existing wrappers), count 1, destination ES:BX=0000:6000;
- capture carry status;
- build one forensic result sector containing ASCII header `H1READ6_CHS`, status byte, and first 128 bytes from 0x6000;
- only after the read, persist that result to physically proven writable LBA257 using AH=41 + AH=43;
- halt forever.

Only LBA257 may be written. No second-stage execution, graphics transition, internal-disk path, or probe execution.

Interpretation:
- returned bytes match known LBA1 prefix -> CHS single-sector reads work; construct physical H1 loader as bounded single-sector CHS reads rather than multi-sector CHS or EDD reads.
- CF=1 -> even one-sector CHS read is rejected; boot-sector-only or firmware-provided alternatives required.
- CF=0 + zero/wrong data -> BIOS reports success without usable destination data across both EDD and CHS; reassess the boot-device presentation/virtualization rather than loader transfer size.
