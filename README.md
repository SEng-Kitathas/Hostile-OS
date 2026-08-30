# HOSTILE-OS

HOSTILE-OS is an experimental operating-system research project built under the PCMMAD method. The repository intentionally preserves both the evolving OS work and the research/evidence that produced it.

## Current status

HOSTILE-OS is **not yet a user-installable operating system**. The current architecture posture is a bounded integrated research candidate, not a production or canonical release.

The installable OS tree will live under:

`os/`

The scientific record lives under:

`research/`

Research is part of the project history, but it is not required in a code-only checkout.

## Repository layout

- `os/` — install/build surface for the OS as it becomes installable.
- `research/` — preregistrations, experiments, run receipts, traces, audits, architecture reviews, and research plans.
- `continuity/` — current state, Live Shadow, Design Thread Stream, and recovery surfaces.
- `authority/` — adopted engineering/research SOP and authority lineage.
- `lineage/` — donor/source and contamination ledgers.
- `scars/` — preserved engineering/research scars.
- `infra/` — qualified infrastructure source and portable tooling.
- `payload_history/` — historical payloads retained for project provenance.
- `tools/` — project maintenance and publication tooling.

## Code-only checkout

You do not need to pull the research tree to obtain the future installable OS surface.

See `INSTALL_FROM_GIT.md` for the sparse/partial-clone command. It uses Git's partial clone plus sparse checkout so research blobs are not downloaded unless requested.

## Full project checkout

A normal clone intentionally retrieves the whole published project record:

```text
git clone https://github.com/SEng-Kitathas/Hostile-OS.git
```

That is the archival/research view.

## GitHub publication model

The canonical local engineering repository preserves exact experiment commit lineage. An old historical toolchain payload in that history exceeds GitHub's normal 100 MB Git-blob limit, so the canonical history is not rewritten merely to satisfy hosting policy.

Instead, GitHub is maintained as a chronological **publication snapshot history**. At the end of each substantive pass:

1. canonical local work is committed first;
2. all tracked project files are copied into the publication mirror;
3. oversized payloads are represented through Git LFS;
4. a publication metadata file records the exact canonical local HEAD and UTC timestamp;
5. the publication commit is pushed and remote HEAD is read back.

This preserves the project's exact local scientific lineage while still making GitHub a dated project-wide record.

The policy is recorded in `continuity/05_GITHUB_PUBLICATION_POLICY.md`.

## Research authority

Research files are evidence, not automatic architecture authority. Experiment results, adoption reviews, current state, and explicit promotion decisions determine what is load-bearing.
