# H1 physical-probe splash wrapper preregistration — 2026-08-31

Status: **PREREGISTERED / NOT YET QUALIFIED**
Nature: presentation/boot-transport wrapper around the already-qualified H1 physical probe; not a new science campaign, not C006, not D64-v3.

## Purpose

Show the commander-supplied HOSTILE-OS artwork as a BIOS-era boot splash, then transfer control to the exact already-qualified H1 probe stage2 without changing that probe's mechanism bytes.

## Source artwork provenance

Inbound file: `Gemini_Generated_Image_ebf7omebf7omebf7.jpg`

- source dimensions: 1408x768 RGB;
- source bytes: 822,945;
- source SHA-256: `c7e5d0b83ddbd74cdf1291e7e68bbabd418d7c89ed42ada96204392e4630dc63`.

The source JPEG itself is not duplicated into the science repository. The repository carries the exact derived VGA payload and its conversion recipe/provenance.

## VGA conversion contract

- target mode: BIOS VGA mode 13h, 320x200 indexed color;
- source is aspect-fit to 320x175 using Lanczos and letterboxed at y=12 on a black 320x200 canvas;
- quantization: Pillow median-cut, 32 colors, no dithering;
- DAC representation: first 32 palette entries, RGB values mapped from 8-bit to 6-bit VGA values by `round(v*63/255)`;
- palette payload: 96 bytes, SHA-256 `c0056796d5c7ec2cb5edc95510b66a058a1705e7dcc1dc3ec750b2f511526744`;
- pixel payload: 64,000 bytes, SHA-256 `c1467575fe43e5b4b466cf27be0997ad97a12496bbfd49e39057038005ac845f`.

## Wrapper architecture

The splash SHALL remain outside the qualified probe stage2.

Disk layout, starting at LBA 0:
- LBA 0: wrapper boot sector;
- LBA 1..8: splash loader reserved envelope (4 KiB);
- LBA 9: palette sector (96 bytes + zero padding);
- LBA 10..134: 125 raw pixel sectors (64,000 bytes exactly);
- LBA 135..150: exact qualified probe stage2 envelope (16 sectors / 8 KiB), physical or QEMU variant depending on image target.

The wrapper boot sector SHALL load only the splash loader and transfer control to it. The splash loader SHALL later load the exact probe stage2 to linear 0x8000 and far-jump there with the BIOS boot drive preserved in DL.

## BIOS-drive mapping requirement

The image SHALL be qualified under both common legacy BIOS presentations:

1. floppy-like boot (`DL=00` / QEMU floppy path);
2. hard-disk-like boot (`DL=80` / QEMU IDE path).

The first-stage splash-loader read is restricted to sectors 2..9 of cylinder 0/head 0 so it does not depend on later track geometry. The splash loader SHALL prefer INT13 extensions (AH=42) when available and otherwise fall back to one-sector CHS reads using geometry reported by INT13 AH=08.

## Display behavior

1. enter VGA mode 13h;
2. load/set the 32-entry palette;
3. load the 64,000-byte pixel frame directly into A000:0000;
4. emit `H1SPLASH_VISIBLE` to debug port 0xE9 for emulator qualification;
5. hold the splash for about 3 seconds, or continue early on any keypress;
6. restore BIOS text mode 03h;
7. load the exact qualified probe stage2;
8. emit `H1SPLASH_CHAIN_PROBE` to debug port 0xE9;
9. jump to probe stage2.

The physical screen SHALL not require debug-port support.

## Safety boundary

The wrapper SHALL perform only reads from its own removable-media image. It SHALL NOT write the USB after boot, write the target disk, modify PCI configuration, reprogram APIC/PIC state, or alter D64-v3.

## Qualification gate

Before this wrapper becomes the recommended thumb-drive image:

- wrapper source/assets are committed;
- loader fits its reserved 4 KiB envelope;
- exact underlying physical probe stage2 hash is recorded and unchanged from the qualified probe build;
- exact underlying QEMU probe stage2 hash is recorded for emulator runs;
- resulting physical image is hash-bound;
- QEMU floppy-like boot reaches `H1SPLASH_VISIBLE`, chains to the probe, and reaches `H1PROBE_END`;
- QEMU hard-disk-like boot does the same;
- a QEMU framebuffer screendump taken while the splash is visible matches the derived VGA frame;
- static audit shows no disk-write BIOS function in the wrapper;
- physical H1 remains unqualified until actual hardware boot.

Any failure is a wrapper/transport result, not a demotion of the already-qualified underlying probe.
