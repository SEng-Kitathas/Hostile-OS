# H1 physical qualification probe — Bochs independent-proxy preregistration

Date: 2026-08-31
Status: **PREREGISTERED / NOT YET EXECUTED**
Nature: independent proxy qualification of the already-built physical observation instrument; **not C006, not physical-H1 qualification, not architecture promotion**.

## Parent evidence

- QEMU instrument qualification result: `H1_PHYSICAL_PROBE_QUALIFICATION_RESULT_2026-08-31.md`
- exact physical removable-media image SHA-256: `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`
- physical image must be used unchanged.

## Question

Can the exact non-destructive physical H1 probe image reach its complete observation framing and all required observation families under an independent x86 emulator/firmware implementation, without relying on the QEMU-only debug-exit image or QEMU-specific result values?

## Environment

Use installed Bochs at `C:\Program Files\Bochs-3.1\bochs.exe` with:

- Bochs BIOS/VGA BIOS from the same installed package;
- one CPU using the existing project-qualified `phenom_8650_toliman` model;
- 4096 MiB guest memory;
- exact physical probe image attached as **write-protected 1.44 MiB floppy**;
- boot from floppy;
- `port_e9_hack: enabled=1, all_rings=1`;
- `display_library: nogui`;
- no network or host-disk attachment.

This is intentionally an independent proxy, not an H1 hardware model.

## Required collection consequence

The captured port-E9 stream must contain, in order:

1. `H1PROBE_BEGIN`
2. CPU observation family: one of `CPU_VENDOR=` or `CPU_CPUID=UNAVAILABLE`
3. boot observation family: `BOOT_DRIVE=` and a geometry result (`BOOT_GEOM` or explicit geometry failure marker)
4. firmware observation family: `FW_EBDA=` and an RSDP result marker
5. interrupt/APIC observation family: `IRQ_PIC_MASK=` and `IRQ_CAP`
6. memory observation family: `E820_BEGIN` followed by `E820_END`
7. PCI observation family: `PCI_BEGIN` followed by `PCI_END`
8. `H1PROBE_END`

Exact observed values are **not preregistered** and must not be judged by equality with QEMU. Differences are evidence about proxy diversity, not failures by themselves.

## Completion semantics

The physical probe deliberately halts after `H1PROBE_END` and contains no QEMU/Bochs exit instruction.

Therefore:

- collection becomes complete when `H1PROBE_END` is durably captured after all required families;
- the harness may then terminate the Bochs process;
- such a run must be reported as `COLLECTION_COMPLETE / EMULATOR_TERMINATED_BY_HARNESS`, not as a guest process exit;
- timeout before `H1PROBE_END`, Bochs panic/fatal failure, missing family, or image mutation is FAIL/UNKNOWN according to the observed condition.

## Safety / integrity gates

1. hash the source physical image before launch;
2. copy it into a stable run directory and hash the run copy;
3. configure the floppy write-protected;
4. hash the run copy after execution; it must be unchanged;
5. preserve exact Bochs config, command, PID, start/end timestamps, stdout, stderr, Bochs log, captured E9 stream if separate, and evaluation receipt;
6. preserve Bochs executable SHA-256 and version evidence;
7. do not modify the physical image or the probe source to make Bochs pass.

## Pass meaning

PASS would strengthen the **instrument qualification** by showing that one unchanged physical image collects the preregistered observation families under two independent emulator/firmware stacks.

It would not:

- qualify the HP Pavilion p2-1120 physical H1;
- prove any QEMU or Bochs value is true of H1;
- open C006;
- modify C004/C005 pass counts;
- promote D64-v3, architecture, release, or production status.

## Next-step rule

After reconciliation, inspect any Bochs/QEMU observation differences only as proxy-diversity evidence. A new broad campaign remains forbidden unless physical H1 or another verified input exposes a new responsibility domain or mechanism contradiction that cannot be handled as bounded qualification/integration work.
