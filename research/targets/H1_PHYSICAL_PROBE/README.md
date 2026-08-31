# H1 physical qualification probe

Purpose: prepare a non-destructive removable-media observation instrument for the first physical HOSTILE-OS target, HP Pavilion p2-1120 H1.

This is **not C006**, not D64-v3, and not architecture promotion. It is a separate qualification instrument.

## Safety posture

The physical image:
- boots through legacy BIOS;
- reads its own removable-media sectors through INT13h AH=02 in stage1;
- uses only read-only INT13h AH=08/AH=41 queries after stage2 starts;
- reads CPUID, E820, PCI configuration, PIC masks and APIC-base capability/state;
- scans EBDA/high BIOS memory for the ACPI RSDP signature;
- writes no target-disk sectors, partition tables, filesystems, PCI BARs/configuration data, APIC/PIC state, or firmware;
- does not start the second core;
- halts after reporting.

The QEMU-only build has one extra emulator-exit write to I/O port `0xF4`. The physical build does not contain that sequence.

## Output

Records are emitted to both BIOS VGA teletype and QEMU debug port `0xE9`.

Required framing:

`H1PROBE_BEGIN`

... observation records ...

`H1PROBE_END`

For a physical run, record the complete screen output with continuous phone video from before boot until `H1PROBE_END`; the output may exceed one VGA screen. Do not rely on memory or transcription alone.

## Build

Use the same qualified LLVM path used by current HOSTILE-OS research tooling, then run:

`python build.py`

Outputs under ignored `build/` include:
- `h1_probe_physical.img` — removable-media physical image;
- `h1_probe_qemu.img` — emulator qualification image;
- `build_manifest.json`.

Run `python verify_static.py` after build.

## Physical use gate

Do not boot the HP from this image until the committed implementation has a qualified QEMU run receipt and the physical image hash is recorded in the qualification result.

A physical run may produce a partial packet. Missing fields remain UNKNOWN; do not fill them from QEMU.
