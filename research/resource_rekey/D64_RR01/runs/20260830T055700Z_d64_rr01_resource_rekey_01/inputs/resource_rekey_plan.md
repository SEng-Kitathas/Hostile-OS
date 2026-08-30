# D64 Resource Namespace Rekey Plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent resource evidence:** D64/RB02 CLOSED PASS
**Parent activity/binding composition:** D64/ARB01 CLOSED PASS + adopted D64 shadow rule
**Experiment preregistration:** not created by this document
**Architecture promotion:** none

## Problem

RB02 uses finite resource currentness:

`(resource slot, resource generation, resource epoch)`

Ordinary resource-slot reuse fails closed at generation 255 rather than silently wrapping.

That preserves stale-handle rejection but eventually prevents further resource-slot reuse. D64 has no credible finite maximum resource-reuse count for a long-running general-purpose runtime.

The resource namespace therefore needs its own explicit renewal rule.

The activity namespace already has a checked quiescent rekey, but ARB01 established that activity/binding namespace history and resource namespace history are separate. Resource rekey must preserve that separation.

## Namespace separation

### Activity/binding namespace

Currentness includes:

- activity slot / activity generation / activity epoch;
- binding index / binding generation.

ARB01 allows activity rekey to reset activity + binding namespace state while preserving resource generation/epoch.

### Resource namespace

Currentness includes:

- resource slot;
- resource generation;
- resource epoch.

Resource rekey should therefore reset resource namespace state while preserving:

- activity epoch;
- activity generations/state;
- binding generations.

A resource rekey is not an activity rekey and must not silently invalidate current activities.

## Candidate checked resource rekey

`resource_rekey_checked` may mutate resource namespace state only after:

1. all 1,280 `binding_resource_plus1` cells are zero;
2. all 64 `resource_identity` entries are zero;
3. all 64 16-bit `resource_live_count` values are zero;
4. `relation_active == 0`.

Current activities may remain admitted/current while these conditions are true.

If any guard fails:

- return `R`;
- do not change resource epoch;
- do not change resource generation/value/live-count arrays;
- do not change activity or binding state.

## Successful resource rekey

After all guards pass:

1. compute next nonzero `resource_epoch`:
   - 1..254 -> +1;
   - 255 -> 1 only inside checked resource rekey;
2. reset all 64 `resource_generation` entries to zero;
3. reset resource identity/value/live-count arrays to zero as defensive closure even though guards require them already quiescent;
4. publish the new resource epoch;
5. return `W`.

Successful resource rekey must **not**:

- change activity epoch;
- reset any activity array;
- reset `binding_generation`;
- reset or otherwise rekey the activity/binding namespace.

## Why binding generation must survive resource rekey

Binding generation identifies reuse of a per-activity binding cell.

A resource rekey does not retire the activity/binding namespace. If binding generations were reset merely because resource epoch changed, an old binding handle could alias a later binding reuse inside the same current activity namespace.

Therefore binding-generation history survives resource rekey.

This is the mirror image of ARB01, where activity rekey lawfully reset binding generation because the activity epoch changed at the same cooperative revocation boundary.

## Good path

Use one current activity A throughout the resource rekey.

1. Reset full state to activity epoch 1 / resource epoch 1.
2. Acquire A at activity slot 0 / generation 1 / activity epoch 1.
3. A creates resource X identity `0x51`, value `0x7E` in binding index 0 / binding generation 1 / resource slot 0 / resource generation 1.
4. Save:
   - old direct resource handle `(resource0,gen1,res-epoch1)`;
   - old binding handle `(activity0,act-gen1,act-epoch1,binding0,bind-gen1)`.
5. Call checked resource rekey while binding/resource live.
6. Required `R`; resource epoch remains 1; resource identity/live count/binding cell remain unchanged.
7. Detach A binding 0 through ordinary RB02 detach.
8. Required live count 0 and resource identity/value reclaimed; resource generation remains 1; binding generation remains 1.
9. A remains current at activity slot0/gen1/epoch1.
10. Call checked resource rekey.
11. Required `W`.
12. Resource epoch becomes 2.
13. Resource generation slot0 becomes 0.
14. Activity epoch remains 1; A identity/generation remain `0x41` / 1.
15. Binding generation cell0 remains 1.
16. A creates resource Y identity `0x5A`, value `0xEE`.
17. Required binding index0, binding generation advances 1 -> 2.
18. Required resource slot0, resource generation becomes 1, resource epoch2.
19. Old direct X handle `(0,1,1)` returns `R`.
20. Fresh Y direct handle `(0,1,2)` returns `W / EE`.
21. Old binding handle generation1 returns `R`.
22. Fresh binding handle generation2 returns `W / EE`.

This proves resource rekey can renew resource-slot generation state while leaving the activity/binding namespace current and monotonic.

## Negative control — resource generation reset without resource epoch change

Independent reset to activity epoch1 / resource epoch1.

1. Acquire A.
2. A creates X at resource slot0/gen1/epoch1 and save old direct handle.
3. Detach X so resource slot0 is free and generation remains 1.
4. Intentionally bad `resource_reset_generation_only` zeros resource generation while leaving resource epoch1 unchanged.
5. A creates Y -> resource slot0/gen1/epoch1.
6. Present old direct X handle `(0,1,1)`.
7. Required bad-control result: `W / Y-value`.

This is the required stale-token alias: resetting generation without a resource-namespace change makes the old direct handle current again numerically.

The bad routine must not be used by the good rekey path.

## Explicit epoch 255 -> 1 path

Independent bounded fixture:

1. activity epoch1; resource epoch255;
2. A creates X at resource slot0/gen1/res-epoch255;
3. save old direct handle;
4. detach X and reach resource quiescence;
5. checked resource rekey -> `W`, resource epoch1, resource generation reset0;
6. A creates Y -> resource slot0/gen1/res-epoch1;
7. old `(0,1,255)` returns `R`;
8. fresh `(0,1,1)` returns `W / Y`.

This qualifies one explicit 255->1 resource-epoch transition under the cooperative namespace-revocation contract. It does not claim safety for arbitrary external raw tokens retained across unlimited resource-epoch cycles.

## Quiescence / retention contract

The current D64 shadow target treats direct resource handles as transient runtime tokens.

Successful resource rekey is a resource-handle revocation boundary:

- every pre-rekey direct resource handle becomes invalid;
- live bindings/resources block rekey;
- current activities may survive resource rekey because their namespace does not change;
- old binding handles remain governed by binding-generation history, not resource epoch alone.

If a later target requires externally persistent resource handles across resource rekey, this mechanism is insufficient and must be demoted or extended.

## Pareto costs

For RESOURCE_CAP=64:

- quiescence scans 1,280 binding reference cells;
- scans 64 resource identities/live counts;
- resets 64 resource-generation entries and resource state;
- no 1,280-cell binding-generation reset;
- no 64x11 activity-state reset;
- one existing resource-epoch byte changes.

The resource rekey should therefore be cheaper than full activity/binding rekey, while preserving current activities.

## Evidence envelope

Use the qualified fixed 8 KiB stage-2 envelope.

ARB01 occupies 6,591 bytes and already carries the required arrays/routines. A focused resource-rekey discriminator should fit without new large state arrays.

If it does not fit, preserve the size scar before changing the envelope.

## Preregistration gate

A future resource-rekey discriminator must fix:

- exact good, bad-reset, and epoch-wrap matrices;
- exact quiescence checks and transition order;
- static proof that no resource-namespace mutation occurs before all guards pass;
- static proof that activity epoch/state and binding generation are not reset by resource rekey;
- ordinary RB02 binding detach/read/resource read reused rather than test-only substitutes;
- input-snapshot protocol from attempt 1;
- strict nonclaims for external persistent handles and live resource rekey.

## Authority ceiling

A passing discriminator may establish only bounded resource-namespace renewal under the current cooperative D64 runtime-handle contract.

It would not establish:

- externally persistent resource capabilities;
- safety across unlimited retained raw tokens;
- live resource rekey with active bindings;
- resource migration;
- filesystem semantics;
- crash durability;
- SMP/NMI/DMA correctness;
- final architecture;
- R3.1/R6 authority change.

## Disposition

`D64_RESOURCE_REKEY_PLAN_READY / RESOURCE_REKEY_REQUIRES_EMPTY_BINDINGS_AND_RESOURCES / ACTIVITY_NAMESPACE_SURVIVES / BINDING_GENERATION_SURVIVES / BAD_GENERATION_RESET_ALIAS_CONTROL_REQUIRED / NO_EXPERIMENT_YET`
