# D64 / RR01 — resource namespace rekey preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** D64 donor-scale reference profile
**Parent resource evidence:** D64/RB02 CLOSED PASS
**Parent activity/binding composition:** D64/ARB01 CLOSED PASS + adopted shadow rule
**Parent plan:** `research/plans/D64_RESOURCE_NAMESPACE_REKEY_PLAN_2026-08-30.md`
**Evidence envelope:** qualified fixed 8 KiB stage 2
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can the D64 resource namespace be explicitly renewed after finite generation pressure while current activities remain current, by requiring binding/resource quiescence, changing resource epoch, resetting resource generation/state, preserving activity epoch/state and binding-generation history, rejecting old direct-resource handles, and exposing generation-reset-without-resource-epoch-change as the stale-alias negative control?

## Fixed state

Use the same earned D64 arrays and capacities:

- `ACTIVITY_CAP = 64`;
- `BINDINGS_PER_ACTIVITY = 20`;
- `BINDING_CELL_COUNT = 1280`;
- `RESOURCE_CAP = 64`;
- eleven 64-entry activity arrays;
- two 1,280-entry binding arrays;
- 64-entry resource identity/generation/value arrays;
- 64 16-bit resource live counts;
- one activity epoch and one resource epoch.

Activity/binding handles retain ARB01 currentness. Direct resource handles remain `(resource slot, resource generation, resource epoch)`.

## Checked resource rekey

`resource_rekey_checked` may mutate resource namespace state only after:

1. all 1,280 `binding_resource_plus1` cells are zero;
2. all 64 `resource_identity` entries are zero;
3. all 64 16-bit `resource_live_count` entries are zero;
4. `relation_active == 0`.

Current activity identities may remain nonzero/current.

Any failed guard returns `R` and changes none of:

- resource epoch;
- resource generation/value/live-count arrays;
- activity epoch or arrays;
- binding generation.

On success:

1. next resource epoch = current+1 for 1..254, or 1 from 255 only inside this checked rekey;
2. reset all 64 resource-generation entries to zero;
3. reset resource identity/value/live-count arrays through a 64-bound loop;
4. publish the new nonzero resource epoch;
5. leave activity epoch/state unchanged;
6. leave both binding arrays unchanged, including binding-generation history;
7. return `W`.

## Path G — good resource rekey with current activity surviving

Reset to activity epoch1 / resource epoch1.

1. Acquire A (`0x41`) -> activity slot0 / generation1 / epoch1.
2. A creates X identity `0x51`, value `0x7E` -> binding0 / binding generation1 / resource0 / resource generation1 / resource epoch1.
3. Save old X direct handle and old binding handle.
4. `resource_rekey_checked` while X is bound/live must return `R`.
5. Required resource epoch remains `01`; resource identity `51`; live count `0001`; binding cell0 `01`.
6. Detach A binding0 through ordinary RB02 detach -> `W`; live count `0000`, resource identity/value cleared, resource generation remains `01`, binding generation remains `01`.
7. A must remain current: identity `41`, activity generation `01`, activity epoch `01`.
8. `resource_rekey_checked` now returns `W`.
9. Required resource epoch becomes `02`.
10. Resource generation0 becomes `00`.
11. Activity epoch remains `01`; A identity/gen remain `41/01`.
12. Binding generation0 remains `01`.
13. A creates Y identity `0x5A`, value `0xEE` in binding0.
14. Required binding generation advances `01 -> 02`.
15. Required resource slot0 generation becomes `01`, resource epoch2.
16. Old X direct handle `(0,1,1)` returns `R`.
17. Fresh Y direct handle `(0,1,2)` returns `W / EE`.
18. Old binding handle generation1 returns `R`.
19. Fresh binding handle generation2 returns `W / EE`.

## Path B — bad generation reset without resource-epoch change

Independent reset to activity epoch1 / resource epoch1.

1. Acquire A.
2. A creates X at resource0/gen1/epoch1; save old direct handle.
3. Detach X; resource generation remains1.
4. Deliberately bad `resource_reset_generation_only` zeros resource generation while leaving resource epoch1 unchanged.
5. A creates Y -> resource0/gen1/epoch1.
6. Present old X direct handle `(0,1,1)`.
7. Required result `W / EE`.

The bad reset must be separate and never called by good rekey.

## Path W — explicit checked resource epoch 255 -> 1

Independent reset to activity epoch1 / resource epoch255.

1. Acquire A.
2. A creates X at resource0/gen1/epoch255; save old direct handle.
3. Detach X and reach resource quiescence.
4. Checked resource rekey returns `W`.
5. Required resource epoch `01`, resource generation0 `00`.
6. A creates Y -> resource0/gen1/epoch1.
7. Old `(0,1,255)` returns `R`.
8. Fresh `(0,1,1)` returns `W / EE`.

## Exact required debug matrix

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
RES_CAP=40
LIVE_REKEY=R
LIVE_REPOCH=01
LIVE_RID=51
LIVE_RCOUNT=0001
LIVE_BIND=01
DETACH=W
AFTER_RCOUNT=0000
AFTER_RID=00
AFTER_RGEN=01
A_ID=41
A_GEN=01
A_EPOCH=01
BGEN_BEFORE=01
GOOD_REKEY=W
NEW_REPOCH=02
RGEN_AFTER_REKEY=00
A_EPOCH_AFTER=01
A_ID_AFTER=41
A_GEN_AFTER=01
BGEN_AFTER_REKEY=01
Y_CREATE=W
Y_BGEN=02
Y_RGEN=01
OLD_RES=R
NEW_RES=W
NEW_RES_VAL=EE
OLD_BIND=R
NEW_BIND=W
NEW_BIND_VAL=EE
BAD_RESET=W
BAD_OLD_RES=W
BAD_OLD_VAL=EE
WRAP_REKEY=W
WRAP_REPOCH=01
WRAP_RGEN=00
WRAP_OLD=R
WRAP_NEW=W
WRAP_VAL=EE
DONE
```

Evaluator must require exact line order and values.

## Static/source closure requirements

Every checker value under `checks` must be literal JSON boolean. Verify at least:

1. exact 64 / 20 / 1280 / 64 capacities and 16-bit live-count storage;
2. ordinary activity acquire, bind-new, binding-detach, binding-read, and resource-read paths are reused;
3. resource rekey scans all 1,280 binding-resource cells before first mutation;
4. resource rekey checks all 64 resource identities and all 64 16-bit live counts before first mutation;
5. relation-active check occurs before first mutation;
6. reject branch mutates no resource/activity/binding namespace state;
7. successful rekey resets resource generation/identity/value/live count through 64-bound loop(s);
8. successful rekey changes resource epoch to nonzero only after guards/reset;
9. successful resource rekey does not write activity epoch or any activity array;
10. successful resource rekey does not write `binding_generation` or `binding_resource_plus1`;
11. bad generation-only reset changes resource generation and does not change resource epoch;
12. bad reset is called only in its negative-control path and not by good rekey;
13. ordinary resource acquire/reuse remains fail-closed at generation255;
14. direct resource read validates slot, identity, generation, epoch before value exposure;
15. binding read validates activity + binding generation before value exposure;
16. run-local input snapshot/receipt source closure holds and host does not mutate guest relation state or synthesize trace;
17. all checks are literal JSON booleans.

## Measurements required

Record:

- stage-2 raw bytes / 8 KiB fit;
- named runtime-state bytes;
- activity/binding/resource capacities;
- resource-rekey binding scan 1,280;
- resource scan/reset 64;
- activity epoch before/after good rekey;
- resource epoch before/after;
- binding generation before/after;
- QEMU wall time as harness data;
- input-manifest/source/artifact hashes.

## Success criterion

RR01 passes only if one controlling run:

- has complete pre-build run-local input snapshot/manifest;
- fits the qualified 8 KiB extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all static checks are literal boolean true;
- independent closure verifies source/manifest/receipt lineage;
- engineering scars remain visible.

## Authority ceiling

A passing RR01 may establish only bounded cooperative resource-namespace renewal while the activity/binding namespace remains current.

It does not establish:

- externally persistent resource capabilities across rekey;
- arbitrary retained raw tokens across unlimited epoch cycles;
- live resource rekey with active bindings;
- resource migration;
- filesystem semantics;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.
