# C003 / P09 — parent-child return from lineage + generic wait/wake

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P09 of 20
**Architecture promotion:** NONE
**P10 earned:** YES

## Question

Can a child completion wake and resume its waiting parent using only explicit lineage, current wait target, current completion state, a generic wait-match transition, and a separate parent application step — with no special parent-return operation or return-binding primitive?

## Controlling preregistration

`C003_P09_PREREGISTRATION.md` was sealed at Git commit `e0ef58056638c55cdafc0e532e9dbf23b217a012` before execution.

## Execution history

### Attempt 01 — `20260829T214530Z_p09_parent_child_return_01`

**Disposition:** BUILD FAILURE / NO SCIENTIFIC CONSEQUENCE

The mechanism and fixture assembled, but the linker rejected a payload of `0x242` bytes (578 bytes), exceeding the one-sector ceiling and overlapping the `55aa` signature location.

Exact linker scar:
- `P09 probe exceeds one boot sector`;
- payload virtual/load range `[0x7C00, 0x7E41]` overlapped signature `[0x7DFE, 0x7DFF]`.

Object-section readback:
- mechanism `.text`: 552 bytes;
- mechanism `.data`: 19 bytes;
- fixture: 7 bytes.

No QEMU launch or evaluator consequence occurred. The representation was compressed by removing temporary observation copies and sharing a label/value print path; the preregistered raw observation contract did not change.

### Attempt 02 — controlling scientific run

Run: `20260829T214600Z_p09_parent_child_return_02`

QEMU:
- PID: `31708`
- started: `2026-08-29T21:45:42.694168+00:00`
- ended: `2026-08-29T21:45:42.892496+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Exact raw observation

```text
GOOD_COMPLETE=S
GOOD_WAKE=1
GOOD_PRE_PROGRESS=0
GOOD_PARENT_STATUS=S
GOOD_POST_PROGRESS=1
BAD_COMPLETE=S
BAD_WAKE=0
BAD_POST_PROGRESS=0
DONE
```

Evaluator version: `C003-P09-lineage-wait-wake-return-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `ae61fba994b633473d5d7fabb58f9b96fcb303dc8162e8401730d251452cf914`
- fixture: `0a33b37026e94d4c274ddbea870dbd1e10bedd4bf5d4d3eddb1d9ed93b7d3a58`
- linker: `f2ef1f3c108f529769e3145647386ee55a23619498f3128ec1d367c547ea39b6`
- evaluator: `d0f6b25d328e0b30f22bf9be6cd35f4d81e17516554247b7bf42a39a8f0547b6`
- launcher: `bb105bf617e7f86a86e01bbdb2d5e4a432c07cf7bbdd5bdb52a4f4137e12ef1e`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `1ad571e5daab6e439d72b6aed3e20863e334456a4f53749478c2f7727f98caf8`
- debugcon SHA-256: `e96fe75904ee533f69bfbf1fe99bccbdac94d1e899dc290acd8b75154b11cdd1`
- evaluation SHA-256: `3976587c2bdfa01272cb7301fd41a81df90e6d856d8f57508e632e2ee53917aa`
- receipt SHA-256: `8ad7491ffcd2e5b6d9e1fd71b2406bdd7ccb80c8c764be6cc6e5053ceabfdb2b`
- evaluator stdout SHA-256: `aba7d873916dc4f997dd487da7b36bb896563488c56368bb2c008181d6a88972`
- all build/QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating inspection matched the receipt.

Static source inspection found only the three load-bearing relations:
- `record_completion`;
- `generic_wait_match`;
- `apply_parent`.

No `return_to_parent` or return-binding mechanism exists in the source.

## Qualified consequence

For this bounded one-parent/one-child fixture:

- terminal child completion `C/S` existed in both good and bad paths;
- matching parent wait target `C` plus lineage `C -> P` and current completion caused the generic wait matcher to wake parent P;
- parent progress was still `0` immediately after wake, proving the wake relation did not itself apply parent progress;
- the separate parent application copied terminal status `S` and advanced parent progress `0 -> 1`;
- with the same completion and wait target but lineage `C -> Q`, the parent did not wake and progress remained `0`;
- child terminal completion bytes alone therefore did not constitute parent return in the tested slice;
- a special return operation, return-binding object, Process, and Scheduler primitive were not required by this bounded consequence.

This does not establish arbitrary process trees, general join semantics, orphan/reparent behavior, or scheduler architecture.

## Whole-workload coverage checkpoint

By P09, every explicit whole-workload obligation listed in the C003 campaign preregistration has received at least one bounded freestanding pressure slice: boot/init, finite/multiple activity, block/wait/wake, child/parent return, persistence across restart, missing-operation failure, asynchronous consequence, and idle/no-useful-work behavior.

This is coverage, not architecture promotion. The remaining campaign frontier is hidden-host subsidy and irreducible-state pressure.

## P10 discriminator earned by P09

The highest-value hidden-host suspect still not directly embodied is **interpreter stack/continuation**.

P09's parent application is invoked linearly by the test program after wake. That does not prove a blocked activity can resume at the correct logical continuation without relying on implicit program-control position or an interpreter call stack.

P10 SHALL pressure explicit continuation binding in the smallest bounded form:

- one activity identity `A` has progress byte `0`;
- before blocking, the mechanism explicitly binds a continuation identity `2` to A and records waiting state;
- a generic wake changes only wait/wake eligibility state and SHALL NOT choose or execute the continuation;
- a separate resume dispatcher consumes A's explicit continuation identity and applies the continuation-2 step, producing progress `2`;
- an identity-only negative control uses the same activity identity and wake state but deliberately discards/ignores the continuation binding and resumes fixed continuation 1, producing progress `1`;
- the evaluator must distinguish correct bound resume (`2`) from identity-only/fixed resume (`1`).

The fixture may supply activity identity and initial progress facts only. The mechanism must create the continuation binding before block. No Python interpreter stack, coroutine runtime, Process, Scheduler, or general context-switch object may be introduced.

P10 success would establish only a bounded explicit continuation-token substitute for implicit interpreter control state; it would not establish register-stack context switching, preemption, arbitrary call stacks, or scheduler architecture.

P11-P20 remain unwritten.
