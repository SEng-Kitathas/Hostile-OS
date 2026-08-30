# D64 Resource-Binding Live-Count Width Correction — 2026-08-30

**Mode:** BUILD-PLAN / append-only correction
**Corrects:** `research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md`
**Reason:** pre-preregistration capacity math exposed an insufficient field width
**Original sealed plan:** remains unchanged
**Architecture promotion:** none

## Discovered conflict

The sealed resource-binding plan proposed:

- 64 activities;
- 20 binding cells per activity;
- `64 * 20 = 1,280` total binding cells;
- one one-byte `resource_live_count` per global resource.

Those statements do not compose at full declared binding capacity.

If all 1,280 live binding cells refer to the same current resource, that resource needs a live count of 1,280 decimal / `0x0500`.

An 8-bit count can represent only 0..255. Therefore one-byte live count would either overflow, require an undeclared sharing cap, or force a different lifetime representation.

None of those hidden choices is lawful under the D64 profile.

## Correction

For the current D64 resource-binding candidate:

`resource_live_count[64]` SHALL use **16-bit unsigned counts**.

Required representable range for the D64 binding matrix:

- minimum: `0`;
- maximum possible live bindings to one resource: `1,280` / `0x0500`.

16 bits are sufficient for the entire declared D64 binding-cell population.

This is a target-derived width, unlike the activity generation witness width. The width comes directly from:

`ACTIVITY_CAP * BINDINGS_PER_ACTIVITY = 64 * 20 = 1,280`.

## Corrected core state cost

- activity arrays: `64 * 11 = 704` bytes;
- binding resource+1 matrix: `1,280` bytes;
- binding generation matrix: `1,280` bytes;
- resource identity array: `64` bytes;
- resource generation array: `64` bytes;
- resource value array: `64` bytes;
- resource live-count array: `64 * 2 = 128` bytes;
- resource epoch: `1` byte.

Corrected core relation-state subtotal:

`704 + 1280 + 1280 + 64 + 64 + 64 + 128 + 1 = 3,585 bytes`.

The prior 3,521-byte subtotal is superseded by 3,585 bytes for any descendant using this representation.

## Operation implications

`bind_existing_resource` and first binding creation must update a 16-bit live count.

`binding_detach` must decrement a 16-bit live count.

The invariant remains:

> every live binding cell contributes exactly one to its target resource's live count, and a resource slot cannot be reclaimed/reused while that count is nonzero.

A descendant checker should pressure this relation rather than trusting the wider field by declaration.

## Next discriminator requirement

The first resource-binding scale discriminator should include an independent **max-sharing path** that reaches the mathematical D64 maximum:

- one current global resource;
- all `1,280` binding cells live and pointing at it;
- observed live count exactly `0x0500`;
- a 21st binding for any already-full activity returns `F` without changing that count;
- a representative last binding can still read the shared resource.

This path proves the corrected count width is not dead state.

A separate reset path should then test the 64-global-resource pressure, shared lifetime, resource reuse, stale binding-cell handle rejection, and stale direct-resource-handle rejection.

## What is not changed

This correction does not change:

- D64's 64-activity / 20-binding / 64-resource pressure profile;
- binding-generation currentness;
- resource-generation/current-epoch currentness;
- the no-File/Manager ontology rule;
- the qualified 8 KiB stage-2 envelope;
- the decision to defer resource-namespace rekey;
- the decision to defer activity-rekey-with-binding composition.

## Scar

`DECLARED_BINDING_CAPACITY * SHARING != ONE_BYTE_LIVE_COUNT`

The error was found before resource science preregistration or implementation and is therefore a plan-level correction, not a failed experiment.

## Disposition

`D64_RESOURCE_LIVE_COUNT_16_BIT / MAX=0x0500 / CORE_RELATION_STATE=3585_BYTES / SEALED_PLAN_RETAINED / DESCENDANTS_USE_CORRECTION`
