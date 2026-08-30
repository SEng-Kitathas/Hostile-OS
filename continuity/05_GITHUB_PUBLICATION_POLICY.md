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
