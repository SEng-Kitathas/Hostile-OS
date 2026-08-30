# Durable repository + embodied research OS policy — 2026-08-30

Status: OPERATOR-DIRECTED PROJECT POLICY

## 1. Whole-project durability

GitHub is the durable repository for the complete HOSTILE-OS project, not merely product source. Every unique project datum must be admitted into the canonical folder tree and published: code, research, successful evidence, failed evidence, logs, reviews, continuity, transcripts, decisions, scars, SOP archives, raw packages, historical corrections, build/reproduction tooling, and relevant environment/provenance records.

Scratch execution planes may exist locally, but unique data is forbidden from existing only in scratch when a meaningful turn closes. Bulk evidence may be transport-adapted into a lossless archive plus manifest/hash rather than expanded into millions of Git blobs. Transport adaptation is not evidence deletion.

Duplicate caches, process-ID breadcrumbs, editor/OS noise, and exact duplicate expanded copies are not separate unique project data. Their scientific/operational meaning, if any, is recorded before disposal.

This clarification strengthens `continuity/11_PER_TURN_GITHUB_CONTINUITY_POLICY.md`: per-turn publication is not only continuity text publication; it is publication of the complete newly admitted project delta.

## 2. Embodied research-only OS

`os/` must no longer remain purely empty while the research substrate is inspectable only through experiment directories. A clearly marked research-only embodied OS is required so reviewers/contributors can build, boot, inspect, and reproduce a selected integrated witness.

Initial embodiment:
`os/research_only/i001_reference/`

The initial seed is I001 because it is the first whole-workload integrated freestanding witness. This is **not** final architecture promotion and does not silently incorporate every later D64 result. It is a reproducible review target whose limitations and lineage are explicit.

A research-only embodiment may evolve by reviewed revisions. Any change claiming new scientific/architecture authority must still pass the normal preregistration/experiment/adoption gates; convenient edits under `os/` do not overwrite sealed science.

## 3. Reproducibility

Every embodied research OS revision should provide:
- repo-relative source;
- one-command build entry point;
- explicit tool discovery/version reporting;
- machine-byte/reference checks where a historical target exists;
- runnable boot path;
- verification report distinct from historical science closure;
- source/provenance mapping;
- cross-platform line-ending policy.

## 4. Checkout separation

The repository may contain the whole laboratory while `os/` remains independently obtainable by partial/blobless sparse checkout. No research/continuity/authority/handoff file may become an implicit OS build dependency.
