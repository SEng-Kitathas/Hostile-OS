# Legacy reincarnation builder invocation scar — 2026-08-31

Status: **PRESERVED TOOLING SCAR / NO SCIENCE OR ARCHITECTURE EFFECT**

## Trigger

During the H1 Bochs qualification close, the lab attempted to inspect command usage with:

`python tools/build_hostile_os_reincarnation.py --help`

The script has no argument parser or help guard. It immediately executed its historical build body instead.

## Observed failure

Execution failed at its first payload-copy loop because the script still hard-codes historical sandbox inputs under `/mnt/data`, including an old R3.1 ZIP filename and old foundation/C001 payload paths that are not the current durable project source.

Representative failure:

`FileNotFoundError` from `shutil.copy2(sources[k], ROOT/rel)`.

The canonical Git worktree was checked immediately afterward and remained clean. No tracked project mutation came from the failed legacy build.

## Finding

`tools/build_hostile_os_reincarnation.py` is a **historical package constructor**, not the current safe per-turn `handoffs/CURRENT_REINCARNATION/` refresh path.

It SHALL NOT be invoked as though it were a modern CLI, and it SHALL NOT be used to rebuild current reincarnation state from obsolete `/mnt/data` assumptions without a separately reviewed maintenance change.

## Current close method

For this turn, the current reincarnation package was refreshed directly from canonical durable project files, then its complete membership, byte sizes, and SHA-256 hashes were regenerated and verified against `MANIFEST_SHA256.json`.

This scar does not alter C004, C005, D64-v3, H1 probe evidence, physical-H1 status, or campaign authority.
