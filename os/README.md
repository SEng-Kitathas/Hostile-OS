# HOSTILE-OS embodied tree

This directory is the only repository subtree that may become an OS build/install dependency.

## Current surfaces

### `research_only/d64_reference_v2/` — current research reference

A real, bootable, **RESEARCH PURPOSES ONLY** integrated body for reviewers and contributors.

Status: **CURRENT_RESEARCH_REFERENCE**.

It embodies the current adopted D64-era reviewer baseline:
- finite 64-activity / 64x20 binding / 64-resource profile;
- checked generation/epoch currentness;
- binding-aware lifecycle and shared live-count lifetime;
- real IRQ0 count1/count2/stale-relation wake/application behavior;
- two-boot durable meaning -> validation -> fresh reconstruction;
- FR01-compatible CRC+commit candidate recovery;
- bounded faulted-media reviewer cases.

It passes from an isolated `os/`-only export and does not require the R&D/history trees to build/run/verify.

This status is **not** release or final architecture promotion.

### `research_only/i001_reference/` — historical integrated reference

The original I001 reference remains unchanged and independently reproducible. It is preserved as a historical embodiment generation rather than rewritten into the current body.

### Future release/install surface

Not yet promoted. Research witnesses do not become release architecture merely because they are convenient to build.

## Repository rule

A future released build/install path must not require `research/`, `continuity/`, `authority/`, `handoffs/`, or other R&D/history trees to be checked out. Anything needed to build/run the OS must live under `os/` or be fetched explicitly/versioned by tooling under `os/`.
