# H1 public firmware research — 2026-08-31

Mode: AUDIT / research
Status: research evidence only; not architecture authority
Target: HP Pavilion p2-1120 / H1 physical probe machine

## Verified local package evidence

- Local SoftPaq: `sp70481.exe`
- SHA-256: `b1f0fde1052d997d005b0f662be4c38ad027b06a56bee6fd2f5a5c0c8827ca45`
- MD5: `76992921b9a17622b27b3957d4f63adc`
- Local HP metadata file states:
  - title: `HP Consumer Desktop PC BIOS Update (ROM Family SSID 2AE3 2AE4 2B01)`
  - version: `8.24 Rev. A Pass 1`
  - purpose: `Critical`
  - effective date: `January 23, 2015`
  - SoftPaq: `SP70481.exe`
  - declared SoftPaq MD5: `76992921b9a17622b27b3957d4f63adc`
  - enhancement: improved security of UEFI code and variables
  - supported family includes HP Pavilion p2-xxxx PC
- The computed local SoftPaq MD5 exactly matches the MD5 declared in the HP metadata.

## Extracted ROM

- Path: `sp70481_extracted/RED_824.ROM`
- Bytes: `4194304`
- SHA-256: `41e643e4650a9c6e7886caf41edc383b55523179c996ff6661eb96cd78a774eb`
- Static string inspection directly finds extensive EFI status/protocol terminology, HP UEFI diagnostic strings, `UsbSupport`, `UsbMassStorage`, and `Failed to locate LegacyBiosPlatformProtocol`.
- This is direct evidence that RED_824 is a UEFI firmware image with a legacy-BIOS compatibility path present in the image. The exact implementation and runtime path used by H1 remain unverified.

## Public-source findings

### HP
HP's UEFI firmware security bulletin lists the Pavilion p2-1120 with `RED_8.24` / `sp70481`. The same SoftPaq is shared across a wider RED_8.24 desktop family.

Source: https://support.hp.com/id-en/document/ish_10124197-10124229-16/hpsbhf03374

### Board / chipset corroboration
A repair-firmware archive identifies Pavilion p2-1120 as APXD1-DM (Redwood B), Pegatron, AMD Hudson-D1 FCH, BIOS RED_824. Treat this source as corroboration only until H1's board markings or firmware tables confirm the exact board revision.

Source: https://vinafix.com/threads/hp-pavilion-p2-1120-apxd1-dm-redwood-b.24069/

### AMD Hudson-1 register guide
A public archived AMD Hudson-1 Register Reference Guide states that A45 = Hudson-D1. This directly matches the chipset family attributed to the p2-1120 by the board-source material.

Source: https://ftp.kolibrios.org/users/art_zh/doc/public/A50_RRG.pdf

### AMD later-family BIOS guide as architectural corroboration only
AMD's Bolton FCH BIOS Developer's Guide documents the same general AMD FCH USB organization: OHCI/EHCI controller pairs, ACPI/SMI control surfaces, port routing, and BIOS-resident USB-controller firmware handling. Bolton is a later FCH and is NOT evidence of exact Hudson-D1 behavior; use it only as a family-level implementation analogue.

Source: https://www.amd.com/content/dam/amd/en/documents/archived-tech-docs/programmer-references/51205_Bolton_FCH_BIOS_Dev_Guide.pdf

### INT 13h / EDD baseline
Phoenix EDD 1.1 defines AH=41h support discovery and AH=42h packet reads. A basic packet-access support bit covers AH=42h/43h/44h/47h/48h. This sets the standards baseline but does not guarantee bug-free USB emulation on a specific firmware.

Source: https://wiki.sensi.org/download/doc/ata_edd_11.pdf

## Relevant historical implementation reports

OSDev historical reports document real machines that boot a USB sector successfully but then behave differently from emulators on later INT 13h reads, including AH=42h failures or successful calls returning unexpected data. These are anecdotes, not proof about H1, but they establish that this failure class existed in contemporaneous firmware.

Sources:
- https://f.osdev.org/viewtopic.php?t=30014
- https://f.osdev.org/viewtopic.php?t=19222

## Current interpretation

Verified:
- H1's target model is listed by HP under RED_8.24 / sp70481.
- The locally preserved SoftPaq matches HP's declared MD5 exactly.
- RED_824.ROM is a 4 MiB UEFI image and contains direct signs of EFI, USB mass-storage, and legacy-BIOS compatibility machinery.

Provisional:
- H1's exact motherboard revision is APXD1-DM / Redwood B.
- The observed physical USB INT 13h behavior is caused by the UEFI legacy-compatibility path rather than by media, transfer parameters, or another firmware layer.
- Any Bolton-FCH mechanism applies identically to Hudson-D1.

## Highest-value next checks

1. Confirm H1 board identity from physical board markings, SMBIOS, or firmware-resident board/SSID data.
2. Extract UEFI firmware volumes/modules from RED_824 with a qualified parser and identify the USB mass-storage and legacy BIOS/CSM modules by GUID/name.
3. Compare the physical discriminator outcome against the EDD baseline before changing the boot loader.
4. If one-sector AH=42h is physically confirmed while an eight-sector AH=42h fails, test one-sector-at-a-time loading as a narrowly preregistered repair, not as a generalized firmware conclusion.
