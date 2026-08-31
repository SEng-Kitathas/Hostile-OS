# H1 durable-log physical use

Status: **READY FOR PHYSICAL RETEST**

Write this exact image to the SanDisk:

`research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG/package/h1_probe_durable_log_physical.img`

Initial image SHA-256:
`ddf9ceec0b97ed8014874e11e804716867ad0956eaa980085373bb803e9a6cca`

This descendant intentionally writes **only** its reserved journal region on the boot USB (LBAs 256..383). The HP internal disk remains outside the write path.

## On H1

Boot the SanDisk once. The wrapper preserves the firmware-selected text/video mode; there is no mode-13h splash transition.

If the TV shows output, photograph/video it as before. If the TV reports NO SIGNAL, that no longer destroys the evidence path: let the machine run for about 30 seconds, then power it off.

Do not boot the same image repeatedly before extracting the journal unless necessary; each boot begins a new session at the same journal base and can overwrite the previous session.

## Recover journal on the dev machine

Plug the SanDisk back into the dev machine. Identify its current `PhysicalDriveN` by model + serial; do not assume it will still be PhysicalDrive3.

From an elevated PowerShell in the staged repository, run:

`python research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG/package/extract_log.py '\.\PhysicalDriveN'`

The extractor reads raw sectors directly; no filesystem or drive letter is required.

A valid packet begins with `H1LOG_BEGIN`. If execution reaches the probe it includes `H1PROBE_BEGIN`. A complete run ends with `H1PROBE_END`.

The last valid durable line is the evidence boundary if the run stops early.
