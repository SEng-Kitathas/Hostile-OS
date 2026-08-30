# I001 research-only embodied OS reproduction result

Status: PASS
Date: 2026-08-30
Purpose: outside-review/reproduction surface, not historical science replacement and not final architecture promotion.

## Build reproduction

Repo-contained source under `os/research_only/i001_reference/src/` rebuilt to the exact controlling I001 machine bytes:

- stage1: 512 bytes, SHA-256 `bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8`
- stage2 raw: 2478 bytes, SHA-256 `2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be`
- padded stage2 SHA-256 `4ffea35b376e3213aff118cc5d904a9a18f73c2aa473bdbb4b388be99205856b`
- initial disk SHA-256 `b9c79c821d0be352132e940201f23d1e2bcd0456d994a1a142fd01a183bc4218`

The final `build_manifest.json` records observed tool executable paths, version strings, and SHA-256 hashes. The historical exact toolchain lock is under `os/research_only/i001_reference/toolchain.lock.json`.

## Exact historical toolchain identity

The observed executable SHA-256 values for Clang, LLD, llvm-objcopy, QEMU, and Python all match the original controlling I001 receipt exactly. This captured run therefore used the same historical tool binaries through the new portable/repo-relative interface.

## Runtime reproduction

Final captured run:
- Boot1 QEMU PID `27432`, status `COMPLETED`, exit `33`
- Boot2 QEMU PID `27240`, status `COMPLETED`, exit `33`
- distinct QEMU processes: true
- no host disk write between boots: true
- verification report: PASS

The verifier confirms the stable I001 semantic markers for acquisition/capacity, wait/missing behavior, IRQ observation/release/wake/application, reuse/currentness, spanning-read controls, durable write, generation exhaustion, clean restart/rebind, old-token rejection, and runtime epoch advance.

The observed final run reported historical exact `IRQ_EVENT=1`. The reproduction verifier deliberately treats exact-one as informational rather than required because the 3304-cycle campaign previously observed I001 traces with `IRQ_EVENT=2` while boot/static closure remained successful. The sealed historical evaluator is unchanged; that science seam remains open.

## Historical hash portability check

`rb02_historical_source_hash_check.json` independently verifies all 12 RB02 historical inputs:
- all sealed run snapshots match their receipt hashes;
- all canonical Git blobs classify `CRLF_NORMALIZED` relative to those Windows historical hashes;
- zero mismatches remain after explicit normalization classification.

## Claim ceiling

This packet earns a **local end-to-end reproduction of the I001 reference embodiment**: source -> exact machine bytes -> two QEMU boots -> reproduction verifier. It does not yet prove cross-platform reproduction on a foreign machine, physical hardware behavior, or new architecture authority.
