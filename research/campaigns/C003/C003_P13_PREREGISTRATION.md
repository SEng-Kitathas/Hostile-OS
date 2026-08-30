# C003 / P13 preregistration — explicit initialization versus stale-state carryover on slot reuse

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P13 of 20
**Earned by:** C003/P12 bounded generation-width success
**Architecture promotion:** FORBIDDEN

## Why P13 exists

P12 exposed finite integer width as a low-level burden that Python arbitrary-width integers can hide.

Another host service Python commonly supplied to C002 was **clean object construction/default initialization**. A new Python record could begin from constructor/default values. A fixed freestanding memory slot can be reused while still containing bytes left by its prior owner.

P13 pressures only that fixed-slot reuse seam. It does not introduce an allocator, object system, process table, manager, or garbage collector.

## P13 question

When one fixed record slot is reused from owner A to owner B, must the new acquisition explicitly initialize every load-bearing relation field to avoid stale A state, or is changing the owner identity alone sufficient?

## Fixture responsibility

The fixture supplies facts only:
- first owner identity: ASCII `A`;
- second owner identity: ASCII `B`;
- A waiting residue: ASCII `1`;
- A continuation residue: ASCII `2`;
- A progress residue: ASCII `7`;
- clean default byte: ASCII `0`.

The fixture SHALL NOT:
- acquire or release the slot;
- choose good versus bad reuse behavior;
- clear any field;
- grade the result.

## Fixed record state

Exactly one guest record contains:
- `owner`;
- `waiting`;
- `continuation`;
- `progress`.

There is no dynamic allocation and no second record used as a hidden fresh slot.

## Dirty A state

The mechanism first assigns owner A and writes the fixture's non-default waiting, continuation, and progress residue into the one record.

### `release_slot`

Release changes only `owner` to zero/free.

It SHALL NOT erase waiting, continuation, or progress.

Immediately after release, raw observation must show:
- owner byte `0`;
- waiting residue still `1`.

This proves the slot being reused is dirty rather than freshly zeroed memory.

## Good B reuse path

### `acquire_b_clean`

The mechanism assigns owner B and explicitly initializes every load-bearing relation field:
- owner = `B`;
- waiting = `0`;
- continuation = `0`;
- progress = `0`.

The observed B state must therefore be clean.

## Owner-only negative control

Recreate the same dirty A state in the same fixed record, call the same `release_slot`, then perform `acquire_b_owner_only`.

### `acquire_b_owner_only`

The bad control changes only:
- owner = `B`.

It SHALL NOT write waiting, continuation, or progress.

The observed B state must therefore expose A's residue:
- waiting `1`;
- continuation `2`;
- progress `7`.

This is a negative control only. It is not an allocation or ownership architecture proposal.

## Exact raw guest observation contract

```text
RELEASE_OWNER=0
RELEASE_WAIT=1
GOOD_OWNER=B
GOOD_WAIT=0
GOOD_CONT=0
GOOD_PROGRESS=0
BAD_OWNER=B
BAD_WAIT=1
BAD_CONT=2
BAD_PROGRESS=7
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- release marked the record free (`RELEASE_OWNER=0`);
- release preserved dirty waiting residue (`RELEASE_WAIT=1`);
- good B acquisition assigned B;
- good B acquisition reset waiting, continuation, and progress to zero;
- bad B acquisition assigned the same B identity;
- bad B acquisition retained waiting 1, continuation 2, progress 7.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- only one record storage instance exists;
- `release_slot` writes owner only;
- `acquire_b_clean` writes owner plus all three relation fields;
- `acquire_b_owner_only` writes owner only.

This is required to rule out a hidden second clean slot or guest output that merely prints expected values.

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

P13 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit, independent evaluator pass, and static/source closure.

A completed alternate matrix is a qualified mechanism failure. Build failure before execution is an engineering scar with no scientific consequence. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that explicit field initialization is required to obtain clean default semantics when this one fixed dirty record is reassigned from A to B.

It would not establish:
- a general allocator;
- object construction semantics in general;
- garbage collection;
- memory reclamation policy;
- lifetime safety under concurrency;
- use-after-free protection;
- process-table architecture;
- a Manager primitive;
- architecture promotion.

## Pareto / ontology pressure

The tested clean-reuse property should cost only explicit initialization of the fields that actually carry future behavior. Do not import an allocator or object framework merely to obtain default bytes.

## Stop rule

Reconcile P13 before deriving P14. P14-P20 remain unwritten until P13 consequence earns the next discriminator.
