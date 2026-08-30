# C003 / P10 preregistration — explicit continuation binding versus identity-only resume

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P10 of 20
**Earned by:** C003/P09 bounded parent-child return success
**Architecture promotion:** FORBIDDEN

## Why P10 exists

By P09 the explicit whole-workload obligations inherited from C002 have each received bounded freestanding pressure. The remaining campaign frontier is hidden-host subsidy.

One high-value suspect remains directly unembodied: **interpreter stack/continuation**.

P09 invoked parent application linearly after wake. That does not establish that an activity can block and later resume at the correct logical continuation using explicit state rather than relying on activity identity plus implicit interpreter/program-control position.

## P10 question

Can one bounded activity bind an explicit continuation identity before blocking, be generically woken without executing that continuation, and later resume the correct continuation through a separate dispatcher — while an identity-only fixed-resume control demonstrably resumes the wrong logical step?

## Fixture responsibility

The fixture supplies facts only:
- activity identity: ASCII `A`;
- initial progress: ASCII `0`.

The fixture SHALL NOT:
- choose a continuation;
- bind a continuation;
- wake the activity;
- execute a continuation;
- mutate progress.

## Explicit-bound path

Guest state:
- `activity_identity`;
- `waiting`;
- `woken`;
- `continuation_id`;
- `progress`.

### `arm_wait_step2`

The mechanism itself:
- binds `continuation_id = '2'`;
- sets waiting state;
- does not mutate progress.

This represents the activity's logical resume point as explicit relation state rather than implicit activity identity.

### `wake_activity`

A generic bounded wake transition:
- clears waiting;
- sets woken;
- SHALL NOT inspect/execute continuation state;
- SHALL NOT mutate progress.

### `resume_bound`

A separate dispatcher:
- requires woken state;
- reads `continuation_id`;
- continuation `1` writes progress `1`;
- continuation `2` writes progress `2`;
- any other continuation returns bounded invalid status `X` without progress mutation.

For the bound path, the mechanism-created continuation is `2`, so the correct result is progress `2`.

## Identity-only negative control

Reset the same activity identity `A`, initial progress `0`, and wake state.

The bad control deliberately discards/ignores continuation binding and resumes activity A at a fixed default continuation 1 solely from identity.

It therefore produces progress `1`.

This fixed-resume path is a negative control only. It is not a scheduler or architecture proposal.

## Exact raw guest observation contract

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

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- activity identity is the same A in both paths;
- bound path created continuation 2 before wake;
- generic wake did not alter pre-resume progress (`BOUND_PRE=0`);
- bound dispatcher produced progress 2;
- identity-only control with the same A/wake produced fixed progress 1.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- one 512-byte boot image with `55aa` signature/hash;
- exact QEMU argv/PID/start/end/exit;
- bounded launcher timeout;
- debugcon artifact/hash;
- build/QEMU/evaluator stdout+stderr;
- evaluator result/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P10 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit and independent evaluator pass.

A completed alternate matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that a one-byte explicit activity-continuation identity can replace implicit activity-control position for this bounded block/wake/resume discriminator.

It would not establish:
- arbitrary call-stack preservation;
- register/stack context switching;
- coroutine architecture;
- preemption;
- scheduler architecture;
- arbitrary continuation count;
- exception unwinding;
- architecture promotion.

The boot program may still use ordinary machine `call/ret` internally; those calls are implementation structure, not the blocked activity's continuation binding. The tested distinction is whether the activity's logical resume step is explicit durable-in-RAM relation state rather than inferred from identity alone.

## Stop rule

Reconcile P10 before deriving P11. P11-P20 remain unwritten until P10 consequence earns the next discriminator.
