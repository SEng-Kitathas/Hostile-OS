# H1 Bochs independent-proxy qualification close — 2026-08-31

Status: **CLOSED PASS / INSTRUMENT QUALIFICATION STRENGTHENED / PHYSICAL H1 STILL UNQUALIFIED**

## What changed

The exact physical H1 probe image already qualified under the QEMU H1 proxy was replayed unchanged under Bochs 3.1 using a write-protected floppy and port-E9 capture.

Preregistration seal: `77b91de3878eb6b1164e3805259c34cce2adbf34`.
Harness seal: `d8cc509cdffa3f85503d632e6b597e6e2db307b9`.
Controlling run: `research/targets/H1_PHYSICAL_PROBE/runs/20260831T182218Z_h1_physical_probe_bochs_01`.

The same physical image SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead` was unchanged before/after execution. All preregistered CPU, boot, firmware, IRQ/APIC, E820, PCI and framing families were captured through `H1PROBE_END`.

Because the physical image deliberately halts forever after reporting, the harness then terminated Bochs. The receipt correctly records `COLLECTION_COMPLETE / EMULATOR_TERMINATED_BY_HARNESS`; no guest-exit claim is made.

## Why this matters

Bochs reported materially different CPU detail, ACPI placement, PIC mask, E820 layout and PCI topology from QEMU while the same immutable probe still completed. This is good instrument evidence: success is not tied to QEMU's first observed values.

The differences are proxy diversity, not physical-H1 truth and not a HOSTILE-OS mechanism contradiction.

## Authority ceiling

- physical H1 remains UNQUALIFIED;
- C004/C005 remain CLOSED20/20;
- no C006 is opened;
- D64-v3 is unchanged;
- no architecture/release/production promotion follows.

## Current frontier

The instrument has now passed two independent emulator/firmware stacks. The next load-bearing reality step is the physical H1 boot/probe packet. A broad campaign remains blocked until that packet or another verified input exposes a new responsibility domain or mechanism contradiction.
