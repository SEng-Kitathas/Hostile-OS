# C003 / P10 — explicit continuation binding versus identity-only resume

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P10 of 20
**Architecture promotion:** NONE
**P11 earned:** YES

## Question

Can one bounded activity bind an explicit continuation identity before blocking, be generically woken without executing that continuation, and later resume the correct continuation through a separate dispatcher — while an identity-only fixed-resume control demonstrably resumes the wrong logical step?

## Controlling preregistration

`C003_P10_PREREGISTRATION.md` was sealed at Git commit `76181aa3cdbb62b7c5342f726507d0f69cf869a1` before execution.

## Controlling scientific run

Run: `20260829T214920Z_p10_continuation_binding_01`

QEMU:
- PID: `2952`
- started: `2026-08-29T21:49:06.870406+00:00`
- ended: `2026-08-29T21:49:07.072146+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Exact raw observation

```text
BOUND_ID=A
BOUND_CONT=2
BOUND_WAKE=1
BOUND_PRE=0
BOUND_POST=2
BAD_ID=A
BAD_WAKE=1
BAD_POST=1
DONE
```

Evaluator version: `C003-P10-explicit-continuation-v1`
Evaluator result: `passed=true`.

Evaluator checks all passed:
- exact line equality;
- same identity A in both paths;
- explicit continuation 2 created before wake;
- wake left pre-resume progress at 0;
- bound resume selected step 2;
- identity-only fixed resume selected step 1.

## Exact source hashes

- mechanism: `028d4fc6ab3eb027392992645693d69706c6ac0643b8a153d901550ef4502717`
- fixture: `e35046cf41a2eefa71181bae368df00a4fadf9ddbee544fd0eb74012a52f725f`
- linker: `1c124d0b1bb05fea1fc140ad8da7856727ae6cabb578b36ec2540fe5194c9f87`
- evaluator: `4dbf5b1f62d4f1f58ca825f3a5e5867f17ca89f22a57320f45d2b3793b7d1883`
- launcher: `bf2fffe2cf5af9ab59552bdcddadc9e1a2ebaffc9003568bd88f210ceef784d9`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `cdf99dba44759fc07d6e988d5163c5135227d86c3c582d3855118a3687d0f1d7`
- debugcon SHA-256: `98b0384dd3c2a1a4d4dcd70a0d317cd5bbc09b929e3920d61711abac1db466af`
- evaluation SHA-256: `84f1d3ed655ce818962dfca86e44e2f5df31ea145e52c5dafdbba09eccdb8025`
- receipt SHA-256: `2a1f4503f588418cc84773229a3821a1d576035d27db3fabdb1600a363c01abf`
- evaluator stdout SHA-256: `b064f58db225bae6eaf15305046012312645fdcd1e0bbf812b6d207a3d2bc2ee`
- all QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating receipt/hash closure passed for all five source files, seven recorded run artifacts, the exact raw matrix, evaluator pass state, and QEMU `COMPLETED/33` state.

## Static mechanism readback

The fixture supplies only:
- activity identity `A`;
- initial progress `0`.

The mechanism itself performs the tested control behavior:
- `arm_wait_step2` binds `continuation_id='2'` and marks waiting;
- `wake_activity` changes only wait/wake state;
- `resume_bound` reads the explicit continuation and applies step 2;
- the negative control discards the continuation and `resume_identity_only` applies fixed step 1.

The ordinary boot program still uses machine `call/ret` internally. Those calls are implementation structure, not the blocked activity's tested logical continuation binding.

## Qualified consequence

For this bounded one-activity fixture:

- activity identity A was the same in both paths;
- the bound path made logical resume point 2 explicit before block;
- generic wake did not choose or execute that continuation and did not advance progress;
- a separate dispatcher consumed the explicit continuation and advanced progress `0 -> 2`;
- the identity-only control had the same A and successful wake but, after discarding continuation state, resumed fixed step 1 and advanced progress `0 -> 1`;
- identity plus wake state was therefore insufficient to distinguish the intended logical resume point in this discriminator;
- one byte of explicit continuation identity was sufficient for the tested two-continuation case.

This is consistent with the broader donor-neutral rule already under test: identity and continuation are separate responsibilities, and the binding matters more than the historical carrier used by a donor.

## Authority ceiling / nonclaims

P10 does **not** establish:
- arbitrary call-stack preservation;
- stack-pointer or register context switching;
- coroutine architecture;
- preemption;
- scheduler architecture;
- arbitrary continuation count;
- exception unwinding;
- physical-hardware timing behavior;
- architecture promotion.

It establishes only a bounded explicit activity-continuation identity substitute for implicit logical control position in this block/wake/resume slice.

## P11 discriminator earned by P10

P10 removes one interpreter-control subsidy by making the logical continuation explicit. The next pass should continue hidden-host pressure rather than introduce a historical subsystem noun.

The highest-value remaining suspect for the next smallest discriminator is **implicit memory safety / bounds checking around fixed-capacity relation state**.

P11 should ask whether a bounded relation write can reject an out-of-range relation slot while preserving adjacent state, and whether an intentionally unchecked control corrupts adjacent state under the same fixture.

This would test a service Python supplied silently in C002 without introducing allocation, a manager, a process model, or a general memory-protection architecture.

P11 must be preregistered and sealed before execution. P12-P20 remain unwritten.
