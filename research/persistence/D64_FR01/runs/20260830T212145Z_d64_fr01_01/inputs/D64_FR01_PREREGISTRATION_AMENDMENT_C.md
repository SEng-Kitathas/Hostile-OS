# D64/FR01 preregistration amendment C — qualified stage1 boot-drive handoff

Date: 2026-08-30
Status: VISIBLE TRANSPORT AMENDMENT AFTER FAILED CAMPAIGN, BEFORE RERUN
Parent preregistration: `D64_FR01_PREREGISTRATION.md`
Parent amendments: A, B
Failed campaign: `runs/20260830T212018Z_d64_fr01_01`

## Why this amendment exists

After Amendment B corrected floppy CHS mapping, all 41 fixtures still exited through `IO_FAIL` before record validation.

All 41 traces again had one signature:

```text
S1_8K_OK
IO_FAIL
```

The qualified 8 KiB stage1 saves the BIOS boot drive into its own `boot_drive` byte before loading stage2, but its `print_string` helper later uses register `DX` for debug-port output before the far jump. Therefore stage2 may not infer that `DL` still contains the boot drive.

The already-qualified PR01 lineage explicitly solved this by reading the stage1 saved byte at physical address `0x7c4b`.

Independent symbol readback of the current qualified stage1 ELF confirms:

```text
00007c4b t boot_drive
```

## Amendment

FR01 stage2 SHALL obtain the BIOS boot drive from physical `0x7c4b`, the qualified stage1 `boot_drive` symbol, before issuing any INT13 reads.

FR01 stage2 SHALL NOT use incoming `DL` as the durable-sector transport authority after the stage1 debug print.

Static closure must verify:
- a named constant binds qualified stage1 boot-drive memory to `0x7c4b`;
- stage2 copies that memory byte into its local `boot_drive` before durable reads;
- INT13 reads use the local saved byte.

## Science disposition of failed campaign

`20260830T212018Z_d64_fr01_01` is `FAILED_FIXTURE_TRANSPORT / NO_RECOVERY_MECHANISM_EXECUTION`.

All 41 QEMU processes completed through the explicit failure exit35. The evaluator and independent audit failed cleanly after the robustness repairs. Static closure passed.

Because the durable sectors were not successfully read, this campaign does not support or refute CRC validation, selection, fallback, ambiguity, stale-handle rejection, or reconstruction behavior.

## What does not change

No record format, CRC parameter, commit marker, fixture media bytes, CHS mapping from Amendment B, selection rule, recovery rule, expected trace, or authority ceiling changes.
