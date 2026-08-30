# HOSTILE-OS durable repository tree

GitHub is the durable project/reincarnation ledger for the whole HOSTILE-OS effort. The repository intentionally separates the bootable OS surface from the research/history surface so outside reviewers can inspect everything without forcing OS-only users to download everything.

## Canonical top-level responsibilities

- `os/` — embodied OS code/build surfaces. `os/research_only/` is explicitly non-release research embodiment; future release/install surfaces also live under `os/`.
- `research/` — experiments, raw/packaged evidence, receipts, preregistrations, results, audits, donor reviews, reproduction records, recovery logs, and scientific history.
- `continuity/` — current state, commander's intent, decisions, project policy, Live Shadow, Design Thread Stream, and interpretive handoff surfaces.
- `handoffs/` — complete recoverable conversation and frozen reincarnation package.
- `authority/` — adopted SOP/authority packages, including original R3.1 archive and exact extracted package.
- `scars/` — failures, anti-regression rules, never-reintroduce constraints, execution/provenance defects.
- `lineage/` — historical lineage surfaces and donor ancestry records.
- `infra/` — project infrastructure and qualification support that is not OS runtime code.
- `payload_history/` — admitted historical large payloads/tooling whose exact bytes matter to lineage.
- `tools/` — repository maintenance, publication, verification, continuity, and reproducibility tooling.
- `logs/` — only logs deliberately admitted as durable project history; unique science/recovery logs should normally be placed under the appropriate `research/` subtree.

## “Everything goes to GitHub” rule

All **unique project data** must become canonical Git/GitHub state. This includes successful and failed runs, raw evidence, receipts, audits, source, build logic, review material, recovery attempts, decisions, continuity, transcripts, SOP packages, original archives, correction notes, and environment/reproduction records.

`.pcmmad_sync_runs/` may be used as an execution scratch plane, but it may never be the sole surviving copy of unique project evidence at turn close. Unique scratch data must be promoted into an appropriate canonical folder or losslessly archived with hashes before the turn is durably closed.

Generated caches, duplicate copies, process breadcrumbs, index locks, editor files, and reproducible temporary build trees are not additional unique project data. They are not required as redundant copies. If their failure/disposition matters, record that fact in a scar or result artifact.

## OS-only retrieval

The full durable repository may be multi-gigabyte. OS-only users use blobless partial clone + sparse checkout of `os/` with LFS smudge disabled. Research, continuity, transcripts, authority packages, and bulk evidence are prohibited implicit build/install dependencies.
