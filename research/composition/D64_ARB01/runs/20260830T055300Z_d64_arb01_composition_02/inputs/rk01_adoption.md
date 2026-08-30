# D64 RK01 Rekey Adoption Review — 2026-08-30

**Mode:** AUDIT / architecture-rule adoption review
**Current architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Question:** should RK01's checked quiescent activity-namespace rekey become the incumbent currentness-renewal rule for the current D64 shadow scope?
**Higher architecture promotion:** NO
**R3.1/R6 authority change:** NO

## Evidence reviewed

- target-boundary rule: finite currentness fields may not silently wrap into aliases;
- D64 profile: no credible finite maximum activity-slot reuse count for a long-running general-purpose runtime;
- D64/A01: configured 64-slot activity storage/lifecycle works at bounded scope;
- D64 rekey plan: finite deterministic tokens need an explicit retention/revocation contract if no finite lifetime bound exists;
- RK01 preregistration at `7ca3dce6ec8e130661823203ce9de4ad326a3d85`;
- RK01 controlling result at `34123fbd89aa9c759dee5c58ec12e27b6dc7ea2f`.

RK01 result SHA-256:

`6b8833690083e83e78ea0bd59f0b1c79b1bc6a7f3c09e365faced69d1ee209c1`

## What RK01 established

For the configured 64-slot activity namespace:

- rekey while a live activity exists returns `R` without changing that activity or epoch;
- completion status, backing-live state, and active relation mutation independently block rekey;
- full quiescence permits one checked namespace retirement;
- rekey changes epoch, resets all eleven activity arrays across 64 slots, and resumes fresh admission;
- an immediate pre-rekey handle is rejected after the new namespace is installed;
- a fresh handle in the new namespace succeeds;
- generation reset without epoch change makes an old token alias a new occupant;
- explicit epoch 255 -> 1 works at the checked quiescent boundary and rejects the immediate epoch-255 token;
- ordinary per-slot generation still fails closed at 255 rather than silently wrapping.

The controlling stage 2 is 2,177 bytes with 738 bytes of named runtime state. Successful rekey scans 64 activity slots and resets 64 activity records.

## Why a rule adoption is justified

The current architecture already needs some answer to finite namespace exhaustion because D64 has no credible lifetime bound.

Widening the generation field alone does not resolve that semantic problem. It only moves the exhaustion point.

RK01 supplies a smaller explicit answer under the current target assumptions:

- runtime activity handles are internal/transient;
- the current target does not require arbitrary external handles to survive namespace retirement;
- a stop/revoke boundary is therefore lawful if it refuses to proceed while in-scope holders are live;
- the costs are visible: O(64) scan, O(64*11) reset, and possible rekey starvation if an activity never becomes quiescent.

The mechanism also has a useful negative control: resetting generations without changing namespace epoch produces the stale-token alias the mechanism is meant to prevent.

## Adoption decision

**ADOPT for the current D64 integrated-shadow scope.**

Current activity-currentness rule becomes:

1. ordinary activity acquire/reuse never silently wraps slot generation;
2. a free slot at generation 255 returns explicit `G`;
3. if continued activity reuse is required, the runtime may enter an explicit checked activity-namespace rekey;
4. rekey succeeds only after all in-scope activity-handle holders and activity-owned currentness state are quiescent;
5. failed quiescence returns `R` with no namespace mutation;
6. successful rekey changes the current activity epoch, resets the complete configured activity table, and revokes all pre-rekey activity handles;
7. epoch 255 -> 1 is allowed only inside that explicit revocation boundary;
8. durable identity remains separate from runtime activity handles;
9. restart remains a separate fresh-runtime-namespace boundary as already earned by I001.

This rule is an incumbent **shadow architecture rule**, not final production doctrine.

## Retention contract

The adopted rule is valid only under the current cooperative in-scope retention contract:

- no in-scope holder may retain a live activity handle across successful rekey;
- a holder that still owns/uses a handle prevents quiescence;
- raw tokens retained outside the declared runtime contract across unlimited namespace cycles are not covered.

If future requirements include uncooperative external token holders, persistent exported activity handles, or live rekey without global activity quiescence, this rule must be demoted or extended.

## Availability cost

Rekey is not wait-free and not guaranteed to complete while activities remain live.

This matters.

The current target does not yet require uninterrupted namespace renewal, so the cost is accepted at shadow scope rather than hidden.

A later service-availability target may prefer:

- wider currentness fields to make rekey rarer;
- two-namespace handoff;
- explicit live revocation/indirection;
- or another mechanism.

Those are not earned now.

## Demotion triggers

Reopen or demote this rule if later evidence shows any of:

- D64 or successor workload requires permanently live activities such that quiescence cannot be reached at an acceptable interval;
- external/uncooperative holders must present activity handles across rekeys;
- the O(capacity) scan/reset cost violates the target latency/availability budget;
- a resource-binding model needs a different namespace/currentness relation that cannot compose with activity rekey;
- integrated replay shows cross-mechanism state survives rekey when it should have been revoked;
- physical-hardware or stronger concurrency evidence changes the quiescence boundary.

## Remaining frontier

With 64-slot activity scaling and bounded namespace renewal now earned, the next target-scale gap is **resource binding**:

- D64 pressure: up to 20 references from one activity;
- D64 global pressure: 64 live resources;
- I001 evidence: one shared backing with live-count lifetime behavior;
- missing: a generic bounded relation representation that scales those references/resources without importing donor File/Manager ontology.

That problem should enter BUILD-PLAN before any experiment is preregistered.

## Disposition

`RK01_RULE_ADOPTED_AT_D64_SHADOW_SCOPE / QUIESCENT_ACTIVITY_NAMESPACE_REKEY_INCUMBENT / NO_HIGHER_ARCHITECTURE_PROMOTION / RESOURCE_BINDING_NEXT`
