# C003 / P07 preregistration — failure locality / distinct later progress

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P07 of 20
**Earned by:** C003/P06 bounded missing-operation success
**Architecture promotion:** FORBIDDEN

## Why P07 exists

P06 proved only that an unknown operation can return explicit bounded missing status without mutating one protected state. It did not prove that the failure remains local enough for a distinct later progress-capable activity to continue.

C002's surviving claim is stronger and still unembodied at machine-code level: bounded local failure can preserve coherent later progress without a global error-manager object.

## P07 question

Can one activity receive a bounded local missing-operation result while a distinct later activity still executes a present operation and advances progress state, and does a deliberately bad global-failure-latch control block that same later progress after the same initial miss?

## Fixture responsibility

The fixture supplies facts only:

- missing requester identity: ASCII `A`;
- later requester identity: ASCII `B`;
- missing operation code: `0x7f`;
- present operation code: `0x01`;
- initial protected progress state: ASCII `A`.

The fixture SHALL NOT:

- decide operation presence;
- synthesize success/failure/blocked status;
- mutate protected state;
- set/clear the global control latch;
- execute the later present operation.

## Mechanism

One bounded operation relation:

- present operation `0x01`: mutate protected state `A -> B`, return ASCII status `O`;
- any other operation: leave protected state unchanged, return ASCII status `M`.

Two trials use the same operation relation.

### Trial L — local failure

1. initialize progress state `A`;
2. activity A requests missing `0x7f`;
3. relation returns `M`; no global latch is changed;
4. distinct activity B requests present `0x01`;
5. relation returns `O`; state becomes `B`.

### Trial G — deliberately global-poison control

1. reset progress state `A`; reset `global_failed=0`;
2. activity A requests missing `0x7f` through the same relation and receives `M`;
3. control deliberately sets `global_failed=1` because the prior request returned `M`;
4. distinct activity B requests present `0x01`;
5. control checks `global_failed` before relation application, returns blocked ASCII `X`, and leaves state `A`.

The one-byte global latch is a deliberately bad negative control. It SHALL NOT be interpreted as an earned ErrorManager primitive.

## Raw guest observation contract

The guest emits raw status/state only:

```text
LOCAL_MISS=M
LOCAL_LATER=O
LOCAL_STATE=B
GLOBAL_MISS=M
GLOBAL_LATER=X
GLOBAL_STATE=A
DONE
```

The guest SHALL NOT emit self-graded `PASS` for the discriminator.

Activity identities may exist in fixture data for causal traceability but are not required in the debug lines if the execution order and source establish which request belongs to which identity.

## Independent evaluator

The evaluator SHALL consume the debug artifact and require exact line equality.

It must establish:

- both trials produce the same missing result `M` for the initial missing request;
- local failure permits the later present operation to return `O` and state to become `B`;
- global-poison control blocks the later present operation with `X` and state remains `A`;
- no self-graded guest PASS substitutes for evaluation.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:

- stable run directory;
- exact source/tool hashes;
- one 512-byte boot image with `55aa` signature and hash;
- exact QEMU argv, PID, start, end, exit;
- bounded launcher timeout;
- debugcon artifact/hash;
- build/QEMU/evaluator stdout+stderr;
- evaluator result/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P07 succeeds for this bounded discriminator only if the exact raw observation is:

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

A completed guest producing another raw matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this bounded fixed-capacity failure-locality/later-progress consequence does not require Python exception propagation, a host dispatch dictionary, a global error-manager object, or scheduler machinery.

It would not establish:

- general fault containment;
- isolation/security boundaries;
- process semantics;
- scheduler architecture;
- general syscall/API namespace;
- dynamic linking;
- capability architecture;
- architecture promotion.

## Stop rule

Reconcile P07 before deriving P08. P08-P20 remain unwritten until P07 consequence earns the next discriminator.
