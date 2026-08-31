# GitHub publication scratch-space scar — 2026-08-31

Status: **INFRASTRUCTURE SCAR / CANONICAL CONTENT UNAFFECTED**
Canonical commit being published when exposed: `4dccb659284d3f80abb8005bb293035fc0fcf3c4`

## Failure A — async execution wrapper

Attempt to submit `python tools/publish_github_snapshot.py` through the server async-job wrapper returned:

`EXECUTION_SUBMIT_FAILED: job not found`

No publication was started by that call. No canonical mutation followed from it.

## Failure B — publication scratch exhausted source drive

The qualified detached publisher was then started as PID27072 against exact canonical `4dccb659...`.

Verified progress before failure:
- child `git archive` was running against exact captured commit;
- immutable publication TAR grew to about3.19GB;
- source drive E: had only about2.97GB free at the later audit;
- D: had about153GB free.

Publisher terminated with:

`PUBLISH_FAIL: [Errno 28] No space left on device`

Remote publication success was **not** claimed.

## Cause

`tools/publish_github_snapshot.py` placed both its immutable archive scratch and isolated publication mirror under the canonical repository's `.pcmmad_sync_runs/` tree. For the current multi-gigabyte repository, publication can transiently require more space than the canonical source drive has free even though another local drive has ample capacity.

## Correction

Publisher now supports:

`HOSTILE_GITHUB_PUBLISH_SCRATCH_ROOT=<path>`

When supplied, publication archives and isolated mirrors live below that external scratch root while the snapshot source remains exact `git archive <captured canonical commit>` from canonical Git.

For this machine, the rerun uses D: scratch.

## Authority / anti-regression

- This is publication infrastructure only; no science/architecture result changes.
- Canonical Git history remains untouched.
- Research/data must not be dropped to work around storage pressure.
- Publication success still requires exact remote SHA readback.
- External scratch is disposable/reproducible publication transport, not project evidence.
