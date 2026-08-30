# C003 / P11 preregistration — explicit bounds check versus adjacent-state corruption

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P11 of 20
**Earned by:** C003/P10 bounded explicit-continuation success
**Architecture promotion:** FORBIDDEN

## Why P11 exists

P10 made one hidden interpreter control service explicit: logical continuation identity.

The C003 campaign question is broader: what services did the Python host silently supply to the C002 relation composition?

A high-value remaining suspect is **implicit memory safety / bounds checking**. Python collection access did not permit a raw out-of-range indexed write to overwrite an adjacent object byte. A freestanding fixed-memory embodiment does not get that property for free.

P11 pressures only that narrow distinction. It does not introduce a memory manager, allocator, process, protection domain, or general memory-safety architecture.

## P11 question

Can a two-slot fixed-capacity relation state accept an in-range write, reject an out-of-range write, and preserve an immediately adjacent sentinel using only an explicit bounds check — while an intentionally unchecked control with the same invalid index overwrites that adjacent sentinel?

## Fixture responsibility

The fixture supplies facts only:
- valid slot index: numeric `1`;
- invalid slot index: numeric `2` for a two-slot state;
- write value: ASCII `X`;
- initial slot 0: ASCII `A`;
- initial slot 1: ASCII `B`;
- initial adjacent sentinel: ASCII `S`.

The fixture SHALL NOT:
- perform bounds checking;
- choose checked versus unchecked behavior;
- perform a relation write;
- protect or restore the sentinel after a write;
- grade the result.

## Explicit checked path

Guest state contains exactly two relation slots followed immediately by one sentinel byte:

```text
relation_slots[0]
relation_slots[1]
adjacent_sentinel
```

No padding byte may exist between slot 1 and the sentinel.

### `checked_write`

Input:
- requested slot index;
- write value.

Behavior:
- if `index < 2`, write the selected relation slot and return status `W`;
- otherwise, perform no write and return bounded status `R`.

The mechanism SHALL first apply the valid fixture index `1` and value `X`. This must produce:
- status `W`;
- slot 1 = `X`.

Without resetting the state, it SHALL then apply invalid index `2` and value `X`. This must produce:
- status `R`;
- adjacent sentinel remains `S`.

This prevents a trivial reject-all implementation from satisfying the discriminator.

## Unchecked negative control

Reset the same two slots and sentinel to fixture facts.

The bad control deliberately omits the `index < 2` check and performs a raw indexed byte write relative to the start of `relation_slots` using invalid index `2`.

Because the sentinel is immediately adjacent to slot 1, the raw index-2 write targets the sentinel byte.

The bad control reports status `W` after performing the raw write. The sentinel must then be `X`.

This unchecked path is a negative control only. It is not a proposed API or architecture.

## Exact raw guest observation contract

```text
VALID_INDEX=1
INVALID_INDEX=2
GOOD_VALID=W
GOOD_SLOT1=X
GOOD_INVALID=R
GOOD_SENT=S
BAD_INVALID=W
BAD_SENT=X
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- valid fixture index is 1;
- invalid fixture index is 2;
- checked valid write returned `W`;
- checked valid write changed slot 1 to `X`;
- checked invalid write returned `R`;
- checked invalid write preserved sentinel `S`;
- unchecked invalid write reported `W`;
- unchecked invalid write changed the adjacent sentinel to `X`.

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

P11 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit and independent evaluator pass.

A completed alternate matrix is a qualified mechanism failure. Build failure before execution is an engineering scar with no scientific consequence. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that, for this fixed three-byte layout, one explicit index bound distinguishes a valid relation-slot write from an out-of-range write that would otherwise corrupt the immediately adjacent byte.

It would not establish:
- general memory safety;
- arbitrary buffer safety;
- memory protection;
- virtual memory;
- allocator design;
- object lifetime safety;
- pointer provenance;
- concurrency safety;
- spatial safety outside this fixed layout;
- a MemoryManager primitive;
- architecture promotion.

## Pareto / ontology pressure

The checked mechanism earns only the smallest distinction demanded by the discriminator: a capacity constant and one explicit bound before indexed mutation.

Do not import a larger historical memory-safety subsystem merely because Python used to supply the safety property implicitly.

## Stop rule

Reconcile P11 before deriving P12. P12-P20 remain unwritten until P11 consequence earns the next discriminator.
