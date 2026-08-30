# HOSTILE-OS embodied tree

This directory is the only repository subtree that may become an OS build/install dependency.

## Current surfaces

### `research_only/`
A real, bootable, **RESEARCH PURPOSES ONLY** embodiment for reviewers and contributors. It is not a release and not final architecture promotion.

Current seed:
`os/research_only/i001_reference/`

The I001 reference can be built from repo-contained source, compared against the controlling historical machine-code hashes, booted twice under QEMU, and verified through a reproduction-specific report.

### Future release/install surface
Not yet promoted. Research witnesses do not become release architecture merely because they are copied or made convenient to build.

## Repository rule

A future released build/install path must not require `research/`, `continuity/`, `authority/`, `handoffs/`, or other R&D/history trees to be checked out. Anything needed to build/run the OS must live under `os/` or be fetched explicitly/versioned by tooling under `os/`.
