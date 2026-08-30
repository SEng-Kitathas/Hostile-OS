# D64 / RB01 — bounded resource-binding scale preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md`
**Parent plan:** `research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md`
**Activity scale evidence:** D64/A01 CLOSED PASS
**Activity namespace rule:** D64/RK01 adopted at current shadow scope
**8 KiB loader qualification:** `734674f8a35974433fd6a213e2a2cf1e4de93b43`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can a generic relation representation support the D64 donor-scale pressure of 20 binding references per activity and 64 global live resources, preserve shared-resource lifetime, reject stale binding-cell and direct-resource handles after reuse, and expose per-activity/global exhaustion separately — without importing a historical `File`, descriptor manager, allocator, or service object?

## Evidence envelope

Use the qualified D64 fixed 8 KiB loader:

- 512-byte stage 1;
- stage 1 loads exactly 16 sectors / 8,192 bytes from BIOS sectors 2..17 to `0x8000..0x9FFF`;
- stage 2 must fit inside the exact 8,192-byte loaded extent;
- QEMU i386, one core, TCG;
- stage-2 guest executes with maskable interrupts disabled for this discriminator;
- debug port `0xE9`;
- deterministic `isa-debug-exit` success exit 33.

No durability/restart is tested in RB01.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before compilation snapshot at least:

- this preregistration;
- D64 profile;
- resource-binding plan;
- qualified 8 KiB stage-1 source/linker;
- RB01 stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build must use the run-local snapshots and the receipt must bind to their manifest.

## Fixed representation

### Activities

`ACTIVITY_CAP = 64`.

Preserve the existing eleven one-byte activity field species per slot. Four current activities are used in the scale workload:

- A = activity slot 0 / generation 1 / epoch 1;
- B = slot 1 / generation 1 / epoch 1;
- C = slot 2 / generation 1 / epoch 1;
- D = slot 3 / generation 1 / epoch 1.

They must be created through one generic activity-acquire path.

### Binding matrix

`BINDINGS_PER_ACTIVITY = 20` (`0x14`).

`BINDING_CELL_COUNT = 64 * 20 = 1280`.

Exactly two one-byte arrays span the same 1,280 cells:

- `binding_resource_plus1[cell]`: 0 empty; otherwise resource slot+1;
- `binding_generation[cell]`: generation/currentness for reuse of the binding cell.

Ordinary binding-cell reuse must fail `G` at generation 255 rather than silently wrap to zero.

A binding handle for RB01 is:

`(activity slot, activity generation, activity epoch, binding index, binding generation)`.

### Resource table

`RESOURCE_CAP = 64` (`0x40`).

Exactly four one-byte arrays of 64 entries:

- `resource_identity`;
- `resource_generation`;
- `resource_value`;
- `resource_live_count`.

One global `resource_epoch` byte is used by direct resource handles.

A direct resource handle is:

`(resource slot, resource generation, resource epoch)`.

Ordinary resource-slot reuse must fail `G` at resource generation 255 rather than silently wrap.

## Currentness and lifetime invariant

For this discriminator:

> a resource slot may not be reclaimed or reused while `resource_live_count > 0`, and every live binding cell contributes exactly one to that count.

Therefore a live binding cell may store the resource slot only; it does not copy resource generation.

Binding-cell currentness is supplied by `binding_generation`. Direct resource-handle currentness is supplied by resource generation + resource epoch.

## Coupled transition rule

RB01 runs with maskable interrupts disabled. For the bounded single-core fixture, `bind_new_resource` must publish the binding cell only **after** the new resource record is initialized.

Required good mutation order after all capacity/currentness checks pass:

1. increment resource generation;
2. write resource identity;
3. write resource value;
4. set resource live count = 1;
5. increment binding generation;
6. publish binding resource slot+1 last.

`binding_detach` must withdraw the binding reference before decrementing resource live count. If the count becomes zero, only then may resource identity/value be cleared.

No claim is made about SMP or interruptible concurrent mutation.

## Runtime path A — scale and separate exhaustion

1. Initialize four activities A-D through the generic activity acquire path.
2. Through one generic `bind_new_resource` routine, A creates 20 resources/bindings.
3. A's 21st new-resource bind is attempted **before** the global resource table is full.
4. Required A21 result: `F` due to its 20-cell binding row being full.
5. Required global live-resource count remains 20 (`0x14`) after A21.
6. B creates 20 resources/bindings.
7. C creates 20 resources/bindings.
8. D creates 4 resources/bindings.
9. Required global live-resource count becomes 64 (`0x40`).
10. Required binding counts: A=20, B=20, C=20, D=4.
11. D then attempts one more new-resource bind while its row still has free binding cells.
12. Required result: `F` due to global resource table full.
13. Required D binding count remains 4 and global resource count remains 64.

This separates per-activity binding exhaustion from global resource exhaustion.

## Runtime path B — shared lifetime

Reset only binding/resource state in guest code; keep current A-D activity handles.

1. A creates resource identity `0x52` (`R`) with value `0x58` (`X`).
2. Save direct resource handle `(slot0, generation1, resource_epoch1)`.
3. B binds the same current resource through `bind_existing_resource`.
4. Required resource live count = 2.
5. A detaches its binding through generic `binding_detach`.
6. Required live count = 1.
7. Required resource identity/value still `0x52/0x58`.
8. B detaches its binding.
9. Required live count = 0.
10. Required resource identity/value cleared to zero.

## Runtime path C — binding/resource reuse currentness

Continue from path B after final reclaim.

1. A creates a new resource identity `0x5A` (`Z`) with value `0x59` (`Y`).
2. It must reuse binding cell A/index0 and resource slot0.
3. Required binding generation = 2.
4. Required resource generation = 2.
5. Old binding handle `(A,gen1,epoch1,index0,binding_gen1)` must return `R` before value exposure.
6. Fresh binding handle using binding generation 2 must return `W` and value `0x59`.
7. Intentionally bad binding-index-only read, ignoring binding generation, must return `W` and value `0x59`, exposing retargeting.
8. Old direct resource handle `(slot0,res_gen1,res_epoch1)` must return `R` before value exposure.
9. Fresh direct resource handle generation 2 must return `W` and value `0x59`.
10. Intentionally bad resource-slot-only read, ignoring resource generation/epoch, must return `W` and value `0x59`.

The bad reads are negative controls only and must not be used by the good paths.

## Exact required debug matrix

Hex values use two digits.

```text
ACT_CAP=40
BIND_CAP=14
RES_CAP=40
A_FILL=14
A21=F
RES_AFTER_A21=14
B_FILL=14
C_FILL=14
D_FILL=04
RES_COUNT=40
GLOBAL65=F
D_AFTER_GLOBAL65=04
RES_AFTER_GLOBAL65=40
SHARED_LIVE=02
DETACH_A=W
LIVE_AFTER_A=01
SHARED_ID_AFTER_A=52
SHARED_VAL_AFTER_A=58
DETACH_B=W
LIVE_AFTER_B=00
ID_AFTER_B=00
VAL_AFTER_B=00
REUSE=W
REUSE_BIND_GEN=02
REUSE_RES_GEN=02
STALE_BIND=R
FRESH_BIND=W
FRESH_BIND_VAL=59
BAD_BIND=W
BAD_BIND_VAL=59
STALE_RES=R
FRESH_RES=W
FRESH_RES_VAL=59
BAD_RES=W
BAD_RES_VAL=59
DONE
```

Evaluator must require exact line order and values.

## Static/source closure requirements

All checks must be literal booleans and verify:

1. `ACTIVITY_CAP=64`, `BINDINGS_PER_ACTIVITY=20`, `BINDING_CELL_COUNT=1280`, `RESOURCE_CAP=64` are named constants;
2. all eleven activity arrays use 64 entries;
3. exactly two 1,280-cell binding arrays exist and exactly four 64-entry resource arrays exist;
4. one generic activity acquire path creates A-D;
5. one generic `bind_new_resource` scans only the selected activity's 20-cell row and checks row full before resource mutation;
6. `bind_new_resource` checks global resource full before mutation when a binding cell is available;
7. ordinary binding/resource generation increments fail `G` at 255 rather than wrapping;
8. new-resource mutation publishes the binding reference only after resource identity/value/live-count initialization;
9. `bind_existing_resource` validates the direct resource handle before incrementing live count or publishing a binding;
10. `binding_detach` clears the binding reference before decrementing live count and clears resource identity/value only when live count reaches zero;
11. good `binding_read` validates activity, binding index, nonempty cell, and binding-generation equality before resource value exposure;
12. good direct `resource_read` validates resource slot, occupancy, resource generation, and resource epoch before value exposure;
13. bad binding read ignores binding generation and bad resource read ignores resource generation/epoch; neither is called by a good read path;
14. scale path attempts A21 before B/C/D global fill, while GLOBAL65 occurs only after 64 resources are present;
15. shared-lifetime and reuse paths use the same binding/resource arrays and good operations as scale path;
16. run-local input snapshots/manifest exist before build and receipt source hashes match snapshots;
17. host launcher/evaluator/static checker do not mutate guest relation state or synthesize guest debug lines;
18. all checker values under `checks` are literal JSON booleans.

## Measurements required

Record at least:

- stage-2 raw bytes;
- named runtime-state bytes;
- activity capacity 64;
- binding cells per activity 20;
- total binding cells 1,280;
- resource capacity 64;
- activity field species 11;
- binding field species 2;
- resource field species 4 + one epoch;
- maximum binding-row scan iterations 20;
- maximum resource scan iterations 64;
- coupled new-resource publication region instruction count or source-operation count;
- QEMU wall time as harness data;
- input-manifest/source/artifact hashes.

## Success criterion

RB01 passes only if one controlling run:

- has a complete pre-build run-local input snapshot/manifest;
- builds inside the qualified 8 KiB stage-2 extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all 18 static/source checks are literal boolean true;
- independent closure verifies run-local source/manifest/receipt lineage;
- engineering scars remain visible.

## Authority ceiling

A passing RB01 may establish only:

> one bounded generic relation representation can carry D64 pressure of 20 binding cells per activity and 64 global live resources, preserve the tested shared-lifetime invariant, expose distinct row/global exhaustion, and reject the tested stale binding/resource handles after reuse.

It does **not** establish:

- historical `File` architecture;
- POSIX descriptor or filesystem semantics;
- arbitrary resource types;
- dynamic allocation;
- unlimited capacities;
- resource namespace rekey;
- activity rekey composed with live binding rows;
- crash durability;
- SMP/NMI/DMA correctness;
- native storage transport;
- final architecture;
- R3.1/R6 authority change.
