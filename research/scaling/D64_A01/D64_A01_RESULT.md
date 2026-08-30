# D64 / A01 — generic activity-capacity scaling result

**Disposition:** PASS CLOSED / BOUNDED SCALING SUCCESS
**Parent profile:** D64 donor-scale reference profile
**Architecture promotion:** NONE
**R3.1/R6 authority change:** NONE

## Lineage

D64 target profile commit:

`bb33e65cf9c88f79b84bc34021eb585ccef33c29`

A01 preregistration commit:

`eca4069643d81a5415d677c494c4b5ef8c305c3e`

The preregistration was sealed before A01 probe source existed.

## Controlling run

Run:

`20260830T044700Z_d64_a01_capacity_01`

QEMU:

- PID `7532`
- status `COMPLETED`
- exit `33`
- wall time `639.163 ms` as harness data only

Evaluator exit: `0`.
Static/source checker exit: `0`.

The run obeyed the post-I001 input-snapshot protocol from its first attempt. The run directory contains a pre-build `inputs/` tree and `inputs_manifest.json` binding the exact preregistration, target profile, stage-1 source/linker, stage-2 source/linker, launcher, evaluator, and static checker that were built or used.

## Exact raw trace

```text
S1_OK
CAP=40
FILL_COUNT=40
FIRST_ID=01
FIRST_GEN=01
LAST_ID=40
LAST_GEN=01
FULL=F
POST_FULL_FIRST=01
POST_FULL_LAST=40
RELEASE=W
REUSE=W
REUSE_SLOT=1F
REUSE_ID=5A
REUSE_GEN=02
STALE=R
FRESH=W
FRESH_ID=5A
DONE
```

Hex `40` = 64 decimal. Hex `1F` = slot index 31.

## Qualified consequence

For this bounded freestanding scaling workload:

1. one generic checked-acquire routine filled all 64 configured activity slots;
2. slot 0 ended at identity `01`, generation `01`;
3. slot 63 ended at identity `40`, generation `01`;
4. the 65th acquire returned explicit `F` after scanning the full configured table;
5. the full result preserved both first and last occupied slots;
6. one generic indexed release cleared slot 31 occupancy;
7. the same generic acquire path selected that first free slot for identity `5A` and advanced its generation to `02`;
8. stale handle `(31,1,epoch1)` returned `R`;
9. fresh handle `(31,2,epoch1)` returned `W` and exposed identity `5A`.

This closes the immediate D64 activity-capacity gap at bounded scope: I001's activity state/lifecycle semantics are not inherently tied to two slots. They can be embodied as one configured 64-slot table with generic checked acquire/release/currentness behavior.

## Pareto / size observations

- activity capacity: `64`
- activity field species: `11`
- named A01 runtime state: `719` bytes
- stage-2 raw/linked payload: `1,528` bytes
- fixed stage-2 extent: `4,096` bytes
- generation width in this discriminator: `8` bits
- epoch width in this discriminator: `8` bits

The D64 plan's pre-build static projection estimated 704 activity-array bytes plus fixed state. The built A01 runtime state is 719 bytes because A01's fixed observation/status state differs from I001's fixed state.

The result is stronger than the static projection: a 64-slot generic capacity witness fits comfortably inside the already-qualified 4 KiB stage-2 envelope.

It does not prove that every future whole-workload D64 integration will fit 4 KiB.

## Input snapshot / provenance closure

Input manifest SHA-256:

`bb2ebdaec97d6a8111867608801282c6a8f38726f7ca960d076fac95b8f1f075`

Receipt SHA-256:

`879789754f53bf62b41e460b7eb3cc9afdf4e9155c610def3a9378d95b91e721`

Independent closure audit SHA-256:

`2af74ea61432d108e2a38b7541501e42a08ee6cc1ca102cde5e6be6b01b41590`

The independent audit verified:

- receipt manifest hash matches the exact run-local manifest;
- every run-local input snapshot matches its manifest byte count and SHA-256;
- every receipt source hash equals the corresponding manifest snapshot hash;
- preregistration lineage is exactly `eca4069643d81a5415d677c494c4b5ef8c305c3e`;
- stage 2 was built from the run-local snapshot;
- QEMU/evaluator/static closure all passed;
- stage 2 stayed inside 4 KiB;
- runtime state readback was 719 bytes;
- manifest snapshot time precedes guest execution.

This is the first real post-protocol HOSTILE-OS experiment to exercise the run-input snapshot rule end to end.

## Assurance scar

The built-in static checker serialized `input_manifest_snapshots_verify` as the controlling preregistration commit string rather than literal JSON `true` because the Python expression returned the final truthy operand.

This is a checker-output typing scar, not a failed predicate. The checker still passed only because the value was truthy, and the separate independent audit recomputed the snapshot/receipt closure directly and passed.

The scar is preserved rather than rewritten out of the run.

## Key hashes

- stage-2 source: `57bee427faf9330059a6e8e181b01721f5c37cf335a353ff2985db306c2f7936`
- stage-2 raw: `db0eb49d37df648d6a85a50b0c0bff10034146ef607366c58041a4413863b8de`
- debug trace: `f5ee4bb8868a2149dbdddebc5c5339babb868280c0be6d8f9624fe52e48fa0d4`
- evaluation: `5b75c7a160674d38db6a468f3323e2453bb064dba34274b5e2e90a942cd5d917`
- static closure: `ef59f249a0cf7ae23dbb24c9acfca5e4e40fe0c792f50c77c6e34764317d44a1`

## What remains open

A01 does not close the other D64 pressure surfaces.

### Resource binding scale remains open

I001 has one shared-backing record. D64 pressure includes up to 20 binding references from one activity and a global live-resource pressure of 64. No representation for that scale has been earned yet.

### Long-lifetime namespace renewal remains open

A01 deliberately keeps 8-bit generation/epoch because it uses only generations 1 and 2. D64 declares no credible fixed maximum reuse count, so continued operation requires an explicit rekey/new-namespace mechanism or another currentness design before aliasing wrap.

### Whole D64 workload remains unintegrated

A01 is an activity-table scaling discriminator, not a 64-activity rerun of I001's whole two-boot integration workload.

## Authority ceiling / nonclaims

A01 does not establish:

- arbitrary/dynamic capacity;
- Linux task/process architecture;
- scheduling policy;
- donor-equivalent workload support;
- resource-binding scale;
- long-lifetime generation sizing;
- namespace rekey behavior;
- SMP/NMI/DMA correctness;
- physical hardware behavior;
- final architecture;
- R3.1 replacement readiness;
- R6 demotion.

## Disposition

`D64_A01_CLOSED_PASS / CONFIGURED_64_ACTIVITY_TABLE_EARNED / HARDCODED_TWO_SLOT_GAP_RESOLVED_AT_BOUNDED_SCOPE / INPUT_SNAPSHOT_PROTOCOL_EXERCISED / RESOURCE_SCALE_AND_REKEY_REMAIN_OPEN`
