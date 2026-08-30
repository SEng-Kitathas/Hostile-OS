# D64 interrupted-write feasibility result — 2026-08-30

Status: NON-SCIENTIFIC FEASIBILITY / NOT AN ARCHITECTURE RESULT
Parent science: D64/FR01 deterministic faulted-media recovery CLOSED PASS
Source writer inspected: sealed D64/PR01 BIOS one-sector durable write

## Question

Can the existing QEMU/BIOS floppy write path be controlled finely enough to make an actual interrupted-write experiment meaningful, or would a host timing race merely manufacture ambiguous evidence?

## Writer path inspected

PR01's durable writer issues BIOS INT13 AH=03 for one sector. From the sealed controlling PR01 stage2 binary:

- `durable_write` symbol: `0x8368`;
- the actual `int 13h` opcode begins at guest linear address `0x837d`.

QEMU 11.1.0 supports `-S`, GDB remote control, TCG, and `-icount`. A scratch probe used:
- TCG;
- GDB remote breakpoint at `0x837d` immediately before the real BIOS write call;
- `cache=directsync` for the raw floppy image;
- guest single-step through BIOS instructions;
- backing-sector read/hash while QEMU was stopped after each guest instruction.

## First observed transition

Immediately before `int 13h`, durable LBA17 was all zero:

- SHA-256 `076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560`.

For BIOS single-steps 1..546 after entering the call, that sector remained byte-identical to the old all-zero sector.

After single-step **547**, the sector changed directly to the complete PR01 durable-sector image:

- SHA-256 `81f0ef773233ec321a7d649294bf0a6fc549342f2d013486afcc405689f1e004`.

No intermediate/torn sector bytes were observed at any guest-instruction stop point.

## Repeatability pressure

The probe was repeated in five fresh QEMU processes. Every run showed:

- same pre-write zero-sector hash;
- first observed sector change at exactly BIOS step547;
- same complete post-write sector hash `81f0ef...`;
- same first30 bytes of the complete record.

Therefore the observed transition point was **5/5 repeatable** in this local QEMU/BIOS/directsync environment.

## What this does and does not mean

This does **not** prove physical sector atomicity and does not prove QEMU cannot be killed inside its internal device-emulation operation.

It does show that guest-instruction-level stopping exposes one deterministic boundary where media appears whole-old through step546 and whole-new at step547. GDB cannot stop halfway through the host-side device action associated with a single guest instruction.

Therefore a scientifically clean next experiment should first test actual process termination at controlled guest stop boundaries around that transition and then run the already-qualified FR01 recovery reader on the resulting disk. A separate uncontrolled host kill sweep may look for additional states, but it must be classified as stress evidence rather than the controlling discriminator.

If the controlled boundary campaign yields only old/complete-new media, that is a valid result about this QEMU/BIOS transport envelope; it is not a reason to synthesize a torn actual-write result.

## Evidence files

- `gdb_step_result.json` — first detailed breakpoint/single-step transition observation;
- `repeatability.json` — five fresh-process repetitions.

The scratch QEMU disk images/process files are reproducible temporary transport and are not the sole copy of any unique conclusion/evidence after this admission.
