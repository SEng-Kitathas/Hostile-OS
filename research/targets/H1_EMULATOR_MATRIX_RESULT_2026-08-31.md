# H1 emulator matrix result — current D64-v2 body

Status: **CLOSED PASS / CROSS-EMULATOR QUALIFICATION AT STATED CEILINGS**
Matrix implementation commit: `3f216af`
Controlling run: `research/targets/H1_EMULATOR_REPLAYS/runs/20260831T053017Z_h1_emulator_matrix_01`

## Exact body identity

- source Git HEAD: `3f216afb3187b9c4a1b7e0db2d4a8859681238f5`
- `os/research_only/d64_reference_v2` Git tree: `03af56020afe6d117836133c0e33092d098fc13e`
- base disk SHA-256: `ce19f42e6e74fc9b0b3db09a1bb9af11d9a05126762e34079e80034d0606b06c`

## QEMU H1 constraint proxy

PASS:
- machine `pc-q35-11.1`;
- CPU model `phenom`;
-2 vCPU (`1 socket /2 cores /1 thread`);
-4096 MiB RAM;
-500 GiB target disk present;
- current core trace exact;
- current IRQ trace complete;
- guest exit33.

This is the coarse H1 envelope proxy, not E2-1800/A45 identity.

## Bochs independent replay

Installed binary:
`C:\Program Files\Bochs-3.1\bochs.exe`

SHA-256:
`a59871b4cae1f8f7729eeb1419ec25e15543641b348bc32f712946d8fb04b1bb`

The installed Windows Bochs3.1 package rejects CPU count2 with:
`n_processors was set to 2, which is out of range 1 to 1`.

Therefore Bochs is **not** admitted as an H1 dual-core proxy. It is a one-CPU independent x86 semantic replay witness.

From the same exact D64-v2 body, Bochs PASSed all current integrated reviewer boots:
- core + real IRQ exact through `IRQ_DONE`;
- restart Boot1 exact and wrote expected A candidate;
- restart Boot2 exact from a fresh emulator process;
- restart B remained zero after Boot1;
- no host write occurred between restart boots;
- recovery Boot2 left disk unchanged;
- faulted-media `old_empty` exact/read-only;
- `newer_valid` exact/read-only;
- `newer_corrupt` exact/read-only;
- `equal_conflict` exact/read-only;
- `both_invalid` exact/read-only.

Bochs lacks QEMU's `isa-debug-exit` device. Success therefore requires the exact terminal guest trace first; the matrix runner host-terminates Bochs only after `IRQ_DONE` or `PERSIST_DONE` is observed. Host termination itself is not success authority.

## Earned

The current D64-v2 boot/core/IRQ/restart/faulted-media semantics are no longer QEMU-only observations: the full eight-boot semantic surface reproduced under a second independently implemented x86 emulator at the stated one-CPU Bochs scope.

This reduces single-emulator dependence and gives H1 development two different execution witnesses.

## Not earned

`QEMU_PASS + BOCHS_PASS != H1_PHYSICAL_PASS`.

No claim is made for:
- exact AMD E2-1800/Bobcat behavior;
- AMD A45 FCH;
- HP BIOS/ACPI/PCI identity;
- Bochs SMP for this package;
- physical two-core timing/order;
- real SATA/media ordering;
- Radeon HD7340;
- real power/reset/fault behavior.
