# D64 / RK01 — quiescent activity-namespace rekey result

**Disposition:** PASS CLOSED / BOUNDED REKEY SUCCESS
**Parent profile:** D64 donor-scale reference profile
**Parent plan:** quiescent activity-namespace rekey
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Lineage

Rekey BUILD-PLAN commit:

`ddcab6523ab0bfb1634ffc4934efb5da652ff0be`

RK01 preregistration commit:

`7ca3dce6ec8e130661823203ce9de4ad326a3d85`

The preregistration was sealed before RK01 mechanism, evaluator, checker, or launcher source existed.

## Attempt 1 engineering scar — runtime passed, static parser failed

Run:

`20260830T045700Z_d64_rk01_rekey_01`

Attempt 1 reached qualified guest execution:

- QEMU PID `1412`
- status `COMPLETED`
- exit `33`
- exact evaluator matrix: PASS
- evaluator exit `0`

It was **not** admitted as controlling science because the built-in static checker returned failure on:

`reject_branch_no_namespace_mutation=false`

The guest source did not violate the preregistration. The checker had required exact text equality for the `rekey_reject` block; a source comment between the `R; ret` instructions and the next label caused that parser rule to fail.

Attempt-1 input-manifest SHA-256:

`0b6c6f3dd1d8715cac4c5fd4a82771a76e6bd0406c22cd032ec02bb5c35cb833`

Attempt-1 receipt SHA-256:

`980b60b5dfb565377b6f064f80496b79335e47071d5ded9330b976af1d79150d`

Attempt-1 static-closure SHA-256:

`ce5c7e1f588c0ff9e770dd177cf87bb3fb8f1e7df172cb0097b172089ba46386`

The repair changed only the static checker predicate from brittle exact-block text matching to the preregistered semantic condition: reject returns `R` without activity-array, epoch, completion, backing, or relation-active mutation. A new run ID was required because a controlling input changed.

Independent later readback proved attempt 1 and attempt 2 used identical guest stage-2 source SHA-256:

`445050a2be84c4f4482fbc42b0e8e12f3d192b524ce51d8d5cba2fde50cbb68f`

Attempt-1 checker SHA-256:

`7c67b558787880364d5dce0df4338a57502ccbe80e178de5e6fd4ea664e8c65e`

Attempt-2 checker SHA-256:

`08ddcb94b8cd31144b13726f73c0933ffe85f64790a9b95529cac740c8d7755d`

## Controlling run

Run:

`20260830T050000Z_d64_rk01_rekey_02`

QEMU:

- PID `6948`
- started `2026-08-30T04:56:23.365822+00:00`
- ended `2026-08-30T04:56:23.577487+00:00`
- status `COMPLETED`
- exit `33`
- wall time `211.645 ms` as harness data only

Evaluator exit: `0`.
Static/source checker exit: `0`.
Independent closure audit: PASS.

## Exact raw trace

```text
S1_OK
CAP=40
LIVE_REKEY=R
LIVE_EPOCH=01
LIVE_ID=41
LIVE_GEN=01
RELEASE=W
COMP_REKEY=R
BACKING_REKEY=R
ACTIVE_REKEY=R
QUIESCENT_REKEY=W
NEW_EPOCH=02
TAIL_GEN=00
TAIL_CONT=00
NEW_ACQ=W
NEW_SLOT=00
NEW_GEN=01
OLD=R
NEW=W
NEW_ID=42
BAD_OLD=W
BAD_READ=42
WRAP_REKEY=W
WRAP_EPOCH=01
WRAP_OLD=R
WRAP_NEW=W
WRAP_ID=44
DONE
```

Hex `40` = 64 decimal.

## Qualified consequence

For this configured 64-slot cooperative activity namespace:

### Live-state rejection

- A was admitted at slot 0, generation 1, epoch 1.
- checked rekey while A was live returned `R`.
- epoch stayed 1.
- A identity `0x41` and generation 1 stayed unchanged.

Rekey therefore did not silently revoke a live activity.

### Other quiescence guards

With all activity identities free:

- current completion status blocked rekey with `R`;
- live shared-backing count blocked rekey with `R`;
- active relation mutation blocked rekey with `R`.

These guards were cleared only by the guest fixture path after each rejected attempt.

### Successful quiescent namespace renewal

With all quiescence conditions clear:

- checked rekey returned `W`;
- global activity epoch advanced 1 -> 2;
- stale free-slot residue at slot 63 was reset: generation 7 -> 0, continuation 2 -> 0;
- all eleven activity arrays were reset by the same capacity-bounded loop;
- fresh B admission selected slot 0 at generation 1 / epoch 2;
- old saved handle `(0,1,1)` returned `R`;
- fresh `(0,1,2)` returned `W` and identity `0x42`.

### Negative control — generation reset without epoch change

The bad control used the same activity arrays and handle checker but zeroed per-slot generation without changing epoch.

After A `(0,1,1)` was released, the bad reset allowed B to become `(0,1,1)`. The saved old A token then returned `W` and exposed B (`0x42`).

This demonstrates the alias the checked rekey is designed to prevent: **generation reset alone is not namespace renewal.**

### Explicit epoch-255 -> 1 transition at quiescence

Under an independent fixture beginning at epoch 255:

- C was admitted at `(0,1,255)` and released;
- checked quiescent rekey returned `W`;
- new current epoch became 1, never zero;
- D was admitted at `(0,1,1)`;
- old `(0,1,255)` returned `R`;
- fresh `(0,1,1)` returned `W` and D (`0x44`).

This establishes one explicit checked epoch-wrap transition under the preregistered revocation/quiescence contract. It does not establish safety for arbitrary out-of-contract holders retaining an old epoch-1 token through hundreds of future rekeys.

## Static/source closure

All 15 preregistered static checks are literal JSON booleans and all are `true`:

1. 64-slot capacity and all eleven arrays use that capacity;
2. one generic acquire and release path;
3. full identity scan before first namespace mutation;
4. completion/backing/relation-active guards before first namespace mutation;
5. reject path has no namespace mutation;
6. successful rekey resets all eleven fields through a capacity-bounded loop;
7. successful rekey publishes a nonzero new epoch;
8. 255 -> 1 exists only as explicit rekey behavior, not ordinary epoch wrap;
9. ordinary per-slot generation remains fail-closed with `G` at 255;
10. checked handle validates slot, occupancy, generation, per-slot epoch, and global epoch before identity exposure;
11. bad reset changes generation only and is separate from checked rekey;
12. good/bad controls share the same arrays and handle checker;
13. run-input manifest and receipt source hashes match;
14. host harness does not mutate guest activity state or synthesize guest debug output;
15. every checker field under `checks` is a literal JSON boolean, repairing the A01 checker-output typing scar for this experiment.

Static measurements:

- successful identity-scan bound: `64` iterations;
- successful activity-reset loop: `64` iterations;
- activity capacity: `64`;
- activity field species: `11`.

## Provenance closure

Controlling input-manifest SHA-256:

`44f78e073f473a85b23711b36a75e1f5519ef5059fd9b273d2d8fe14048ea9fd`

Controlling receipt SHA-256:

`b654464b2214ab8d758554a43445336fae9a6433f3345b8b4ace738ca71bffe9`

Independent closure audit SHA-256:

`02884ac916448c13e8224da84b8ecd2a46959ee171d2d5bdca596a9ef718560d`

The independent audit verified:

- exact manifest hash in receipt;
- every run-local input snapshot byte count and SHA-256;
- receipt source hashes equal manifest snapshot hashes;
- preregistration lineage exactly `7ca3dce6ec8e130661823203ce9de4ad326a3d85`;
- snapshot timestamp precedes QEMU execution;
- QEMU/evaluator/static closure all pass;
- all 15 static checks are literal boolean true;
- stage 2 remains inside 4 KiB;
- runtime-state readback is 738 bytes;
- scan/reset measurements are 64/64;
- attempt 1 and attempt 2 guest source hashes are identical;
- only the static checker changed between those attempts;
- attempt 1 runtime/evaluator passed and static failed on the one parser predicate.

## Pareto / size observations

- stage-2 raw/linked payload: `2,177` bytes;
- fixed stage-2 extent: `4,096` bytes;
- named runtime state: `738` bytes;
- configured activity capacity: `64`;
- per-slot activity field species: `11`;
- generation width in discriminator: `8` bits;
- activity-epoch width in discriminator: `8` bits;
- successful checked rekey scans 64 identity slots and resets 64 activity records.

The candidate avoids widening every per-slot generation field, but it pays with a rare O(64) scan/reset and a hard quiescence/revocation boundary. A permanently live activity can prevent rekey. That availability cost remains real and is not hidden by the passing trace.

## Key controlling hashes

- stage-2 source: `445050a2be84c4f4482fbc42b0e8e12f3d192b524ce51d8d5cba2fde50cbb68f`
- stage-2 linker: `45c8cddaf8219e3eaa85c285e73104657cfdadb3127227a501f7b5ed1dc3eabb`
- evaluator: `8dc34e4576d9681a90d05b255ff740404801466979a64bbc89429e36a0b78ba4`
- static checker: `08ddcb94b8cd31144b13726f73c0933ffe85f64790a9b95529cac740c8d7755d`
- launcher: `980dab213472200c296e19435b91666b4749b6acfbbd2bf53aac956e73ffa60a`
- stage-2 raw: `697f995bad1c7112622056ec13eb9fc00ec179544b21bacb99fd0c98cabbbf36`
- debug trace: `aa44abd3d61137a23174416149fc03889edc0aa17ea02d5682f1e88d9c621b7d`
- evaluation: `7563d9ddca950a9ccaf988bc340f2565aad2a608454e27c522c16fa8e99c49b0`
- static closure: `f5c42dc8af73ace5e42baa398db9299bb8fdc1c018f81efa68f65499ab50c2ab`

## What RK01 resolves

RK01 resolves the immediate D64 question of **how the current finite activity namespace can resume after generation-exhaustion pressure without silently aliasing the immediately retired namespace**, under a cooperative quiescence/revocation contract.

It replaces the vague instruction “rekey somehow” with a bounded explicit mechanism:

- reject while live/current state exists;
- retire namespace only at quiescence;
- change epoch;
- reset all activity state;
- reject immediate old handles;
- resume fresh admission;
- make generation-reset-without-epoch alias visible as the bad control.

## What remains open

### Availability / live rekey

A permanently live activity can prevent quiescence forever. RK01 does not establish a way to renew a namespace while live activities continue.

A future target may decide this rare stop/revoke boundary is acceptable, or may justify a wider epoch, two-epoch handoff, explicit revocation, indirection, or another mechanism.

### Arbitrarily retained external handles

RK01's cooperative retention contract excludes uncooperative external holders retaining old raw tokens across unlimited namespace cycles. If that becomes a target requirement, this mechanism is insufficient.

### Resource-binding scale

D64's 20-reference-per-activity / 64-global-resource pressure remains unembodied. RK01 renews only activity handles.

## Authority ceiling / nonclaims

RK01 does not establish:

- general external capability revocation;
- safety for arbitrarily retained tokens across unlimited namespace cycles;
- live/non-quiescent rekey;
- wait-free or lock-free renewal;
- arbitrary resource-handle rekey;
- cryptographic identity;
- SMP/NMI/DMA correctness;
- production availability policy;
- final architecture;
- R3.1 replacement readiness;
- R6 demotion.

## Disposition

`D64_RK01_CLOSED_PASS / 64_SLOT_QUIESCENT_ACTIVITY_NAMESPACE_REKEY_EARNED / IMMEDIATE_OLD_NAMESPACE_REJECTED / GENERATION_RESET_WITHOUT_EPOCH_ALIAS_EXPOSED / EXPLICIT_255_TO_1_REKEY_EARNED / LIVE_REKEY_AND_RESOURCE_SCALE_REMAIN_OPEN`
