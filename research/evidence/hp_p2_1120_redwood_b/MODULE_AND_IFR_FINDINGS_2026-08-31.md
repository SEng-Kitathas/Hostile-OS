# H1 HP Pavilion p2-1120 — RED firmware module and setup-form findings

Date: 2026-08-31
Status: research evidence; static firmware analysis only
Target family: HP Pavilion p2-1120 / RED firmware family / SSIDs 2AE3, 2AE4, 2B01

## Purpose

This note records a bounded static comparison of public HP RED 8.23 and RED 8.24 firmware packages and the USB/legacy-boot controls present in the firmware setup forms. It is intended to reduce blind physical probing on the H1 machine.

This note does **not** establish which firmware revision is currently installed on the physical H1 machine, and it does **not** establish the machine's current NVRAM values. The ROM-resident defaults below are factory/default-image evidence only.

## Public lineage

Official HP bulletin HPSBHF03374 lists **HP Pavilion p2-1120 Desktop PC — RED_8.24 — sp70481**.

Public source:
- https://support.hp.com/th-en/document/ish_10124197-10124229-16/hpsbhf03374

CERT VU#758382 records a 2014 UEFI-variable protection issue and states that AMI supplied generic fixes to OEMs. This provides public context for the later HP firmware publication but does not explain H1's USB behavior by itself.

- https://www.kb.cert.org/vuls/id/758382

CERT VU#552286 records 2014 EDK2 Capsule Update issues and lists both AMI and Hewlett-Packard among affected vendors.

- https://www.kb.cert.org/vuls/id/552286

AMD's public Family 12h BIOS and Kernel Developer's Guide is relevant platform documentation for this processor generation:

- https://www.amd.com/content/dam/amd/en/documents/archived-tech-docs/programmer-references/12h_bkdg_pub.pdf

## Preserved HP packages

### RED 8.23 / SP67088

- `sp67088.exe` SHA-256: `1478d3473e383859a80b7d6f9119bad7083066fb64e01fa40c0fe9bcf1e57e99`
- `RED_823.ROM` SHA-256: `75fd4eda61a909bbffd87efcb06f112269c3ae79a0c126c8765f356eb491a6fd`
- Local ROM: `sp67088_extracted/RED_823.ROM`

### RED 8.24 / SP70481

- `sp70481.exe` SHA-256: `b1f0fde1052d997d005b0f662be4c38ad027b06a56bee6fd2f5a5c0c8827ca45`
- `RED_824.ROM` size: 4,194,304 bytes
- `RED_824.ROM` SHA-256: `41e643e4650a9c6e7886caf41edc383b55523179c996ff6661eb96cd78a774eb`
- Local ROM: `sp70481_extracted/RED_824.ROM`

The HP 8.24 package identifies itself as a critical BIOS update for ROM-family SSIDs `2AE3 2AE4 2B01` and says the update improves security of UEFI code and variables.

## Analysis tools

### UEFIExtract

LongSoft UEFITool/UEFIExtract NE A75 Windows release:

- archive: `research/tools/UEFIExtract_NE_A75/UEFIExtract_NE_A75_win64.zip`
- archive SHA-256: `20ff18208913d32c99e3b002717abeddaa3b6509ac62e6699e462b0f533be646`
- executable SHA-256: `e372554c8ec1c8f1ad123d739072eb699cf011d12d2d71954bcdb63c79812fb0`
- release archive hash matched the digest published by GitHub for the release asset.

### IFRExtractor-RS

LongSoft IFRExtractor-RS v1.6.1 Windows release:

- archive: `research/tools/IFRExtractor_RS_v1.6.1/ifrextractor_1.6.1_windows.zip`
- archive SHA-256: `3a0d93ecd3a4cb092d210c499d125ffd782982311f5f8dc40a8b180b58c4ffe7`
- executable SHA-256: `01b50d394a93edad8299207ae0c88577d65db5fc86280467afab55e486d62c1c`
- local archive hash matched the digest published by GitHub for the release asset.

UEFIExtract parsed both HP ROMs successfully. It emitted the same non-fatal warning about non-UEFI data in a padding file.

## Legacy/USB module map in RED 8.24

Relevant named firmware files include:

| Module | GUID |
|---|---|
| AINT13 | `67820532-7613-4DD3-9ED7-3D9BE3A7DA63` |
| USBINT13 | `4C006CD9-19BA-4617-8483-609194A1ACFC` |
| BIOSBLKIO | `25ACF158-DD61-4E64-9A49-55851E9A26C7` |
| CSMCORE | `A062CF1F-8473-4AA3-8793-600BC4FFE9A8` |
| USBRT | `04EAAAA1-29A1-11D7-8838-00500473D4EB` |
| LegacyInterrupt | `71ED12D1-250B-42FB-8C17-10DCFA771701` |
| LegacyRegion | `59242DD8-E7CF-4979-B60E-A6067E2A185F` |
| CsmVideo | `29CF55F8-B675-4F5D-8F2F-B87A3ECFD063` |
| Setup | `899407D7-99FE-43D8-9A21-79EC328CAC21` |
| UsbBotPeim | `8401A046-6F70-4505-8471-7015B40355E3` |

## 8.23 -> 8.24 module comparison

The first report-level comparison suggested several legacy/USB modules changed because their reported CRCs changed. Targeted PE extraction showed that interpretation was too broad.

After zeroing the PE COFF timestamp field, these modules are byte-identical between 8.23 and 8.24:

| Module | PE body bytes | Timestamp-zeroed SHA-256, both revisions |
|---|---:|---|
| AINT13 | 7,072 | `cc9e454c590fe2c7533457a18d9b1612d89e4cae9db6b8ee5ff541e4e2deb672` |
| USBINT13 | 6,656 | `df62c4db45efb935fed2cc6a02cbf3f80b6dc23f35a69d54e91d6b1653043363` |
| BIOSBLKIO | 12,448 | `2a8d8bd8fe7086c4154052da2b0dbb8a041be19a0a4b5b7d652b4bfd24b973c5` |
| USBRT | 87,776 | `85bff7c42d78ea3fef55a177f8f35cc52a271a429813b12d823c3439eed16f97` |

For each of those four PE bodies, the only observed byte difference was the four-byte PE build timestamp.

### CSMCORE

CSMCORE's EFI/DXE PE body changed materially:

- 8.23 PE body: 46,560 bytes; timestamp-zeroed SHA-256 `ce8be02a2b7fcb8ce80bf0333d39d64dba4f4f4f9989b8c86215958f5014e8d1`
- 8.24 PE body: 46,592 bytes; timestamp-zeroed SHA-256 `cdce5362a4259a5b483443534adf79df59aa80da5c0c92c61df3af2887fc897c`
- `.text` grew by 0x10 virtual bytes / 0x20 raw bytes.

However, the large raw legacy payload extracted from CSMCORE is exactly identical between revisions:

- size: 252,338 bytes
- SHA-256, both revisions: `11852b92588b6472b5d5481d7e0a4c245268f053acd9baeea593cbc8f8746d38`

That payload contains legacy BIOS strings including `USB Storage`, `Hard Disk`, and `INT13-1.3`.

### Interpretation

**Verified static result:** the obvious AINT13, USBINT13, BIOSBLKIO, and USBRT executable code did not change from 8.23 to 8.24. CSMCORE's EFI/DXE wrapper changed, but its extracted large legacy payload did not.

**Provisional consequence:** the H1 USB-read behavior is unlikely to have been introduced by the 8.23 -> 8.24 update through a code change inside those four obvious modules. This is not proof that firmware revision is irrelevant; surrounding initialization, state, or CSM wrapper behavior can still matter.

## Setup/HII comparison

The `Setup` firmware file was extracted from both ROMs and its HII/form body was processed with IFRExtractor-RS.

- 8.23 HII body: 345,433 bytes; SHA-256 `c03bd279bb097bd62d32c4d3d3a3ad9861a7b0f56a7101c4fd20ba159524e314`
- 8.24 HII body: 345,433 bytes; SHA-256 `aee08a732ee3188dda851df5c4b1fb87085eb5edd309b390c21c06afd9c17ec9`
- raw HII difference: 25 bytes total.

Inspection of all changed bytes shows they are copyright-year changes from 2013 to 2014 in localized strings. The parsed IFR control structures are otherwise identical; IFR text diffs contain only the extractor's source-SHA header.

Therefore the USB, CSM, and mass-storage emulation controls described below are unchanged across 8.23 and 8.24.

## Exact USB variable layout and defaults

The Advanced form exposes these variable stores:

- `UsbMassDevNum`: VarStore ID `0x8`, GUID `EC87D643-EBA4-4BB5-A1E5-3F3E36B20DA9`, size 2
- `UsbMassDevValid`: VarStore ID `0x9`, same GUID, size 16
- `UsbSupport`: VarStore ID `0xA`, same GUID, size 29 (`0x1D`)

The ROM's full `UsbSupport` NVAR entry exists in both 8.23 and 8.24. Its 29-byte data payload is identical in both revisions:

`01 00 00 00 00 00 00 01 14 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 01 00 05`

Payload SHA-256, both revisions:

`27db94ea5e10ef6d694d0181c3b70a0180af7da00248849ac62b9187e19be5bd`

The bytes align exactly with the IFR defaults:

| UsbSupport offset | Meaning | ROM default |
|---:|---|---|
| `0x00` | USB Support | Enabled (`1`) |
| `0x01` | Legacy USB Support | Enabled (`0` in this enum) |
| `0x02` | EHCI Hand-off | Disabled (`0`) |
| `0x07` | Device reset time-out | enum `1` = 20 sec |
| `0x08` | USB transfer time-out | `20` sec |
| `0x09..0x18` | 16 per-device emulation selectors | all `0` = Auto |
| `0x19` | USB3/XHCI controller support | Enabled (`1`) |
| `0x1A` | XHCI Hand-off | Enabled (`1`) |
| `0x1B` | Device power-up delay mode | Auto (`0`) |
| `0x1C` | manual power-up delay seconds | `5` |

The per-device selectors offer:

- `0` = Auto — default and manufacturing default
- `1` = Floppy
- `2` = Forced FDD
- `3` = Hard Disk
- `4` = CD-ROM

The help text says Auto selects emulation according to media format; another string in the same firmware states that Auto can classify devices below 530 MB as floppies and that Forced FDD can force an HDD-formatted device to FDD behavior.

## Device-slot visibility mechanism

The Advanced USB form contains 16 hidden validity checkboxes backed by `UsbMassDevValid[0..15]`. Each device emulation selector is wrapped in a suppression condition tied to the matching validity slot.

Observed mapping:

- selector QID `0x45`, `UsbSupport[0x09]` is controlled by `UsbMassDevValid[0]`
- selector QID `0x46`, `UsbSupport[0x0A]` is controlled by `UsbMassDevValid[1]`
- ...
- selector QID `0x54`, `UsbSupport[0x18]` is controlled by `UsbMassDevValid[15]`

The prompts are `N/A` in the static form package, consistent with runtime population of the attached device name.

This is evidence that the firmware maintains explicit per-device USB mass-storage classification/emulation state. It does **not** tell us which slot or classification the physical SanDisk currently receives.

## CSM and boot-policy defaults

The `Setup` NVAR data payload is also identical between 8.23 and 8.24:

- payload size: 471 bytes
- SHA-256: `ae90733b56e661755a6b57c3c50a9ad771a97a5c3c79e32dccd27bd433a1f899`

Relevant bytes and IFR definitions:

- `Setup[0x1BA]` = `1` — `Launch CSM`; enum: Auto=0, Always=1, Never=2. Normal default is Always; manufacturing default is Auto.
- `Setup[0x1BB]` = `0` — boot option filter; enum: UEFI and Legacy=0, Legacy only=1, UEFI only=2. Default is UEFI and Legacy.

## Relevance to the H1 physical findings

The H1 physical campaign has shown that sector 0 executes and some BIOS-mediated writes persist, while several BIOS-mediated read calls have returned success without delivering expected source bytes to tested destinations.

The static firmware evidence now adds a concrete variable that had not been isolated before: **the boot USB is passed through AMI's per-device mass-storage emulation/classification machinery, with Auto as the ROM default.**

That suggests the next physical work should distinguish:

1. the physical machine's installed RED revision and exact board identity;
2. the runtime classification/emulation chosen for the SanDisk;
3. whether the read behavior changes with explicit device classification or with another media geometry/device.

It is premature to attribute the observed read behavior to a specific firmware defect or to the 8.24 update.

## Next research/verification seam

Before more blind variations of the existing AH=02/AH=42 read tests, prefer a passive identity/state discriminator that records the installed BIOS/SMBIOS identity and, if a safe read-only path is available, relevant USB/CSM state. Do not change firmware settings or flash an older ROM merely for this comparison.
