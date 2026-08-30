# Overnight PR01 Replay / Integrity Campaign — 2026-08-30

Mode: BUILD-COMMIT
Role: R5 Reality Pressure Engine
Status: ACTIVE — both detached overnight jobs verified running

## Intent
Use unattended machine time without laundering repetition into new architecture authority.

## Job A — PR01 sealed-fixture replay/soak
- Re-run the already-closed PR01 launcher with fresh run IDs.
- Each iteration creates fresh run-local snapshots and a fresh disk image.
- Stop immediately on first nonzero launcher exit or closure failure.
- Preserve every run directory and a compact journal under `.pcmmad_sync_runs/overnight_2026-08-30/`.
- Maximum wall duration: 8 hours.
- Cadence: 120 seconds.
- Maximum iterations: 240.
- Reliability/replay evidence only; no new numbered science passes.

## Job B — read-only integrity/provenance sweep
- `git fsck --full`
- `git lfs fsck` when Git LFS is available
- scan persistence run receipts/audits for parseability and closure consistency
- compare new closure failures against startup baseline so historical scars remain visible without poisoning the overnight monitor
- no project mutation other than logs under `.pcmmad_sync_runs/overnight_2026-08-30/`
- Maximum wall duration: 8 hours.
- Cadence: 1800 seconds.

## Stop / truth rules
- Missing process return or missing closure artifact is UNKNOWN, never PASS.
- A replay mismatch stops Job A and preserves the failing run.
- Job status is reported only after explicit PID/process readback.
- Large logs remain server-side.
- GitHub publication is a separate explicit publication step with remote SHA readback.

## Launch readback — 2026-08-30 06:45 UTC
- Job A PR01 soak launched detached as PID `27700` using Python 3.14.
- Job A iteration 1: PASS, return code 0, Boot1/Boot2 exit 33, evaluator/static/audit PASS, failures 0.
- Job B integrity monitor launched detached as PID `3624` using Python 3.14.
- Job B cycle 1: `git fsck --full` exit 0; `git lfs fsck` OK; no new PR01 closure failures relative to startup baseline.
- Historical failed PR01 runs remain visible but are baseline scars, not overnight failures.
- Canonical launch checkpoint before this readback update: `e7810ebbbf4d04fb682384e318f15c0c9e775aa4`.
- Verified GitHub publication of that checkpoint: remote `4f9d99516165498f35a0a283a740de2a17681454`.

## Maintenance scar
A write intended as an append replaced this note's earlier body before commit `fab3e80`. The replacement was detected from the Git commit summary (`10 insertions, 35 deletions`). This revision restores the full campaign intent and preserves the launch readback instead of rewriting history silently.
