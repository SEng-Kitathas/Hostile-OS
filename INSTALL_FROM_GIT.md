# Install / build checkout from GitHub

HOSTILE-OS is not installable yet. This document fixes the repository access contract now so that future installation does **not** require downloading the research/reincarnation archive.

## OS-only sparse checkout — preferred

Use a partial/blobless clone, disable automatic LFS smudge, then materialize only `os/`:

```text
set GIT_LFS_SKIP_SMUDGE=1
git clone --filter=blob:none --no-checkout https://github.com/SEng-Kitathas/Hostile-OS.git
cd Hostile-OS
git sparse-checkout init --cone
git sparse-checkout set os
git checkout main
```

PowerShell equivalent for the first line:

```text
$env:GIT_LFS_SKIP_SMUDGE="1"
```

Why both controls exist:
- `--filter=blob:none` avoids fetching ordinary blob bodies until required by checked-out paths;
- sparse checkout materializes only `os/`;
- `GIT_LFS_SKIP_SMUDGE=1` prevents large R&D/history LFS objects from being fetched automatically during checkout.

The `research/`, `authority/`, `continuity/`, `handoffs/`, scars, historical payloads, transcripts, and bulk evidence archives are therefore **not** required merely to obtain the OS surface.

## Full project / research checkout

For the complete timestamped engineering/science/reincarnation ledger:

```text
git clone https://github.com/SEng-Kitathas/Hostile-OS.git
```

If Git LFS is installed, a full checkout may fetch admitted large evidence/history objects.

## Repository contract for future OS dependencies

Anything required to build, install, boot, or operate a released HOSTILE-OS version must either:
1. live under `os/`, or
2. be fetched by explicit versioned logic under `os/`.

The install/build path MUST NOT silently require `research/`, `authority/`, `continuity/`, `handoffs/`, transcripts, or historical R&D archives. Research may explain or verify an OS mechanism; it is not an installation dependency.

## Research-only embodied OS

There is not yet a release installer, but the `os/` sparse checkout now contains a bootable research-only embodiment:

```text
cd os/research_only/i001_reference
python build.py
python run.py
python verify.py
```

This path is intentionally self-contained under `os/`; it does not require the research/continuity/history trees to build or boot.
