# D64 / ARB01 — activity-rekey + binding-state composition preregistration

**Mode:** BUILD-COMMIT
**Parent plan:** `research/plans/D64_ACTIVITY_REKEY_BINDING_COMPOSITION_PLAN_2026-08-30.md`
**Parent activity-rekey evidence:** D64/RK01 CLOSED PASS + adopted D64 shadow rule
**Parent binding evidence:** D64/RB02 CLOSED PASS + audit-pointer correction
**Evidence envelope:** qualified fixed 8 KiB stage 2
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Does the adopted checked activity release/rekey lifecycle remain sound after the D64 64 x 20 binding matrix becomes load-bearing, if:

- checked activity release refuses a nonempty binding row;
- checked activity rekey refuses any live activity, any nonempty binding cell, or nonzero resource live-count/accounting state before namespace mutation;
- successful rekey changes activity epoch and resets activity + binding namespace state while preserving separate resource generation/epoch history;
- an unsafe identity-only release negative control is allowed to leave a binding row behind?

## Fixed capacities and state

Use the same D64 representation:

- `ACTIVITY_CAP = 64`;
- `BINDINGS_PER_ACTIVITY = 20`;
- `BINDING_CELL_COUNT = 1280`;
- `RESOURCE_CAP = 64`;
- eleven one-byte activity arrays;
- `binding_resource_plus1[1280]`;
- `binding_generation[1280]`;
- resource identity/generation/value arrays of 64 bytes;
- `resource_live_count[64]` as 16-bit unsigned;
- one `activity_epoch` byte and one `resource_epoch` byte.

No File/Manager/process/scheduler primitive may be added.

## Checked activity release

`activity_release_checked(activity_handle)` must:

1. validate slot/generation/activity epoch;
2. compute the selected activity's 20-cell binding row;
3. scan all 20 cells;
4. if any `binding_resource_plus1` cell is nonzero, return `R` with no activity/binding/resource mutation;
5. only if the row is empty, clear activity identity and return `W`;
6. preserve activity generation until rekey/reuse rules act on it.

## Checked composed activity rekey

`activity_rekey_checked` may mutate only after all guards pass:

1. all 64 activity identities are zero;
2. all 1,280 binding resource cells are zero;
3. all 64 16-bit resource live counts are zero;
4. all 64 resource identities are zero under the current RB02 lifetime invariant;
5. completion/currentness scratch is quiescent;
6. relation mutation flag is clear.

Any failed guard returns `R` and changes none of:

- activity epoch;
- activity arrays;
- binding arrays;
- resource arrays;
- resource epoch.

On success:

1. compute next nonzero activity epoch under the adopted RK01 rule;
2. reset all eleven activity arrays across 64 slots;
3. reset both binding arrays across all 1,280 cells;
4. clear activity completion/currentness scratch;
5. publish the new activity epoch;
6. leave resource generation array unchanged;
7. leave resource epoch unchanged;
8. return `W`.

Resource namespace rekey is explicitly out of scope.

## Path U — unsafe release inheritance negative control

Independent reset: activity epoch 1, resource epoch 1.

1. acquire activity A (`0x41`) at slot 0 -> generation 1 / epoch 1;
2. A creates resource identity `0x51`, value `0x7E` at binding index 0 / binding generation 1 / resource slot 0 / resource generation 1;
3. call intentionally unsafe `activity_release_identity_only` that clears A identity without scanning/detaching its row; required status `W`;
4. all activity identities are now free, but binding cell 0 remains resource+1 = `01` and resource-0 live count remains `0001`;
5. call good `activity_rekey_checked`; required `R`;
6. required activity epoch remains `01`;
7. required binding cell 0 remains `01` and resource live count remains `0001`;
8. acquire B (`0x42`) through the generic activity acquire path -> same slot 0, generation 2, epoch 1;
9. use B's current activity handle plus binding index 0 / binding generation 1 through the ordinary RB02 `binding_read`;
10. required result `W`, value `7E`.

This is the required composition failure shape: identity-only release lets a later occupant inherit the previous occupant's binding row. Good rekey must refuse to launder that state.

## Path G — checked release + detach + composed rekey

Independent reset: activity epoch 1, resource epoch 1.

1. acquire A (`0x41`) at slot0 -> gen1/epoch1;
2. A creates resource identity `0x51`, value `0x7E` at binding0/gen1/resource0/gen1;
3. save old A binding handle and old direct resource handle;
4. call checked activity release while binding0 is live; required `R`;
5. A identity remains `41`, generation remains `01`;
6. binding cell0 remains `01`;
7. resource live count remains `0001`;
8. checked detach of A binding0 returns `W`;
9. resource live count becomes `0000`, resource identity/value clear, resource generation remains `01`;
10. checked activity release now returns `W` and clears A identity;
11. seed free tail binding-generation residue at cell1279 = `07` while binding resource cell1279 remains empty; this is observation-only stale generation residue inside an otherwise quiescent binding namespace;
12. checked activity rekey returns `W`;
13. activity epoch becomes `02`;
14. binding resource cell0 = `00`, binding generation cell0 = `00`;
15. tail binding resource cell1279 = `00`, tail binding generation cell1279 = `00`, proving full binding-array reset;
16. resource epoch remains `01`;
17. resource generation slot0 remains `01`, proving activity rekey did not reset the separate resource namespace.

### Fresh namespace reuse

18. acquire activity C (`0x43`) -> slot0 / activity generation1 / activity epoch2;
19. old A binding handle `(slot0, act-gen1, act-epoch1, binding0, bind-gen1)` returns `R` before value exposure;
20. C creates resource identity `0x5A`, value `0xEE`;
21. required binding index0 / binding generation1;
22. required resource slot0 / resource generation2 / resource epoch1;
23. fresh C binding read returns `W / EE`;
24. old direct resource handle `(slot0, resource-gen1, resource-epoch1)` returns `R`;
25. fresh direct resource handle `(slot0, resource-gen2, resource-epoch1)` returns `W / EE`.

The tail generation seed in step 11 is allowed only after every binding reference is empty and all resource live counts/identities are zero. It must not create a live binding or resource.

## Exact required debug matrix

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
CELL_COUNT=0500
UNSAFE_RELEASE=W
BAD_REKEY=R
BAD_EPOCH=01
BAD_BIND0=01
BAD_RLIVE=0001
INHERIT_ACQ=W
INHERIT_GEN=02
INHERIT_READ=W
INHERIT_VAL=7E
CHECK_RELEASE_LIVE=R
CHECK_ID=41
CHECK_GEN=01
CHECK_BIND0=01
CHECK_RLIVE=0001
DETACH=W
AFTER_DETACH=0000
AFTER_RESID=00
AFTER_RGEN=01
CHECK_RELEASE=W
GOOD_REKEY=W
NEW_EPOCH=02
BIND0=00
BGEN0=00
TAIL_BIND=00
TAIL_BGEN=00
RES_EPOCH=01
RES_GEN=01
NEW_ACQ=W
NEW_ACT_GEN=01
NEW_ACT_EPOCH=02
OLD_BIND=R
NEW_BIND_CREATE=W
NEW_BIND_GEN=01
NEW_RES_GEN=02
NEW_BIND_READ=W
NEW_BIND_VAL=EE
OLD_RES=R
NEW_RES=W
NEW_RES_VAL=EE
DONE
```

Evaluator must require exact line order and exact values.

## Static/source closure requirements

Every checker value under `checks` must be literal JSON boolean. Verify at least:

1. exact 64 / 20 / 1,280 / 64 capacities and 16-bit resource live-count storage;
2. good and bad paths use the same activity/binding/resource arrays;
3. checked release validates current activity then scans exactly the selected 20-cell row before identity mutation;
4. checked-release reject branch mutates no protected state;
5. unsafe release omits binding-row scan and clears identity only;
6. composed rekey scans all 64 activity identities before first mutation;
7. composed rekey scans all 1,280 binding resource cells before first mutation;
8. composed rekey scans all 64 resource live counts using 16-bit reads before first mutation;
9. composed rekey checks all 64 resource identities before first mutation;
10. completion/currentness/relation guards occur before first mutation;
11. any rekey reject returns before activity/binding/resource namespace mutation;
12. successful rekey resets all eleven activity arrays with capacity-bounded loop(s);
13. successful rekey resets both binding arrays through a full 1,280-cell loop;
14. successful rekey changes activity epoch and never publishes zero;
15. successful activity rekey does not write resource generation or resource epoch;
16. binding-generation reset occurs only after all quiescence guards pass;
17. ordinary RB02 binding detach/read and resource read currentness paths are reused rather than replaced by test-only operations;
18. unsafe inheritance path calls the ordinary good `binding_read` using the new occupant's current activity handle;
19. tail binding-generation residue is seeded only after live binding/resource state is zero and good rekey resets it;
20. run-local input snapshot/receipt source closure holds and host harness does not mutate guest relation state or synthesize trace.

## Measurements required

Record:

- stage-2 raw bytes / 8 KiB fit;
- named runtime-state bytes;
- activity capacity 64;
- binding cells 1,280;
- resource capacity 64;
- activity identity scan bound 64;
- checked-release row scan bound 20;
- rekey binding scan bound 1,280;
- rekey resource live-count/identity scan bound 64;
- activity reset bound 64 x eleven fields;
- binding reset bound 1,280 x two fields;
- activity epoch before/after;
- resource epoch before/after;
- resource generation slot0 before/after rekey;
- input-manifest SHA-256 and exact artifact hashes;
- QEMU wall time as harness data only.

## Success criterion

ARB01 passes only if one controlling run:

- has complete pre-build run-local input snapshots/manifest;
- fits the qualified 8 KiB stage-2 envelope;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all static/source checks are literal boolean true;
- independent closure verifies manifest/receipt/run-local source lineage;
- all engineering scars remain visible.

## Authority ceiling

A passing ARB01 may establish only:

> the adopted bounded D64 activity release/rekey rule composes with the RB02 binding/resource relation under a cooperative quiescence contract by refusing live binding rows, rejecting orphan binding/resource residue, and resetting activity+binding namespace state while preserving separate resource generation/epoch history.

It does not establish:

- cascade destruction semantics;
- live/non-quiescent rekey;
- resource namespace rekey;
- external capability revocation;
- File/POSIX/DOS semantics;
- arbitrary resource types;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.
