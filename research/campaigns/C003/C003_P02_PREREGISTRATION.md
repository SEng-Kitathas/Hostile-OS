# C003 / P02 preregistration — identity-bound policy history under membership mutation

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P02 of 20
**Earned by:** C003/P01 reconciled negative result
**Architecture promotion:** FORBIDDEN

## Why P02 exists

C003/P01 showed that the bounded current-completion distinction can survive in fixed-capacity freestanding state without Python runtime machinery, but exact C002 Python source remained unrecovered and actual host-service reliance stayed UNKNOWN.

The next strongest surviving C002 semantic pressure is:

- raw numeric policy position can drift when membership changes;
- identity-bound policy history survived the tested mutation in C002;
- lifecycle and policy may be semantically separate while still requiring a coherent mutation boundary.

This directly pressures still-UNKNOWN host suspects including container ordering/membership semantics, dynamic allocation, Python object identity, collection mutation behavior, and implicit atomicity.

## P02 question

Can bounded identity-bound policy history preserve the same next-choice consequence across compacting membership mutation using only fixed-capacity explicit state, while a raw numeric/index history control becomes observably wrong?

## Scope

P02 SHALL test one bounded mutation discriminator only.

Fixture state:

- initial ordered eligible membership: `[A, B, C]`;
- last selected identity: `B`;
- raw last-selected numeric index control: `1`;
- mutation: remove unrelated identity `A`, compacting membership to `[B, C]`.

Mechanism responsibilities:

1. load the fixed-capacity fixture into explicit guest state;
2. compute next choice before mutation using:
   - identity-bound history;
   - raw numeric/index history control;
3. apply the membership removal/compaction inside the mechanism, not the fixture/evaluator;
4. compute next choice after mutation with the same two history forms;
5. emit actual selected identities only.

Evaluator responsibilities:

- before mutation, require both forms to select `C`;
- after mutation, require identity-bound history to still select `C`;
- require the stale raw-index control to select `B`, demonstrating numeric-position drift;
- reject missing/extra/malformed observations.

## Why this is discriminating

Before mutation:

- `B` is member index 1 of `[A,B,C]`;
- both identity lookup and raw index 1 advance to `C`.

After removing `A` and compacting:

- membership is `[B,C]`;
- identity-bound history re-finds `B` at its new index 0 and advances to `C`;
- stale numeric history still says index 1 was last, so advancing wraps to index 0 and reselects `B`.

The control therefore agrees before mutation and diverges only after the membership change.

## Representation constraints

- fixed capacity: 3 member slots;
- byte-sized explicit member identities are sufficient for this pass;
- no heap/dynamic allocation;
- no Python runtime in guest mechanism;
- no dict/list/set runtime;
- no historical Process/Scheduler/File/Manager/Service primitive;
- no harness-supplied membership repair or selection result;
- no claim that this layout matches the lost C002 Python representation.

## Execution evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence SHALL remain separate.

Required run evidence:

- stable run directory;
- exact source hashes;
- exact compiler/linker/objcopy/QEMU/Python evaluator identities and hashes;
- build stdout/stderr and exits;
- raw image size/signature/hash;
- QEMU stdout/stderr and deterministic exit;
- debug observation artifact/hash;
- evaluator output/stderr/result artifact/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P02 succeeds for this bounded discriminator only if:

```text
PRE_ID=C
PRE_IDX=C
POST_ID=C
POST_IDX=B
DONE
```

is emitted by the guest, QEMU completes through the expected deterministic exit path, and the separate evaluator confirms the exact matrix.

A failure is still useful if it reveals an additional state distinction or hidden representation cost.

## Authority ceiling

Success would establish only that a bounded identity-history / compacting-membership distinction can be embodied in fixed-capacity freestanding state without Python container/object machinery for this case.

It would not establish:

- exact C002 host reliance;
- general scheduling policy;
- universal fairness;
- concurrent mutation atomicity on real multicore hardware;
- architecture promotion;
- P03 content.

## Stop rule

After the P02 result is reconciled, stop and derive only the next discriminator earned by the observed P02 consequence. P03-P20 remain unwritten until then.
