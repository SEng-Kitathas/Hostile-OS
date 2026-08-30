# Reproducibility, portability, and scratch-disposition scars — 2026-08-30

## Historical CRLF receipt hashes

RB02's twelve input hashes were recorded from a Windows CRLF working-tree snapshot. Canonical Git blobs are LF. All twelve receipt hashes are recovered exactly by CRLF-normalizing the canonical blob bytes. This is a repository-portability scar, not evidence corruption. Root `.gitattributes` now establishes LF canonical text; `tools/verify_historical_receipt_sources.py` adjudicates old receipts without rewriting them.

## Historical launchers are host-path-bound

Research launchers such as I001 are executable on the original host but hard-code LLVM/QEMU/Python paths. They remain historical evidence and are not rewritten. The new `os/research_only/i001_reference/` embodiment provides a separate portable review path.

## Abandoned earned-chain ZIP transport

An early attempt to ZIP the broad earned-chain overnight campaign was terminated during an inefficient pre-hash/archive path. The resulting file later measured:

- path: `research/campaigns/EARNED_CHAIN_OVERNIGHT_ARCHIVE_2026-08-30/EARNED_CHAIN_OVERNIGHT_20260830T063648Z.zip`
- bytes: `1028750723`
- SHA-256: `0e6358da25cf27a85b52f2d8717dd4c2fe29e676c4a6813b1cbc3c0890a09942`
- structural status: `BadZipFile / File is not a zip file`

It is an incomplete duplicate transport artifact, not unique campaign evidence. The complete original campaign scratch source was separately streamed into the verified 2,143,104,512-byte TAR with SHA-256 `eef7a2fd43a1c4819927c3a0d8afb976470171af8f3cd55d0237d1e2b8f2cc0e`. The corrupt partial ZIP is therefore moved to ignored scratch after this scar records its exact disposition; it is not published as a misleading second evidence archive.

## Stray numeric breadcrumb files

Two untracked root files were inspected:

- `27376` contained `.pcmmad_sync_runs\\overnight_2026-08-30\\integrity.pid`
- `29312` contained `.pcmmad_sync_runs\\overnight_2026-08-30\\pr01_soak.pid`

These are process-path breadcrumbs, not project evidence. Their contents are preserved here; the files themselves are moved to ignored scratch.

## Incomplete C002 recovery scan

`logs/C002_SOURCE_RECOVERY_SCAN_2026-08-29.txt` contained only the scan start timestamp and `ROOT=C:\\`. Because recovery attempts are project history under the strengthened durability policy, its original bytes are admitted at `research/recovery_logs/C002_SOURCE_RECOVERY_SCAN_2026-08-29.txt`; the redundant untracked root-log copy is moved to scratch.

## Rule earned

Unique project data must leave scratch before a meaningful turn closes. Redundant/incomplete transport artifacts may be removed from the canonical tree only after their load-bearing disposition and, where relevant, size/hash are recorded and a verified durable source contains the unique evidence.

## Current reincarnation manifest LF repair

After the whole-project commit, Git-object verification found one reincarnation-manifest mismatch: the frozen `10_AUTHORITY_ADOPTION_STATE.md` copy had been hashed from CRLF working bytes while root `.gitattributes` stored the staged blob as LF. The canonical authority source was not wrong and was not rewritten. The snapshot copy was replaced from the canonical Git blob and the snapshot manifest was regenerated. Reproduction-packet Git-object verification already passed.

## Independent-host portability defects — Opus report

An outside-host I001 reproduction report exposed three additional transplant defects:

1. `find_tool()` used `.resolve()` before execution. On POSIX, `/usr/bin/ld.lld` may resolve to a generic multi-call `lld` binary; changing argv[0] can change driver behavior. Repair: preserve invocation spelling and resolve separately for identity/hash metadata.
2. historical `runtime/qemu/run-qemu-i386.sh` omitted `QEMU_MODULE_DIR` while PATCH_002 contains `modules/accel-tcg-i386.so`. Repair: append-only PATCH_003 exports module directory.
3. I001 runner did not disable QEMU's default NIC, allowing missing `efi-e1000.rom` to block an unrelated non-network workload. Repair: `-nic none` in `run.py` and PATCH_003 default wrapper behavior.

Local Windows could not create a real symlink without elevation, so the exact POSIX symlink failure is externally observed. Repository-side path-spelling identity and module/NIC gates pass. Exact I001 machine bytes and two-boot behavior remain unchanged after the repairs.

Rule earned for infrastructure: **tool path is not tool identity, and transplanted binary is not transplanted environment**. These are infrastructure rules/analogies, not automatic OS architecture proof.
