# HP Pavilion p2-1120 / APXD1-DM Redwood B — public firmware and platform evidence

Date: 2026-08-31
Status: RESEARCH EVIDENCE / NOT ARCHITECTURE AUTHORITY
Target: HP Pavilion p2-1120, product H2L67AA#ABA; Pegatron APXD1-DM Redwood B family

## Highest-value official firmware evidence

HP still serves two relevant Consumer Desktop BIOS SoftPaqs directly from ftp.hp.com.

### SP67088 — BIOS 8.23
- Source: HP SoftPaq sp67088.exe
- Local SHA-256: `1478d3473e383859a80b7d6f9119bad7083066fb64e01fa40c0fe9bcf1e57e99`
- Extracted without executing updater:
  - `RED_823.ROM` — 4,194,304 bytes — SHA-256 `75fd4eda61a909bbffd87efcb06f112269c3ae79a0c126c8765f356eb491a6fd`
  - `safuwin.exe` — 302,352 bytes — SHA-256 `bcfd8de24def6286d09440fe71da50a5aaba70981f328c646d4b30c9beacd725`
  - `flash.bat` — `SAFUWIN RED_823.ROM /P /B /N /R /K`
  - `sp67088.cva`
- CVA metadata:
  - title: `HP Consumer Desktop PC BIOS Update (ROM Family 2AE3_2AE4_2B01)`
  - Version 8.23, Revision A, Pass 1
  - SysIDs: 0x2AE3, 0x2AE4, 0x2B01
  - enhancement: `Security enhancement`
  - CVA timestamp: 2014-06-30

### SP70481 — BIOS 8.24
- Source: HP SoftPaq sp70481.exe
- HP endpoint returned HTTP 200; Content-Length 2,745,632 bytes.
- Local SHA-256: `b1f0fde1052d997d005b0f662be4c38ad027b06a56bee6fd2f5a5c0c8827ca45`
- Extracted without executing updater:
  - `RED_824.ROM` — 4,194,304 bytes — SHA-256 `41e643e4650a9c6e7886caf41edc383b55523179c996ff6661eb96cd78a774eb`
  - `safuwin.exe` — 302,352 bytes — same SHA-256 as SP67088
  - `flash.bat` — `SAFUWIN RED_824.ROM /P /B /N /R /K`
- SoftPaq wrapper identifies product as `HP Consumer Desktop PC BIOS Update (ROM Family SSID 2AE3 2AE4 2B01)`, ProductVersion 8.24.

## Security-disclosure lineage

Public HP/CERT records tie this firmware family to published UEFI research:
- 2014 HP bulletin HPSBHF03084: p2-1120 listed with RED 8.23 / SP67088 in response to EDK2 Capsule Update vulnerabilities CVE-2014-4859 and CVE-2014-4860 / CERT VU#552286.
- 2015 HP bulletin HPSBHF03374: p2-1120 listed with RED 8.24 / SP70481 for CVE-2014-2961 / CERT VU#758382, associated with UEFI variable handling research.

This provides a documented public path from firmware research/disclosure to two official HP firmware generations for this exact model family.

## Firmware-body observations from official RED_824.ROM

Non-executing string extraction from the 4 MiB ROM found:
- `AMITSESetup`
- `AmiAgesaSetup`
- `UsbSupport`
- `SecureBootSetup`
- EFI status vocabulary and EDK source-path residue
- `UsbMassStorage`
- USB device-path format strings
- `BBS(...)`
- `Failed to locate LegacyBiosPlatformProtocol`
- `PeiRamBoot`
- HP UEFI diagnostics strings
- EFI Block I/O / Extended SCSI pass-through / ATA / SATA / AHCI diagnostic strings
- FAT12/FAT16/FAT32, `EFI Protective MBR`, `EFI System Partition`

Working interpretation: RED_824 is an AMI/EDK-derived UEFI firmware with both EFI Block I/O/USB mass-storage machinery and a legacy BBS/LegacyBiosPlatform compatibility path. This is relevant to the H1 physical INT 13h USB anomaly but does not yet identify the failing module or mechanism.

## RED_823 vs RED_824 raw comparison

Both images are exactly 4 MiB. A bytewise comparison reports 2,469,351 differing bytes (~58.87%). This MUST NOT be read as 58.87% of firmware logic changing: UEFI compression/repacking can cause large binary avalanches after a small module change. Module-level extraction/diff is required before semantic interpretation.

## AMD platform-development material

Public AMD documentation relevant to the E2-1800 / Family 14h platform includes:
- BIOS and Kernel Developer's Guide for AMD Family 14h Models 00h-0Fh, publication 43170.
- Revision Guide for AMD Family 14h Models 00h-0Fh, publication 47534.
- AGESA Arch2008 interface documentation referencing the Family 14h BKDG and revision guide.

These are useful substrate references for CPU/chipset initialization, register semantics, errata, and firmware/OS boundary work. They are not HP-specific BIOS documentation.

## Regulatory/public-record finding

Historical 2011 FCC 47 CFR 15.101 allowed Class B personal computers and their CPU boards/power supplies to be authorized by Declaration of Conformity or Certification. Therefore absence of a convenient public FCC-ID grant for this desktop does not imply absence of required Part 15 compliance. The model also appears in retail records as Energy Star / EPEAT Silver.

No model-specific FCC filing with useful board/BIOS internals was verified in this pass.

## Repair / service ecosystem

Independent repair sites identify the p2-1120 as APXD1-DM (Redwood B) and circulate 4 MiB `RED_824.ROM` dumps. These are useful corroboration and possible donor comparisons, but the official HP SoftPaq ROM above is the stronger firmware reference.

## Next high-value research seam

Use a trustworthy open-source UEFI parser to extract module/FV structure from official `RED_823.ROM` and `RED_824.ROM`, then:
1. identify AMI CSM/LegacyBios/USB mass-storage/BBS-related modules;
2. diff module GUIDs, sizes, hashes, and contents across 8.23→8.24;
3. locate legacy INT 13h / USB boot compatibility code if extractable;
4. compare findings against the physical READ4–READ9 behavior;
5. keep firmware reverse engineering as research evidence until a causal path is verified.

No updater executable or ROM has been executed or flashed during this research pass.
