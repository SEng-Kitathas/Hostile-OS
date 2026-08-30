# Per-Turn GitHub Continuity Publication Policy

Adopted: 2026-08-30
Supersedes the weaker cadence phrase “end of every substantive pass” wherever this document is more specific.

## Commander's publication intent

GitHub is the remote reincarnation/time-stamp ledger for the **whole project**, not merely the source tree. A future thread should be able to recover current intent, state, science, scars, history, and next action from Git plus the published continuity package without the operator re-explaining the project.

## Per-turn rule

Every meaningful conversational turn that changes any load-bearing project state SHALL, before the turn is considered durably closed:

1. reconcile the current request with Live Shadow + recent thread + canonical Git state;
2. update `continuity/LIVE_SHADOW.md` if active state changed;
3. append the exchange/state change to `continuity/DESIGN_THREAD_STREAM.md`;
4. update `handoffs/THIS_CONVERSATION.md` or its generation source so the recoverable transcript remains current;
5. update any affected current-state, decision, scar, revisit, authority, or next-step surface;
6. update `handoffs/CURRENT_REINCARNATION/` and its SHA-256 manifest when the handoff truth changed;
7. commit the exact admitted paths to canonical local Git; never use `git add .` as a substitute for adjudication;
8. run `tools/publish_github_snapshot.py` against the captured canonical commit;
9. read back GitHub `refs/heads/main` and require equality with the publication commit before claiming publication;
10. report canonical local SHA and verified GitHub publication SHA.

A meaningful turn includes: new user intent, architecture/science decision, experiment result, correction, failure, scar, authority change, next-step change, tooling/publishing rule, or newly verified status that changes what a new thread should believe.

Tiny turns that truly change no load-bearing state do not need a manufactured science commit. They still must not leave a known stale Live Shadow/DTS/transcript surface.

## Failure behavior

If publication cannot complete:
- preserve the canonical local commit;
- record publication as FAILED or UNKNOWN, never implied success;
- do not rewrite canonical science history merely to satisfy GitHub transport;
- on next reachable turn, publication of the pending canonical commit is the first durability obligation unless immediate safety/recovery work outranks it.

## Full-project publication set

Normal publication includes all canonically admitted:
- `os/`
- `research/`
- `continuity/`
- `handoffs/`
- `authority/` including the original R3.1 archive and exact extracted R3.1 tree
- `lineage/`
- `scars/`
- project tools/infrastructure
- admitted historical payloads and evidence archives
- decision/history/revisit/trace surfaces

Scratch, caches, duplicate worktrees, tool stdout caches, and unexplained files are not automatically project data merely because they exist locally. Unique evidence from scratch must be explicitly admitted or losslessly packaged with hashes.

## OS-only checkout independence

The full publication may be very large. That must never make the R&D dump an installation dependency.

The release/install surface is `os/`. Research/continuity/authority/handoffs/history are prohibited build/install dependencies unless an explicit future operator decision changes the repository contract.

OS-only retrieval must support partial/blobless + sparse checkout with LFS smudge disabled before `os/` is materialized. `INSTALL_FROM_GIT.md` is the operator-facing procedure.

## Full-delta clarification — 2026-08-30

“Per-turn continuity publication” means publication of the **complete admitted project delta** for that meaningful turn, not merely Live Shadow/DTS text. If the turn creates unique source, evidence, review material, logs, raw outputs, reproduction records, or scars, those must be promoted into the canonical tree (or losslessly packaged with hashes) before the turn is durably closed.
