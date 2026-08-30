# C003 / P09 preregistration — parent-child return from lineage + generic wait/wake

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P09 of 20
**Earned by:** C003/P08 bounded selection/application separation success
**Architecture promotion:** FORBIDDEN

## Why P09 exists

C002's surviving whole-P01 result says narrow parent-child return composes from lineage plus generic wait/wake and did not require a special return mechanism or return-binding primitive.

P05 already embodied a generic wake consequence under virtual hardware. P07 embodied distinct activity identities, and P08 showed selection can remain separate from application. P09 now pressures the remaining narrow claim directly in a bounded lineage/wait/completion fixture.

## P09 question

Can a child completion wake and resume its waiting parent using only explicit lineage, current wait target, current completion state, a generic wait-match transition, and a separate parent application step — with no `return_to_parent`, return-binding object, Process, or Scheduler primitive?

## Fixture responsibility

The fixture supplies facts only.

Good path facts:
- parent identity: ASCII `P`;
- child identity: ASCII `C`;
- lineage child: `C`;
- lineage parent: `P`;
- parent wait target: `C`;
- child terminal status to record: ASCII `S`;
- initial parent progress: ASCII `0`.

Negative-control facts:
- same parent `P`;
- same child `C`;
- same parent wait target `C`;
- deliberately nonmatching lineage parent: ASCII `Q`;
- same terminal child status `S`.

The fixture SHALL NOT:
- record completion;
- decide whether a wait matches;
- wake the parent;
- copy status into parent-visible state;
- advance parent progress.

## Explicit guest state

At minimum:
- `parent_identity`;
- `child_identity`;
- `lineage_child`;
- `lineage_parent`;
- `parent_waiting`;
- `parent_wait_target`;
- `parent_woken` or equivalent eligibility/current-wake byte;
- `completion_identity`;
- `completion_status`;
- `completion_current`;
- `parent_received_status`;
- `parent_progress`.

No special parent-return state or return-binding relation is permitted.

## Relations

### `record_completion`

Input: completed child identity + terminal status.

Effect:
- set `completion_identity=C`;
- set `completion_status=S`;
- set `completion_current=1`.

It SHALL NOT directly wake or advance the parent.

### `generic_wait_match`

Input: current completion identity/event.

It may wake the bounded waiting activity only if all required relation facts match:
- parent is currently waiting;
- parent wait target equals completion identity;
- lineage child equals completion identity;
- lineage parent equals parent identity;
- completion is current.

On match:
- clear waiting;
- set parent woken/eligible byte.

It SHALL NOT advance parent progress or synthesize a special return operation.

### `apply_parent`

Runs separately after wake.

If parent is woken/eligible and completion remains current for the matched child:
- copy terminal child status `S` into `parent_received_status`;
- advance parent progress `0 -> 1`.

## Good path raw observation

After child completion and generic wait match, before parent application:

```text
GOOD_COMPLETE=S
GOOD_WAKE=1
GOOD_PRE_PROGRESS=0
```

After separate parent application:

```text
GOOD_PARENT_STATUS=S
GOOD_POST_PROGRESS=1
```

## Negative control

Reset bounded state using the same completion identity/status and same parent wait target, but use lineage `C -> Q` while parent identity remains `P`.

`record_completion` still records terminal `C/S`.

`generic_wait_match` SHALL reject the lineage mismatch. Parent remains waiting/not woken; `apply_parent` SHALL not advance parent progress.

Raw observation:

```text
BAD_COMPLETE=S
BAD_WAKE=0
BAD_POST_PROGRESS=0
DONE
```

This demonstrates that child terminal completion bytes alone do not constitute parent return; the lineage/wait relation is load-bearing in this bounded slice.

## Exact raw guest observation contract

```text
GOOD_COMPLETE=S
GOOD_WAKE=1
GOOD_PRE_PROGRESS=0
GOOD_PARENT_STATUS=S
GOOD_POST_PROGRESS=1
BAD_COMPLETE=S
BAD_WAKE=0
BAD_POST_PROGRESS=0
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately check:
- completion exists in both good and bad paths;
- good lineage/wait relation wakes P before parent progress changes;
- separate parent application transfers status and advances progress only after wake;
- bad lineage prevents wake/progress despite the same terminal completion and wait target.

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

P09 succeeds only if the exact raw observation matches the preregistered matrix with QEMU deterministic success exit and independent evaluator pass.

A completed alternate matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this bounded one-parent/one-child return consequence can be composed from explicit lineage + current wait/completion + generic wake + separate application without a special return primitive.

It would not establish:
- arbitrary process trees;
- general join/wait semantics;
- orphan/reparent semantics;
- scheduler architecture;
- arbitrary fan-in/fan-out;
- signal semantics;
- isolation/security;
- architecture promotion.

## Stop rule

Reconcile P09 before deriving P10. P10-P20 remain unwritten until P09 consequence earns the next discriminator.
