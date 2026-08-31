# H1 splash-wrapper physical use instructions

Status: **RECOMMENDED THUMB-DRIVE IMAGE / PHYSICAL H1 NOT YET TESTED**

Exact image:
`research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`

Required SHA-256:
`bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`

## What you should see

1. HOSTILE-OS splash artwork in a retro 320x200 VGA presentation.
2. The splash stays visible for about three seconds; any key can skip the wait.
3. Screen returns to BIOS text mode.
4. Probe output starts with `H1PROBE_BEGIN`.
5. CPU, boot, firmware/ACPI, interrupt/APIC, E820 and PCI facts scroll by.
6. Normal end marker: `H1PROBE_END`.
7. The physical build halts there.

Start continuous phone video before power-on. The diagnostic text is longer than one screen, so a single final photo is not enough to preserve the whole packet. A splash-screen photo is welcome, but the continuous video is the primary physical evidence.

## Safety boundary

Writing the image to a USB thumb drive destroys the prior contents of **that USB device**. The booted wrapper/probe itself is read-only with respect to storage:
- stage1 reads its own wrapper sectors;
- splash loader reads its own palette/pixels/probe sectors;
- underlying probe uses only admitted read-only BIOS storage queries;
- no target-disk sector writes;
- no partitioning, formatting or filesystem mutation;
- no PCI BAR/configuration writes;
- no AP startup.

The previous plain no-splash probe image remains preserved and qualified separately. This wrapper does not replace its scientific lineage; it is the recommended human-facing transport image.

## Evidence rule

If the physical HP does not show the expected splash or probe sequence, preserve exactly what it does show. A partial boot or failure is evidence. Do not fill missing physical facts from QEMU or Bochs.
