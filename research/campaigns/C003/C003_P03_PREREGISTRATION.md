# C003 / P03 preregistration — intermediate mutation coherence / explicit currentness guard

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P03 of 20
**Earned by:** C003/P02 bounded success
**Architecture promotion:** FORBIDDEN

## Why P03 exists

P02 established that identity-bound policy history can survive compacting membership mutation in fixed-capacity state and that stale raw numeric/index history can drift. P02 observed only coherent state before and after mutation.

C002's surviving result says lifecycle and policy can remain semantically separate while still requiring one coherent/atomic mutation boundary. The next earned pressure is therefore an observer landing between membership mutation and history repair.

## P03 question

Can a minimal explicit mutation-currentness guard prevent an observer from accepting incoherent intermediate membership/history state during bounded lifecycle mutation, while an otherwise identical unguarded control exposes that stale state?

## Fixture

Initial state:
- members `[A,B,C]`;
- policy history identity `B`;
- mutation removes `B`;
- observation cut occurs after membership compaction and before policy-history repair.

Two mechanism copies receive identical fixture facts:

1. **unguarded control**;
2. **guarded mechanism** with one explicit `mutation_active` byte.

The fixture SHALL NOT repair state, choose an observation result, or set the guard dynamically.

## Mechanism sequence

### Unguarded control

1. compact-remove `B`, leaving `[A,C]`;
2. observe at the preregistered cut while history still says `B`;
3. repair history by clearing it when its identity is no longer a member;
4. observe again post-repair.

Expected semantic statuses:
- cut observation: `STALE`;
- post-repair observation: `COHERENT`.

### Guarded path

1. set `mutation_active = 1`;
2. compact-remove `B`, leaving `[A,C]`;
3. observe at the identical cut;
4. repair history by clearing missing identity `B`;
5. set `mutation_active = 0`;
6. observe post-commit.

Observer rule:
- if `mutation_active == 1`, return `RETRY` without accepting membership/history as current;
- otherwise, return `COHERENT` iff history is empty or names a current member;
- otherwise return `STALE`.

## Guest output contract

The guest SHALL emit semantic status codes only; the external evaluator interprets the exact expected matrix:

```text
RAW_CUT=S
RAW_POST=C
GUARD_CUT=R
GUARD_POST=C
DONE
```

where:
- `S` = stale/incoherent accepted snapshot;
- `R` = retry/reject intermediate state;
- `C` = coherent accepted snapshot.

## Representation constraints

- fixed capacity: three member slots per path;
- byte-sized identities and one-byte mutation guard;
- no heap/dynamic allocation;
- no Python runtime/container/object machinery in guest;
- no lock manager, scheduler, process, service, or transaction subsystem primitive;
- no claim of multicore hardware atomicity;
- observer is a bounded discriminator at an explicit cut, not a model of all possible interleavings.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate. Require stable run directory, exact source/tool hashes, build logs/exits, 512-byte/signature/hash evidence, deterministic QEMU exit, debug artifact, separate evaluator artifact, durable receipt, and post-run non-mutating inspection.

Timeout/ambiguous process state = UNKNOWN.

## Success / failure criterion

P03 succeeds for this bounded discriminator only if the exact guest observation matrix is:

```text
RAW_CUT=S
RAW_POST=C
GUARD_CUT=R
GUARD_POST=C
DONE
```

and QEMU/evaluator complete under the established evidence contract.

A failure is useful if it exposes additional state needed to distinguish current/coherent observation.

## Authority ceiling

Success would establish only that one explicit mutation-currentness byte can prevent acceptance of the tested intermediate state in this single-core bounded model. It would not establish lock-freedom, linearizability in general, real interrupt masking semantics, SMP/multicore atomicity, memory ordering, or architecture promotion.

## Stop rule

Reconcile P03 before deriving P04. P04-P20 remain unwritten until P03 consequence earns the next discriminator.
