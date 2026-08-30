# C003 / P13 — explicit initialization versus stale-state carryover on slot reuse

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P13 of 20
**Architecture promotion:** NONE
**P14 earned:** YES

## Question

When one fixed record slot is reused from owner A to owner B, must the new acquisition explicitly initialize every load-bearing relation field to avoid stale A state, or is changing the owner identity alone sufficient?

## Controlling preregistration

`C003_P13_PREREGISTRATION.md` was sealed at Git commit `5688a87bd27ed14e9b0a815fa2d61554fc0569a9` before any P13 mechanism code or execution existed.

## Controlling scientific run

Run: `20260830T021300Z_p13_reuse_init_01`

QEMU:
- PID: `26812`
- started: `2026-08-30T02:13:19.744345+00:00`
- ended: `2026-08-30T02:13:19.946611+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator exit: `0`.
Evaluator stderr: empty.

## Exact raw observation

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

Evaluator version: `C003-P13-fixed-slot-init-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `20060d9b904abde6270c606ab5bfb4e40a1504bb3f1436fc996341d930ab9a22`
- fixture: `bf0973910ca319ca834813825a046a3b6bcc8c20a984c9ce33f1445c05838636`
- linker: `4068b5cd406ab418a2b7a425e6b3c81cec4f800280d72d732cc39aa8f2227fe6`
- evaluator: `78c2584c4639910dfa8daf7f7dbdf3a6f5192ecb419eaa9d973bf524c16c5188`
- launcher: `734f92d32cc37665c3f058fc994e488d1edc3eed098b1a8472bea7419e899e88`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `0b438107b636288fa29a854801f5efebb55d01fefbdad9b46ce050e780f014aa`
- debugcon SHA-256: `d82cdbbf3ea6ad77b189e3ee8db58e692d6fa5a6887c616c013b09207e77481b`
- evaluation SHA-256: `22f4d7deea8bea02d5304b704aa8d03f38e6b9a26a328ea66730306204a2de13`
- receipt SHA-256: `c90450286786e1d243c93e466e88f58b1755a82cc5aeb4cfc81fcb1c5c6494cd`
- evaluator stdout SHA-256: `03f4c3ee64a25be249ff1b5ad765ee630c72cfcff859826620bdfea1a140af24`
- all QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating closure matched all source and run hashes, the exact raw matrix, evaluator pass state, and QEMU `COMPLETED/33` state.

## Static/source closure

Source inspection confirmed:
- exactly one storage instance each for `record_owner`, `record_waiting`, `record_continuation`, and `record_progress`;
- `release_slot` writes only `record_owner`;
- `acquire_b_clean` writes owner plus waiting, continuation, and progress;
- `acquire_b_owner_only` writes owner only.

The result therefore does not come from a hidden second clean record or a cleanup step inside release.

## Qualified consequence

For this one fixed reusable record:

- owner A left waiting `1`, continuation `2`, and progress `7`;
- release marked the slot free by clearing owner only and left waiting residue `1`, proving the slot remained dirty;
- clean B acquisition explicitly wrote owner B and reset all three relation fields to `0`;
- owner-only B acquisition assigned the same owner B but inherited A's waiting `1`, continuation `2`, and progress `7`;
- changing identity alone was therefore insufficient to reproduce clean/default construction semantics on reused storage;
- explicit initialization of the load-bearing fields was sufficient for this bounded reuse case.

This exposes another host subsidy: fresh/default object state must become explicit when fixed memory is reused.

## Authority ceiling / nonclaims

P13 does **not** establish:
- a general allocator;
- object construction semantics in general;
- garbage collection;
- memory reclamation policy;
- lifetime safety under concurrency;
- use-after-free protection;
- process-table architecture;
- a Manager primitive;
- architecture promotion.

It establishes only the explicit-initialization burden for this one dirty fixed slot.

## Pareto / ontology consequence

The clean-reuse property did not require an allocator or object framework. The bounded cost was simply initializing the fields that can affect future behavior.

That cost still matters: every added load-bearing field expands the initialization obligation. Ontology growth therefore increases not only storage size but also reset/reuse burden.

## P14 discriminator earned by P13

A high-value remaining host subsidy is **implicit atomicity of multi-field mechanism transitions**.

The Python descendant could perform a relation transition inside one host-language step without a freestanding hardware interrupt observing a partially updated relation bundle. P05 established that real virtual-hardware interrupts can arrive and wake the guest, but it did not pressure a multi-field update against such an observer.

P14 should use one real QEMU PIT/PIC interrupt as a bounded observer:
- old relation state is owner `A`, continuation `1`;
- target state is owner `B`, continuation `2`;
- in the good path, interrupts remain masked while both bytes are updated, then the guest enables interrupts and halts; the IRQ handler snapshots coherent `B/2`;
- in the bad path, the guest writes owner `B`, enables interrupts and halts before writing continuation `2`; the IRQ handler snapshots torn state `B/1`; after wake the guest completes continuation `2`;
- the IRQ handler observes state only and does not repair it.

P14 must remain a bounded two-field interrupt-coherence discriminator. It must not promote a global lock, scheduler, transaction system, or general atomicity architecture. P15-P20 remain unwritten.
