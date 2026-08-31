# H1 physical qualification probe preregistration — 2026-08-31

Status: **PREREGISTERED / PHYSICAL EXECUTION NOT YET PERFORMED**
Target: HP Pavilion p2-1120 H1
Parent body: `os/research_only/d64_reference_v3/` (CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY)
Nature: physical-target observation/qualification support; **not C006 and not architecture promotion**.

## Question

Can one non-destructive removable-media boot collect enough direct machine facts from physical H1 to replace the main emulator assumptions before any destructive install or target-disk write?

## Safety boundary

The probe SHALL:
- boot from removable media through legacy BIOS;
- perform no writes to the physical target disk;
- perform no partitioning, formatting, filesystem mutation, flash/BIOS writes, PCI configuration writes, APIC/PIC/PIT reprogramming, or SMP startup;
- use BIOS/video output plus debug-port output when available;
- halt after reporting observations;
- keep the D64-v3 body unchanged.

The probe MAY read CPUID, BIOS data, BIOS E820, PCI configuration space, boot-drive parameters, PIC masks, and read-only CPU/MSR state needed to identify interrupt/APIC capability.

## Required observation families

A physical H1 run is useful only if the packet captures, at minimum:

1. **CPU identity and capability**
   - CPUID vendor;
   - maximum basic leaf;
   - leaf 1 raw EAX/EBX/ECX/EDX;
   - decoded family/model/stepping;
   - APIC capability bit;
   - logical-processor count reported by leaf 1 where present.

2. **Firmware / memory facts**
   - BIOS boot drive number;
   - EBDA segment from BDA;
   - BIOS E820 entries with base, length and type until BIOS terminates the walk or the probe's explicit bounded capture limit is reached;
   - an explicit truncation marker if the bounded E820 capture limit is reached.

3. **PCI topology facts**
   - enumerate PCI configuration mechanism #1 over buses 0..255, devices 0..31, functions 0..7;
   - for each present function report BDF, vendor/device, class/subclass/prog-if/header type;
   - report BAR0..BAR5 raw values for type-0 headers and the applicable BAR subset for bridge headers;
   - do not write BARs or probe BAR sizes by write-all-ones.

4. **Interrupt/APIC facts**
   - current PIC mask bytes (read only);
   - CPUID APIC capability;
   - if MSR support and APIC capability are present, IA32_APIC_BASE raw low/high dwords via `rdmsr`;
   - no interrupt-controller reprogramming in this probe.

5. **Boot/storage-facing facts**
   - INT13h AH=08 boot-drive geometry/status where supported;
   - INT13h extensions presence via AH=41 where supported;
   - physical storage-controller identity is expected to come from PCI enumeration, not from a driver claim.

## Output contract

The probe SHALL emit line-oriented ASCII records to both:
- BIOS teletype/VGA screen;
- I/O port `0xE9` for emulator capture.

Required framing:
- `H1PROBE_BEGIN`
- one or more records from every required family above;
- `H1PROBE_END`

Every bounded list SHALL either terminate normally or emit an explicit truncation/error record.

## Qualification before physical use

Before the probe is presented for physical H1 use:

1. source/build inputs are committed or sealed;
2. the probe builds reproducibly with the qualified local LLVM path;
3. stage1 is exactly 512 bytes with `55 AA` signature;
4. stage2 fits the existing 16-sector / 8192-byte removable-media load envelope;
5. the resulting image boots under the current H1 QEMU proxy;
6. QEMU output contains BEGIN/END and all observation-family markers;
7. QEMU run uses a read-only probe image and no writable target disk;
8. source/static audit confirms no disk-write BIOS function, PCI config write, flash path, or controller reprogramming is present.

This emulator qualification proves only that the collection instrument functions under the proxy. It does not qualify physical H1.

## Physical evidence status law

Before a real H1 boot: `PHYSICAL_H1 = UNQUALIFIED`.

After a real boot, each observation is admitted only from the captured physical packet. Emulator values may be shown beside physical values for comparison but may not fill a missing physical field.

A failed or partial physical boot remains a result. Missing fields remain UNKNOWN; they are not copied from QEMU.

## Campaign relationship

This lane is deliberately not named C006. C004 and C005 are closed at their 20-pass hard stops, and current architecture doctrine says not to open a new broad science campaign by momentum. Physical observations may later earn a narrow campaign if they expose a real mechanism contradiction or unresolved responsibility.
