# H1 BIOS USB write discriminator preregistration — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Physical trigger: verified durable-log prefix booted on H1 but raw journal LBAs 256..383 remained byte-exact zero. The current seam is whether execution failed before logger persistence or H1 BIOS rejects boot-device writes.

This discriminator SHALL execute entirely from the 512-byte boot sector. It SHALL not load any secondary stage, change video mode, touch internal disks, or depend on display output.

It SHALL:
- preserve BIOS boot drive DL;
- build two 512-byte in-memory sentinel sectors;
- attempt a CHS write of sentinel `H1CHS_WRITE_OK` to logical LBA 256 using geometry returned by INT13 AH=08 and AH=03;
- independently test EDD support via INT13 AH=41 and, when available, attempt an EDD write of sentinel `H1EDD_WRITE_OK` to LBA 257 using AH=43;
- halt forever.

Only LBAs 256 and 257 on the BIOS-selected boot device may be written.

Interpretation after one physical boot:
- CHS sentinel only -> CHS boot-device writes work; EDD write did not persist.
- EDD sentinel only -> EDD boot-device writes work; CHS write did not persist.
- both sentinels -> both write paths work; durable logger failure lies elsewhere.
- neither sentinel -> either both BIOS writes are rejected or sector-0 code did not execute far enough; this becomes the next discriminator.

QEMU qualification SHALL verify floppy/CHS and IDE/EDD presentations, exact sentinel placement, and no changes outside LBAs 256/257.
