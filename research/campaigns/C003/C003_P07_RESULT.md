# C003 / P07 — local failure preserves distinct later progress

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P07 of 20
**Architecture promotion:** NONE
**P08 earned:** YES

## Question

Can one activity receive a bounded local missing-operation result while a distinct later activity still executes a present operation and advances progress state, and does a deliberately bad global-failure-latch control block that same later progress after the same initial miss?

## Controlling preregistration

`C003_P07_PREREGISTRATION.md` was sealed before execution. The working tree briefly received a duplicate continuity-only preregistration commit after the original seal; the discriminator remained byte/semantics-equivalent and unchanged.

## Controlling run

Run: `20260829T213845Z_p07_failure_locality_01`

QEMU:
- PID: `24564`
- started: `2026-08-29T21:38:42.409136+00:00`
- ended: `2026-08-29T21:38:42.612206+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Raw observation

```text
LOCAL_MISS=M
LOCAL_LATER=O
LOCAL_STATE=B
GLOBAL_MISS=M
GLOBAL_LATER=X
GLOBAL_STATE=A
DONE
```

Evaluator version: `C003-P07-failure-locality-v1`
Evaluator result: `passed=true`

The guest emitted raw status/state only; it did not self-grade the discriminator.

## Mechanism boundary

Both trials use one bounded operation relation:
- present operation `0x01`: advance protected state `A -> B`, return `O`;
- missing operation: leave protected state unchanged, return `M`.

Local trial:
- activity A receives `M`;
- no global poison state is set;
- distinct activity B subsequently receives `O` and advances state to `B`.

Negative control:
- activity A receives the same `M`;
- control deliberately sets one-byte `global_failed`;
- activity B's same present operation is blocked with `X` and state remains `A`.

The global latch is a negative control only and is not an earned ErrorManager primitive.

## Exact source hashes

- mechanism: `4b376f052a25d7f3cbbcb121f3f23355267a3213d41250305a7651738d5feaba`
- fixture: `221cd6402009ebc889f2581c328e757bb79d07081eb7f4e4f867d11d5825a5e8`
- linker: `41468eda94422f930952f743b17d5b6b4015788890658eb5f34786eaad41afb5`
- evaluator: `907ee6f576b752ab9c70cddead8b74bba7d5e2f44550fdddea4ab62c14cdc6b1`
- launcher: `fc2ccabc6921ec5ddbacdc18732017a17f290a0741d528139324f8ddbedb0a4d`

## Exact run artifacts

- boot image: 512 bytes
- boot image SHA-256: `fdf46a35150e58bb11d99beefd3a84c92020ccb6404cb3d00795b8f1a6f53c1e`
- debugcon SHA-256: `37e3bdd7800e0a2b723729c10cef60ffd19ca4d10e9dc6e3b298b18694736dc1`
- evaluation SHA-256: `e47082f916ecda827cddf4c45fc65c44b8dd2793fa433154255ca96ca28dd893`
- receipt SHA-256: `ad608925a35eeac0fb9f4b8482c7847e16a49651ae583b8f7aa923b64dc877b9`

No standard QEMU process remained after post-inspection.

## Qualified conclusion

For this bounded two-activity slice:

- a missing operation can remain a local result rather than poisoning unrelated later progress;
- distinct later activity B can still execute a present operation and change state after activity A's local miss;
- a deliberately global poison latch is causally distinguishable because it blocks that same later progress;
- Python exception propagation, host dispatch dictionaries, a global error-manager object, Process, and Scheduler primitives are not required by this tested consequence.

This does not establish general fault containment, isolation/security boundaries, arbitrary activity count, fairness, scheduler architecture, or architecture promotion.

## P08 discriminator earned by P07

P07 establishes multiple progress-capable activities in a bounded causal sequence, but it does not yet embody the C002 survivor that **selection can remain separate from execution application**.

C002 also preserves that bounded multi-eligible choice can carry separate policy history. P02 already pressured identity-bound policy history under membership mutation; P08 should now join those facts without collapsing selection into execution.

P08 is earned as a selection/application separation discriminator:

- two eligible activities `A` and `B` have independent continuation/progress bytes;
- policy history makes `B` the selected identity for the next step;
- a `select_next` relation returns selected identity `B` but SHALL NOT mutate either activity continuation/progress state;
- raw observation immediately after selection must show selected `B` while both progress bytes are unchanged;
- a separate `apply_selected` relation then applies one bounded progress step only to selected `B`;
- raw post-application observation must show A unchanged and B advanced;
- a deliberately conflated control may mutate B during selection, allowing the evaluator to distinguish separation from select-and-apply collapse.

P09-P20 remain unwritten.
