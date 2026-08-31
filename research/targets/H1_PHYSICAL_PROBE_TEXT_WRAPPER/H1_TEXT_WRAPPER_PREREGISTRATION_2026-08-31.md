# H1 text-only wrapper preregistration — 2026-08-31

Status: **PREREGISTERED AFTER PHYSICAL SPLASH-TRANSPORT FAILURE / BEFORE TEXT-WRAPPER EXECUTION**

Physical trigger: operator reports that selecting the qualified splash-wrapper USB on physical H1 caused the attached TV to report `NO SIGNAL` immediately after boot handoff. No thumb-drive log exists because the physical probe is read-only and does not persist output.

This result is evidence of a physical display/transport incompatibility, not yet proof of the exact failing instruction. The leading discriminator is the splash wrapper's explicit BIOS switch to VGA mode 13h (`INT 10h AX=0013h`).

## Question

Can the same hardened dual BIOS USB transport and exact qualified probe stage2 boot physical H1 while preserving the firmware-selected display mode and avoiding every explicit video-mode transition?

## Required implementation

- separate wrapper; do not modify D64-v3 or qualified probe stage2;
- preserve the splash wrapper's EDD-first / CHS-fallback disk reader;
- no VGA mode 13h, no mode 3 reset, no DAC programming, no direct framebuffer writes;
- BIOS teletype output only, in the firmware's existing video mode;
- visible marker before probe chain: `H1TEXT_WRAPPER_OK`;
- exact qualified physical/QEMU probe stage2 bytes embedded;
- no disk writes;
- physical image remains 1.44 MB for the current raw-write workflow.

## Emulator qualification

Before physical use:
- clean committed source required;
- static audit must prove no explicit `INT 10h` mode-set AX values and no VGA DAC/framebuffer writes;
- floppy/CHS QEMU boot must reach `H1TEXT_WRAPPER_OK`, `H1PROBE_BEGIN`, and `H1PROBE_END`;
- IDE/EDD QEMU boot must reach the same markers;
- backing image must remain unchanged;
- exact physical image SHA-256 must be recorded.

## Physical interpretation

If this text-only wrapper keeps the TV synchronized and prints, the splash graphics transition is strongly implicated.

If the TV still loses signal before text appears, the failure lies earlier or deeper than the explicit graphics-mode transition; that result must be preserved rather than guessed across.
