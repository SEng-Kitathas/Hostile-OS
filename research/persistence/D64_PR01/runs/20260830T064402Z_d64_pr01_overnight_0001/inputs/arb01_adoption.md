# D64 ARB01 Composition Adoption Review — 2026-08-30

**Mode:** AUDIT / shadow-rule adoption review
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Question:** should ARB01's binding-aware activity release/rekey rule replace the pre-RB02 activity-lifecycle assumption at current D64 shadow scope?
**Higher architecture promotion:** NO
**R3.1/R6 authority change:** NO

## Evidence reviewed

- D64/A01: generic 64-slot activity lifecycle scaling;
- D64/RK01: checked quiescent activity-namespace rekey and its existing shadow-rule adoption;
- D64/RB02: 64 x 20 binding matrix, 64 resources, 16-bit shared live-count lifetime, binding/resource reuse currentness;
- ARB01 controlling preregistration: `c7170dc018e463e6220bb7ce39e9018950e65754`;
- overlapping preregistration supersession: `dbd969cf437398044ff73161dbb970131a6a30b6`;
- ARB01 science close: `cdc1aea963f37168e2fdbd317a0beff353ce42c1`.

The controlling ARB01 run is `20260830T055300Z_d64_arb01_composition_02`.

Verified controlling readback:

- QEMU `COMPLETED`, exit 33;
- evaluator exit 0;
- static checker exit 0;
- independent audit PASS;
- stage-2 raw 6,591 bytes inside the 8,192-byte envelope;
- named runtime state 3,665 bytes;
- all static checks literal boolean true.

## What ARB01 established

### Release boundary

Clearing activity identity while its 20-cell binding row remains live is unsafe.

The intentionally unsafe identity-only release left binding/resource state intact. A new activity reused the same activity slot and, using its current activity handle with the inherited binding index/generation, the ordinary good binding-read routine returned the prior occupant's value `0x7E`.

Checked release avoided that failure by rejecting while any cell in the selected activity's binding row was nonempty.

### Rekey boundary

Checked activity rekey rejected orphan binding/resource residue even when all activity identity slots were free.

After explicit binding detach and checked activity release, full relation quiescence permitted rekey.

Successful rekey:

- changed activity epoch `1 -> 2`;
- reset all eleven 64-entry activity arrays;
- reset both 1,280-entry binding arrays;
- cleared seeded tail binding-generation residue at cell 1279;
- preserved resource epoch `1`;
- preserved resource slot-0 generation history `1`.

Fresh resource reuse after activity rekey therefore advanced resource generation to 2 rather than treating the resource namespace as new.

### Currentness after composition

After successful activity rekey:

- old activity/binding handle returned `R`;
- fresh activity/binding handle succeeded;
- old direct resource generation-1 handle returned `R` after resource slot reuse;
- fresh generation-2 direct resource handle succeeded.

The activity/binding namespace and resource namespace remain separate currentness domains.

## Adoption decision

**ADOPT for the current D64 integrated-shadow scope.**

The incumbent activity lifecycle rule is amended to:

1. an activity owns its fixed 20-cell binding row while current;
2. checked activity release must validate the activity and require that row to be empty before clearing activity identity;
3. activity release does not implicitly cascade-detach resource bindings;
4. callers must explicitly detach/release owned binding relations before activity release;
5. checked activity-namespace rekey requires complete activity/binding/resource relation quiescence before namespace mutation;
6. successful activity rekey changes activity epoch and resets activity + binding namespace state;
7. successful activity rekey does **not** reset resource generation or resource epoch;
8. binding-generation reset is lawful at successful activity rekey only because the same cooperative revocation boundary retires all in-scope old activity/binding handles;
9. unsafe identity-only activity release is forbidden in the incumbent good path because it can transfer a prior occupant's binding relation to a later occupant.

This supersedes the narrower pre-RB02 interpretation of the RK01 quiescence rule. RK01 remains valid lineage for the activity-namespace mechanism; ARB01 supplies the expanded-state composition rule.

## Why no cascade detach is adopted

ARB01 did not test or require implicit cascade destruction.

Keeping detach explicit preserves causal visibility:

- binding lifetime changes occur in the binding operation;
- resource live-count changes remain directly attributable;
- activity release stays a checked lifecycle operation rather than becoming a hidden multi-resource teardown service.

A later workload may justify cascade semantics, but they are not earned here.

## Costs / limits

The adopted rule adds bounded scans and reset work:

- checked release: up to 20 binding cells;
- activity-rekey activity scan: 64;
- binding quiescence/reset: 1,280 cells;
- resource identity/live-count quiescence scan: 64 resources.

This remains a quiescent stop/revoke mechanism. Permanently live activities or bindings can prevent rekey indefinitely.

## Demotion / extension triggers

Reopen this rule if future evidence requires or shows:

- live/non-quiescent activity rekey;
- activity release with automatic cascade semantics;
- bindings that are intentionally transferable between activity identities;
- external holders that retain binding handles across activity rekey;
- resource namespace renewal that cannot remain separate from activity/binding namespace renewal;
- asynchronous observation or stronger concurrency that breaks the current publication/quiescence assumptions;
- measured scan/reset latency that violates the target availability budget.

## Next architecture seam

With binding-aware activity lifecycle composition now earned, the next direct currentness seam is **resource namespace renewal/rekey**.

RB02 uses finite resource generation/epoch state and only generations 1 and 2. It does not provide continued operation after resource-generation exhaustion.

The next BUILD-PLAN should derive the smallest resource-namespace rekey that:

- rejects while any live binding/resource exists;
- changes resource epoch only at explicit quiescence;
- resets resource generation/state without changing activity epoch or binding-generation history;
- rejects immediate old direct-resource handles;
- exposes generation-reset-without-resource-epoch change as the negative control.

## Disposition

`ARB01_RULE_ADOPTED_AT_D64_SHADOW_SCOPE / CHECKED_RELEASE_REQUIRES_EMPTY_BINDING_ROW / ACTIVITY_REKEY_REQUIRES_FULL_RELATION_QUIESCENCE / ACTIVITY_BINDING_NAMESPACE_SEPARATE_FROM_RESOURCE_NAMESPACE / NO_HIGHER_ARCHITECTURE_PROMOTION`
