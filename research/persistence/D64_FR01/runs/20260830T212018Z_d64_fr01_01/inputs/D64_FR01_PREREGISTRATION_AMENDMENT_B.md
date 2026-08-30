# D64/FR01 preregistration amendment B — floppy CHS mapping for LBA18/LBA19

Date: 2026-08-30
Status: VISIBLE FIXTURE/TRANSPORT AMENDMENT AFTER FAILED CAMPAIGN, BEFORE RERUN
Parent preregistration: `D64_FR01_PREREGISTRATION.md`
Parent amendment A: `D64_FR01_PREREGISTRATION_AMENDMENT_A.md`
Failed campaign: `runs/20260830T211841Z_d64_fr01_01`

## Why this amendment exists

The first execution-capable 41-fixture campaign reached stage1 on every fixture but every stage2 guest exited through `IO_FAIL` before any record validation or selection.

All 41 traces were identical:

```text
S1_8K_OK
IO_FAIL
```

All QEMU processes terminated with isa-debug-exit code35. Static/source closure passed, but the evaluator correctly failed and the independent audit then exposed a separate harness robustness defect by assuming `SELECT=` existed.

Cause: FR01's disk layout was specified in LBA terms but the guest BIOS INT13 reader used CHS. A standard 1.44 MiB floppy has 18 sectors per track. Therefore CHS sector numbers 19 and20 on head0 are invalid.

## Correct CHS mapping

The LBA layout remains unchanged:
- LBA17 = record A;
- LBA18 = record B;
- LBA19 = fixture label.

The correct CHS addresses are:

| Purpose | LBA | Cylinder | Head | Sector |
|---|---:|---:|---:|---:|
| record A | 17 | 0 | 0 | 18 |
| record B | 18 | 0 | 1 | 1 |
| fixture label | 19 | 0 | 1 | 2 |

The stage2 read helper must therefore receive both head (`DH`) and sector (`CL`) rather than forcing head0 for all three reads.

## Science disposition of failed campaign

`20260830T211841Z_d64_fr01_01` is `FAILED_FIXTURE_TRANSPORT / NO_RECOVERY_MECHANISM_EXECUTION`.

It does not support or refute any preregistered CRC, selection, fallback, ambiguity, stale-handle, or reconstruction consequence because stage2 failed before reading the durable candidates successfully.

## Harness robustness repair

The failed campaign also showed two reporting defects:
- independent audit used `next()` on a missing `SELECT=` line and crashed instead of producing a clean failed audit;
- launcher summary assumed the audit JSON always existed and raised `FileNotFoundError` after the audit crash.

Before rerun:
- audit must treat missing trace fields as boolean failure, never as an exception;
- launcher must write a terminal result summary even if evaluator/static/audit outputs are missing or nonzero.

These reporting fixes do not alter the recovery mechanism or expected fixture outcomes.

## What does not change

No durable record bytes, CRC parameters, commit marker, sequence rule, fixture matrix, expected selection, reconstruction rule, or authority ceiling changes.
