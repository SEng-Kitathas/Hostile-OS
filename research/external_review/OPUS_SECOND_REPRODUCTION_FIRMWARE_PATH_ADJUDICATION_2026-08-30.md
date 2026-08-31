# Opus second independent reproduction / firmware-path finding — adjudication

Date: 2026-08-30
Source: `OPUS_SECOND_REPRODUCTION_FIRMWARE_PATH_REPORT_RAW_2026-08-30.md`
Mode: AUDIT

## External reproduction claim

Opus reports a second independent I001 reproduction on the repaired tree and says the prior tool-invocation, QEMU-module, and default-NIC fixes worked without the previous shims.

Authority ceiling remains unchanged:

`EXTERNAL REPRODUCTION REPORTED / FOREIGN RAW PACKET NOT YET SUPPLIED`

The foreign `build_manifest.json`, debugcon traces, and verification report have not been supplied to this local project plane, so the second reproduction is not promoted into locally hash-verified foreign raw evidence.

## IRQ interpretation

Opus correctly describes the repository's current tested IRQ-count scope:
- historical exact evaluator remains unchanged;
- 660 historical FAILs remain historical FAILs;
- their reconciled signature is only `IRQ_EVENT=1` expected versus `IRQ_EVENT=2` observed in Boot1, with Boot2 exact;
- living verifier accepts only tested counts1/2;
- counts >2 remain unearned.

The single external count-one observation is not a discriminator between count-one and count-two semantics and does not alter IRQCOUNT01 authority.

## Remaining firmware/data-path assertion — VERIFIED WITH IMPORTANT NUANCE

### Verified direct-runner gap

Inspection of both Python research runners at canonical HEAD before repair showed:
- QEMU module-directory inference/override support;
- explicit `-nic none`;
- **no QEMU firmware/data-directory discovery and no `-L` argument**.

Therefore Opus's direct claim is technically correct: invoking a relocated `qemu-system-i386` binary directly through Python can fail if its firmware data directory moved with the transplant and is not on QEMU's compiled/system search path.

This is the same broad portability class as the module-dir defect:

`TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT`

The binary's usable runtime identity includes at least executable bytes plus loadable modules plus firmware/data files for this transplant envelope.

### Prior wrapper coverage already existed

The project was not entirely unaware of this requirement. Existing immutable PATCH_003 wrapper source already executes:

```text
-L "$HERE/share/qemu"
```

and therefore the official wrapper-based smuggle/transplant path already carried the firmware-data location.

So the accurate disposition is:

`KNOWN_IN_WRAPPER / MISSING_IN_DIRECT_PYTHON_RUNNER`

not `COMPLETELY_MISSING_FROM_PROJECT`.

## Repair disposition

### Current D64 v2 reference — fixed at source

`os/research_only/d64_reference_v2/run.py` now:
- accepts `HOSTILE_QEMU_DATA_DIR`;
- accepts `HOSTILE_QEMU_FIRMWARE` as an alias;
- validates explicit directory existence;
- auto-discovers adjacent transplant/system data directories;
- requires `bios-256k.bin` for auto-discovery;
- supports both `share/qemu` and `share` layouts near the binary;
- passes the discovered directory to QEMU using `-L`;
- records `qemu_data_dir` in the run receipt.

Synthetic transplant pressure with:

```text
runtime/qemu/bin/qemu-system-i386
runtime/qemu/modules/
runtime/qemu/share/qemu/bios-256k.bin
```

correctly inferred both module and data directories.

On the local installed QEMU, the runner auto-discovered:

`C:\Program Files\qemu\share`

and every reviewer argv visibly included:

```text
-L C:\Program Files\qemu\share
```

The complete current-reference suite then remained PASS:
- 8 reviewer QEMU boots;
- all required exits/traces unchanged;
- verifier17/17 PASS.

### Historical I001 reference — deliberately not rewritten

`os/research_only/i001_reference/` is a frozen historical reference generation whose Git tree is explicitly preserved unchanged by current continuity policy.

Therefore its Python `run.py` is **not** rewritten merely to align convenience behavior with v2.

For transplanted historical-I001 execution, the project-supported wrapper route remains PATCH_003, which already supplies `-L "$HERE/share/qemu"`, module-directory binding, and default `-nic none`.

This means:
- direct-binary historical I001 Python invocation still lacks the new environment hook;
- official wrapper-based historical transplant execution carries the firmware path;
- current v2 direct Python invocation is repaired.

This distinction is intentional lineage preservation, not an accidental unresolved defect.

## Architectural relevance

The finding is infrastructure evidence, not new HOSTILE-OS architecture proof.

But the analogy is technically useful:
- invocation path can carry executable dispatch identity;
- executable bytes alone do not carry module/data runtime environment;
- relocation can invalidate hidden assumptions even when hashes remain exact.

That is consistent with the project's broader identity/currentness discipline, but it must remain analogy rather than circular architectural proof.

## Final disposition

`SECOND EXTERNAL REPRODUCTION REPORTED / FIRMWARE-DATA DIRECT-RUNNER GAP VERIFIED / CURRENT V2 FIXED / HISTORICAL I001 WRAPPER COVERAGE RETAINED / FOREIGN RAW PACKET STILL NOT SUPPLIED / SCIENCE AUTHORITY UNCHANGED`
