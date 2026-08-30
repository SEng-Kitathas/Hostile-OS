# D64 / PR01 engineering scars — 2026-08-30

These attempts are engineering/control evidence only unless explicitly named as controlling science.

## Attempt 1 — missing adoption input path

Run ID: `20260830T064300Z_d64_pr01_persistence_01`

Launcher exited before snapshot/build/QEMU because it referenced a nonexistent ARB01 adoption filename.

Actual tracked file:
`research/architecture/D64_ARB01_COMPOSITION_ADOPTION_REVIEW_2026-08-30.md`

Consequence: no science ran.

## Attempt 2 — invalid boot-drive handoff

Run ID: `20260830T064500Z_d64_pr01_persistence_02`

Boot 1 reached stage2 but printed only:

```text
S1_8K_OK
FAIL
```

QEMU completed with exit35.

Diagnostic scratch established the first failure was `durable_read`.

Root cause: the qualified stage1 saves BIOS `DL` internally, then prints `S1_8K_OK` using `DX=0x00E9` before the far jump. PR01 stage2 incorrectly assumed incoming `DL` still contained the boot drive and therefore attempted INT13 against drive `0xE9`.

Qualified stage1 itself was not changed. Its linked saved `boot_drive` symbol was independently resolved at `0x7C4B`. PR01 stage2 now reads that saved byte from `0x7C4B` and uses it for sector18 firmware transport.

Consequence: mechanism transport defect fixed before controlling run.

## Attempt 3 — checker argv guard

Run ID: `20260830T064900Z_d64_pr01_persistence_03`

Both QEMU boots completed exit33 with the exact preregistered traces. Evaluator passed. Durable-sector hashes matched later controlling values.

Static checker exited64 because its usage guard required `len(sys.argv)==9` while the declared interface actually has nine arguments after the script name (`len(sys.argv)==10`).

Consequence: harness defect only; attempt not promoted.

## Attempt 4 — static-checker false negatives

Run ID: `20260830T065100Z_d64_pr01_persistence_04`

Both QEMU boots again completed exit33 with exact traces, evaluator passed, and durable bytes matched. Static closure returned false on three checks:

- detach clear/decrement/reclaim order;
- old-handle checks before/after rebind;
- two-distinct-QEMU-process launcher structure.

Source review established all three were checker-shape false negatives:

1. detach checker matched the earlier validation `live_count==0` comparison instead of the post-clear zero test;
2. old-handle checker used repeated generic call strings and matched wrong occurrences;
3. launcher checker expected two inline `subprocess.Popen` statements even though spawning is correctly centralized in `run_qemu()` and called twice.

The checker was repaired to use order-specific unique assignments/regions and the actual launcher abstraction.

Consequence: no mechanism change between attempts4 and5.

## Attempt 5 — controlling PASS

Run ID: `20260830T065500Z_d64_pr01_persistence_05`

Both boots exit33; exact evaluator PASS; 27/27 literal static checks true; independent audit PASS. This is the controlling scientific run.
