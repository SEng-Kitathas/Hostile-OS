# D64 RR01 Resource-Rekey Adoption Review — 2026-08-30

**Mode:** AUDIT / shadow-rule adoption review
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Question:** should RR01's checked quiescent resource-namespace rekey become the incumbent D64 resource-currentness renewal rule?
**Higher architecture promotion:** NO
**R3.1/R6 authority change:** NO

## Evidence reviewed

- D64/RB02: 64-resource currentness, generation-qualified direct handles, 16-bit live-count lifetime;
- D64/ARB01: activity/binding namespace composition and preservation of resource generation/epoch across activity rekey;
- ARB01 shadow-rule adoption at `184eb53f32b5b082c5b0ffa91b1d59bdf78a4032`;
- RR01 preregistration at `d293ecc46437a50fe642ea7dc944dc2213fe3b26`;
- RR01 science close at `0615f4b2b80e3e7a9d8e6dd727e266d119a623c5`.

RR01 result SHA-256:

`c958531ff4b35bf168e1c650722d48fdb302bc80578ac7373ff45815bdcb449e`

Controlling run:

`20260830T055700Z_d64_rr01_resource_rekey_01`

Verified:

- QEMU `COMPLETED`, exit 33;
- evaluator exit 0;
- static checker exit 0;
- independent audit PASS;
- stage 2 6,655 / 8,192 bytes;
- named runtime state 3,665 bytes;
- all 17 static checks literal boolean true.

## What RR01 established

### Resource rekey refuses live relation state

While activity A remained current and owned resource X through a live binding, checked resource rekey returned `R` without changing resource epoch, identity, live count, or binding relation.

### Resource rekey can occur while activities remain current

After ordinary binding detach reclaimed X and reduced resource live count to zero, A remained current at activity generation1 / activity epoch1.

Checked resource rekey then:

- returned `W`;
- changed resource epoch `1 -> 2`;
- reset resource generation slot0 `1 -> 0`;
- preserved activity epoch `1`;
- preserved A identity/generation;
- preserved binding generation `1`.

This confirms resource namespace renewal is independent from the current activity/binding namespace.

### Separate histories remain current

After resource rekey, A created Y:

- binding generation advanced `1 -> 2` because the binding namespace was not reset;
- resource generation became `1` in resource epoch2 because the resource namespace was reset.

Old X direct resource handle `(slot0,gen1,epoch1)` rejected.
Fresh Y direct handle `(slot0,gen1,epoch2)` succeeded.
Old binding generation1 rejected.
Fresh binding generation2 succeeded.

### Negative control proves epoch change is load-bearing

Generation-only reset without resource epoch change let an old direct resource handle alias the new occupant and return its value.

Therefore resource-generation reset alone is not resource namespace renewal.

### Checked resource epoch 255 -> 1

RR01 also qualified one explicit resource epoch 255 -> 1 transition at resource quiescence. Old epoch255 handle rejected; fresh epoch1 handle succeeded.

## Adoption decision

**ADOPT for the current D64 integrated-shadow scope.**

The incumbent resource-currentness rule becomes:

1. ordinary resource-slot reuse never silently wraps generation;
2. a free resource slot at generation255 fails closed rather than wrapping;
3. continued reuse after finite-generation pressure may enter checked resource-namespace rekey;
4. resource rekey requires every binding reference empty, every resource identity/live count quiescent, and relation mutation inactive;
5. current activities may remain live/current through resource rekey;
6. successful resource rekey changes resource epoch and resets resource generation/state;
7. successful resource rekey leaves activity epoch/state and binding-generation history unchanged;
8. resource epoch 255 -> 1 is allowed only at that explicit checked revocation boundary;
9. every pre-rekey direct resource handle becomes invalid under the cooperative runtime-handle contract.

This is an incumbent shadow rule, not final production doctrine.

## Retention / availability contract

The rule assumes direct resource handles are transient runtime tokens that may be revoked at successful resource rekey.

Live bindings/resources block rekey. Current activities may continue if their binding rows are empty.

A later target requiring externally persistent resource handles or live rekey with active bindings must demote or extend this rule.

## Costs

At D64 scale:

- binding-quiescence scan: 1,280 cells;
- resource quiescence/reset scan: 64 resources;
- no activity-array reset;
- no binding-generation reset.

The resource rekey is therefore narrower than full activity/binding rekey but still pays an O(1,280) proof-of-quiescence scan.

## Demotion / extension triggers

Reopen if later evidence requires:

- externally persistent direct resource handles across rekey;
- live resource rekey while bindings remain active;
- resource migration rather than revoke/recreate;
- tighter availability latency than the quiescence scan/reset allows;
- asynchronous observation showing the publication/detach assumptions are insufficient;
- persistence/restart composition that changes the resource namespace boundary.

## Next architecture seam

The direct finite-currentness seams are now boundedly covered for both activity/binding and resource namespaces.

The next causal seam is **asynchronous observation of coupled binding/resource mutation**.

RB02/ARB01/RR01 all execute their binding/resource publication and detach paths with maskable interrupts disabled. P14 earlier established that coupled state can require an explicit coherence boundary under IRQ observation, but the full D64 binding/resource transition has not yet been replayed under a real asynchronous observer.

The next BUILD-PLAN should derive one discriminator that observes the bind-publication and detach transition with real IRQ0, compares an intentionally unprotected path against a minimal protected region, and measures interrupt-off cost.

## Disposition

`RR01_RULE_ADOPTED_AT_D64_SHADOW_SCOPE / RESOURCE_NAMESPACE_REKEY_INCUMBENT / ACTIVITY_BINDING_NAMESPACE_PRESERVED / NO_HIGHER_ARCHITECTURE_PROMOTION / ASYNC_COUPLED_MUTATION_NEXT`
