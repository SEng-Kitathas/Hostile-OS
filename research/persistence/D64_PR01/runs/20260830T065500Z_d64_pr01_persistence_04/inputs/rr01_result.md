# D64 / RR01 — resource namespace rekey result

**Disposition:** PASS CLOSED / BOUNDED RESOURCE-REKEY SUCCESS
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Lineage

Resource-rekey plan commit:

`eb32e0fde4163540d023e895a75e6c1e144bcd7c`

RR01 preregistration commit:

`d293ecc46437a50fe642ea7dc944dc2213fe3b26`

Preregistration SHA-256:

`28da389abff32889360b8405f60d1a1392e03ad5b867422b492be51bea19b0a4`

ARB01 result used as parent evidence:

`4dc29d3ec73edace379fd4200bb5e0e34569429b8f6fb7a9487eba594c629ede`

ARB01 adoption review:

`a602169694643bb8e52c3d64825827403bc12986db325962e56426ca4c0868ac`

RB02 result:

`634edb4185e20388f3c80b13b32b5140b35b7ff0be257aa56dd59fc32094767c`

The preregistration was sealed before RR01 mechanism/evaluator/checker/launcher source existed.

## Controlling run

Run:

`20260830T055700Z_d64_rr01_resource_rekey_01`

QEMU:

- PID `33952`
- started `2026-08-30T05:56:07.981072+00:00`
- ended `2026-08-30T05:56:08.180497+00:00`
- status `COMPLETED`
- exit `33`
- wall time `199.407 ms` as harness data only

Evaluator exit: `0`.
Static checker exit: `0`.
Independent closure audit: PASS.

## Exact guest trace

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
RES_CAP=40
LIVE_REKEY=R
LIVE_REPOCH=01
LIVE_RID=51
LIVE_RCOUNT=0001
LIVE_BIND=01
DETACH=W
AFTER_RCOUNT=0000
AFTER_RID=00
AFTER_RGEN=01
A_ID=41
A_GEN=01
A_EPOCH=01
BGEN_BEFORE=01
GOOD_REKEY=W
NEW_REPOCH=02
RGEN_AFTER_REKEY=00
A_EPOCH_AFTER=01
A_ID_AFTER=41
A_GEN_AFTER=01
BGEN_AFTER_REKEY=01
Y_CREATE=W
Y_BGEN=02
Y_RGEN=01
OLD_RES=R
NEW_RES=W
NEW_RES_VAL=EE
OLD_BIND=R
NEW_BIND=W
NEW_BIND_VAL=EE
BAD_RESET=W
BAD_OLD_RES=W
BAD_OLD_VAL=EE
WRAP_REKEY=W
WRAP_REPOCH=01
WRAP_RGEN=00
WRAP_OLD=R
WRAP_NEW=W
WRAP_VAL=EE
DONE
```

## Qualified consequence

### Live binding/resource state blocks resource rekey

Activity A remained current at slot0 / activity generation1 / activity epoch1 and owned resource X through binding0.

Checked resource rekey returned `R` while that relation was live and preserved:

- resource epoch `01`;
- resource identity `51`;
- resource live count `0001`;
- binding cell0 `01`.

Resource namespace renewal therefore does not silently revoke a live binding/resource relation.

### Explicit detach reaches resource quiescence without changing activity namespace

Ordinary RB02 binding detach returned `W`.

After detach:

- resource live count became `0000`;
- resource identity cleared `00`;
- resource generation remained `01`;
- A remained identity `41`, activity generation `01`, activity epoch `01`;
- binding generation remained `01`.

The activity/binding namespace stayed current while the resource became quiescent.

### Resource rekey renews only the resource namespace

Checked resource rekey then returned `W`.

Observed after successful rekey:

- resource epoch `01 -> 02`;
- resource generation slot0 reset `01 -> 00`;
- activity epoch remained `01`;
- A identity/generation remained `41 / 01`;
- binding generation remained `01`.

This is the central RR01 distinction: resource namespace renewal does not reset the current activity/binding namespace.

### Fresh resource/binding reuse preserves separate histories

A created resource Y (`0x5A`, value `0xEE`) after resource rekey.

Required/current observations:

- binding generation advanced `01 -> 02` because the binding namespace was not rekeyed;
- resource generation became `01` inside new resource epoch `02` because the resource namespace was rekeyed.

Old X direct handle `(slot0, resource-gen1, resource-epoch1)` returned `R`.

Fresh Y direct handle `(slot0, resource-gen1, resource-epoch2)` returned `W / EE`.

Old binding handle generation1 returned `R`.

Fresh binding handle generation2 returned `W / EE`.

### Negative control — generation reset without resource epoch change aliases

Under an independent reset, X was created at resource slot0/gen1/epoch1 and then detached.

The deliberately bad `resource_reset_generation_only` zeroed resource generation without changing resource epoch.

Y then reused resource slot0/gen1/epoch1.

The saved old X direct handle `(0,1,1)` returned:

`W / EE`

against Y.

This is the required failure shape: **resource generation reset alone is not resource namespace renewal.**

### Explicit checked resource epoch 255 -> 1

Under an independent fixture beginning at resource epoch255:

- X was created at slot0/gen1/epoch255 and detached;
- checked resource rekey returned `W`;
- resource epoch became `01`;
- resource generation slot0 reset to `00`;
- Y reused slot0/gen1/epoch1;
- old `(0,1,255)` returned `R`;
- fresh `(0,1,1)` returned `W / EE`.

This qualifies one explicit checked 255->1 resource-epoch transition under the current cooperative resource-handle revocation contract. It does not establish safety for arbitrary out-of-contract raw handles retained across unlimited resource-epoch cycles.

## Static/source closure

All 17 static checker values are literal JSON booleans and all are `true`.

The checker verified:

- exact D64 capacities and arrays;
- ordinary activity acquire, bind-new, detach, binding-read, and resource-read paths are reused;
- resource rekey scans all 1,280 binding reference cells before mutation;
- resource rekey checks all 64 resource identities and all 64 16-bit live counts before mutation;
- relation-active guard occurs before mutation;
- reject branch performs no namespace mutation;
- successful resource rekey resets resource generation/identity/value/live-count state through a 64-bound loop;
- successful rekey publishes a nonzero resource epoch after guards/reset;
- resource rekey does not write activity epoch or activity arrays;
- resource rekey does not write either binding array;
- bad generation-only reset does not change resource epoch and is separate from the good path;
- ordinary resource generation remains fail-closed at 255;
- direct resource read checks slot/identity/generation/epoch before value exposure;
- binding read checks activity and binding currentness before value exposure;
- run-local manifest/receipt source closure and host nonmutation/nonsynthesis hold;
- every checker result is a literal JSON boolean.

## Independent closure

Independent audit:

`D64-RR01-independent-closure-v1`

SHA-256:

`42564aacb5879b1226a9898b93cac27e4fb785aede0c3ee3a5e5288eacaa61b0`

All 13 audit checks passed:

- manifest hash matches receipt;
- all run-local snapshots match manifest bytes/hashes;
- receipt source hashes match manifest snapshots;
- preregistration lineage exactly `d293ecc46437a50fe642ea7dc944dc2213fe3b26`;
- QEMU exit33;
- evaluator pass;
- static pass;
- all static checks boolean true;
- stage2 fit 6,655 / 8,192;
- named runtime state 3,665 bytes;
- capacities match;
- scan measurements match;
- namespace observations confirm activity epoch `01`, resource epoch `02`, binding generation `01` after good rekey.

## Pareto / size observations

- stage-2 raw bytes: `6,655`
- qualified stage-2 extent: `8,192`
- headroom: `1,537` bytes
- named runtime state: `3,665` bytes
- activity capacity: `64`
- binding cells/activity: `20`
- total binding cells: `1,280`
- resource capacity: `64`
- resource-rekey binding scan bound: `1,280`
- resource scan/reset bound: `64`
- activity state reset by resource rekey: `0`
- binding-generation reset by resource rekey: `0`
- QEMU wall time: `199.407 ms` as harness data only

Resource rekey is therefore cheaper in reset scope than full activity/binding rekey, while still paying the 1,280-cell binding-quiescence scan required to prove no live relation points into the resource namespace being retired.

## Provenance / key hashes

Controlling input-manifest SHA-256:

`363a3192b9125f85f168d925022f988a3d7e9366a5ec496de8a4e5dff6e69836`

Controlling receipt SHA-256:

`797250cc58d8022d2386295fc4630637b094f4caecbd7ad6379d0f748f5067b6`

Sources:

- stage2.S: `c79dc30860e7670d23d666ea8f82f42c74d6083b5cfbd6f881747bc12a5b8094`
- stage2.ld: `5ca745e7d51e8d69ae9bdb5f86d137e7c7d4cd69e161ab5c8b61a105af5502fb`
- launcher: `796529eb8490a8cbabff52cc752bff5d7fc9a22f991d590f78ca90774d7cde25`
- evaluator: `1b22c5d7fd06cc77a3c32b2b63ebaf5cce141e752f4951c03c2fdededda4d876`
- static checker: `62d29762e88e8da9a3dbd812a4859ab827251c8891bb5ef6fe09447efc47aa74`

Artifacts:

- stage2.raw.bin: `caea88dd7ff3bac445ef99a9483a9e68ba86a8642551e71528610cf98ac906dd`
- debug trace: `a35805dcdedf634ff0b3ab6c434e00dfacd33f3c156479c03fb6c6d8115e59d8`
- evaluation: `4f9c1060ed4de3dd4ba460f5f1c907b61885311d6170b8ee2a5cb04c89629e5b`
- static closure: `a98ced098900ec3a704f487c318d5e3ac68394767a06b9fcac988e4b8f219b26`
- independent audit: `42564aacb5879b1226a9898b93cac27e4fb785aede0c3ee3a5e5288eacaa61b0`

## What RR01 resolves

RR01 resolves the immediate finite resource-namespace renewal seam at bounded D64 shadow scope:

- live binding/resource state blocks resource rekey;
- resource rekey can occur while activities remain current once bindings/resources are quiescent;
- successful resource rekey changes resource epoch and resets resource generation/state only;
- activity epoch/state and binding-generation history survive;
- stale direct resource handles reject after rekey;
- fresh direct resource handles succeed;
- binding-cell reuse remains independently current through binding generation;
- generation reset without resource-epoch change aliases the stale direct handle exactly as predicted.

## Open seams after RR01

RR01 deliberately does not solve:

1. live/non-quiescent resource rekey with active bindings;
2. external/persistent resource handles across namespace retirement;
3. resource/binding persistence across restart;
4. asynchronous observation of binding/resource publication and detach transitions;
5. crash/partial-write durability;
6. physical-hardware behavior.

The most direct next science seam is asynchronous observation of the coupled binding/resource mutation because RB02/RR01 ran with interrupts disabled. Persistence is a separate later responsibility.

## Authority ceiling / nonclaims

RR01 does not establish:

- externally persistent resource capabilities across rekey;
- safety for arbitrary raw handles retained through unlimited namespace cycles;
- live resource rekey with active bindings;
- resource migration;
- historical File/POSIX/DOS semantics;
- crash durability;
- SMP/NMI/DMA correctness;
- physical hardware behavior;
- final/canonical/production HOSTILE-OS architecture;
- any R3.1/R6 authority change.

## Disposition

`D64_RR01_CLOSED_PASS / RESOURCE_NAMESPACE_REKEY_EARNED_AT_QUIESCENCE / CURRENT_ACTIVITY_NAMESPACE_SURVIVES / BINDING_GENERATION_HISTORY_SURVIVES / GENERATION_ONLY_RESET_ALIAS_EXPOSED / EXPLICIT_RESOURCE_EPOCH_255_TO_1_EARNED`
