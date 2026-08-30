# D64 / PR01 — expanded relation clean-restart persistence preregistration

**Mode:** BUILD-COMMIT
**Parent plan:** `research/plans/D64_EXPANDED_RELATION_CLEAN_RESTART_PLAN_2026-08-30.md`
**Parent persistence evidence:** I001 CLOSED PASS
**Parent D64 relation evidence:** A01 / RK01 / RB02 / ARB01 / RR01 / IRQ01 CLOSED at bounded scopes
**Qualified loader:** fixed 8 KiB stage-2 envelope
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Across two distinct QEMU processes using one shared raw floppy image, can durable resource identity/value survive boot-1 runtime reclamation while boot 2 reconstructs the full D64 relation under fresh activity/resource namespaces, rejecting intentionally reused boot-1 binding/resource handles even though slot/generation/index values repeat?

## Evidence envelope

Use the qualified 8 KiB layout:

- BIOS sector 1: stage 1;
- BIOS sectors 2..17: fixed 8,192-byte stage 2 loaded at `0x8000..0x9FFF`;
- BIOS sector 18 / zero-based sector17: one 512-byte durable sector;
- remaining disk sectors stay fixture-zero unless guest writes them;
- QEMU i386 / TCG / one core;
- no IRQ/PIC takeover in PR01;
- debug port `0xE9`;
- `isa-debug-exit` success exit 33 for both boots.

BIOS INT13 is firmware/platform transport evidence only.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before build snapshot at least:

- this preregistration;
- parent persistence plan;
- I001 result;
- RB02 result;
- ARB01 result/adoption review;
- RR01 result/adoption review;
- IRQ01 result/adoption review;
- qualified 8 KiB stage-1 source/linker;
- PR01 stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build only from run-local snapshots. Receipt source hashes must bind to the manifest.

## Fixed D64 runtime representation

Link the earned static D64 relation sizes:

- `ACTIVITY_CAP = 64`;
- `BINDINGS_PER_ACTIVITY = 20`;
- `BINDING_CELL_COUNT = 1280`;
- `RESOURCE_CAP = 64`;
- eleven one-byte activity arrays of 64 entries;
- one activity namespace epoch byte;
- `binding_resource_plus1[1280]`;
- `binding_generation[1280]`;
- resource identity/generation/value arrays of 64 bytes each;
- 64 16-bit resource live counts;
- one resource namespace epoch byte.

PR01 does not persist this runtime table image.

## Durable record

The first 20 bytes of BIOS sector18 are fixed:

| Offset | Meaning | Boot 1 expected | Boot 2 expected after persistence update |
|---|---|---:|---:|
| 0..3 | magic | ASCII `H4P1` | unchanged |
| 4 | durable identity | `51` | unchanged |
| 5 | durable value | `7E` | unchanged |
| 6 | last activity epoch | `01` | `02` |
| 7 | last resource epoch | `01` | `02` |
| 8 | historical activity slot | `00` | unchanged |
| 9 | historical activity generation | `01` | unchanged |
| 10 | historical activity epoch | `01` | unchanged |
| 11 | historical binding index | `00` | unchanged |
| 12 | historical binding generation | `01` | unchanged |
| 13 | historical resource slot | `00` | unchanged |
| 14 | historical resource generation | `01` | unchanged |
| 15 | historical resource epoch | `01` | unchanged |
| 16 | marker low | `34` | unchanged |
| 17 | marker high | `12` | unchanged |
| 18 | record version | `01` | unchanged |
| 19 | reserved | `00` | unchanged |

Bytes 20..511 must remain zero after both boots.

Historical handle bytes are negative-control evidence only. They are never hydrated as current state.

## Boot 1 required sequence

1. Stage 1 prints `S1_8K_OK`.
2. Stage 2 saves boot drive and reads BIOS sector18.
3. Absent `H4P1` magic selects Boot 1.
4. Explicitly initialize the full D64 runtime arrays.
5. Set activity epoch = 1 and resource epoch = 1.
6. Generic activity acquire creates A identity `0x41` at slot0/gen1/epoch1.
7. Generic `bind_new_resource` creates durable resource identity `0x51`, value `0x7E` at binding index0/gen1 and resource slot0/gen1/epoch1 with live count1.
8. Ordinary checked `binding_read` returns `W / 0x7E`.
9. Serialize the exact 20-byte durable record including the boot-1 historical handles.
10. Guest writes BIOS sector18 and returns `W`.
11. Checked `binding_detach` returns `W`, live count becomes zero, resource identity/value clear, resource generation remains1.
12. Checked `activity_release` returns `W` only after row0 is empty; activity identity clears and generation remains1.
13. Exit QEMU success.

## Boot 1 exact debug matrix

```text
S1_8K_OK
BOOT=1
DURABLE_PRESENT=00
A_ACQ=W
A_SLOT=00
A_GEN=01
A_EPOCH=01
BIND=W
BIND_INDEX=00
BIND_GEN=01
RES_SLOT=00
RES_GEN=01
RES_EPOCH=01
READ=W
READ_VAL=7E
PERSIST1=W
DETACH=W
LIVE_AFTER_DETACH=0000
RES_ID_AFTER_DETACH=00
RELEASE=W
ACT_ID_AFTER_RELEASE=00
DONE1
```

## Boot 2 required sequence

1. Launch a second, distinct QEMU process against the same disk image.
2. Stage 1 prints `S1_8K_OK`.
3. Stage 2 reads sector18 and exact `H4P1` magic selects Boot2.
4. Verify durable identity `0x51`, value `0x7E`, marker `0x1234`, version1, last activity epoch1, last resource epoch1.
5. Explicitly initialize the full D64 runtime arrays to empty.
6. Independently compute next activity epoch =2 and resource epoch =2. If either durable prior epoch is255, ordinary restart setup returns `G` rather than silently wrapping.
7. Before any acquire/rebind, the historical boot-1 binding handle returns `R` and historical direct resource handle returns `R`.
8. Generic activity acquire intentionally reuses slot0/gen1, now under activity epoch2.
9. Generic bind-new/rebind intentionally reuses binding index0/gen1 and resource slot0/gen1, now under resource epoch2, using durable identity/value.
10. Historical boot-1 binding handle `(slot0,actgen1,actepoch1,index0,bgen1)` returns `R` before value exposure.
11. Historical boot-1 direct resource handle `(slot0,resgen1,repoch1)` returns `R` before value exposure.
12. Fresh checked binding handle returns `W / 0x7E`.
13. Fresh checked direct resource handle returns `W / 0x7E`.
14. Deliberately bad binding control that omits activity epoch returns `W / 0x7E` under the intentionally reused slot/gen/index/binding-generation values.
15. Deliberately bad resource control that omits resource epoch returns `W / 0x7E` under intentionally reused slot/resource-generation values.
16. Update only durable offsets6 and7 from1 to2 and write sector18. Durable identity/value, boot-1 historical handle bytes, marker/version, and all zero tail bytes remain unchanged.
17. Exit QEMU success.

## Boot 2 exact debug matrix

```text
S1_8K_OK
BOOT=2
DURABLE_PRESENT=01
DUR_ID=51
DUR_VAL=7E
DUR_ACT_EPOCH=01
DUR_RES_EPOCH=01
OLD_BIND_PRE=R
OLD_RES_PRE=R
A_ACQ=W
A_SLOT=00
A_GEN=01
A_EPOCH=02
REBIND=W
BIND_INDEX=00
BIND_GEN=01
RES_SLOT=00
RES_GEN=01
RES_EPOCH=02
OLD_BIND_POST=R
OLD_RES_POST=R
FRESH_BIND=W
FRESH_BIND_VAL=7E
FRESH_RES=W
FRESH_RES_VAL=7E
BAD_BIND_EPOCHLESS=W
BAD_BIND_VAL=7E
BAD_RES_EPOCHLESS=W
BAD_RES_VAL=7E
PERSIST2=W
DONE2
```

Evaluator must require exact line order and values independently for boot1 and boot2.

## Durable-sector exact byte closure

After Boot1, bytes0..19 must be:

```text
48 34 50 31 51 7E 01 01 00 01 01 00 01 00 01 01 34 12 01 00
```

After Boot2, bytes0..19 must be:

```text
48 34 50 31 51 7E 02 02 00 01 01 00 01 00 01 01 34 12 01 00
```

Bytes20..511 must be zero in both extracted durable sectors.

## Static/source closure requirements

Every checker value under `checks` must be a literal JSON boolean. Verify at least:

1. exact D64 capacities and all full-sized activity/binding/resource arrays;
2. resource live-count storage is exactly 128 bytes / 64 words;
3. stage2 linker fits <= `0xA000` / 8,192-byte extent;
4. BIOS durable transport is exactly one sector at CH0/CL18/DH0 and uses saved boot drive;
5. durable logical record is exactly20 bytes and tail zeroing covers bytes20..511 before Boot1 write;
6. boot selection is based on durable magic, not host-selected mode;
7. one generic activity-acquire routine is used on both boots;
8. one generic bind-new/rebind routine is used on both boots and publishes binding only after resource initialization/live count;
9. ordinary checked binding read validates activity slot/gen/epoch and binding index/gen before value exposure;
10. ordinary checked direct resource read validates resource slot/gen/epoch before value exposure;
11. Boot1 serialization copies only declared durable fields/historical scalar handles; no loop copies activity/binding/resource runtime arrays into the durable sector;
12. Boot1 detach clears binding ref before 16-bit live-count decrement and clears resource identity/value only on zero;
13. Boot1 checked activity release scans the selected20-cell binding row before identity clear;
14. Boot2 explicitly resets the full runtime relation before rebind;
15. Boot2 next activity and resource epochs are derived independently from durable offsets6/7 and ordinary setup fails `G` at prior255 instead of wrapping;
16. old boot1 binding/resource checks occur both before and after rebind;
17. post-rebind old binding check uses old activity epoch1 against current epoch2 before value exposure;
18. post-rebind old resource check uses old resource epoch1 against current epoch2 before value exposure;
19. fresh binding/direct-resource checks use current epoch2 and expose durable value only after full validation;
20. bad binding control omits activity epoch but otherwise validates reused slot/gen/index/binding-generation;
21. bad resource control omits resource epoch but otherwise validates reused slot/resource-generation;
22. Boot2 persistence update changes only durable last-activity/resource epoch bytes among dynamic durable fields before write;
23. launcher uses one disk image and two distinct QEMU processes in strict Boot1-complete -> Boot2-start order;
24. launcher performs no host disk write/mutation between boot processes;
25. host evaluator/checker/launcher do not synthesize guest debug lines or runtime relation state;
26. run-local input snapshots/manifest exist before build and receipt source hashes match snapshots;
27. all checker values are literal JSON booleans.

## Launcher / process requirements

The controlling launcher must record:

- Boot1 PID, start/end/status/exit/wall time;
- Boot2 PID, start/end/status/exit/wall time;
- distinct PID check;
- Boot2 start strictly after Boot1 terminal end;
- same disk-image path/hash chain;
- durable-sector SHA after Boot1 and after Boot2;
- no host mutation between boots;
- exact evaluator/static/audit hashes.

A timeout or ambiguous process state is `UNKNOWN`, not PASS/FAIL inference.

## Measurements required

Record at least:

- stage2 raw bytes / 8,192-byte extent;
- named runtime-state bytes;
- activity capacity64;
- bindings/activity20;
- binding cells1,280;
- resource capacity64;
- resource live-count width16 bits;
- durable logical record20 bytes in one512-byte sector;
- Boot1/Boot2 QEMU wall times as harness data;
- durable-sector hashes after each boot;
- input-manifest/source/artifact hashes.

## Success criterion

PR01 passes only if one controlling two-process run:

- snapshots all controlling inputs before build;
- builds within the qualified8KiB extent;
- Boot1 completes exit33 with exact Boot1 matrix;
- durable sector after Boot1 exactly matches the preregistered bytes and zero tail;
- Boot2 is a distinct later QEMU process on the same disk and completes exit33 with exact Boot2 matrix;
- durable sector after Boot2 exactly matches the preregistered bytes and zero tail;
- evaluator passes both traces;
- all27 static/source checks are literal true;
- independent closure verifies source/manifest/receipt/process/disk lineage;
- engineering scars remain visible.

## Authority ceiling

A passing PR01 may establish only:

> under clean restart across two fresh QEMU processes, the tested durable identity/value outlives boot-1 runtime relation reclamation; boot2 reconstructs the D64 relation explicitly under fresh activity/resource namespace epochs; intentionally reused boot-1 binding/resource handles remain stale because their namespace epochs are old, while epoch-omitting controls retarget to the reconstructed relation.

It does not establish:

- crash/partial-write durability;
- power-fail atomicity;
- filesystem semantics;
- arbitrary durable object graphs;
- unlimited reboot epoch lifetime;
- external capability revocation;
- SMP/NMI/DMA/weak-memory correctness;
- native post-takeover storage transport;
- final/canonical/production architecture;
- R3.1/R6 authority change.
