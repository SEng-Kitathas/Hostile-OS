# Current reincarnation CRLF manifest scar — 2026-08-31

Status: **REPAIRED BEFORE PUBLICATION / NO SCIENCE OR ARCHITECTURE EFFECT**

## Failure

After commit `d52854ffcad562dbde4e18387264e91c2b5b75ca`, a stronger reincarnation check compared `handoffs/CURRENT_REINCARNATION/MANIFEST_SHA256.json` against the **committed Git blobs**, not only the worktree files.

That check failed for 10 text files. Their worktree copies used CRLF when the manifest was generated, while Git's text normalization stored LF blobs. The committed manifest therefore described pre-normalization worktree bytes rather than the committed package bytes.

## Scope

The mismatches were text newline encoding only. No scientific result, source mechanism, run receipt, physical image, D64-v3 body, campaign state, or authority claim changed.

## Repair

- normalize current reincarnation text copies to LF before hashing;
- regenerate the complete package manifest after normalization;
- verify worktree membership/size/SHA closure;
- commit the repair;
- verify every package entry again from `HEAD` Git blobs against the committed manifest;
- publish only after Git-blob closure passes.

## Rule earned

A reincarnation package intended to be verified from committed Git MUST generate its final manifest over bytes that are identical to Git's committed representation. Worktree-only hash closure is insufficient when line-ending normalization can occur at commit time.
