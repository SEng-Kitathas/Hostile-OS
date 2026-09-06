# H1 BIOS USB read discriminator physical result 09 — firmware drive parameters — 2026-08-31

Status: PHYSICAL RUN COMPLETE / PARAMETER PACKET DID NOT PERSIST

## Preregistered question
What geometry and EDD parameters does the H1 firmware advertise for the BIOS-selected boot device after READ4–READ8 reported successful reads without changing the tested destination buffer?

## Physical medium identity
Readback was accepted only after the hard identity guard resolved exactly one device:
- model: `SanDisk Extreme Pro`
- serial: `0FDC87754321`
- bus: `USB`
- size: `128043712512`
- IsBoot: `false`
- IsSystem: `false`
- resolved device at readback: `\\.\PhysicalDrive3`

## Raw physical readback
Captured LBA257 exactly once after the physical boot into:
`physical_runs/20260831_h1_read9_01/lba257.bin`

Observed:
- bytes: `512`
- nonzero bytes: `0`
- SHA-256: `076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560`
- `H1READ9_PARAMS`: absent

The captured sector is exactly all zero.

## Earned interpretation
READ9 does **not** yield a physical AH=08/AH=48 parameter packet and therefore does not answer the preregistered geometry/EDD question.

Because earlier sector-0 discrimination physically established that AH=41 + AH=43 can persist a result to LBA257 on this same H1 boot-device path, the all-zero READ9 result localizes the new seam to the READ9 execution/writeback chain rather than establishing that LBA257 is generally unwritable.

The current physical evidence does not distinguish among:
- failure/non-return of AH=08;
- state corruption or unexpected register/segment mutation across AH=08;
- failure/non-return of AH=48;
- state corruption or unexpected register/segment mutation across AH=48;
- failure of the final AH=41/AH=43 writeback only after those calls;
- another execution-local effect not yet instrumented.

No geometry, bytes-per-sector, total-sector count, or interface/device-path field may be inferred from this run.

## Next discriminator
Use one physically proven LBA257 as a sequential overwrite breadcrumb surface from sector 0:
1. persist `H1READ10_ENTER` before AH=08;
2. persist `H1READ10_AH08_RETURN` immediately after AH=08 returns;
3. persist `H1READ10_AH48_RETURN` immediately after AH=48 returns;
4. persist the full parameter packet last.

Reassert the required local segment state before each breadcrumb/result construction so the experiment tests control-flow return separately from accidental reliance on BIOS register preservation.

Only the last successfully persisted overwrite matters; the marker therefore identifies the furthest physically demonstrated point.
