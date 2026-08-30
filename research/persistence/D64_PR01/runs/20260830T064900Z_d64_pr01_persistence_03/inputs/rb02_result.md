# D64 / RB02 — corrected bounded resource-binding scale result

**Disposition:** PASS CLOSED / BOUNDED RESOURCE-BINDING SCALE SUCCESS
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Lineage

The original RB01 preregistration at `76fb008cb5e6c3ad16a8e3497dc8b781fd06cfee` fixed resource live count at one byte. Before any RB01 build or run, D64 capacity math showed that 64 activities x 20 binding cells permits 1,280 simultaneous bindings to one resource. The one-byte field could not represent that state.

The append-only correction was sealed at:

`d03182995dd882a7bebdf7ff76fe8fd9785be803`

RB01 was superseded before execution at:

`f9205041c07a5b223ae164e0e597e681fb35e670`

No RB01 guest ran and no RB01 scientific result exists.

RB02 corrected the representation to one 16-bit live count per resource and added a maximum-sharing pressure path. Controlling preregistration:

`0d0305ebde56d7a9eb70a3db84b00fcf96b33c17`

Qualified 8 KiB stage-2 envelope:

`734674f8a35974433fd6a213e2a2cf1e4de93b43`

## Engineering scars

### Attempt 1 — assembly failure before guest execution

Run:

`20260830T054100Z_d64_rb02_resource_binding_01`

The pre-build input snapshot/manifest was created correctly. Stage 1 compiled and linked. Stage-2 assembly then failed on two invalid instructions:

```text
xorw %bh,%bh
```

`BH` is an 8-bit register, so the correct zeroing instruction is `xorb %bh,%bh`.

Attempt 1 stopped at `04_stage2_clang`. It created no QEMU trace and no evaluation. It has no scientific consequence.

Attempt-1 stage-2 snapshot SHA-256:

`88d9ea6644783b85821638ed17dec97b26efb78de2e90858221136cf55e48c42`

Attempt-1 input-manifest SHA-256:

`260509dd08d84bcb7d7410647f3baf58efb2122a30f3c5abb041249355fbaae8`

Attempt-1 failure record SHA-256:

`607ec0ae351e98f095b840e50cb5aec204799eb92ec970767d9b6ab1c699be91`

The only guest-source change from attempt 1 to attempt 2 was exactly two replacements of `xorw %bh,%bh` with `xorb %bh,%bh`.

### Attempt 2 — exact guest success, static-checker failure

Run:

`20260830T054500Z_d64_rb02_resource_binding_02`

QEMU completed exit 33 and the evaluator matched the complete preregistered matrix. The run was not promoted because two static-checker predicates returned false:

- `detach_lifetime_order`
- `host_no_guest_mutation_or_trace_synthesis`

Both were checker defects rather than guest/source violations.

`detach_lifetime_order` used the first `cmpw $0,resource_live_count(...)` in the detach block, which was the pre-decrement guard, instead of the post-decrement zero test required by the ordering rule.

`host_no_guest_mutation_or_trace_synthesis` rejected the harmless launcher receipt key `resource_live_count_bits` because it searched for the broad substring `resource_live_count` rather than an actual guest-state write expression.

The checker was tightened to the preregistered semantics. A new run ID was required because the checker is a controlling input.

Attempt-2 input-manifest SHA-256:

`923151035dcba3fd29d29638e237cb6ee377a6fc55e9e840ceedb177411ab353`

Attempt-2 receipt SHA-256:

`240ac5f5be0b5d0dc5e16c7428ccce68f0ce73fc61a58dde04dfcb4ab25c5251`

Attempt-2 stage-2 SHA-256:

`44f655331e5aec79ec8dac7c4e7cc514907a103bc7bf55312fd62a6c753f363a`

Attempt-2 checker SHA-256:

`5e030c7060d67b9cef416f3e479df9e9393d3597ba2ff73398792ce9aeee855f`

Independent later readback proved attempt 2 and attempt 3 used identical guest source, launcher, and evaluator. Only the static checker changed.

## Controlling run

Run:

`20260830T054900Z_d64_rb02_resource_binding_03`

QEMU:

- PID: `4996`
- started: `2026-08-30T05:39:57.327209+00:00`
- ended: `2026-08-30T05:39:57.533541+00:00`
- status: `COMPLETED`
- exit: `33`
- wall time: `206.314 ms` as harness data only

Evaluator exit: `0`.
Static/source checker exit: `0`.
Independent closure audit: PASS.

## Exact guest trace

```text
S1_8K_OK
ACT_CAP=40
BIND_PER_ACT=14
RES_CAP=40
CELL_COUNT=0500
SHARE_COUNT=0500
SHARE_FULL=F
SHARE_COUNT_POST=0500
SHARE_LAST=W
SHARE_VAL=7E
A_FULL=F
RES_AFTER_A=0014
GLOBAL_COUNT=0040
GLOBAL_FULL=F
D_BIND5=00
R0_LIVE2=0002
DETACH_A=W
R0_AFTER_A=0001
B_READ=W
B_VAL=80
DETACH_B=W
R0_AFTER_B=0000
R0_ID_AFTER_B=00
REUSE_NEW=W
REUSE_BIND=05
REUSE_RES=00
REUSE_RGEN=02
A_REBIND=W
A_BGEN=02
R0_LIVE=0002
OLD_BIND=R
NEW_BIND=W
NEW_BIND_VAL=EE
BAD_BIND=W
BAD_BIND_VAL=EE
OLD_RES=R
NEW_RES=W
NEW_RES_VAL=EE
BAD_RES=W
BAD_RES_VAL=EE
DONE
```

## Qualified consequence

### Maximum sharing / corrected live-count width

All 64 activities were admitted through one generic activity-acquire path. One resource was created at identity `0x51`, value `0x7E`. The remaining 1,279 binding cells were attached to that same current resource through the generic bind-existing path.

The observed 16-bit live count reached exactly:

`0x0500 = 1280`

A further binding attempt from the already-full final activity returned `F`, and the live count remained `0x0500`. The representative last binding still read `W / 0x7E`.

This proves that the 16-bit live-count correction is load-bearing rather than dead state. The prior one-byte field would have been insufficient for the declared D64 binding population.

### Separate per-activity and global exhaustion

Under an independent reset:

- activity A filled its 20-cell row;
- A's 21st new-resource bind returned `F` while only 20 global resources were occupied;
- the global table was then filled to exactly 64 resources using B/C/D;
- D still had a free binding cell when the next new-resource attempt returned `F` because the global resource table was full;
- D binding index 5 remained empty.

The two exhaustion surfaces therefore remain separate and explicitly non-mutating for the tested protected state.

### Shared lifetime

Resource slot 0 had two bindings and observed live count `0x0002`.

After A detached:

- detach returned `W`;
- live count became `0x0001`;
- B still read the resource successfully with value `0x80`.

After B detached:

- detach returned `W`;
- live count became `0x0000`;
- resource identity was cleared;
- resource generation was preserved for later reuse currentness.

This is the D64-scale descendant of the earlier bounded shared-backing lifetime distinction; it does not create a garbage collector or ownership manager.

### Binding-cell reuse currentness

After resource-slot reuse, A binding index 0 was reused and binding generation advanced from 1 to 2.

- old binding handle generation 1 returned `R`;
- fresh binding handle generation 2 returned `W / 0xEE`;
- the intentionally bad binding-index-only control ignored binding generation and returned `W / 0xEE`, exposing silent retargeting.

### Direct resource-slot reuse currentness

Resource slot 0 was reused and resource generation advanced from 1 to 2.

- old direct resource handle generation 1 returned `R`;
- fresh generation 2 returned `W / 0xEE`;
- the intentionally bad slot-only control ignored generation/epoch and returned `W / 0xEE`.

The result therefore preserves the repeated project distinction that bare index/location is not currentness.

## Representation and Pareto readback

Configured capacities:

- activity capacity: `64`
- bindings per activity: `20`
- total binding cells: `1,280`
- global resource capacity: `64`
- resource live-count width: `16` bits
- binding generation width in this discriminator: `8` bits
- resource generation width in this discriminator: `8` bits

Core relation-state subtotal from the corrected design:

- 64 x 11 activity bytes = `704`
- binding resource matrix = `1,280`
- binding-generation matrix = `1,280`
- resource identity/generation/value arrays = `192`
- 64 x 16-bit resource live counts = `128`
- resource epoch = `1`

Core subtotal: `3,585` bytes.

Controlling built readback:

- named runtime state: `3,658` bytes
- observation/scratch above the core subtotal: `73` bytes
- stage-2 raw/linked payload: `6,432` bytes
- qualified stage-2 extent: `8,192` bytes
- remaining envelope: `1,760` bytes
- maximum binding-row scan: `20`
- maximum resource scan: `64`
- maximum observed live count: `1,280`

The larger evidence envelope was therefore actually needed for this representation, but the qualified 8 KiB stage 2 still had material headroom.

## Static/source closure

All 21 checker values are literal JSON booleans and all are `true` in the controlling run.

The checks cover:

- exact named capacities;
- eleven 64-entry activity arrays;
- two 1,280-entry binding arrays;
- three 64-byte resource arrays plus the 128-byte 16-bit live-count array;
- one generic activity-acquire path;
- 20-cell row calculation;
- row/global capacity checks before mutation;
- fail-closed binding/resource generation at 255;
- resource initialization before binding publication;
- direct-resource validation before bind-existing mutation;
- 16-bit live-count increment/decrement/read operations;
- detach withdrawal-before-decrement and zero-only reclaim behavior;
- good binding/resource currentness checks before value exposure;
- deliberately weakened negative controls;
- non-mutating full branches;
- full 64 x 20 maximum-sharing path;
- input snapshot/receipt source closure;
- host nonmutation/nonsynthesis boundary;
- strict boolean checker output.

## Provenance closure

Controlling input-manifest SHA-256:

`be2d19842736a8af2cf381523949fbe53055ed914b16d2cdb5804f507e282d7e`

Controlling receipt SHA-256:

`13f0edd609181213e854938a08f051c5b4548163047e0e978eebdffcae360d97`

Independent audit SHA-256:

`0c1cbc9e75ac391fbac591ef841bf13577768e470f7dac7078e22e7615658fe7`

The independent audit additionally verified:

- all run-local input snapshot bytes and hashes;
- exact preregistration lineage `0d0305ebde56d7a9eb70a3db84b00fcf96b33c17`;
- snapshot time before QEMU execution;
- exact evaluator match;
- all 21 static checks literal true;
- 6,432-byte stage-2 fit;
- 3,658-byte runtime-state readback;
- 128-byte live-count storage and word operations;
- attempt-1 assembly failure before guest execution;
- attempt-1 -> attempt-2 guest change was exactly the two `BH` width fixes;
- attempt-2 runtime/evaluator exact success with exactly the two checker failures named above;
- attempts 2 and 3 used identical guest source, launcher, and evaluator;
- only the checker changed from attempt 2 to attempt 3.

## Key controlling hashes

Sources:

- stage2.S: `44f655331e5aec79ec8dac7c4e7cc514907a103bc7bf55312fd62a6c753f363a`
- stage2.ld: `6865f7f83dd72a4a11247fa1d792405653fbe1e83baed1e80abd3e7f1f517875`
- evaluator: `9135c8e476d096435d87cb25123976ed35295db03479a27ffda3c2055cecdff2`
- static checker: `7df60b8016090459d327a350fa478b24777c0bed60c48d0d9cb4227520bcc6dc`
- launcher: `3b7e096dfbdb63d6ed1b2505d1e6c8193d20562934f9b220f89c909072312b84`

Artifacts:

- stage1.bin: `feecbbfdea750fc26f401c0e8eeeabcdd70953036bd60e287368e987ac1ed97d`
- stage2.raw.bin: `501773e4afe2d12221f6d6ce8cb89ea73739c40ba389f226be58e10e6a8e3760`
- stage2.padded.bin: `4deac5202c3bf50d9863a276d013029f5a0a277b5b63210dc3d3072b54e391ef`
- disk.img: `67aa0a09afbced714e9aacb3895a210ab8452ea5b6a9d613cfcdfe182151f9ef`
- debug trace: `c11c392ec2c82ae8cab934697afc129b5610fe78346cd1a2c4468e5f582d4cfe`
- evaluation: `eb42163a2ba9e68f60735bbe70248db396f1de25eb3cd108811e997f2d8d4645`
- static closure: `0469a8de6b90cee97fc9ca59852a7739b5ad72a4c8e582dcbc4d70a846e77c06`

## What RB02 earns

RB02 resolves the immediate D64 **resource-binding scale** question at bounded scope:

- the relation representation supports 20 binding cells per activity;
- all 1,280 binding cells can simultaneously target one current resource;
- the corrected 16-bit live count represents that exact maximum;
- 64 global resource slots can be occupied separately;
- per-row and global exhaustion remain distinct;
- tested shared lifetime is preserved;
- binding-cell and resource-slot stale handles reject after reuse;
- weakened index/slot-only controls retarget exactly as predicted.

No historical File/descriptor manager was required for this workload.

## Open seams after RB02

RB02 deliberately does not solve:

1. **resource namespace renewal/rekey** after finite resource-generation exhaustion;
2. **activity rekey composed with nonempty binding rows** — adopted RK01 did not include the new binding matrix;
3. **resource/binding persistence** across restart;
4. **interruptible/SMP resource-binding mutation**;
5. arbitrary resource semantics beyond the tested identity/value/lifetime relation;
6. dynamic/unbounded capacity.

The first two are now the most direct descendants of the earned representation and should be reconciled before any higher architecture posture is considered.

## Authority ceiling / nonclaims

RB02 does not establish:

- historical `File`, descriptor, inode, or service architecture;
- POSIX/DOS filesystem semantics;
- arbitrary resource types;
- dynamic allocation;
- unlimited binding/resource capacity;
- resource namespace rekey;
- activity rekey with live bindings;
- general capability safety;
- crash durability;
- SMP/NMI/DMA correctness;
- native post-takeover storage transport;
- physical-hardware behavior;
- final/canonical/production HOSTILE-OS architecture;
- any R3.1/R6 authority change.

## Disposition

`D64_RB02_CLOSED_PASS / 64x20_BINDING_MATRIX_EARNED / 1280_MAX_SHARE_LIVECOUNT_0x0500_EARNED / 64_GLOBAL_RESOURCES_EARNED / ROW_AND_GLOBAL_EXHAUSTION_SEPARATED / SHARED_LIFETIME_EARNED / STALE_BINDING_AND_RESOURCE_CURRENTNESS_EARNED / NO_FILE_MANAGER_PROMOTION`
