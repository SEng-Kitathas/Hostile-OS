# H1-SMP-MIN01 result — AP bring-up fit test

Status: **CLOSED PASS / INTEGRATION QUALIFICATION**
Implementation commit: `1f7852d`
Controlling run: `runs/20260831T055649Z_h1_smp_min01_01`

The exact D64-v2 body was extended only with S-mode AP startup/provenance and three handshake bytes placed inside the existing128-byte implementation-scratch allowance.

Verified:
- linked runtime footprint: **7811 / 8192 bytes**;
- remaining headroom: **381 bytes**;
- named semantic state unchanged: **3467 bytes**;
- H1 QEMU proxy S mode exact: BSP APIC00, AP APIC01, ready1, clean exit33;
- H1 QEMU proxy C mode retained the exact current D64-v2 core+IRQ trace;
- Bochs one-CPU replay retained exact core, restart and all five faulted-media semantics/invariants.

Consequence: **second-core startup/provenance does not force an envelope enlargement.** The current8 KiB body can absorb the H1 AP bring-up transport while preserving existing semantics.

MIN01 does not establish relation-table SMP safety or replace `d64_reference_v2`. Proceed to MIN02 whole-operation-gate composition as planned.
