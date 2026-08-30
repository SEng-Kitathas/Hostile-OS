# Overnight PR01 Replay / Integrity Campaign — 2026-08-30

Mode: BUILD-COMMIT
Role: R5 Reality Pressure Engine
Status: overnight jobs launched and verified by PID/status readback

## Intent
Use unattended machine time without laundering repetition into new architecture authority.

## Job A — PR01 sealed-fixture replay/soak
- Re-run the already-closed PR01 launcher with fresh run IDs.
- Each iteration creates fresh run-local snapshots and a fresh disk image.
- Stop immediately on first nonzero launcher exit or closure failure.
- Preserve every run directory and a compact journal under `.pcmmad_sync_runs/overnight_2026-08-30/`.
- Maximum wall duration: 8 hours.
- Reliability/replay evidence only; no new numbered science passes.

## Job B — read-only integrity/provenance sweep
- `git fsck --full`
- `git lfs fsck` when Git LFS is available
- scan persistence run receipts/audits for parseability and closure consistency
- no project mutation other than logs under `.pcmmad_sync_runs/overnight_2026-08-30/`

## Stop / truth rules
- Missing process return or missing closure artifact is UNKNOWN, never PASS.
- A replay mismatch stops Job A and preserves the failing run.
- Job status is reported only after explicit PID/process readback.
- Large logs remain server-side.
- GitHub publication is a separate explicit publication step with remote SHA readback.

## Launch readback
- Existing full-chain regression campaign: PID `24520` (child `24156`), RUNNING. Covers A01/RK01/RB02/ARB01/RR01/IRQ01/I001 from detached canonical `0f1146f...`; sampled cycles PASS.
- PR01 sealed-fixture soak: PID `29312`, RUNNING under `.pcmmad_sync_runs/overnight_2026-08-30/`; immutable worktree commit `50e33085805d3bb5b74eba4df1ca23683c8d0283`; iteration 1 launcher/evaluator/static/audit PASS; successful full-run retention first + every 20th, compact journal for all; stop on first mismatch.
- Read-only integrity/provenance sweep: PID `27376`, RUNNING under the same ignored overnight directory; first `git fsck --full --strict`, `git lfs fsck`, critical JSON parse/closure, and GitHub remote readback sweep PASS. Sweep interval 300 seconds.

These lanes are reliability/control evidence only unless separately reviewed. They do not silently expand architecture authority.
