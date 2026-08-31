# GitHub publication policy

Date adopted: 2026-08-30
Operator instruction: publish HOSTILE-OS to GitHub and push again at the end of every substantive pass.
Remote: `https://github.com/SEng-Kitathas/Hostile-OS.git`

## Purpose

GitHub is a dated publication ledger for the project as a whole, not only a code drop.

The published snapshot SHALL include the tracked research/evidence tree as well as project code, continuity, authority, lineage, scars, infrastructure source, and historical payloads admitted to canonical Git.

## Canonical history versus publication history

The local `HOSTILE_OS` Git repository is the canonical engineering/science history.

An existing historical payload in that canonical history exceeds GitHub's normal 100 MB Git-blob limit. Canonical history SHALL NOT be rewritten merely to satisfy hosting limits because experiment and continuity artifacts cite canonical commit IDs.

GitHub therefore uses a publication-mirror history:

1. commit the canonical local pass first;
2. snapshot all canonically tracked files into the GitHub publication mirror;
3. represent oversized payload files through Git LFS in the publication mirror;
4. write `.github-publication-source.json` containing the exact canonical local HEAD and UTC publication time;
5. commit the publication snapshot;
6. push `main` to GitHub;
7. read back remote `refs/heads/main` and require equality with the publication commit before claiming success.

The publication mirror is a chronological project ledger. Its commit SHA is not a substitute for the canonical local commit SHA. The metadata file binds the two surfaces.

## Substantive-pass rule

At the end of every substantive pass:

- canonical local mutations must be committed or explicitly left uncommitted with reason;
- if the pass changed load-bearing project state, run `tools/publish_github_snapshot.py`;
- report both the canonical local HEAD and verified GitHub publication HEAD;
- if push fails, report the failure exactly and leave the local canonical state intact;
- do not claim GitHub publication until remote readback confirms it.

Tiny conversational turns that create no project-state change do not require a new publication commit.

## Research inclusion rule

The full tracked `research/` tree is part of normal GitHub publication.

Research SHALL NOT be stripped merely to produce a smaller archive. Research is the evidence/history surface of this project.

Local scratch, downloaded toolchains, drive-wide scan dumps, and `.pcmmad_sync_runs/` are not automatically research evidence and remain excluded unless explicitly admitted into canonical Git.

## Install/build independence rule

A released HOSTILE-OS must not require `research/` to be checked out.

The installable system surface lives under `os/`.

Anything required for a released build/install must either live under `os/` or be fetched explicitly by versioned logic under `os/`.

`INSTALL_FROM_GIT.md` defines the sparse/partial-clone route that checks out `os/` without pulling research blobs.

## LFS rule

The publication mirror may use Git LFS for oversized historical payloads. LFS use is a transport/storage adaptation only; it does not promote those payloads to architecture authority.

## Failure rule

Do not rewrite canonical scientific Git history, squash experiment lineage, delete scars, or silently drop admitted research solely because GitHub rejects a transport detail. Adapt the publication surface instead and preserve the canonical hashes.

## Publication workspace isolation rule

Publication mirror worktrees are per-run scratch, not shared mutable project state.

Each publication SHALL use an isolated ignored workspace under:

`.pcmmad_sync_runs/github_publish_mirrors/<canonical-head-prefix>_<pid>/`

If remote `main` exists, the isolated workspace clones it first so the GitHub publication ledger remains chronological. If remote `main` does not exist, the isolated workspace initializes a fresh `main`.

Separate PCMMAD threads/processes SHALL NOT reuse one mutable publication worktree. This prevents mirror cleanup/copy/index races from one publication corrupting another publication attempt.

The isolated workspace itself is never project content and SHALL NOT be staged into canonical Git or the GitHub publication snapshot.

## Exact-commit snapshot rule

The publication unit is an immutable canonical Git commit, not the moving canonical worktree.

At publication start:

1. capture canonical `HEAD` as `canonical_local_head`;
2. require the tracked index/worktree to be clean for that pass;
3. export exactly that captured commit from the Git object database with `git archive <canonical_local_head>` into an isolated publication workspace;
4. build the publication snapshot/LFS commit from that exported tree;
5. record both the captured canonical commit and the canonical HEAD observed after export;
6. if canonical `main` advances concurrently, do **not** invalidate the already-captured publication. Mark `canonical_advanced_during_publication=true`; the later canonical commit becomes a separate publication obligation;
7. publication success still requires publication-mirror HEAD == GitHub remote `main` readback.

This rule prevents concurrent writers from changing the files underneath a publication snapshot while preserving exact canonical lineage.

## Per-turn continuity publication amendment — 2026-08-30

Operator instruction supersedes the older “end of every substantive pass” cadence with a stronger per-turn continuity rule. See `continuity/11_PER_TURN_GITHUB_CONTINUITY_POLICY.md`.

Every meaningful turn that changes load-bearing intent/state/evidence/decisions/scars/authority/next actions must update the Live Shadow, Design Thread Stream, recoverable conversation/handoff surfaces, commit the exact admitted delta, publish the captured canonical commit, and verify remote GitHub `main` readback before that turn is durably closed. Tiny turns with genuinely no state change need not manufacture an engineering commit.

This amendment does not weaken the exact-commit snapshot, isolated-workspace, non-force-push, LFS transport, or OS-install-independence rules above.

## Whole-project durability clarification — 2026-08-30

Operator clarified “full project snapshot” as **all unique project data**, not only selected research/code surfaces. See `continuity/13_DURABLE_REPOSITORY_AND_RESEARCH_OS_POLICY_2026-08-30.md` and `PROJECT_TREE.md`.

At each meaningful turn, unique new project data from execution scratch, donor review, recovery scans, failed runs, or reproduction work must be admitted into the canonical folder tree or losslessly archived with hashes before publication. `.pcmmad_sync_runs/` is execution scratch, never the sole durable home of unique evidence.

Exact duplicates/caches/process breadcrumbs are not required as redundant Git copies, but a load-bearing failure/disposition must be recorded before cleanup.

## Publication scratch capacity / external-root rule — 2026-08-31

A full immutable publication can transiently require space for both a canonical `git archive` and an isolated publication mirror. Publication scratch therefore SHALL NOT be assumed to fit on the canonical repository drive.

`tools/publish_github_snapshot.py` supports `HOSTILE_GITHUB_PUBLISH_SCRATCH_ROOT`. When set, archive and mirror scratch live under that root while the canonical source remains the captured Git commit.

Disk-space pressure is a transport problem. It SHALL NOT be solved by dropping admitted research, rewriting canonical science history, or weakening whole-project publication.

The 2026-08-31 E:-drive exhaustion is recorded in `scars/GITHUB_PUBLICATION_SCRATCH_SPACE_SCAR_2026-08-31.md`.
