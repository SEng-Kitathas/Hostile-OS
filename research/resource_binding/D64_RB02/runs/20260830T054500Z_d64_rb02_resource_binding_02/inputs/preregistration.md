# D64 / RB02 — corrected donor-scale resource-binding relation preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md`
**Parent plan:** `research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md`
**Required plan correction:** `research/plans/D64_RESOURCE_BINDING_LIVE_COUNT_WIDTH_CORRECTION_2026-08-30.md`
**Supersedes before execution:** D64/RB01 at `76fb008cb5e6c3ad16a8e3497dc8b781fd06cfee`
**RB01 supersession record:** `f920504`
**Qualified evidence envelope:** D64 fixed 16-sector / 8,192-byte stage 2 at `734674f8a35974433fd6a213e2a2cf1e4de93b43`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can one bounded generic relation representation support the D64 pressure of:

- 64 current activities;
- 20 binding references per activity;
- 1,280 total binding cells;
- 64 global live resources;
- and up to all 1,280 bindings sharing one resource;

while preserving explicit row/global exhaustion, exact shared-resource lifetime, binding-cell currentness after reuse, direct-resource currentness after slot reuse, and no donor `File`/descriptor-manager/inode/service primitive?

## Evidence envelope

Use the qualified D64 8 KiB loader:

- 512-byte stage 1;
- BIOS sectors 2..17 loaded to `0x8000..0x9FFF`;
- fixed stage-2 extent 8,192 bytes;
- QEMU i386 / one core / TCG;
- guest runs with maskable interrupts disabled for this discriminator;
- debug port `0xE9`;
- success through `isa-debug-exit` host exit 33.

No durability/restart, resource namespace rekey, or activity rekey is tested in RB02.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before compilation snapshot at least:

- this preregistration;
- D64 profile;
- resource-binding plan;
- live-count width correction;
- qualified 8 KiB stage-1 source/linker;
- RB02 stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build must use run-local snapshots. Receipt source hashes must bind to the manifest. If a controlling input changes after snapshot, abort and use a fresh run ID.

## Fixed representation

### Activity state

`ACTIVITY_CAP = 64` (`0x40`).

Preserve the eleven one-byte activity field species already used by A01/RK01:

1. identity
2. generation
3. progress
4. continuation
5. waiting
6. woken
7. parent slot
8. parent generation
9. wait slot
10. wait generation
11. activity epoch

All activities used by RB02 must be created through one generic checked activity-acquire path.

### Binding matrix

`BINDINGS_PER_ACTIVITY = 20` (`0x14`).

`BINDING_CELL_COUNT = 64 * 20 = 1280` (`0x0500`).

Exactly two one-byte arrays span the same 1,280 cells:

- `binding_resource_plus1[cell]`: 0 empty; 1..64 means resource slot 0..63;
- `binding_generation[cell]`: cell-reuse currentness.

Ordinary binding-cell reuse must return `G` at generation 255 rather than silently wrap to zero.

A binding handle is:

`(activity slot, activity generation, activity epoch, binding index, binding generation)`.

### Resource table

`RESOURCE_CAP = 64` (`0x40`).

Arrays:

- `resource_identity[64]`, byte;
- `resource_generation[64]`, byte;
- `resource_value[64]`, byte;
- `resource_live_count[64]`, **16-bit unsigned**;
- one global `resource_epoch` byte.

The 16-bit live count is mandatory because the declared binding matrix permits one resource to have `0x0500` / 1,280 simultaneous live bindings.

Ordinary resource-slot reuse must return `G` at resource generation 255 rather than silently wrap.

A direct resource handle is:

`(resource slot, resource generation, resource epoch)`.

## Currentness checks

### Binding handle validation

Before resource value exposure or detach:

1. validate current activity slot/generation/epoch;
2. require binding index `< 20`;
3. require binding cell nonempty;
4. require binding-generation equality;
5. decode resource slot;
6. require decoded slot `< 64` and resource identity nonzero;
7. only then expose resource value or mutate detach state.

### Direct resource handle validation

Before value exposure or bind-existing:

1. require resource slot `< 64`;
2. require resource identity nonzero;
3. require resource-generation equality;
4. require current global resource-epoch equality;
5. only then expose value or mutate binding/live-count state.

## Lifetime invariant

Every live binding cell contributes exactly one to its target resource's 16-bit live count.

A resource slot may not be reclaimed or reused while that count is nonzero.

`binding_detach` must:

1. validate the binding handle;
2. withdraw/clear the binding reference;
3. decrement the 16-bit live count;
4. preserve resource identity/value while count remains nonzero;
5. clear resource identity/value only on transition to zero;
6. preserve resource generation for later reuse currentness.

Binding generation is preserved on detach and increments only on later successful reuse.

## Good publication order

For this single-core interrupt-disabled discriminator, `bind_new_resource` must perform all row/resource capacity and currentness checks before mutation. On success publish in this order:

1. increment resource generation;
2. write resource identity;
3. write resource value;
4. set 16-bit resource live count to 1;
5. increment binding generation;
6. publish binding resource slot+1 last.

`bind_existing_resource` must validate the direct resource handle before incrementing live count or publishing the new binding reference.

## Path S — maximum sharing / count-width pressure

Reset all relation state. Set activity epoch 1 and resource epoch 1.

1. Admit all 64 activities through one generic activity-acquire path using identities `01..40`, each generation 1 / epoch 1.
2. Activity 0 creates resource identity `0x51`, value `0x7E` in resource slot 0 through `bind_new_resource`, producing binding index 0 and live count 1.
3. Bind every remaining one of the 1,279 binding cells to current resource `(slot0, generation1, epoch1)` through `bind_existing_resource`:
   - activity 0 fills indices 1..19;
   - activities 1..63 fill indices 0..19.
4. Required resource-0 live count = `0x0500`.
5. A further bind-existing attempt for activity 63 must return `F` because its 20-cell row is full.
6. Required resource-0 live count after rejection remains `0x0500`.
7. Good binding read through activity 63 / binding index 19 / binding generation 1 must return `W` and resource value `0x7E`.

## Path G — 64 distinct resources, shared lifetime, and reuse currentness

Reset all relation state. Set activity epoch 1 and resource epoch 1. Admit activities A/B/C/D into slots 0..3, generation 1 / epoch 1.

### A row and per-activity full

1. A creates 20 new resources and consumes all 20 of its binding cells.
2. Resource identities are hex `01..14`; values are hex `80..93`, so resource slot 0 has value `0x80`.
3. Save A binding-0 handle using binding generation 1.
4. Save direct resource-0 handle `(slot0, resource generation1, resource epoch1)`.
5. A's 21st new-resource bind occurs before global resource exhaustion and must return `F` because A's row is full.
6. Occupied global resource count must remain `0x0014` / 20.

### Global fill with one shared resource

7. B binding index 0 binds existing resource slot 0, making its live count 2.
8. B creates 19 additional new resources.
9. C creates 20 new resources.
10. D creates 5 new resources.
11. Occupied global resource count must be `0x0040` / 64.
12. A/B/C/D binding counts must be 20/20/20/5.
13. D then attempts one further new-resource bind while its row has free cells; this must return `F` because the global resource table is full.
14. D binding index 5 must remain empty and occupied resource count must remain 64.
15. Resource-0 live count before detach must be `0x0002`.

### Shared lifetime

16. Checked detach of A binding 0 returns `W`; resource-0 live count becomes `0x0001`.
17. B binding 0 still reads `W` / value `0x80`.
18. Checked detach of B binding 0 returns `W`; resource-0 live count becomes `0x0000`.
19. Resource-0 identity/value become zero while resource generation remains 1.

### Resource-slot and binding-cell reuse

20. D creates new resource identity `0x5A`, value `0xEE`.
21. It must use D binding index 5 and first free resource slot 0.
22. Required new resource generation = 2 and live count = 1.
23. A binds existing current resource `(slot0, generation2, epoch1)`.
24. A binding index 0 is reused and binding generation advances 1 -> 2.
25. Resource-0 live count becomes `0x0002`.

### Binding currentness controls

26. Old A binding handle with binding generation 1 must return `R` before value exposure.
27. Fresh A binding handle with binding generation 2 must return `W` / `EE`.
28. Intentionally bad binding-index-only control ignores binding generation and returns `W` / `EE` from the reused cell.

### Direct resource currentness controls

29. Old direct resource handle `(slot0, generation1, epoch1)` must return `R` before value exposure.
30. Fresh direct resource handle `(slot0, generation2, epoch1)` must return `W` / `EE`.
31. Intentionally bad resource-slot-only control ignores resource generation/epoch and returns `W` / `EE` from reused slot 0.

## Exact required debug matrix

Hex values use fixed widths where shown.

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
RES_CAP=40
CELL_COUNT=0500
SHARE_COUNT=0500
SHARE_FULL=F
SHARE_COUNT_POST=0500
SHARE_LAST=W
SHARE_VAL=7E
A_FULL=F
RES_AFTER_A=0014
GLOBAL_COUNT=0040
GLOBAL_FULL=F
D_BIND5=00
R0_LIVE2=0002
DETACH_A=W
R0_AFTER_A=0001
B_READ=W
B_VAL=80
DETACH_B=W
R0_AFTER_B=0000
R0_ID_AFTER_B=00
REUSE_NEW=W
REUSE_BIND=05
REUSE_RES=00
REUSE_RGEN=02
A_REBIND=W
A_BGEN=02
R0_LIVE=0002
OLD_BIND=R
NEW_BIND=W
NEW_BIND_VAL=EE
BAD_BIND=W
BAD_BIND_VAL=EE
OLD_RES=R
NEW_RES=W
NEW_RES_VAL=EE
BAD_RES=W
BAD_RES_VAL=EE
DONE
```

Evaluator must require exact line order and exact values.

## Static/source closure requirements

All checker values under `checks` must be literal JSON booleans. Verify at least:

1. exact named capacities 64 / 20 / 1280 / 64;
2. all eleven activity arrays use exactly 64 entries;
3. binding resource and binding-generation arrays each use exactly 1,280 cells;
4. resource identity/generation/value each use 64 entries and live-count storage uses exactly 128 bytes / 64 words;
5. one generic activity-acquire path is used by both scale paths;
6. binding row calculation is bounded to the selected activity's 20-cell row;
7. `bind_new_resource` detects row full before resource mutation and detects global resource full before binding/resource publication;
8. ordinary binding generation checks 255 and returns `G` before wrap;
9. ordinary resource generation checks 255 and returns `G` before wrap;
10. successful new-resource publication initializes resource state/live count before publishing binding resource+1;
11. `bind_existing_resource` validates current activity and direct resource handle before live-count/binding mutation;
12. resource live count is incremented/decremented using 16-bit operations;
13. `binding_detach` withdraws the binding before decrement and clears resource identity/value only when live count becomes zero, preserving resource generation;
14. good `binding_read` validates activity, binding index, nonempty cell, and binding generation before resource-value exposure;
15. good direct `resource_read` validates slot, occupancy, resource generation, and resource epoch before value exposure;
16. bad binding control omits binding-generation comparison while using the same binding matrix;
17. bad resource control omits resource-generation/epoch comparison while using the same resource table;
18. full/reject branches do not mutate the protected state they reject;
19. max-sharing path iterates the full 64 x 20 binding-cell population through generic operations and runtime count reaches `0x0500`;
20. run-local input snapshots/manifest exist before build, receipt source hashes match snapshots, and host launcher/evaluator/checker do not mutate guest relation state or synthesize debug lines.

## Measurements required

Record at least:

- stage-2 raw bytes and 8 KiB fit;
- named runtime-state bytes;
- activity capacity 64;
- bindings/activity 20;
- total binding cells 1,280;
- global resource capacity 64;
- live-count width 16 bits;
- max observed live count `0x0500`;
- binding-generation width 8 bits;
- resource-generation width 8 bits;
- max binding-row scan 20;
- max resource scan 64;
- QEMU wall time as harness data;
- input-manifest SHA-256;
- exact source/artifact hashes.

## Success criterion

RB02 passes only if one controlling run:

- has complete pre-build run-local input snapshots/manifest;
- fits stage 2 inside qualified 8 KiB;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all static/source checks are literal boolean true;
- independent closure verifies manifest/receipt/run-local-source lineage;
- all failed attempts/scars remain visible.

## Authority ceiling

A passing RB02 may establish only:

> one bounded generic relation representation supports the D64 64-activity / 20-binding-per-activity / 64-global-resource pressure workload, including the 1,280-binding maximum-sharing case, separate row/global exhaustion, tested shared lifetime, binding-cell reuse currentness, and direct resource-slot reuse currentness inside the qualified 8 KiB freestanding envelope.

It does **not** establish:

- historical `File`/descriptor/inode architecture;
- POSIX/DOS filesystem semantics;
- arbitrary resource types;
- dynamic allocation;
- unlimited capacity;
- resource namespace rekey;
- activity rekey composed with live bindings;
- general capability safety;
- crash durability;
- SMP/NMI/DMA correctness;
- physical hardware behavior;
- final architecture;
- R3.1/R6 authority change.
