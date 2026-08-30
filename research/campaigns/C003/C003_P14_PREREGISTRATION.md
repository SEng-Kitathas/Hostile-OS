# C003 / P14 preregistration — two-field transition coherence under a real IRQ observer

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P14 of 20
**Earned by:** C003/P13 bounded fixed-slot initialization success
**Architecture promotion:** FORBIDDEN

## Why P14 exists

P13 exposed clean/default initialization as an explicit burden on reused fixed storage.

Another hidden-host suspect named by C003 is **implicit atomicity**. The bounded Python descendant could apply a multi-field mechanism transition as one host-language operation from the harness point of view. A freestanding guest with maskable hardware interrupts can expose intermediate state between separate machine writes.

P05 already qualified the QEMU PIT/PIC IRQ0 path and `STI; HLT` wake behavior. P14 reuses that real virtual-hardware observer to pressure a two-field relation update.

## P14 question

Can masking the tested IRQ across both writes keep a two-field transition coherent to a real interrupt observer, while enabling the IRQ after only the first write exposes a torn intermediate state?

## Fixture responsibility

The fixture supplies facts only:
- old owner: ASCII `A`;
- old continuation: ASCII `1`;
- new owner: ASCII `B`;
- new continuation: ASCII `2`;
- PIT divisor: word `4096`.

The fixture SHALL NOT:
- install the interrupt handler;
- mask/unmask interrupts;
- program the PIT;
- mutate relation state;
- snapshot state;
- grade the result.

## Guest relation state

The tested relation contains exactly:
- `relation_owner`;
- `relation_continuation`.

The IRQ handler owns separate observation bytes:
- `irq_seen`;
- `irq_owner_snapshot`;
- `irq_cont_snapshot`.

The handler SHALL NOT repair or mutate `relation_owner` or `relation_continuation`.

## IRQ setup

The mechanism SHALL:
- install a real-mode IRQ0 handler at vector 8;
- use PIT channel 0 mode 0 one-shot with the fixture divisor;
- mask IRQ0 while preparing each path;
- unmask only IRQ0 before the `STI; HLT` observation point;
- send PIC EOI in the handler.

## Good coherent path

Starting relation: `A/1`.

With IRQ0 masked and IF cleared:
1. program the PIT one-shot;
2. write owner `B`;
3. write continuation `2`;
4. unmask IRQ0;
5. execute `STI; HLT` until the handler runs.

The IRQ handler snapshots the tested relation and must observe:
- owner `B`;
- continuation `2`.

After wake, the guest must still observe post-state `B/2`.

## Torn negative control

Reset relation to `A/1`, clear IRQ observation state, and reprogram the PIT one-shot with IRQ0 masked.

Then:
1. write owner `B`;
2. unmask IRQ0;
3. execute `STI; HLT` until the handler runs;
4. after wake, disable interrupts;
5. write continuation `2`.

The IRQ handler must therefore snapshot the intermediate relation:
- owner `B`;
- continuation `1`.

The final post-state must still become `B/2` after the guest completes the second write.

This bad path is a negative control only. It is not a proposed update protocol.

## Exact raw guest observation contract

```text
GOOD_IRQ_OWNER=B
GOOD_IRQ_CONT=2
GOOD_POST_OWNER=B
GOOD_POST_CONT=2
BAD_IRQ_OWNER=B
BAD_IRQ_CONT=1
BAD_POST_OWNER=B
BAD_POST_CONT=2
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- good IRQ snapshot is coherent `B/2`;
- good final state is `B/2`;
- bad IRQ snapshot is torn `B/1`;
- bad final state becomes `B/2` after wake.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- the IRQ handler reads `relation_owner` and `relation_continuation` into snapshot bytes;
- the IRQ handler does not write either tested relation field;
- the good path writes both tested fields before IRQ0 unmask / `STI; HLT`;
- the bad path writes new owner before IRQ0 unmask / `STI; HLT` and writes new continuation only after the IRQ observation returns.

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

P14 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit, independent evaluator pass, and static/source closure.

A completed alternate matrix is a qualified mechanism failure. Build failure before execution is an engineering scar with no scientific consequence. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that masking this real virtual IRQ across two byte writes prevents this IRQ handler from observing the tested relation half-updated, while enabling the IRQ between the writes exposes the torn state.

It would not establish:
- general atomicity;
- multiprocessor atomicity;
- lock-free correctness;
- transaction semantics;
- non-maskable interrupt safety;
- DMA coherence;
- memory-ordering rules beyond this uniprocessor real-mode QEMU slice;
- a global lock or Scheduler primitive;
- physical-hardware proof;
- architecture promotion.

## Pareto / ontology pressure

The discriminator pays only for the smallest coherence mechanism under test: IRQ masking around the coupled writes. It does not earn a transaction system merely because a host runtime previously hid the observation window.

## Stop rule

Reconcile P14 before deriving P15. P15-P20 remain unwritten until P14 consequence earns the next discriminator.
