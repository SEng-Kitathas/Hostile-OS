# HOSTILE-OS

HOSTILE-OS is an experimental operating-system research project built under the PCMMAD method. The repository is the durable project ledger: OS code, research, evidence, failures, decisions, continuity, SOP packages, transcripts, reviews, and project history are intentionally preserved together.

## Current status

HOSTILE-OS is **not yet a user-installable release**. The current architecture posture is `INTEGRATED_SHADOW_CANDIDATE`, not production/final/canonical architecture.

There is now a real bootable **research-purpose-only embodied OS** under:

`os/research_only/i001_reference/`

It can rebuild the controlling I001 stage1/stage2 machine bytes exactly, produce the same initial raw disk image, boot twice in QEMU, and emit a reproduction-specific verification report. It exists so reviewers/contributors can inspect and run the substrate while later D64 refinements continue to be researched.

## Repository layout

See `PROJECT_TREE.md` for the normative folder responsibilities.

High-level:
- `os/` — embodied OS surfaces; only this subtree may become an OS build/install dependency.
- `research/` — preregistrations, experiments, raw/packaged evidence, receipts, traces, audits, reviews, reproduction records, plans, and failures.
- `continuity/` — commander's intent, current state, decisions, project policy, Live Shadow, Design Thread Stream, and recovery surfaces.
- `handoffs/` — recoverable conversation and frozen reincarnation package.
- `authority/` — adopted SOP/authority packages and exact source archives.
- `scars/` — failures, never-reintroduce rules, portability/provenance scars.
- `lineage/`, `infra/`, `payload_history/`, `tools/` — lineage, qualified infrastructure, admitted historical payloads, and repository tooling.

## Build the research-only OS

From the full repo or an `os/` sparse checkout:

```text
cd os/research_only/i001_reference
python build.py
python run.py
python verify.py
```

Set `HOSTILE_LLVM_BIN` or individual `HOSTILE_CLANG` / `HOSTILE_LLD` / `HOSTILE_OBJCOPY` variables if LLVM is not on `PATH`. Set `HOSTILE_QEMU` if QEMU is not on `PATH` or in the common Windows install location.

`VERIFY_PACKAGE.py` is provided as a reviewer-friendly verification entry point.

## OS-only checkout

The full project is intentionally large. You do **not** need the R&D dump to inspect/build the embodied `os/` tree.

See `INSTALL_FROM_GIT.md` for partial/blobless sparse checkout with LFS smudge disabled.

## Full project checkout

A normal clone is the complete published engineering/science/reincarnation ledger:

```text
git clone https://github.com/SEng-Kitathas/Hostile-OS.git
```

## GitHub durability model

Every meaningful turn publishes the complete admitted project delta, not merely code or continuity prose. Unique data created in execution scratch must be promoted into the canonical folder tree or losslessly archived with hashes before the turn closes.

Canonical local Git remains the exact science lineage. GitHub is an immutable-commit publication snapshot history; oversized payloads use LFS without rewriting canonical science history. Publication is not claimed until remote `main` is read back.

Policies:
- `continuity/05_GITHUB_PUBLICATION_POLICY.md`
- `continuity/11_PER_TURN_GITHUB_CONTINUITY_POLICY.md`
- `continuity/13_DURABLE_REPOSITORY_AND_RESEARCH_OS_POLICY_2026-08-30.md`

## Research authority

Research and the research-only OS are evidence/embodiment, not automatic architecture authority. Experiment results, adoption reviews, current state, and explicit promotion decisions determine what becomes load-bearing release architecture.
