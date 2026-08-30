# D64 Activity Namespace Rekey Plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent profile:** D64 donor-scale reference profile
**Parent scaling evidence:** D64/A01 CLOSED PASS
**Experiment preregistration:** not created by this document
**Architecture promotion:** none

## Problem

D64 has no credible finite upper bound on activity-slot reuse over the life of a long-running general-purpose runtime.

I001 and A01 already establish two useful rules:

- silent generation wrap is forbidden;
- an exhausted finite generation may fail closed with `G`.

That protects currentness, but it eventually stops reuse. A long-running target therefore needs a way to renew the activity-handle namespace without letting old tokens become current again.

## Finite-token limit

A finite deterministic token space cannot guarantee never repeating a token forever if stale tokens may be retained and presented forever.

Therefore at least one additional contract is required:

- bound stale-token lifetime;
- revoke old tokens at an explicit boundary;
- use a larger but still finite namespace with a declared horizon;
- accept a probabilistic collision model;
- or stop when the finite namespace is exhausted.

D64 does not have a credible lifetime bound and does not currently need externally persistent runtime handles. The smallest candidate is therefore an explicit **revocation/quiescence boundary** rather than an arbitrary wider counter.

## Candidate mechanism — quiescent activity-namespace rekey

### Token form

Activity handles remain:

`(slot, generation, activity_epoch)`

All three parts must match current state before identity or activity data is exposed.

### Scope

This plan renews the **activity-handle namespace only**.

It does not claim to rekey arbitrary future resource handles, storage names, network identities, or external capabilities.

### In-scope retention contract

Runtime activity handles are transient internal tokens.

A successful activity-namespace rekey is a revocation boundary:

- every pre-rekey activity handle becomes invalid;
- no in-scope component may retain a live activity handle across the completed rekey;
- a component that still owns/uses a handle prevents quiescence and therefore prevents rekey completion;
- durable identity remains separate and is not converted into a current runtime handle by rekey.

This is the rule that makes finite namespace reuse meaningful. If a later target requires uncooperative external holders to present arbitrarily old handles after many rekeys, this mechanism is insufficient and the target must reopen the identity/capability problem.

## Quiescence condition

A checked activity rekey may succeed only when:

1. every configured activity identity slot is free (`identity == 0`);
2. there is no current activity completion record that can wake an activity;
3. no activity-owned shared-backing binding remains live;
4. no activity mutation/currentness transition is active.

For the first discriminator, items 2-4 may be represented by one completion-status byte, one backing-live byte, and one relation-active byte, matching already-earned state species rather than inventing managers.

If any condition is nonzero/live, rekey returns `R` and changes nothing.

## Successful rekey transition

After the full quiescence scan passes:

1. advance `activity_epoch` to a new nonzero value;
2. if current epoch is `1..254`, next epoch is current+1;
3. if current epoch is `255`, explicit rekey may wrap to `1` because the old namespace has been quiesced and revoked;
4. zero every per-slot generation;
5. zero every other per-slot runtime field;
6. clear completion/currentness scratch belonging to the old activity namespace;
7. return `W`.

The `255 -> 1` transition is **not silent modulo wrap**. It is allowed only inside the explicit checked revocation boundary.

## Why epoch repetition is boundedly lawful here

The old target rule forbids modulo wrap when a repeated value may alias a live/stale token.

This plan changes the condition, not the arithmetic:

- ordinary acquire may never silently wrap a slot generation;
- ordinary runtime operation may never silently wrap the activity epoch;
- only an explicit rekey may reuse epoch value `1` after epoch `255`;
- successful rekey requires that every in-scope holder has reached the revocation/quiescence boundary;
- therefore no **in-scope** old handle from the retired namespace remains valid across that boundary.

The mechanism does **not** claim safety against arbitrary byte-for-byte reintroduction of handles retained outside the declared target contract for hundreds of namespaces.

## Required negative controls for a future discriminator

### Control A — rekey while live

With one live activity:

- checked rekey must return `R`;
- epoch must not change;
- activity identity/generation must not change.

This prevents namespace renewal from revoking a live activity behind its holder.

### Control B — generation reset without epoch change

Construct:

1. epoch 1;
2. slot 0 = A / generation 1;
3. save old handle `(0,1,1)`;
4. release A;
5. bad control resets generation to 0 without changing epoch;
6. acquire B -> slot 0 / generation 1 / epoch 1.

The old handle now aliases B and must read B in the bad control.

This demonstrates why generation reset alone is not a rekey.

### Control C — checked rekey invalidates the immediate old token

Construct:

1. epoch 1;
2. A / generation 1;
3. save `(0,1,1)`;
4. release A and reach quiescence;
5. checked rekey -> epoch 2, generations reset;
6. acquire B -> `(0,1,2)`.

Required consequence:

- old `(0,1,1)` returns `R`;
- new `(0,1,2)` returns `W` and B.

### Control D — explicit epoch wrap at a quiescent boundary

Construct a bounded fixture at epoch 255:

1. acquire C -> `(0,1,255)`;
2. save old token;
3. release C and reach quiescence;
4. checked rekey -> epoch 1;
5. acquire D -> `(0,1,1)`;
6. old epoch-255 token returns `R`;
7. new epoch-1 token returns `W` and D.

This tests the explicit checked wrap transition, not hundreds of historical namespaces.

## Pareto costs

Candidate costs:

- no wider per-slot generation field;
- one activity-epoch value already exists in the current lineage;
- rekey requires an O(activity capacity) quiescence scan;
- rekey requires O(activity capacity * activity-field-count) reset work;
- rekey introduces an availability boundary: activity creation/reuse pauses until quiescence is reached;
- components that keep activities permanently live can starve rekey;
- the design therefore trades state bytes for a rare stop/revoke operation.

For D64/A01's 64 slots and eleven activity field species, reset work is bounded and explicit. No claim is made yet about whether this trade is better than wider counters under a real production workload.

## Alternatives retained

### Wider generation / epoch

Pros:
- simple fast path;
- much longer exhaustion horizon.

Cons:
- adds state bytes to every handle/slot if generation width grows;
- still finite;
- without a declared lifetime bound it postpones rather than resolves the semantic question.

### Compound wide namespace identity

Pros:
- can make practical wrap extremely remote.

Cons:
- more bytes and compare work;
- still requires a stated collision/lifetime model.

### Random/cryptographic nonce

Pros:
- can avoid coordinated quiescent numeric rollover.

Cons:
- probabilistic rather than absolute collision model;
- entropy/crypto/state burden not yet earned by current target.

### Never reuse slot identity

Pros:
- simple stale-token reasoning.

Cons:
- finite resource consumption eventually stops progress;
- does not match long-running reuse requirement without a larger allocation/identity mechanism.

## Plan decision

For the current D64 shadow target, the smallest justified next discriminator is:

> **checked quiescent activity-namespace rekey with epoch change, complete generation reset, immediate old-token rejection, explicit live-state rejection, and a generation-reset-without-epoch negative control.**

It should use the configured 64-slot table, not fall back to a two-slot toy, so the quiescence scan and reset cost are measured at the current donor-scale activity pressure.

## Preregistration gate

A future D64 rekey experiment may be preregistered only when it fixes:

- exact 64-slot state layout;
- exact quiescence fields and scan order;
- exact rekey transition order;
- exact epoch-wrap rule;
- exact good and bad trace matrix;
- static source checks proving no mutation before quiescence succeeds;
- input-snapshot protocol from the first attempt;
- measured stage-2 bytes, runtime-state bytes, quiescence scan/reset instruction or iteration counts;
- authority ceiling that excludes external arbitrarily retained handles and general capability revocation.

## Authority ceiling

Even a passing discriminator would establish only a bounded activity-namespace renewal mechanism under a cooperative in-scope quiescence/revocation contract.

It would not establish:

- arbitrary external capability revocation;
- safety for uncooperative holders retaining tokens across unlimited rekeys;
- general resource-handle rekey;
- lock-free or live rekey;
- wait-free progress;
- SMP/NMI/DMA correctness;
- cryptographic identity;
- final architecture;
- R3.1/R6 authority change.

## Disposition

`D64_REKEY_PLAN_READY / QUIESCENT_REVOCATION_BOUNDARY_CANDIDATE / 64_SLOT_SCALE_REQUIRED / NO_EXPERIMENT_YET / NO_PROMOTION`
