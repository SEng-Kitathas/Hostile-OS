# D64 PR01 Overnight Reliability Replay — 2026-08-30

Status: COMPLETED / RELIABILITY PASS
Science authority: replay/reliability only; no new architecture passes.

## Controlling mechanism
The replay used the already-closed PR01 two-clean-boot fixture/launcher. Each iteration created fresh run-local controlling-input snapshots and a fresh disk image, then executed the same sealed discriminator through two distinct QEMU processes.

## Terminal result
- 240 / 240 iterations completed
- 0 failures
- soak process terminal state: `COMPLETED`
- configured cadence: 120 seconds
- maximum iterations: 240
- approximately eight-hour wall campaign
- every completed iteration returned launcher success and the PR01 evaluator/static/independent closure passed

Final iteration: `20260830T144334Z_d64_pr01_overnight_0240`.

## Meaning
This materially increases confidence that the tested PR01 clean-restart consequence is repeatable under the exercised host/QEMU conditions. It does not expand the scientific authority ceiling. It does not earn crash/power-loss consistency, filesystem semantics, unlimited-reboot claims, stronger concurrency, physical hardware, or final architecture promotion.

## Evidence transport
The complete raw 240-run directory corpus is preserved as an admitted lossless archive with a per-file SHA-256 manifest under `research/persistence/D64_PR01/overnight_archive/`. The bulk archive is expected to be transported by GitHub publication LFS so OS-only sparse checkout does not download it.
