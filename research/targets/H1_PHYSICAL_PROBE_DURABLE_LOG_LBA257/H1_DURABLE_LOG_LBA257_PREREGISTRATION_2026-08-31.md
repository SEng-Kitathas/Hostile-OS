# H1 durable boot-USB journal LBA257 repair preregistration — 2026-08-31

Status: **PREREGISTERED / IMPLEMENTATION DERIVED FROM PRIOR QUALIFIED LOGGER**

Physical evidence established an address-specific BIOS write anomaly:
- EDD AH=43 to LBA257 persisted physically;
- EDD AH=43 to LBA256 did not persist physically;
- CHS target LBA256 did not persist.

The prior durable logger began at LBA256 and disabled itself after the first failed write. This descendant changes only the journal base from **LBA256 to LBA257** and therefore uses LBAs **257..384** for its 128-sector, 64 KiB journal.

All other logger/probe behavior remains inherited:
- firmware-selected text/video mode preserved;
- one indirect `putc` hook at 0x0500;
- newline/full-buffer flush;
- EDD AH=43 primary write path;
- CHS AH=03 fallback retained for emulator coverage;
- HP internal storage remains outside the write path;
- D64-v3 unchanged.

Qualification requirements:
1. static gate updated to prove journal bounds 257..384;
2. QEMU floppy/CHS and IDE/EDD full-probe runs reach `H1PROBE_END`;
3. independently decoded journal reaches `H1PROBE_END` in both modes;
4. no byte outside LBAs257..384 changes;
5. initial physical journal region zero;
6. new physical image/prefix hashes issued before hardware reuse.
