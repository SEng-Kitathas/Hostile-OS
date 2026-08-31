# H1 — HP Pavilion p2-1120 first physical target

Status: **ADOPTED TARGET / VM CONSTRAINT PROXY QUALIFIED / PHYSICAL PROBE PENDING**
Date: 2026-08-31
Purpose: make the operator's dormant HP Pavilion p2-1120 the first real HOSTILE-OS hardware target and pressure development against its constraints before physical deployment.

## Verified model facts

Operator-supplied chassis image identifies the machine as HP Pavilion p2-1120 PC, product family corresponding to HP product H2L67AA#ABA. Do not record the chassis serial in project state.

HP's published p2-1120 data sheet reports:
- AMD E2-1800 Accelerated Processor, 1.70 GHz;
- AMD A45 FCH chipset;
- 1 MB L2 cache;
- 4 GB PC3-10600 DDR3-1333 SDRAM, 1x4 GB, expandable to 8 GB;
- 500 GB Serial ATA hard drive;
- AMD Radeon HD 7340 graphics;
- 10/100Base-T network;
- 6 USB 2.0 ports total;
- VGA and DVI outputs;
- SuperMulti DVD burner;
- original OS: Windows 7 Home Premium 64-bit.

AMD's E2-1800 specification reports 2 CPU cores / 2 threads, 1.7 GHz, 1 MB L2, 18 W TDP and Radeon HD 7340 graphics.

## H1 target constraints adopted now

Development SHALL continuously preserve a runnable H1 proxy path with:
- x86-64-capable machine envelope;
- exactly 2 vCPUs, one socket, two cores, one thread/core;
- 4096 MiB guest RAM by default;
- legacy PC firmware/BIOS boot path;
- 500 GiB virtual target-disk capacity available;
- no dependency on network availability for core boot/reviewer operation;
- current HOSTILE-OS boot/reviewer path must remain usable without graphics acceleration.

These are target pressure constraints, not claims of exact hardware emulation.

## QEMU proxy

Current qualified proxy:
- QEMU 11.1.0 `qemu-system-x86_64`;
- TCG acceleration;
- machine `pc-q35-11.1`;
- CPU model `phenom`;
- `-smp 2,sockets=1,cores=2,threads=1`;
- `-m 4096`;
- SeaBIOS/QEMU legacy firmware path;
- 500 GiB qcow2 target disk attached as IDE under the Q35 proxy;
- current D64-v2 reviewer boot remains a floppy transport only for the present research generation.

Qualified smoke result on 2026-08-31:
- current `d64_reference_v2` build reproduced stage1 512 bytes, stage2 raw 3845 bytes, linked memory 7440/8192;
- H1 q35/x86_64 proxy with 2 vCPU + 4096 MiB booted current core reviewer and exited 33;
- same proxy with a 500 GiB qcow2 target disk attached also exited 33;
- QEMU warns that TCG does not support requested `fxsr-opt` from the `phenom` CPU model. This is an emulation-model warning and part of the proxy fidelity ceiling.

## Explicit non-fidelity

QEMU does **not** provide an exact HP p2-1120 clone. In particular:
- `phenom` != AMD E2-1800 CPU identity;
- Q35/ICH9 != AMD A45 FCH chipset;
- generic/emulated video != Radeon HD 7340;
- QEMU TCG timing != physical 1.70 GHz performance;
- attached IDE presentation != proof of the physical A45 SATA controller programming model;
- NIC/audio/USB controller identities are not yet physically measured;
- BIOS/ACPI/PCI tables are proxy tables, not the HP firmware's tables.

Therefore:

`H1_VM_PROXY != H1_PHYSICAL_MACHINE`

The proxy is for early constraint pressure and repeatable development. Physical qualification remains authoritative for hardware-specific claims.

## Physical probe required later

Before first destructive install, collect a non-destructive H1 hardware packet from the real machine:
- CPUID/vendor/family/model/features;
- PCI vendor/device/class IDs and BARs;
- firmware/BIOS identity and memory map;
- ACPI tables if used;
- storage-controller identity/mode;
- USB controller IDs;
- NIC ID;
- audio ID;
- display adapter ID/aperture details;
- RAM map and usable-memory ceiling;
- boot-device behavior from removable media;
- timer/APIC/interrupt-controller observations.

That packet will replace proxy assumptions one by one. It is a future operator/hardware-touch blocker, not a blocker on current VM development.

## Engineering rule

New HOSTILE-OS work should prefer surviving the H1 constraint proxy unless the experiment explicitly requires a different fixture. Do not optimize only for the high-end development workstation and hope to down-port later.

## Multi-emulator qualification lane

The durable emulator matrix is defined by:
- `research/targets/H1_HP_PAVILION_P2_1120_EMULATOR_MATRIX_V2.json`;
- `research/targets/H1_EMULATOR_QUALIFICATION_POLICY_2026-08-31.md`;
- `tools/run_h1_emulator_matrix.py`.

QEMU remains the only currently qualified two-vCPU H1 constraint proxy. The installed Bochs3.1 Windows package is limited to one processor and is therefore used only as an independent full-body semantic replay/debug witness. Cross-emulator agreement does not substitute for physical H1 qualification.

## Current cross-emulator result

`research/targets/H1_EMULATOR_MATRIX_RESULT_2026-08-31.md` is CLOSED PASS from `research/targets/H1_EMULATOR_REPLAYS/runs/20260831T053017Z_h1_emulator_matrix_01`.

The exact current D64-v2 eight-boot semantic surface reproduced under Bochs at one-CPU scope, while the QEMU H1 proxy remains green at the target-shaped two-vCPU/4GiB/500GiB envelope. Bochs package SMP is unavailable in the installed build, so only QEMU currently supplies virtual two-core H1 pressure.

## C005/P20 target-shaped concurrency evidence

C005/P20 ran its hard-stop two-CPU release-provenance discriminator under the H1 QEMU constraint proxy (`pc-q35-11.1`, `phenom`, 2 vCPU, 4096 MiB, TCG) and passed exactly.

This strengthens target-shaped emulator continuity but does not change the target authority law:

`QEMU_H1_PROXY_PASS + BOCHS_REPLAY_PASS != H1_PHYSICAL_PASS`.

The physical machine remains the authority for real E2-1800/A45/HP firmware, PCI/ACPI, interrupt, storage and timing behavior.
