# D64 / ARB01 — activity-rekey + binding-state composition result

**Disposition:** PASS CLOSED / BOUNDED COMPOSITION SUCCESS
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Lineage

Composition plan:

`research/plans/D64_ACTIVITY_REKEY_BINDING_COMPOSITION_PLAN_2026-08-30.md`

ARB01 preregistration commit:

`c7170dc018e463e6220bb7ce39e9018950e65754`

Preregistration SHA-256:

`3de45c62941522facdc8d83b8f5d322a2a32106f7f8269e8f9849efbd4746b71`

The preregistration was sealed before the controlling mechanism/evaluator/checker/launcher source existed.

## Attempt 1 assurance scar — exact guest success, static label-parser false positive

Run:

`20260830T055100Z_d64_arb01_composition_01`

Attempt 1 completed QEMU exit 33 and matched the complete preregistered evaluator matrix. It was not admitted as controlling science because one static predicate returned false:

`ordinary_rb02_paths_reused=false`

The checker used substring counts such as `t.count('resource_read:')`, which also counted `bad_resource_read:`. The same issue applied to the binding-read label family. This was a checker label-matching defect, not a guest/source defect.

The checker was changed to require exact newline-bounded labels. A fresh run ID was required because the checker is a controlling input.

Attempt-1 guest source SHA-256:

`8b9479e08372d89f0adbc9dc4024d8f147ecf28b5e33aa365ad9c4208dba807a`

Attempt-1 checker SHA-256:

`8507b331b865573dca6a50bc8556f73a9582550e9afbab785a720b50f73a5340`

Independent later audit proves attempt 1 and attempt 2 used identical guest source and identical guest trace. Only the static checker changed among the mechanism/harness controlling inputs.

## Controlling run

Run:

`20260830T055300Z_d64_arb01_composition_02`

QEMU:

- PID `34584`
- started `2026-08-30T05:49:14.198544+00:00`
- ended `2026-08-30T05:49:14.398006+00:00`
- status `COMPLETED`
- exit `33`
- wall time `199.446 ms` as harness data only

Evaluator exit: `0`.
Static checker exit: `0`.
Independent closure audit: PASS.

## Exact guest trace

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

The evaluator required exact line order and values.

## Qualified consequence

### Unsafe identity-only release exposes binding-row inheritance

Activity A was current at slot 0 / generation 1 / epoch 1 and owned binding 0 to resource value `0x7E`.

The intentionally unsafe release cleared only A's activity identity and returned `W`, leaving:

- binding cell 0 occupied (`01` = resource slot 0 + 1);
- resource-0 live count `0001`.

The good composed rekey rejected this state:

- `BAD_REKEY=R`;
- activity epoch stayed `01`;
- binding/resource residue stayed intact.

A new activity B then acquired the same activity slot at generation 2 / epoch 1. Using B's **current** activity handle with the inherited binding index 0 / binding generation 1, the ordinary RB02 binding-read path returned:

- `INHERIT_READ=W`;
- `INHERIT_VAL=7E`.

This is the required composition failure shape: freeing activity identity without releasing its binding row allows a later occupant to inherit the old occupant's relation numerically.

### Checked activity release refuses a live binding row

Under a fresh coherent reset, A again owned binding 0 / resource `0x7E`.

Checked activity release returned `R` and preserved:

- A identity `41`;
- A generation `01`;
- binding cell0 `01`;
- resource live count `0001`.

The current activity lifecycle therefore does not silently revoke or orphan live binding state.

### Explicit detach closes resource lifetime before activity release

Checked binding detach returned `W`.

After detach:

- resource live count `0000`;
- resource identity cleared `00`;
- resource generation preserved `01`.

Checked activity release then returned `W`.

### Binding-aware activity rekey succeeds only after relation quiescence

With all activity identities free, all binding references empty, all resource live counts zero, resource identities empty, and currentness scratch quiescent, composed activity rekey returned `W`.

It changed activity epoch:

`01 -> 02`

and reset activity + binding namespace state.

Representative observations:

- binding resource cell0 `00`;
- binding generation cell0 `00`;
- tail binding resource cell1279 `00`;
- tail binding generation cell1279 `00` even though stale generation residue `07` had been seeded while the binding namespace was empty.

This shows the full 1,280-cell binding reset is load-bearing rather than only a slot-0 special case.

### Resource namespace history is preserved across activity rekey

Activity rekey did **not** reset the separate resource namespace:

- resource epoch remained `01`;
- resource slot0 generation remained `01` after the earlier resource was reclaimed.

A fresh activity C then acquired slot0 at activity generation1 / activity epoch2.

C created resource `0x5A / 0xEE` in resource slot0. Because resource generation history survived activity rekey, the reused resource slot advanced to generation `02`.

### Old activity/binding and resource handles reject; fresh ones succeed

The old A binding handle tied to activity epoch1 returned `R` after the activity namespace moved to epoch2.

The fresh C binding was created at binding generation1 and read `W / EE`.

The old direct resource handle at resource generation1 returned `R`.

The fresh generation2 resource handle returned `W / EE`.

Therefore the tested composition keeps activity/binding namespace retirement separate from resource namespace currentness while allowing the two to work together.

## Static/source closure

All static checker values under `checks` are literal JSON booleans and all are `true` in the controlling run.

The checker verified:

- exact 64 / 20 / 1,280 / 64 capacities and 16-bit live-count storage;
- good and unsafe paths use the same relation arrays;
- checked activity release validates current activity and scans the selected 20-cell row before identity clear;
- checked-release rejection mutates no protected state;
- unsafe release omits binding-row scanning and clears identity only;
- composed rekey scans all 64 activity identities before mutation;
- composed rekey scans all 1,280 binding cells before mutation;
- composed rekey checks all 64 16-bit resource live counts and all resource identities before mutation;
- completion/backing/relation guards occur before mutation;
- rekey reject branch does not mutate namespace state;
- successful rekey resets all eleven activity arrays and both binding arrays through bounded loops;
- successful rekey changes activity epoch to a nonzero value;
- resource generation and resource epoch are not written by activity rekey;
- binding-generation reset occurs only after all rekey guards;
- ordinary RB02 binding detach/read/resource read paths are reused;
- unsafe inheritance uses the ordinary good binding-read path under the new occupant's current activity handle;
- tail binding-generation residue is seeded only after detach and before good rekey;
- run-local input snapshot/receipt closure and host nonmutation/nonsynthesis hold.

## Independent closure

Independent audit:

`D64-ARB01-independent-closure-v1`

SHA-256:

`9e67ef7cc8cfaffdfa057164b1cd200e2ce7f6231b9db0739c8e214589823fc7`

All 19 audit checks passed, including:

- run-local manifest/snapshot/source hash closure;
- exact preregistration lineage `c7170dc018e463e6220bb7ce39e9018950e65754`;
- snapshot before QEMU execution;
- QEMU exit 33;
- evaluator exact pass;
- all static checks literal true;
- 6,591-byte stage-2 fit;
- 3,665-byte runtime-state readback;
- required scan/reset bounds;
- activity epoch observation `02`;
- resource epoch observation `01`;
- resource generation after activity rekey `01`;
- attempt 1 runtime/evaluator pass with exactly one false static predicate;
- attempts 1 and 2 identical guest source and guest trace;
- only the static checker changed among the controlling mechanism/harness inputs;
- unsafe inheritance and good composition consequences both present in the exact trace.

## Pareto / size observations

- stage-2 raw bytes: `6,591`
- qualified stage-2 extent: `8,192`
- headroom: `1,601` bytes
- named runtime state: `3,665` bytes
- activity capacity: `64`
- binding cells/activity: `20`
- total binding cells: `1,280`
- resource capacity: `64`
- checked activity-release row scan bound: `20`
- activity identity rekey scan: `64`
- binding quiescence scan: `1,280`
- resource live-count/identity scan: `64`
- activity reset: 64 records / eleven field arrays
- binding reset: 1,280 cells / two arrays
- QEMU wall time: `199.446 ms` as harness data only

The composed rule adds bounded scan/reset work but still fits the qualified 8 KiB evidence envelope with substantial headroom.

## Provenance / key hashes

Controlling input-manifest SHA-256:

`08c855148869ba3574b08e1c940ee0672bbba6719c9cd020e6174cdde9ec37d6`

Controlling receipt SHA-256:

`f1471e6213cad1ff44f8f0f4f6f28237a03dcdadc6d27dcca4754ef197e78a7f`

Sources:

- stage2.S: `8b9479e08372d89f0adbc9dc4024d8f147ecf28b5e33aa365ad9c4208dba807a`
- stage2.ld: `4282d8563eeab6d86929ba88d040d7dd5b3156b2e40aa0aeda9d9d924905695c`
- evaluator: `62c5141c591702ea2468c78f9523ca06a13caa882d03637e692f95515b637891`
- static checker: `0561cbf7fae68d6693ae83a08b5fd0ce577d3b720f8db5d23d0b0dd741ac7b65`
- launcher: `94ea45301658e4e30b3b45857a45e57adc33ec0e039c1623bb91fff39e9db831`

Artifacts:

- stage2.raw.bin: `e0cd873c859defc642299a74db1d4c184ec17079b7d9ec599b6423ed5bccb470`
- debug trace: `006ca989c0ad2ee5cdc9bcee646dd0e640401062d8c4141ef3d4af4752129b11`
- evaluation: `9a77487d1f10b4eecd6f85cfe1bbf4547f61463388b6523ce52037ebd15b6da5`
- static closure: `133761d8f1d6761332548dc4234adfd5a1c1311089314a66b8140722b885b27c`
- independent audit: `9e67ef7cc8cfaffdfa057164b1cd200e2ce7f6231b9db0739c8e214589823fc7`

## What ARB01 resolves

ARB01 resolves the immediate composition seam created when RB02 added activity-owned binding rows after RK01 had already defined activity release/rekey.

At bounded D64 shadow scope:

- activity identity may not be safely released while its binding row is nonempty;
- activity namespace rekey must treat the binding matrix and resource lifetime accounting as part of quiescence;
- successful activity rekey may reset binding-generation state because activity epoch changes revoke the old activity/binding namespace;
- separate resource generation/epoch history must survive activity rekey;
- unsafe identity-only release measurably transfers an old binding relation to a later occupant.

## Remaining open seam

The next direct currentness seam is **resource namespace renewal/rekey** after finite resource-generation exhaustion.

ARB01 does not solve that problem and deliberately preserves resource generation/epoch across activity rekey.

Availability remains bounded by cooperative quiescence: permanently live activity/binding state can still prevent activity rekey.

## Authority ceiling / nonclaims

ARB01 does not establish:

- cascade destruction semantics;
- live/non-quiescent rekey;
- resource namespace rekey;
- external capability revocation;
- historical File/descriptor/inode/manager architecture;
- arbitrary resource types;
- crash durability;
- SMP/NMI/DMA correctness;
- physical hardware behavior;
- final/canonical/production HOSTILE-OS architecture;
- any R3.1/R6 authority change.

## Disposition

`D64_ARB01_CLOSED_PASS / CHECKED_RELEASE_REQUIRES_EMPTY_BINDING_ROW / ACTIVITY_REKEY_REQUIRES_BINDING_RESOURCE_QUIESCENCE / UNSAFE_IDENTITY_RELEASE_INHERITANCE_EXPOSED / ACTIVITY_BINDING_NAMESPACE_RESET_EARNED / RESOURCE_NAMESPACE_HISTORY_PRESERVED / RESOURCE_REKEY_NEXT`
