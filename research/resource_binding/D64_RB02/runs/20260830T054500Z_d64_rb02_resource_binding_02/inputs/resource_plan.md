# D64 Resource-Binding Scale Plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent profile:** D64 donor-scale reference profile
**Activity scale evidence:** D64/A01 CLOSED PASS
**Activity namespace renewal:** RK01 adopted at current D64 shadow scope
**Experiment preregistration:** not created by this document
**Architecture promotion:** none

## Problem

D64 uses two donor-scale resource-pressure numbers:

- up to 20 simultaneous binding references from one activity;
- 64 global live resources.

I001 proved only one shared backing with a live count. It does not establish this scale or the relation layout needed to carry it.

The job is to derive the smallest generic relation representation that can express the pressure without importing donor `File`, descriptor-manager, inode, or service objects by name.

## Required behaviors, not donor nouns

The target pressure requires only these behaviors at this stage:

1. a current activity can hold up to 20 independently addressable bindings;
2. a binding refers to one current global resource;
3. more than one activity/binding may share a resource;
4. a resource cannot be reclaimed/reused while a live binding still refers to it;
5. releasing one shared binding preserves the resource for the others;
6. releasing the final binding permits bounded reclaim;
7. per-activity binding exhaustion is explicit and non-mutating;
8. global resource exhaustion is explicit and non-mutating;
9. stale binding-index reuse must not silently retarget if binding handles are part of the current interface;
10. stale direct resource handles must be rejected before resource value exposure.

Nothing in this list requires a historical File object.

## Candidate relation representation

### Existing activity state

Retain the current D64 activity representation:

- 64 activity slots;
- eleven one-byte activity field species per slot;
- activity handles already qualified as `(slot, generation, activity_epoch)`.

Activity state cost: `64 * 11 = 704` bytes.

### Binding matrix

`BINDINGS_PER_ACTIVITY = 20`.

`BINDING_CELL_COUNT = 64 * 20 = 1,280`.

Use two one-byte arrays over the same 1,280 cells:

1. `binding_resource_plus1[cell]`
   - `0` = empty;
   - `1..64` = resource slot `0..63` plus one.
2. `binding_generation[cell]`
   - zero invalid before first successful bind;
   - increment on each successful reuse;
   - ordinary reuse fails `G` rather than silently wrap from 255 to zero.

Binding matrix cost: `1,280 * 2 = 2,560` bytes.

### Why binding generation is included

A one-byte resource-slot reference alone is smaller, but a stale `(activity,binding_index)` can silently retarget after the same binding cell is detached and reused.

The project already has repeated evidence that bare location/index is not currentness.

Therefore a current binding handle should include:

`(activity slot, activity generation, activity epoch, binding index, binding generation)`

The binding-generation byte pays rent by distinguishing reuse of the same per-activity binding cell.

### Global resource table

`RESOURCE_CAP = 64`.

Use four one-byte arrays:

1. `resource_identity[64]`
2. `resource_generation[64]`
3. `resource_value[64]`
4. `resource_live_count[64]`

Plus one global `resource_epoch` byte for direct resource-handle currentness.

Global resource-table array cost: `64 * 4 = 256` bytes, plus the epoch byte.

A direct resource handle, where needed for sharing, is:

`(resource slot, resource generation, resource_epoch)`.

## Binding-to-resource currentness rule

A live binding cell does not need to copy resource generation if this invariant is preserved:

> a resource slot may not be reclaimed or reused while `resource_live_count > 0`, and every live binding cell contributes exactly one to that count.

Under that invariant:

- a live binding cell cannot silently point at a different occupant of the same resource slot;
- direct resource handles still use resource generation/epoch currentness;
- binding handles use their own binding generation to prevent binding-cell reuse retargeting.

If later evidence shows the live-count/binding relation can drift or must tolerate partial updates, resource generation may need to be copied into each binding. Do not pay that extra 1,280-byte cost before it is earned.

## Candidate operations

### `bind_new_resource`

Inputs:

- current activity handle;
- resource identity/value.

Behavior:

1. validate current activity handle;
2. find first free binding cell within that activity's 20-cell row;
3. fail `F` if row is full, before resource mutation;
4. fail `G` if that free binding cell's generation is exhausted;
5. find first free global resource slot;
6. fail `F` if resource table is full, before binding/resource mutation;
7. fail `G` if selected free resource slot generation is exhausted;
8. increment binding generation and resource generation;
9. initialize resource identity/value/live_count=1;
10. store resource slot+1 in binding cell;
11. return binding index and currentness data.

The mutation order must not leave a live resource without its first binding or a binding pointing at an uninitialized resource if interrupted/failed. A later preregistration must choose an explicit single-core coherence rule for this coupled transition.

### `bind_existing_resource`

Inputs:

- current activity handle;
- current direct resource handle.

Behavior:

1. validate activity;
2. validate direct resource handle before value/currentness exposure;
3. find free binding cell;
4. check binding generation capacity;
5. store resource slot+1;
6. increment resource live count;
7. return current binding handle.

### `binding_read`

Inputs:

- current activity handle;
- binding index;
- binding generation.

Behavior:

1. validate current activity;
2. require binding index `< 20`;
3. require binding cell nonempty;
4. require binding-generation equality;
5. decode resource slot;
6. require resource slot `< 64` and resource identity nonzero;
7. only then expose resource value.

### `binding_detach`

Behavior:

1. validate activity and binding handle;
2. read bound resource slot;
3. clear the binding cell's resource reference;
4. decrement resource live count;
5. if count remains nonzero, preserve resource;
6. if count reaches zero, clear resource identity/value and leave resource generation for future reuse currentness;
7. return explicit status.

Binding generation is not reset on detach. It advances on next successful reuse.

## Scale workload for a future discriminator

A bounded scale discriminator should use at least four current activities so the global 64-resource pressure is reachable without exceeding the per-activity 20-binding ceiling.

Suggested fill distribution:

- Activity A: 20 new resources;
- Activity B: 20 new resources;
- Activity C: 20 new resources;
- Activity D: 4 new resources.

Total: 64 live resources and 64 live bindings.

Then:

- A's 21st binding attempt must return `F` without mutation;
- a 65th global resource creation attempt from D must return `F` without mutation.

Separate bounded subpaths should pressure:

- shared resource live count 2 -> 1 -> 0;
- stale binding-cell handle after detach/reuse;
- stale direct resource handle after resource slot reuse;
- bad overwrite-on-full controls where useful.

Do not require all 1,280 binding cells to be simultaneously populated merely because the matrix supports them. The D64 profile requires the **capacity to hold 20 per activity**, while the declared global live-resource pressure is 64.

## Static memory cost

Core arrays if the full current activity state and stale-safe binding generation are retained:

- activity arrays: `704` bytes;
- binding resource matrix: `1,280` bytes;
- binding-generation matrix: `1,280` bytes;
- resource arrays: `256` bytes;
- resource epoch: `1` byte.

Core relation-state subtotal:

`3,521` bytes`

before observation/status scratch and code.

This is small in conventional x86 RAM, but it changes the old 4 KiB evidence envelope because code plus statically materialized zero arrays will not fit comfortably in the existing eight-sector stage-2 image.

## Evidence-envelope decision

Do not distort the relation model just to preserve the old 4 KiB loader envelope.

Preferred next infrastructure step:

- qualify a fixed **16-sector / 8,192-byte stage-2 loader** using the same simple BIOS CHS track;
- sector 1 = stage 1;
- sectors 2..17 = stage 2, exactly 16 sectors;
- load to `0x8000` through `0x9FFF`;
- no durable sector needed for the resource-scale discriminator;
- keep runtime relation state and code inside the explicit 8 KiB extent for the first scaling witness.

Starting at floppy sector 2, a 16-sector read ends at sector 17, still inside the standard 18-sector first track. This must be qualified before it becomes experiment infrastructure.

Alternative NOLOAD/BSS placement above the loaded extent is technically possible and may be smaller on disk, but it introduces another initialization/memory-envelope variable. The fixed 8 KiB loaded envelope is the cleaner first discriminator.

## Interaction with activity rekey

Once binding cells exist, the adopted RK01 activity rekey rule must eventually be extended/replayed:

- activity rekey cannot succeed while any binding owned by an activity remains live;
- a future integrated rekey must either require all binding rows empty or explicitly revoke them;
- RK01 did not include the binding matrix and therefore does not establish this composition yet.

Do not silently assume the old rekey scan covers newly added state.

## Resource namespace exhaustion

Resource generation/epoch has the same finite-namespace problem already exposed for activities.

The scale discriminator may use generation values 1 and 2 only and keep 8-bit fields as witness widths.

A general resource-namespace rekey is **not** earned by the activity RK01 result and should not be bundled into the first resource-scale experiment.

## Next lawful steps

1. qualify the fixed 16-sector / 8 KiB stage-2 loader;
2. after qualification, preregister one D64 resource-binding scale discriminator with exact matrix and negative controls;
3. require the run-input snapshot protocol from attempt 1;
4. measure loaded bytes, runtime-state bytes, binding/resource capacities, scan costs, and coupled-transition critical section;
5. keep resource-rekey and activity-rekey-with-bindings as explicit later seams.

## Authority ceiling

Even a passing resource-scale discriminator would establish only a bounded relation representation for the D64 20-per-activity / 64-global pressure workload.

It would not establish:

- historical File architecture;
- arbitrary file descriptors or POSIX semantics;
- dynamic allocation;
- arbitrary resource types;
- unlimited bindings/resources;
- general capability safety;
- resource namespace renewal;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.

## Disposition

`D64_RESOURCE_BINDING_PLAN_READY / 64_ACTIVITIES_X_20_BINDING_CELLS / 64_GLOBAL_RESOURCES / BINDING_GENERATION_CURRENTNESS / 8K_STAGE2_QUALIFICATION_REQUIRED / NO_EXPERIMENT_YET`
