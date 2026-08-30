# D64 / AR01 — binding-aware activity release/rekey composition preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** D64 donor-scale reference profile
**Parent activity-rekey evidence:** D64/RK01 CLOSED PASS + adopted D64 shadow rule
**Parent resource-binding evidence:** D64/RB02 CLOSED PASS
**Parent composition plan:** `research/plans/D64_ACTIVITY_REKEY_BINDING_COMPOSITION_PLAN_2026-08-30.md`
**Qualified evidence envelope:** fixed 16-sector / 8,192-byte stage 2 at `734674f8a35974433fd6a213e2a2cf1e4de93b43`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can the adopted checked activity lifecycle/rekey rule compose with the D64 binding/resource relation so that:

- an activity with a nonempty binding row cannot be safely released;
- activity namespace rekey cannot proceed while binding/resource relation state remains live;
- explicit binding detach followed by activity release permits rekey;
- successful rekey resets activity and binding namespace state while leaving resource epoch unchanged;
- and an intentionally unsafe activity release exposes the predicted failure: a later occupant of the same activity slot inherits/reads the prior occupant's live binding relation?

## Evidence envelope

Use the qualified D64 8 KiB loader:

- 512-byte stage 1;
- BIOS sectors 2..17 loaded to `0x8000..0x9FFF`;
- fixed stage-2 extent 8,192 bytes;
- QEMU i386 / one core / TCG;
- maskable interrupts disabled for this discriminator;
- debug port `0xE9`;
- success through `isa-debug-exit` host exit 33.

No durability/restart, resource-namespace rekey, or asynchronous observer is tested.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before compilation snapshot at least:

- this preregistration;
- D64 target profile;
- activity/binding composition plan;
- RK01 result;
- RB02 result;
- qualified 8 KiB stage-1 source/linker;
- AR01 stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build must use run-local snapshots. Receipt source hashes must bind to the manifest. Changed controlling input after snapshot requires abort and a fresh run ID.

## Fixed representation

### Activity state

`ACTIVITY_CAP = 64` (`0x40`).

Preserve the same eleven one-byte activity arrays:

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

Use one global current `activity_epoch` byte.

### Binding state

`BINDINGS_PER_ACTIVITY = 20` (`0x14`).

`BINDING_CELL_COUNT = 1280` (`0x0500`).

Use the same RB02 arrays:

- `binding_resource_plus1[1280]`;
- `binding_generation[1280]`.

### Resource state

`RESOURCE_CAP = 64` (`0x40`).

Use the same RB02 arrays:

- `resource_identity[64]`;
- `resource_generation[64]`;
- `resource_value[64]`;
- `resource_live_count[64]` as 16-bit unsigned words;
- one global `resource_epoch` byte.

AR01 uses only resource slot 0 in the runtime paths, but the full configured arrays and quiescence scans remain 64/1280 scale.

## Safe activity release

`activity_release_checked` input is a current activity handle `(slot,generation,epoch)`.

Required order:

1. validate activity currentness;
2. compute the selected activity's 20-cell binding row;
3. scan all 20 `binding_resource_plus1` cells;
4. if any cell is nonzero, return `R` with no activity/binding/resource mutation;
5. if the row is empty, clear activity identity only and return `W`;
6. preserve activity generation for later reuse currentness.

No implicit binding detach/cascade is allowed.

## Binding-aware activity rekey

`activity_rekey_checked` may mutate namespace state only after all of these pass:

1. all 64 activity identities are zero;
2. all 1,280 `binding_resource_plus1` cells are zero;
3. all 64 resource identities are zero;
4. all 64 16-bit resource live counts are zero;
5. `completion_status == 0`;
6. `relation_active == 0`.

Reject result is `R` with no namespace mutation.

On success:

1. advance activity epoch to the next nonzero value using RK01 semantics;
2. reset all eleven activity arrays across 64 slots;
3. reset all 1,280 binding-resource cells;
4. reset all 1,280 binding-generation cells;
5. leave `resource_epoch` unchanged;
6. do not perform resource-namespace rekey;
7. return `W`.

## Good path

Reset full relation state. Set activity epoch 1 and resource epoch 1.

1. Acquire A identity `0x41` -> activity slot 0, generation 1, epoch 1.
2. A creates resource identity `0x51`, value `0x7E` at resource slot 0 through generic `bind_new_resource` -> binding index 0, binding generation 1, resource generation 1, live count 1.
3. Save old A binding handle `(activity0, actgen1, acte1, binding0, bindgen1)`.
4. `activity_release_checked(A)` must return `R` because binding row 0 is nonempty.
5. Required A identity remains `0x41`; activity generation remains 1; binding cell 0 remains resource+1 = 1; resource live count remains 1.
6. Checked `binding_detach` using the old A binding handle returns `W`; resource live count becomes 0 and resource identity/value are reclaimed.
7. `activity_release_checked(A)` now returns `W` and clears A identity.
8. `activity_rekey_checked` now returns `W`.
9. Required activity epoch becomes 2.
10. Required binding cell 0 resource reference = 0.
11. Required binding generation cell 0 = 0.
12. Required resource epoch remains 1.
13. Acquire C identity `0x43` -> activity slot 0, generation 1, epoch 2.
14. Required C binding index 0 remains empty.
15. Present old A binding handle from step 3 to ordinary good `binding_read`; it must return `R` before value exposure.

## Unsafe-release negative control

Independent reset to activity epoch 1 / resource epoch 1.

1. Acquire A identity `0x41` -> activity slot 0, generation 1, epoch 1.
2. A creates resource identity `0x51`, value `0x7E` -> binding index 0 / binding generation 1 / live count 1.
3. Intentionally bad `activity_release_unsafe` clears A identity without scanning or detaching binding row 0 and returns `W`.
4. All activity identities are now free, but binding cell 0 remains resource+1=1 and resource live count remains 1.
5. Good `activity_rekey_checked` must return `R`; activity epoch remains 1; binding cell/resource live count remain unchanged.
6. Generic activity acquire admits B identity `0x42` into activity slot 0, generation 2, epoch 1.
7. Use B's current activity handle with binding index 0 / binding generation 1 in the ordinary good `binding_read`.
8. Required result is `W` and value `0x7E`.

This is the negative control: unsafe activity release makes a prior occupant's still-live binding relation visible to the later occupant of the same activity slot.

## Exact required debug matrix

Hex values use fixed widths where shown.

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
RES_CAP=40
SAFE_RELEASE=R
SAFE_ID=41
SAFE_GEN=01
SAFE_BIND=01
SAFE_LIVE=0001
DETACH=W
SAFE_RELEASE2=W
REKEY=W
ACT_EPOCH=02
BIND0=00
BGEN0=00
RES_EPOCH=01
NEW_ACQ=W
NEW_ID=43
NEW_GEN=01
NEW_BIND0=00
OLD_BIND=R
BAD_RELEASE=W
BAD_REKEY=R
BAD_EPOCH=01
BAD_BIND=01
BAD_LIVE=0001
BAD_ACQ=W
BAD_GEN=02
INHERIT=W
INHERIT_VAL=7E
DONE
```

Evaluator must require exact line order and values.

## Static/source closure requirements

All checker values under `checks` must be literal JSON booleans. Verify at least:

1. exact capacities 64 / 20 / 1280 / 64;
2. all eleven activity arrays use 64 entries, both binding arrays 1,280 entries, resource arrays 64 entries with 128-byte live-count storage;
3. generic activity acquire remains fail-closed on generation 255;
4. safe activity release validates current activity before row scan;
5. safe release scans exactly the selected 20-cell row before identity mutation;
6. safe-release reject branch mutates no activity/binding/resource state;
7. unsafe release clears activity identity without scanning/detaching bindings and is called only in the negative-control path;
8. good rekey scans all 64 activity identities before its first namespace mutation;
9. good rekey scans all 1,280 binding-resource cells before its first namespace mutation;
10. good rekey checks all 64 resource identities and all 64 16-bit live counts before mutation;
11. successful rekey resets all eleven activity arrays and both binding arrays through capacity-bounded loops;
12. successful rekey changes activity epoch to nonzero and does not write `resource_epoch`;
13. `binding_detach` withdraws the binding before 16-bit live-count decrement and reclaims resource only at zero;
14. ordinary good `binding_read` validates activity currentness, binding index, nonempty cell, and binding generation before value exposure;
15. safe and unsafe paths use the same activity arrays, binding arrays, resource arrays, and good binding-read routine;
16. run-local input snapshot/manifest exists before build and receipt source hashes match snapshots;
17. host launcher/evaluator/checker do not mutate guest relation state or synthesize debug lines;
18. every checker field under `checks` is a literal JSON boolean.

## Measurements required

Record at least:

- stage-2 raw bytes and 8 KiB fit;
- named runtime-state bytes;
- activity capacity 64;
- bindings/activity 20;
- binding cells 1,280;
- resource capacity 64;
- safe release row-scan bound 20;
- successful rekey activity scan 64;
- successful rekey binding scan 1,280;
- successful rekey resource scan 64;
- QEMU wall time as harness data;
- input-manifest SHA-256;
- exact source/artifact hashes.

## Success criterion

AR01 passes only if one controlling run:

- has complete pre-build run-local input snapshots/manifest;
- fits stage 2 inside the qualified 8 KiB extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all static/source checks are literal boolean true;
- independent closure verifies manifest/receipt/run-local-source lineage;
- all failed attempts/scars remain visible.

## Authority ceiling

A passing AR01 may establish only:

> the current bounded activity release/rekey rule composes with the D64 binding/resource relation under the tested cooperative quiescence contract: release requires an empty owned binding row, rekey requires empty activity/binding/resource relation state, and unsafe identity-only release exposes binding inheritance under activity-slot reuse.

It does **not** establish:

- general ownership types;
- cascade-destruction semantics;
- resource namespace rekey;
- live/non-quiescent rekey;
- uncooperative external handle revocation;
- arbitrary resource lifecycle;
- crash durability;
- asynchronous/SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.
