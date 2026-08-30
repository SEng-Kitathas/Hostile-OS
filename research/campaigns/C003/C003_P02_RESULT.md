# C003 / P02 — identity-bound policy history under membership mutation

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P02 of 20
**Architecture promotion:** NONE
**P03 earned:** YES

## Question

Can bounded identity-bound policy history preserve the same next-choice consequence across compacting membership mutation using only fixed-capacity explicit state, while a raw numeric/index history control becomes observably wrong?

## Preregistered fixture

- initial membership `[A,B,C]`;
- last selected identity `B`;
- raw last-selected numeric index `1`;
- remove unrelated member `A` and compact to `[B,C]`.

Before mutation, identity and raw-index histories must agree on `C`. After mutation, identity-bound history must still select `C`; stale numeric history must drift to `B`.

## Durable run

Run: `20260829T211905Z_p02_membership_history_01`

Guest observation:

```text
PRE_ID=C
PRE_IDX=C
POST_ID=C
POST_IDX=B
DONE
```

Evaluator version: `C003-P02-membership-history-v1`

Evaluator result: `passed=true`

QEMU:
- expected exit 33
- observed exit 33
- stdout empty
- stderr empty

Evaluator stderr: empty

## Exact source hashes

- mechanism: `ec6df07067975c681c36469b548abbfd5675edec7ff3edee66451f2c077e9b47`
- fixture: `49f87bdd7aaf223da5d6f3a3ee823232b48076409646ca175e1488ae2c24f15e`
- linker: `a346a2982b905f6cfe5a1ed500a3e2ed5ce9877d43a4ed7293d34b290d85d340`
- evaluator: `9d56f8809a6e0f5e4a80f4dd963005aa7449f66a06a5a0b7105368b9636575fa`
- launcher: `cbccd56fef769194f90d84ad36e08ad9c78b1fe844bd2380daf1d435f62b0aba`

## Exact run artifacts

- raw image: 512 bytes
- raw SHA-256: `e96b4e9bb9682129fbc3bab126fde9d0b8e1c415920bb0a04503edf32c92872a`
- debugcon SHA-256: `d4f6d69258ba7f31695551d7324ee1fa67c5602dfd9b0a1c53dac7aaeac81c6b`
- evaluation SHA-256: `7f683144b9c3cc31d16402e5e817ae4df7245676959a8dcacaad188a41bfa695`
- receipt SHA-256: `031684599f6f314705c57ced9bdbc0db43d7542695571e4b3e99944d51114087`

## Qualified conclusion

For this bounded fixture:

- fixed-capacity explicit member identities are sufficient;
- dynamic allocation is not required by this slice;
- a Python dict/list/set runtime is not required by this slice;
- Python object identity is not required by this slice;
- identity-bound history preserves the intended next-choice consequence across unrelated-member removal and compaction;
- stale numeric/index history is causally distinguishable because it reselects `B` after mutation.

This is an absence-of-necessity result for the tested slice. Exact lost-C002 Python service reliance remains UNKNOWN.

## What P02 does not earn

- no general scheduler or fairness architecture;
- no claim about arbitrary membership sizes;
- no claim about concurrent/multicore mutation;
- no claim that the representation matches lost C002 source;
- no architecture promotion.

## P03 discriminator earned by P02

P02 observes coherent state before and after compaction, but does not pressure an observer arriving between lifecycle mutation and policy-history repair.

C002's surviving result says lifecycle and policy can be semantically separate while still requiring one coherent/atomic mutation boundary. Therefore P03 SHALL attack that exact seam:

- remove the identity currently held in policy history;
- force observation after membership compaction but before history repair;
- show an unguarded control exposes stale policy history;
- show a minimal explicit mutation-currentness guard causes the observer to reject/retry the intermediate state and exposes only coherent post-commit state.

This directly pressures the still-UNKNOWN `implicit atomicity` host subsidy without claiming real multicore atomicity.

P04-P20 remain unwritten.
