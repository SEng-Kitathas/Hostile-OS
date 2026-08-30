# Contributing to the research-only I001 embodiment

1. Build and run the unmodified reference first.
2. Preserve your tool versions and `build_manifest.json`.
3. Run `verify.py` before proposing changes.
4. Treat changes as a new embodiment revision, not a rewrite of historical I001 science.
5. If the change claims a new architectural consequence, create/preregister the corresponding research discriminator and preserve failed attempts.
6. Keep source LF-normalized; root `.gitattributes` governs canonical line endings.
7. Do not add dependencies on `research/` to the OS build path. Provenance links may point there, but the `os/` subtree must remain independently checkout/buildable.
