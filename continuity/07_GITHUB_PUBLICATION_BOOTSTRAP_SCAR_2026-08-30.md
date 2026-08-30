# GitHub publication bootstrap scar — 2026-08-30

## Attempt

Canonical local HEAD at first publication submission intent:

`200555a` (`Adopt bounded execution and recovery doctrine`)

The preferred async project-job route failed at submission with:

`EXECUTION_SUBMIT_FAILED / job not found`

A separate job-list readback failed with the same control-path error. Server health remained `online`; scheduler/capabilities remained present. Publication state was therefore treated as `UNKNOWN` until direct process inspection.

## Bounded fallback

A detached publication process was started with terminal prompts disabled and stdout/stderr redirected under canonical `.pcmmad_sync_runs/`.

Process PID: `7432`.

The process exited before any successful publication claim. Stderr reported:

`PUBLISH_FAIL: [WinError 32] The process cannot access the file because it is being used by another process: ... .github_publish_mirror\\.pcmmad_sync_runs\\...stderr.log`

Subsequent readback established:

- PID 7432 exited;
- canonical `.pcmmad_sync_runs/**` has zero tracked files;
- the publication mirror contained its own ignored `.pcmmad_sync_runs/` runtime scratch directory;
- no GitHub publication success had been established.

## Root cause

`tools/publish_github_snapshot.py::clear_worktree()` deleted every mirror worktree child except `.git`.

The PCMMAD execution surface can create ignored runtime scratch/log files inside `.github_publish_mirror/.pcmmad_sync_runs/` while publication-related subprocesses use that mirror. On Windows an active log may be locked, making unconditional recursive deletion fail.

This is a publication/control-plane cleanup defect, not canonical project corruption and not a GitHub transport rejection.

## Repair

`clear_worktree()` now preserves both:

- `.git`
- `.pcmmad_sync_runs`

The scratch directory remains ignored and SHALL NOT be staged or published. Canonical tracked-file snapshot semantics are unchanged.

## Scientific / architecture consequence

NONE.

This scar affects publication infrastructure only.
