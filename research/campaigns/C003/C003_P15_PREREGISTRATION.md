# C003 / P15 preregistration — fixed-capacity exhaustion versus overwrite-on-full

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P15 of 20
**Earned by:** C003/P14 bounded IRQ-coherence success
**Architecture promotion:** FORBIDDEN

## Why P15 exists

P14 exposed multi-field transition atomicity as a low-level burden under a real interrupt observer.

Another C003 host suspect is **dynamic allocation / container growth**. Python containers could admit another entry without forcing the mechanism to expose a hard storage boundary. A freestanding fixed representation must choose what happens at capacity.

P15 pressures only that boundary. Success does not require growth; an explicit bounded `FULL` result may be the smaller correct behavior.

## P15 question

Can a two-slot relation store explicitly reject a third admission while preserving both existing identities, and does an overwrite-on-full control demonstrate the consequence of hiding the capacity boundary?

## Fixture responsibility

The fixture supplies facts only:
- identity A;
- identity B;
- identity C;
- capacity = numeric `2`.

The fixture SHALL NOT:
- choose a slot;
- admit an identity;
- count occupancy;
- choose overflow policy;
- grade the result.

## Guest state

The mechanism owns:
- `slots[2]`;
- `count`.

No heap, allocator, dynamic array, or hidden third slot is allowed.

## Checked admission path

### `admit_checked`

Input: one identity byte.

Behavior:
- if `count < capacity`, write the identity into `slots[count]`, increment count, return status `W`;
- if `count == capacity`, write no slot, leave count unchanged, return status `F`.

Starting empty:
- admit A -> `W`;
- admit B -> `W`;
- admit C -> `F`.

After rejected C:
- slot 0 must remain A;
- slot 1 must remain B.

## Overwrite-on-full negative control

Reset to empty and use the same checked admission for A and B, producing the same full state.

Then call `admit_overwrite_full` with C.

The bad control:
- if full, writes C into slot 0 without any release;
- returns `W`;
- leaves slot 1 as B.

The resulting state must therefore be C/B, demonstrating that silent admission by overwrite destroys an existing relation when no explicit capacity policy exists.

## Exact raw guest observation contract

```text
GOOD_A=W
GOOD_B=W
GOOD_C=F
GOOD_SLOT0=A
GOOD_SLOT1=B
BAD_A=W
BAD_B=W
BAD_C=W
BAD_SLOT0=C
BAD_SLOT1=B
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- good A and B admissions succeed;
- good C admission returns `F`;
- good full-state slots remain A/B;
- bad A and B setup admissions succeed;
- bad C overflow reports `W`;
- bad overflow state is C/B.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- exactly two slot bytes exist;
- no third slot storage exists;
- `admit_checked` has a capacity branch before the indexed slot write;
- its full branch does not write either slot;
- `admit_overwrite_full` writes slot 0 when full.

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

P15 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit, independent evaluator pass, and static/source closure.

A completed alternate matrix is a qualified mechanism failure. Build failure before execution is an engineering scar with no scientific consequence. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this two-slot store can make exhaustion explicit and preserve existing entries, while a deliberate overwrite-on-full control clobbers one existing entry.

It would not establish:
- that fixed capacity is universally correct;
- a heap or allocator requirement;
- dynamic-array architecture;
- admission policy for arbitrary workloads;
- eviction policy;
- process-table architecture;
- a Manager primitive;
- architecture promotion.

## Pareto / ontology pressure

Capacity is itself a cost/behavior choice. The campaign SHALL NOT treat dynamic growth as automatically superior to an explicit bounded failure. The smallest lawful behavior for a bounded workload may be finite capacity plus a visible full status.

## Stop rule

Reconcile P15 before deriving P16. P16-P20 remain unwritten until P15 consequence earns the next discriminator.
