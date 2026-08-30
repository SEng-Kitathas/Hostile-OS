# C003 / P06 preregistration supersession — local failure must preserve later progress

**Date:** 2026-08-29
**Status:** ACTIVE PREREGISTRATION CORRECTION / NOT EXECUTED
**Supersedes discriminator details in:** `C003_P06_PREREGISTRATION.md` as committed at `463021d9b385f4a97f7bd314dd54ecc08285ea56`
**Scientific pass:** C003/P06 of 20
**Parent result:** C003/P05 closed at `ae829292f384f89904f0ca3eef63ba122072ebc0`
**Architecture promotion:** FORBIDDEN

## Why supersession is required

The sealed P05 result earned a stronger P06 discriminator than the first P06 preregistration preserved.

P05 explicitly required P06 to test all of the following:

1. one activity requests an absent operation;
2. the missing request returns a bounded **local** failure rather than setting a global failure latch;
3. a **distinct later progress-capable activity** requests a present operation and still completes coherently;
4. an intentionally global-failure control demonstrates the opposite consequence by blocking that later progress after the same missing request.

Commit `463021d` retained the missing-operation/local-status piece but reordered the known operation before the miss and omitted both the later-progress consequence and the global-failure negative control. That weakens the causal discriminator earned by P05.

No P06 scientific execution occurred before this correction. The incomplete probe draft was preserved under `rejected_branches/P06_INCOMPLETE_PREREG_PROBE_DRAFT_2026-08-29/` and SHALL NOT be used as P06 evidence.

## Corrected P06 question

Can a missing operation produce a bounded local failure for one activity while leaving a distinct later progress-capable activity able to execute a present operation, using only fixed explicit guest state and status bytes; and does an otherwise comparable global-failure-latch control block that same later progress?

## Fixture responsibility

The fixture supplies facts only:

- activity identity for the missing requester: ASCII `A`;
- activity identity for the later requester: ASCII `B`;
- missing operation code: `0x7f`;
- present operation code: `0x01`;
- initial protected progress state: ASCII `A`.

The fixture SHALL NOT:

- decide whether an operation is present;
- synthesize result status;
- mutate protected progress state;
- set or clear any failure latch;
- execute the later present operation.

## Mechanism

The mechanism SHALL contain one bounded operation relation:

- operation code `0x01` is present and changes protected progress state `A -> B`, returning status ASCII `O`;
- any other operation code is absent and returns status ASCII `M` without changing protected progress state.

Two bounded trials use the same operation relation.

### Local-failure trial

1. initialize protected state to `A`;
2. activity `A` requests missing operation `0x7f`;
3. mechanism returns `M` locally and does not set a global failure latch;
4. activity `B` then requests present operation `0x01`;
5. mechanism executes it, returns `O`, and protected state becomes `B`.

### Global-failure control

1. reset protected state to `A` and global-failure control byte to zero;
2. activity `A` requests missing operation `0x7f`;
3. the control records the same local missing result `M` **and deliberately sets** a one-byte global-failure latch;
4. activity `B` then requests present operation `0x01`;
5. control checks the global latch first, returns blocked status ASCII `X`, and leaves protected state at `A`.

The global latch is an intentionally bad bounded control, not a promoted ErrorManager primitive.

## Raw guest observation contract

The guest SHALL emit raw facts only:

```text
LOCAL_MISS=M
LOCAL_LATER=O
LOCAL_STATE=B
GLOBAL_MISS=M
GLOBAL_LATER=X
GLOBAL_STATE=A
DONE
```

The guest SHALL NOT emit self-graded `PASS` for these causal outcomes.

## Independent evaluator

The evaluator SHALL decide whether:

- both trials observed the same missing result `M` for activity A;
- the local-failure trial allowed activity B's later present operation to return `O` and change state to `B`;
- the global-latch control blocked the same later present operation with `X` and left state at `A`;
- the output exactly matches the preregistered matrix.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:

- stable run directory;
- exact source/tool hashes;
- 512-byte image/signature/hash;
- exact QEMU argv/PID/start/end/exit;
- bounded launcher timeout;
- debugcon artifact/hash;
- build/QEMU/evaluator stdout and stderr;
- evaluator result/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P06 succeeds only if the exact raw observation is:

```text
LOCAL_MISS=M
LOCAL_LATER=O
LOCAL_STATE=B
GLOBAL_MISS=M
GLOBAL_LATER=X
GLOBAL_STATE=A
DONE
```

with deterministic QEMU success exit and independent evaluator pass.

A completed guest with another raw state/status matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this bounded missing-operation/later-progress consequence can be represented without Python exceptions, host-language dispatch containers, string dispatch, or a global error-manager object.

It would not establish:

- a general syscall or API namespace;
- a capability architecture;
- a service architecture;
- dynamic linking;
- unbounded dispatch;
- general fault containment;
- scheduler architecture;
- architecture promotion.

## Stop rule

Reconcile P06 before deriving P07. P07-P20 remain unwritten until P06 consequence earns the next discriminator.
