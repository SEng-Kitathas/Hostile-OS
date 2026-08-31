# HOSTILE-OS D64 Reference v2

**RESEARCH PURPOSES ONLY — NOT A RELEASE — NOT FINAL ARCHITECTURE**

This directory is the versioned successor body planned after WT01. It is being built representation-first from adopted D64-era shadow mechanisms while preserving `../i001_reference/` unchanged as the historical I001 embodiment.

Current status: **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**. The body composes the adopted D64-era reviewer mechanisms inside the qualified 8 KiB envelope and has passed an isolated `os/`-only build/run/verify audit. This is still not final architecture, production-ready, or a general-purpose release.

The working words `activity`, `binding`, and `resource` are implementation vocabulary, not constitutional primitives.

Build/run from this directory:

```text
python build.py
python run.py
python verify.py
```

The directory is designed to work from an `os/`-only sparse checkout. Build/run scripts do not read the `research/`, `continuity/`, `authority/`, or `handoffs/` trees.
