# H1 BIOS USB read discriminator preregistration 07 — destination 0x7E00 — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: physical READ6 showed a one-sector CHS AH=02 read of sector2/LBA1 returned carry clear while the pre-zeroed destination at physical 0x6000 remained all-zero. Earlier EDD reads showed the same success-without-data symptom at physical 0x6000 under two equivalent DAP encodings.

Question: does H1 firmware only deliver BIOS boot-device read data to a more conventional post-boot transfer window near the boot sector?

This discriminator changes only the destination address from physical 0x6000 to physical 0x7E00. It SHALL:
- preserve BIOS boot drive DL;
- perform no disk write before the read;
- zero physical 0x7E00 before the read;
- issue exactly one INT13 AH=02 read of cylinder0/head0/sector2, count1, destination ES:BX=0000:7E00;
- capture carry status;
- build a forensic result sector containing header `H1READ7_7E00`, status byte, and first 128 bytes from physical 0x7E00;
- only after the read, persist that result to physically proven writable LBA257 using AH=41 + AH=43;
- halt forever.

Only LBA257 may be written. No second-stage execution, graphics transition, internal-disk path, or probe execution.

Interpretation:
- CF=0 + returned bytes match known LBA1 prefix -> H1 has a destination-region constraint/quirk; use a conventional second-stage window and copy onward in software.
- CF=0 + destination still zero -> destination 0x7E00 does not resolve the issue.
- CF=1 -> address change affects BIOS acceptance; capture and continue from earned evidence.
