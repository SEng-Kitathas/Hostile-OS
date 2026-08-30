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

## Attempt 2 — authentication selector stall

After the mirror-cleanup repair, publication attempt 2 started as detached PID `4136`.

Readback showed the process remained responsive but spawned a fresh Git for Windows `git-credential-helper-selector` chain during push. `gh auth status` reported no GitHub CLI login. A bounded `git credential fill` probe then timed out with no trustworthy return and was treated as `UNKNOWN` under the bounded-execution doctrine.

The publication PID and its current credential-helper child chain were terminated explicitly before further mutation. No GitHub publication success was claimed.

Direct Git Credential Manager account listing then established:

- GCM version: `2.9.0+194ba290ce533465310d50f811684ab180536ae7`
- stored GitHub account: `SEng-Kitathas`

Root cause for attempt 2 was therefore the interactive `helper-selector` path in unattended execution, not absence of a stored GitHub account.

Repair:

- publication mirror local Git config uses `credential.helper=manager` on Windows;
- push environment sets `GIT_TERMINAL_PROMPT=0`;
- push environment sets `GCM_INTERACTIVE=Never`.

This makes authentication deterministic: use the stored GCM account or fail fast without opening an interactive selector.

Scientific / architecture consequence remains NONE.

## Pre-retry audit — existing mirror path

Before attempt 3, code review found that the first noninteractive-GCM repair configured `credential.helper=manager` only when creating a new mirror. An already-existing `.github_publish_mirror/.git` returned early from `ensure_mirror()` before that configuration.

This was caught before another push attempt. No additional failed publication occurred.

Repair: the existing-mirror branch now also sets local `credential.helper=manager` on Windows before returning.
