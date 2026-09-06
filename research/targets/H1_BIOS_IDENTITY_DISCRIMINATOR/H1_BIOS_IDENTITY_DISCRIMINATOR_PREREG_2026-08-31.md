# H1 BIOS identity discriminator preregistration — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

## Trigger

Static analysis of the official HP RED 8.23 and 8.24 firmware established a stable AMI legacy/USB stack and explicit per-device USB mass-storage emulation controls. The current physical H1 machine's installed firmware revision and exact SMBIOS/baseboard identity are still not directly earned.

## Question

What BIOS, system, and baseboard identity does the physical H1 firmware publish through SMBIOS at legacy boot time?

## Discriminator

The discriminator SHALL execute entirely from sector 0 and SHALL NOT perform any BIOS disk read.

It SHALL:

1. preserve the BIOS boot-drive value in `DL`;
2. initialize a 512-byte evidence buffer at `0000:5000`;
3. persist an entry breadcrumb to physically proven writable boot-USB LBA257 using INT 13h AH=43;
4. scan physical memory `0xF0000..0xFFFFF` on 16-byte boundaries for a valid SMBIOS 2.x `_SM_` entry point;
5. validate the entry-point checksum and `_DMI_` intermediate anchor;
6. record SMBIOS version, table length, structure count, table physical address, and the raw first 32 bytes of the entry point;
7. when the table address is below 1 MiB, copy up to the first 448 bytes of the SMBIOS structure table into the evidence sector;
8. overwrite LBA257 with the completed evidence sector using INT 13h AH=43;
9. halt forever on physical hardware. A separately compiled QEMU-only build MAY use the emulator debug-exit port after the result write.

## Evidence layout

- `0x00`: ASCII header, normally `H1SMBIOS1`
- `0x10`: boot drive `DL`
- `0x11`: status (`0` found/copied, `1` not found, `2` table address above 1 MiB)
- `0x12`: SMBIOS entry-point length
- `0x13`: SMBIOS major version
- `0x14`: SMBIOS minor version
- `0x15`: entry-point revision
- `0x16`: SMBIOS BCD revision
- `0x17`: checksum-valid marker
- `0x18`: structure-table length, little-endian word
- `0x1A`: structure count, little-endian word
- `0x1C`: structure-table physical address, little-endian dword
- `0x20..0x3F`: raw first 32 bytes of the SMBIOS entry point
- `0x40..0x1FF`: first 448 bytes of the SMBIOS structure table, truncated to advertised table length

## Mutation boundary

Only the boot USB's first 1 MiB is prepared before the run, and only LBA257 is written by the discriminator at runtime. No firmware variable, internal disk, firmware image, setup setting, or second-stage code is modified.

## Interpretation

The result may establish the installed BIOS vendor/version/date and SMBIOS system/baseboard identity if Type 0/1/2 structures are present inside the captured prefix. It SHALL NOT be treated as evidence of the current hidden USB-emulation variable value unless that value is separately observed.
