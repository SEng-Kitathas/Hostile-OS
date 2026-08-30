# D64 Activity-Rekey / Binding Composition Plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent activity-rekey evidence:** D64/RK01 CLOSED PASS + adopted shadow rule
**Parent binding evidence:** D64/RB02 CLOSED PASS
**Experiment preregistration:** not created by this document
**Architecture promotion:** none

## Problem

RK01 earned checked quiescent activity-namespace rekey before the D64 binding matrix existed.

RB02 later added:

- 64 activity rows;
- 20 binding cells per activity;
- 1,280 binding cells total;
- 64 global resources;
- 16-bit resource live counts;
- binding-generation and resource-generation currentness.

The old RK01 quiescence rule therefore cannot simply be assumed to cover the new relation state.

A current activity must not be released or namespace-rekeyed out from under a live binding row, because the binding/resource relation can otherwise survive the activity identity and become visible to a later occupant of the same activity slot.

## Derived ownership/currentness rule

Under the current D64 relation model:

- an activity slot owns one fixed 20-cell binding row;
- a binding handle includes activity slot/generation/epoch plus binding index/generation;
- a live binding contributes one to the target resource's live count;
- resource reclaim occurs only when the final binding is detached.

Therefore activity lifecycle and binding lifecycle are coupled even though no historical File/Manager object is introduced.

## Candidate safe activity release

`activity_release_checked(activity_handle)`:

1. validate current activity slot/generation/epoch;
2. compute that activity's 20-cell binding row;
3. scan all 20 `binding_resource_plus1` cells;
4. if any cell is nonzero, return `R` and change no activity/binding/resource state;
5. otherwise clear activity identity only and return `W`;
6. preserve activity generation until later successful reuse, matching A01/RK01 lifecycle currentness.

The release routine does not auto-detach bindings. The caller must explicitly detach/release owned relations first.

Reason: implicit cascade would hide resource-lifetime work inside activity release and increase the causal surface without evidence that cascade semantics are desired.

## Candidate binding-aware activity rekey

`activity_rekey_checked` may change the activity namespace only after all of these pass:

1. all 64 activity identity entries are zero/free;
2. all 1,280 `binding_resource_plus1` cells are zero/empty;
3. all 64 resource live counts are zero;
4. all 64 resource identity entries are zero under the current RB02 lifetime rule;
5. completion/currentness state required by RK01 is quiescent;
6. no relation mutation is active.

If any condition fails, return `R` with no namespace mutation.

On success:

1. advance activity epoch to the next nonzero value using the already-adopted RK01 rule;
2. reset all eleven 64-entry activity arrays;
3. reset all 1,280 binding resource cells;
4. reset all 1,280 binding generations because all old activity/binding handles have been revoked at the same cooperative boundary;
5. leave `resource_epoch` unchanged — this is activity/binding namespace renewal, not resource-namespace rekey;
6. resource tables should already be empty/quiescent and are not silently rekeyed;
7. return `W`.

Binding-generation reset is lawful only because the activity epoch changes and the rekey contract revokes all in-scope pre-rekey activity/binding handles.

## Negative control — unsafe activity release

An explicitly bad routine clears activity identity without scanning its binding row.

Bounded control:

1. epoch 1; acquire A at slot 0 / generation 1;
2. A creates one resource value `0x7E` in binding index 0 / binding generation 1;
3. bad release clears A identity but leaves the binding/resource relation live;
4. all activity identities are now free, but the binding row and resource live count remain nonzero;
5. good `activity_rekey_checked` must return `R` because relation state is not quiescent;
6. acquire B into the same activity slot, generation 2 / epoch 1;
7. use B's current activity handle with binding index 0 / binding generation 1;
8. the ordinary RB02 binding read returns `W / 0x7E`.

This demonstrates the failure shape: freeing activity identity without releasing its row lets a later occupant inherit/read the prior occupant's resource relation.

The bad routine is a deliberate negative control only.

## Good path

Independent reset:

1. epoch 1; acquire A at slot 0 / generation 1;
2. A creates resource value `0x7E` in binding 0;
3. checked activity release returns `R` while binding 0 is live;
4. activity identity/generation stay A/1;
5. binding 0 remains present;
6. resource live count remains 1;
7. checked binding detach returns `W`, live count becomes 0, resource identity/value are reclaimed;
8. checked activity release now returns `W`;
9. checked activity rekey returns `W`;
10. activity epoch becomes 2;
11. binding row 0 cell 0 is empty and its binding generation has been reset to 0;
12. resource epoch remains 1;
13. acquire C into slot 0 -> generation 1 / activity epoch 2;
14. C sees binding index 0 empty;
15. old A binding handle `(activity slot0, activity generation1, activity epoch1, binding0, binding generation1)` returns `R` before resource value exposure.

## Why this discriminator comes before resource rekey

RB02 introduced the binding matrix into the already-adopted activity lifecycle. If the lifecycle cannot compose with the new relation state, resource-namespace renewal would build on a broken ownership/currentness boundary.

The composition seam therefore has dependency priority over separate resource rekey.

## Evidence envelope

Use the already-qualified fixed 8 KiB stage-2 envelope.

The combined state already fits: RB02 stage 2 is 6,432 bytes with 3,658 named runtime-state bytes. The extra release/rekey loops may consume remaining code headroom, but no new large arrays are required.

If the 8 KiB envelope is exceeded, record that as evidence before changing the envelope; do not silently drop currentness fields to make it fit.

## Required future static checks

A future preregistration should require literal-boolean checks that prove:

- one shared 64x20 binding matrix is used by bind/detach/read/release/rekey;
- checked activity release validates the activity and scans only its 20-cell row before clearing identity;
- release reject branch mutates nothing;
- bad release omits row scan and is used only in the negative-control path;
- checked rekey scans all 64 activity identities before mutation;
- checked rekey scans all 1,280 binding resource cells before mutation;
- checked rekey checks all 64 resource live counts and identities before mutation;
- successful rekey resets all eleven activity arrays and both binding arrays through bounded loops;
- successful rekey changes activity epoch and does not change resource epoch;
- ordinary RB02 binding read is reused for the inheritance negative control;
- run-local input snapshot/receipt closure holds from attempt 1.

## Authority ceiling

A passing discriminator may establish only that the current bounded activity lifecycle/rekey rule composes with the D64 binding/resource relation under the tested cooperative quiescence contract.

It would not establish:

- general ownership types;
- cascade destruction semantics;
- arbitrary resource lifecycle;
- resource namespace rekey;
- live/non-quiescent rekey;
- uncooperative external handle revocation;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.

## Disposition

`D64_ACTIVITY_BINDING_COMPOSITION_PLAN_READY / RELEASE_REQUIRES_EMPTY_BINDING_ROW / REKEY_REQUIRES_RELATION_QUIESCENCE / UNSAFE_RELEASE_INHERITANCE_CONTROL_REQUIRED / RESOURCE_REKEY_DEFERRED`
