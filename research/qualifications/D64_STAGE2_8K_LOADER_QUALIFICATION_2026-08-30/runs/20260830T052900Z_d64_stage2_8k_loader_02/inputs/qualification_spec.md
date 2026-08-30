# D64 Stage-2 8 KiB Loader Qualification Spec — 2026-08-30

**Class:** infrastructure qualification, not HOSTILE-OS scientific evidence
**Parent plan:** `research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md`
**Purpose:** qualify a fixed 16-sector / 8,192-byte stage-2 evidence envelope for D64 resource-binding scale work
**Architecture promotion:** none

## Fixed disk geometry and layout

Use a 1,474,560-byte raw floppy image with 512-byte sectors.

First-track layout:

- BIOS sector 1 / zero-based 0: 512-byte stage-1 boot loader;
- BIOS sectors 2..17 / zero-based 1..16: fixed 16-sector stage 2, exactly 8,192 on-disk bytes;
- BIOS sector 18 / zero-based 17: untouched zero sector;
- remaining image bytes: zero.

Starting at CHS sector 2, count 16 ends at sector 17 and does not cross the standard 18-sector first-track boundary.

## Stage-1 contract

Stage 1 must:

1. run at real-mode boot address `0x7C00`;
2. preserve BIOS boot drive from `DL`;
3. load exactly 16 contiguous sectors starting at CHS 0/0/2 into physical `0x8000` using BIOS INT 13h AH=02h;
4. use `AL=0x10` sector count;
5. print exactly `S1_8K_OK` only after successful read;
6. transfer control to `0000:8000`;
7. print `S1_8K_FAIL` and use the failure debug-exit path if BIOS reports carry;
8. remain exactly 512 bytes with signature `55aa`.

BIOS INT 13h remains platform/firmware transport evidence only.

## Stage-2 contract

Stage 2 must:

1. link for base address `0x8000`;
2. fit within `0x8000..0x9FFF` / 8,192 bytes;
3. place one byte `0xA5` at linked address `0x9FF0` / raw offset `0x1FF0`;
4. at runtime read/check that exact tail byte before declaring success;
5. print exactly `S2_8K_OK` only if the tail byte equals `0xA5`;
6. otherwise print `S2_8K_FAIL` and take the failure exit;
7. exit through `isa-debug-exit` producing host exit code 33 on success.

The tail check is required to show that data near the end of the 16-sector loaded extent is actually present in guest memory. A stage-2 entry point at the start alone is insufficient evidence.

## Input-snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before compilation the launcher must snapshot at least:

- this qualification spec;
- resource-binding scale plan;
- stage-1 source/linker;
- stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build must use the run-local snapshots. If a controlling input changes after snapshot but before QEMU, abort the run and use a new run ID.

## Exact success trace

```text
S1_8K_OK
S2_8K_OK
```

## Static/source closure

All checks must be literal booleans:

1. stage 1 contains BIOS read AH=02h, AL=0x10, CH=0, CL=2, DH=0 and far jump to `0000:8000`;
2. stage-1 linker fixes signature at `0x7DFE`;
3. stage-2 linker places tail section at `0x9FF0` and asserts final address <= `0xA000`;
4. stage-2 source defines tail marker byte `0xA5` and compares it before success output;
5. raw stage-2 binary includes byte `0xA5` at offset `0x1FF0`;
6. padded stage-2 extent is exactly 8,192 bytes;
7. zero-based disk sector 17 remains all zero after execution;
8. run-local input manifest/receipt source hashes agree;
9. host harness does not synthesize guest trace or mutate guest memory.

## Success criterion

Qualification passes only if:

- pre-build run-local input snapshot/manifest exists;
- stage 1 is 512 bytes / `55aa`;
- stage 2 raw <= 8,192 and tail marker is exactly at raw offset `0x1FF0`;
- stage 2 padded extent is exactly 8,192;
- QEMU completes exit 33;
- exact trace matches;
- all nine static/source checks are boolean true;
- independent closure verifies input/receipt lineage;
- sector 18 remains untouched zero.

## Authority ceiling

A pass qualifies only this fixed evidence envelope:

`STAGE1_SECTOR=1 / STAGE2_SECTORS=2..17 / STAGE2_BYTES=8192 / LOAD=0x8000..0x9FFF / FIRST_TRACK_ONLY`

It does not establish resource-binding semantics, native storage transport, arbitrary disk layout, cross-track loading, or final HOSTILE-OS image layout.
