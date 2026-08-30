# Install / build checkout from GitHub

HOSTILE-OS is not installable yet. This document fixes the repository access rule now so that future installation does **not** require downloading the research archive.

## Code-only sparse checkout

When the `os/` tree contains the installable system, use:

```text
git clone --filter=blob:none --no-checkout https://github.com/SEng-Kitathas/Hostile-OS.git
cd Hostile-OS
git sparse-checkout init --cone
git sparse-checkout set os
git checkout main
```

This does two useful things:

- `--filter=blob:none` avoids downloading file contents that are not needed for the checked-out paths;
- sparse checkout materializes only `os/` in the working tree.

The `research/`, `authority/`, `continuity/`, historical payload, and other project-history trees are therefore not required just to obtain the OS surface.

## Full research/project checkout

For the complete timestamped project history:

```text
git clone https://github.com/SEng-Kitathas/Hostile-OS.git
```

## Repository rule for future OS dependencies

Anything required to build, install, boot, or operate a released HOSTILE-OS version must either:

1. live under `os/`, or
2. be fetched by an explicit `os/` build/install script from a versioned external dependency.

The install path must not silently require `research/`.

Research may explain or verify an OS mechanism, but it is not an installation dependency.
