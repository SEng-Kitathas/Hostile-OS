# H1 emulator qualification policy

Status: **ACTIVE / TARGET QUALIFICATION**
Target: H1 HP Pavilion p2-1120

## Purpose

Use more than one emulator implementation to pressure HOSTILE-OS against hidden emulator dependence before physical H1 qualification.

## Backend roles

### QEMU H1 proxy
Primary target-constraint proxy:
- Q35/ICH9 machine approximation;
- AMD `phenom` CPU approximation;
- exactly2 vCPUs;
-4096 MiB;
-500 GiB target disk;
- network disabled for core reviewer work;
- TCG.

It pressures the physical target's coarse envelope but is not an A45/E2-1800 clone.

### Bochs independent replay
Independent x86 execution/firmware/device implementation used to replay the current integrated body.

The installed Windows Bochs3.1 package rejected `cpu count=2` with `n_processors ... out of range 1 to 1`. Therefore this package is **not** a multicore H1 proxy. It is admitted only as a one-CPU independent boot/core/IRQ/persistence semantic witness.

Bochs does not provide QEMU's `isa-debug-exit` device. A Bochs run is successful only when the exact expected terminal trace marker is observed; the host then terminates the emulator. Host termination before the expected terminal marker is never success.

## Required matrix

For the current `d64_reference_v2` generation:
1. QEMU H1 proxy core+IRQ replay must be exact and exit33.
2. Bochs must reproduce the full eight-boot integrated semantic surface:
   - core+IRQ;
   - restart boot1 writable;
   - restart boot2 fresh process/read-only;
   - five faulted-media read-only cases.
3. Restart/fault cases must preserve their disk invariants.
4. Exact boot image/body hash must be recorded.
5. Backend tool path and ceiling must be recorded.

## Authority ceiling

`QEMU_PASS + BOCHS_PASS != H1_PHYSICAL_PASS`

Cross-emulator agreement reduces single-emulator dependence. It does not qualify:
- E2-1800/Bobcat identity or timing;
- AMD A45 FCH;
- HP BIOS/ACPI/PCI tables;
- physical APIC/timer behavior;
- physical SATA/media ordering;
- Radeon HD7340;
- real power/reset behavior.

Those remain H1 physical-probe responsibilities.
