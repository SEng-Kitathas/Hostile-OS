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

## Attempt 3 — inherited helper-chain accumulation

Publication attempt 3 built a complete local publication mirror commit and entered push, but effective Git config readback showed:

- system helper: `helper-selector`
- mirror-local helper: `manager`

Git credential helpers accumulate across config scopes. Adding local `manager` did not suppress the system selector; the helper-selector could still be invoked ahead of GCM.

Attempt 3 was therefore terminated explicitly with its child process tree before any publication success was claimed.

Useful completed local mirror state from attempt 3:

- publication mirror HEAD: `e1ffbc36363ccae52509bdea4ac4de5dfbb7741e`
- canonical local HEAD bound in metadata: `58919fdef1360df50ab878b5159a796aada252f2`
- tracked files snapshotted: `1532`
- tracked bytes before LFS: `185410577`
- research included: `true`
- research required for install: `false`
- LFS path: `payload_history/lab_tooling/HOSTILE_OS_BACKDOOR_004_IA16_TOOLCHAIN.zip`
- LFS object bytes: `115808623`

The public GitHub remote still had no `main` ref at termination.

Repair before attempt 4:

1. mirror-local config now writes an empty `credential.helper` value to reset inherited helper lists;
2. mirror-local config then adds `credential.helper=manager`;
3. public remote probes/clones/readback explicitly run with `-c credential.helper=` so they never invoke authentication helpers;
4. push remains `GIT_TERMINAL_PROMPT=0` + `GCM_INTERACTIVE=Never` and uses direct GCM.

Scientific / architecture consequence remains NONE.

## Attempt 4 — transient mirror indexing race

Publication attempt 4 used the corrected credential-helper reset and reached mirror indexing. Git then failed during `git add -A` with:

`error: open("research/integration/I001/probe/launch_i001.py"): No such file or directory`

`fatal: updating files failed`

Readback after the publisher exited established:

- canonical HEAD remained `1ac99c83e5eaf99435a0d65601f2df931d4d36db`;
- canonical tracked worktree had no tracked modifications;
- canonical `research/integration/I001/probe/launch_i001.py` existed and remained tracked;
- mirror copy of the same file also existed after failure;
- canonical and mirror file SHA-256 matched exactly: `bf4be387c0cd29d662283caa960a7a29619ad9764090c8f05fcfb19a4c25a6a0`;
- the public GitHub remote still had no `main` ref.

The exact transient cause is not proven. The failure is consistent with a shared mutable publication mirror being touched concurrently while indexing, which is plausible in this project because multiple PCMMAD threads/writers can overlap.

Repair removes the shared-workspace assumption entirely:

- every publication process now uses a unique ignored workspace under `.pcmmad_sync_runs/github_publish_mirrors/<canonical-head-prefix>_<pid>`;
- if GitHub `main` already exists, the isolated workspace clones that remote branch before replacing its snapshot, preserving publication history;
- if the remote is empty, the isolated workspace initializes a fresh `main`;
- no two publication processes are expected to mutate the same mirror worktree.

This is a publication-concurrency hardening change. Scientific / architecture consequence remains NONE.

## Bootstrap closure — first verified GitHub publication

After the helper-chain reset and isolated publication-workspace repairs, authentication was separately checked with a bounded `git push --dry-run --no-verify`. That command succeeded for the stored `SEng-Kitathas` Git Credential Manager account. `--no-verify` was used only for the auth diagnostic so the 115.8 MB LFS pre-push transfer would not disguise authentication latency.

A real publication was then launched as a detached bounded process and polled through separate status/readback calls.

Final publisher stdout reported:

- `ok: true`
- canonical local HEAD: `1ac99c83e5eaf99435a0d65601f2df931d4d36db`
- publication HEAD: `d10c6e398ed815b3042ff0f4beee960c2f16f458`
- remote HEAD: `d10c6e398ed815b3042ff0f4beee960c2f16f458`
- publication UTC: `2026-08-30T06:20:17.578219+00:00`
- tracked files: `1532`
- tracked bytes before LFS: `185412381`
- research included: `true`
- LFS path: `payload_history/lab_tooling/HOSTILE_OS_BACKDOOR_004_IA16_TOOLCHAIN.zip`

Independent public remote readback then returned:

`d10c6e398ed815b3042ff0f4beee960c2f16f458 refs/heads/main`

This closes the GitHub publication bootstrap. Future substantive-pass publication remains governed by `continuity/05_GITHUB_PUBLICATION_POLICY.md` and must still require exact remote-head readback before success is claimed.

Scientific / architecture consequence: NONE. This closes publication infrastructure only.
