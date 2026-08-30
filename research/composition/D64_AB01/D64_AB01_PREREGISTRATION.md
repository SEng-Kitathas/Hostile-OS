# D64 / AB01 — activity lifecycle / binding-state composition preregistration

**Mode:** BUILD-COMMIT
**Parent composition plan:** `research/plans/D64_ACTIVITY_REKEY_BINDING_COMPOSITION_PLAN_2026-08-30.md`
**Parent activity lifecycle evidence:** D64/A01 CLOSED PASS + D64/RK01 CLOSED PASS/adopted shadow rule
**Parent binding evidence:** D64/RB02 CLOSED PASS
**8 KiB loader qualification:** `734674f8a35974433fd6a213e2a2cf1e4de93b43`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Does the current D64 activity lifecycle compose safely with the earned 64x20 binding/resource relation when activity release and activity-namespace rekey are made binding-aware, and does an identity-only release expose the predicted inheritance failure when it leaves a binding row live?

## Evidence envelope

Use the qualified fixed 8 KiB stage-2 envelope:

- stage 1: 512 bytes;
- stage 2: exactly 16 loaded sectors / 8,192-byte maximum at `0x8000..0x9FFF`;
- QEMU i386 / one core / TCG;
- maskable interrupts disabled for this discriminator;
- debug port `0xE9`;
- `isa-debug-exit` success exit 33.

No persistence/restart and no resource-namespace rekey are tested.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` applies from attempt 1.

Before compilation snapshot at least:

- this preregistration;
- D64 target profile;
- activity/binding composition plan;
- RB02 result;
- RK01 result and adoption review;
- qualified 8 KiB stage-1 source/linker;
- AB01 stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Build must use the run-local snapshots. Receipt source hashes must bind to the manifest.

## Fixed representation

AB01 must use the earned D64 relation shapes, not a reduced two-slot toy:

- `ACTIVITY_CAP = 64`;
- `BINDINGS_PER_ACTIVITY = 20`;
- `BINDING_CELL_COUNT = 1280`;
- `RESOURCE_CAP = 64`;
- eleven one-byte activity arrays of 64 entries;
- `binding_resource_plus1[1280]` and `binding_generation[1280]`;
- resource identity/generation/value arrays of 64 entries;
- 64 16-bit resource live counts;
- one activity epoch and one resource epoch;
- completion/currentness byte and relation-active byte for activity-rekey quiescence.

Binding handles remain:

`(activity slot, activity generation, activity epoch, binding index, binding generation)`.

Direct resource generation/epoch remains present, but resource namespace renewal is out of scope.

## Candidate checked activity release

`activity_release_checked(activity_handle)` must:

1. validate activity slot/generation/epoch;
2. compute that activity's 20-cell binding row;
3. scan all 20 `binding_resource_plus1` cells before activity mutation;
4. if any binding cell is nonzero, return `R` and mutate no activity/binding/resource state;
5. if the row is empty, clear activity identity only and return `W`;
6. preserve activity generation until later successful reuse or namespace rekey.

It must not auto-detach bindings.

## Candidate binding-aware activity rekey

`activity_rekey_checked` may mutate the activity/binding namespace only after all of these are verified:

1. all 64 activity identities are zero;
2. all 1,280 binding resource cells are zero;
3. all 64 16-bit resource live counts are zero;
4. all 64 resource identities are zero;
5. completion/currentness status is zero;
6. relation-active status is zero.

Any failed condition returns `R` before namespace mutation.

On success:

1. compute next nonzero activity epoch under the RK01 rule (`1..254 -> +1`, `255 -> 1` only here);
2. reset all eleven 64-entry activity arrays;
3. reset both 1,280-entry binding arrays;
4. clear completion/currentness and relation-active scratch;
5. publish the new activity epoch;
6. leave `resource_epoch` unchanged;
7. do not reset resource generation or otherwise rekey the resource namespace;
8. return `W`.

Resetting binding generation is lawful only because this same cooperative rekey boundary revokes all in-scope pre-rekey activity/binding handles.

## Runtime path A — unsafe release inheritance negative control

1. Reset to activity epoch 1 / resource epoch 1 / empty state.
2. Acquire A (`0x41`) through generic activity acquire -> slot 0 / generation 1 / epoch 1.
3. A creates resource identity `0x51` / value `0x7E` in binding index 0 / binding generation 1 / resource slot 0 generation 1.
4. Save A's old binding handle.
5. Call deliberately bad `activity_release_unchecked`, which clears activity identity without scanning binding row.
6. Required result `W`; slot-0 activity identity becomes zero.
7. Required binding cell A/0 remains nonzero; resource live count remains `0x0001`.
8. Call good `activity_rekey_checked` while all activity identities are free but binding/resource state remains live.
9. Required result `R`; activity epoch remains 1; binding/resource state remains live.
10. Acquire B (`0x42`) through the same generic activity acquire -> same slot 0 / generation 2 / epoch 1.
11. Using B's current activity handle with binding index 0 / binding generation 1, call the ordinary good binding read.
12. Required result `W` and value `0x7E`.
13. Using old A activity generation 1 / epoch 1 with that binding handle must return `R`.

This negative control demonstrates the specific failure shape: identity-only release allows a later occupant of the same activity slot to inherit the prior occupant's still-live binding row.

The bad release routine may be used only in this negative-control path.

## Runtime path B — checked release + detach + rekey good path

Independent reset to epoch 1 / empty state.

1. Acquire A at slot 0 / generation 1 / epoch 1.
2. A creates resource identity `0x51` / value `0x7E` in binding index 0 / binding generation 1.
3. Save the old A binding handle.
4. `activity_release_checked(A)` while binding 0 is live must return `R`.
5. Required activity identity remains `0x41`; activity generation remains 1.
6. Required binding cell remains nonzero; resource live count remains `0x0001`.
7. Checked `binding_detach(A,binding0,generation1)` must return `W`.
8. Required resource live count becomes `0x0000`; resource identity/value become zero; resource generation remains 1.
9. `activity_release_checked(A)` now returns `W`; activity identity becomes zero and generation remains 1.
10. `activity_rekey_checked` now returns `W`.
11. Required activity epoch becomes 2.
12. Required activity slot-0 generation becomes 0 after namespace reset.
13. Required binding row0/index0 resource cell becomes 0 and binding generation becomes 0.
14. Required resource epoch remains 1 and resource slot0 generation remains 1.
15. Acquire C (`0x43`) through generic acquire -> slot0 / generation1 / activity epoch2.
16. Old A binding handle `(slot0,actgen1,actepoch1,index0,bgen1)` must return `R` before value exposure.
17. C creates resource identity `0x5A` / value `0x59`; required binding index0 generation1 and resource slot0 generation2.
18. Fresh C binding handle must return `W / 0x59`.

## Exact required debug matrix

Two-byte live counts are four hex digits.

```text
ACT_CAP=40
BIND_CAP=14
RES_CAP=40
BAD_REL=W
BAD_ID=00
BAD_CELL=01
BAD_LIVE=0001
BAD_REKEY=R
BAD_EPOCH=01
B_ACQ=W
B_GEN=02
B_INHERIT=W
B_VAL=7E
OLD_A_AFTER_BAD=R
GOOD_REL_BLOCK=R
GOOD_ID=41
GOOD_GEN=01
GOOD_CELL=01
GOOD_LIVE=0001
DETACH=W
LIVE_AFTER_DETACH=0000
RES_ID_AFTER_DETACH=00
RES_GEN_AFTER_DETACH=01
GOOD_REL=W
ID_AFTER_REL=00
GEN_AFTER_REL=01
GOOD_REKEY=W
NEW_EPOCH=02
ACT_GEN_AFTER_REKEY=00
BIND_CELL_AFTER_REKEY=00
BIND_GEN_AFTER_REKEY=00
RES_EPOCH_AFTER_REKEY=01
RES_GEN_AFTER_REKEY=01
C_ACQ=W
C_GEN=01
OLD_A_AFTER_REKEY=R
C_BIND=W
C_BIND_GEN=01
C_RES_GEN=02
C_READ=W
C_VAL=59
DONE
```

Evaluator must require exact line order and values.

## Static/source closure requirements

All checks under `checks` must be literal JSON booleans and verify:

1. exact named capacities 64 / 20 / 1280 / 64 and corrected 16-bit resource live-count storage;
2. all eleven activity arrays, both binding arrays, and resource arrays use the earned D64 sizes;
3. one generic activity acquire routine is used by A/B/C;
4. checked activity release validates current activity before row scan and scans exactly the selected 20-cell row before identity clear;
5. checked-release reject path performs no activity/binding/resource mutation;
6. bad release clears identity without binding-row scan and is called only in the negative-control path;
7. good binding read is the same routine used by the inheritance negative control and validates activity generation/epoch plus binding generation before value exposure;
8. binding detach clears binding reference before 16-bit live-count decrement and reclaims identity/value only on zero;
9. rekey scans all 64 activity identities before namespace mutation;
10. rekey scans all 1,280 binding resource cells before namespace mutation;
11. rekey checks all 64 resource live counts and identities before namespace mutation;
12. rekey checks completion/currentness and relation-active state before namespace mutation;
13. rekey reject branch changes neither activity epoch nor activity/binding arrays;
14. successful rekey resets all eleven activity arrays through a 64-bound loop;
15. successful rekey resets both binding arrays through a 1,280-bound loop;
16. successful rekey changes activity epoch to nonzero only after quiescence checks and resets;
17. successful rekey leaves resource epoch and resource generation unchanged;
18. ordinary activity acquire remains fail-closed on generation 255 rather than silent wrap;
19. ordinary binding generation remains fail-closed on 255 rather than silent wrap;
20. run-local input snapshot/manifest exists before build and receipt source hashes match snapshots;
21. launcher/evaluator/static checker do not mutate guest relation state or synthesize guest debug lines;
22. every checker value under `checks` is a literal JSON boolean.

## Measurements required

Record at least:

- stage-2 raw bytes;
- named runtime-state bytes;
- activity capacity 64;
- binding cells 1,280;
- resource capacity 64;
- checked-release row scan maximum 20;
- rekey activity scan maximum 64;
- rekey binding scan maximum 1,280;
- rekey resource scan maximum 64;
- activity/binding reset loop bounds 64 / 1,280;
- QEMU wall time as harness data;
- input-manifest/source/artifact hashes.

## Success criterion

AB01 passes only if one controlling run:

- has a complete pre-build run-local input snapshot/manifest;
- builds inside the qualified 8 KiB stage-2 extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all 22 static/source checks are literal boolean true;
- independent closure verifies snapshot/manifest/receipt lineage and attempt scars;
- engineering failures remain visible.

## Authority ceiling

A passing AB01 may establish only:

> under the tested cooperative D64 relation model, checked activity release must require an empty owned binding row, and checked activity-namespace rekey can safely compose with the binding/resource state only after complete activity/binding/resource quiescence; identity-only release exposes the tested binding inheritance failure.

It does **not** establish:

- general ownership types;
- cascade destruction semantics;
- live/non-quiescent rekey;
- resource namespace renewal;
- arbitrary external handle revocation;
- dynamic allocation;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- any R3.1/R6 authority change.
