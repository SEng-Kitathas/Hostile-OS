# C003 / P08 preregistration — selection remains separate from execution application

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P08 of 20
**Earned by:** C003/P07 bounded failure-locality/later-progress success
**Architecture promotion:** FORBIDDEN

## Why P08 exists

P07 established bounded distinct later progress after a local failure. C002's surviving relation result is stronger in another direction: **selection can remain separate from execution application**, and bounded multi-eligible choice may carry separate policy state.

P02 already showed identity-bound policy history can survive membership mutation. P08 now pressures whether the act of choosing an eligible identity can remain distinct from mutating that activity's continuation/progress state.

## P08 question

Can a bounded selector choose activity `B` from two eligible identities while leaving both activity progress states untouched until a separate application relation runs; and does a deliberately conflated select-and-apply control expose an observable mutation during selection?

## Fixture

The fixture supplies facts only:

- eligible identities: `A`, `B`;
- initial policy-history identity: `A`;
- initial progress byte for A: ASCII `0`;
- initial progress byte for B: ASCII `0`.

The fixture SHALL NOT:
- choose the next identity;
- mutate policy history;
- mutate A/B progress;
- apply a progress step.

## Separated path

Explicit guest state:
- `policy_history` identity byte;
- `selected_identity` byte;
- `progress_A` byte;
- `progress_B` byte.

`select_next` relation:
1. reads eligibility + current policy history;
2. with `[A,B]` and history `A`, returns/selects `B`;
3. MAY update separate `policy_history` to `B`;
4. SHALL NOT mutate `progress_A` or `progress_B`.

Raw observation immediately after selection must therefore be:

```text
SEP_SELECTED=B
SEP_SELECT_A=0
SEP_SELECT_B=0
```

`apply_selected` relation then:
1. consumes `selected_identity`;
2. applies one bounded progress step only to selected activity B;
3. leaves A unchanged.

Raw post-application observation:

```text
SEP_APPLY_A=0
SEP_APPLY_B=1
```

## Deliberately conflated negative control

Reset the same fixture state.

`select_and_apply_bad`:
1. chooses the same identity `B`;
2. updates policy history;
3. **also mutates B progress during selection** from `0 -> 1`.

Raw observation immediately after that conflated selection:

```text
BAD_SELECTED=B
BAD_SELECT_A=0
BAD_SELECT_B=1
```

The bad path is a negative control only. It is not a Scheduler primitive.

## Exact raw guest observation contract

```text
SEP_SELECTED=B
SEP_SELECT_A=0
SEP_SELECT_B=0
SEP_APPLY_A=0
SEP_APPLY_B=1
BAD_SELECTED=B
BAD_SELECT_A=0
BAD_SELECT_B=1
DONE
```

The guest SHALL NOT emit self-graded PASS for this discriminator.

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

P08 succeeds only if the exact raw observation is:

```text
SEP_SELECTED=B
SEP_SELECT_A=0
SEP_SELECT_B=0
SEP_APPLY_A=0
SEP_APPLY_B=1
BAD_SELECTED=B
BAD_SELECT_A=0
BAD_SELECT_B=1
DONE
```

with deterministic QEMU success exit and independent evaluator pass.

A completed alternate matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this bounded two-eligible selection/application distinction can be represented with explicit policy/selection/progress state without a Scheduler object or host-language dispatch/runtime machinery.

It would not establish:
- general scheduling;
- fairness beyond this fixture;
- preemption;
- arbitrary activity count;
- real continuation switching;
- multicore execution;
- architecture promotion.

## Stop rule

Reconcile P08 before deriving P09. P09-P20 remain unwritten until P08 consequence earns the next discriminator.
