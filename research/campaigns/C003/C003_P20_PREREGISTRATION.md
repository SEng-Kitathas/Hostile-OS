# C003 / P20 preregistration — final bounded lifecycle composition replay

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P20 of 20 — FINAL PASS
**Earned by:** C003/P19 bounded nested-status success
**Architecture promotion:** FORBIDDEN
**Hard stop:** after P20 reconciliation, no C003/P21 may be created or executed

## Why P20 exists

P01-P19 have pressure-tested inherited workload responsibilities and a sequence of host-runtime subsidies in bounded freestanding slices. The final C003 pass should not add another historical subsystem noun merely to keep the campaign moving.

P20 is a **composition replay**. Its job is to test whether several already-earned distinctions can coexist in one small fixed-slot lifecycle without adding a new primitive species.

## Fixture responsibility

The fixture supplies facts only:
- owner A;
- owner B;
- old value X;
- new value Y;
- known request K;
- missing request U;
- continuation target numeric 2.

The fixture SHALL NOT acquire/release the slot, choose capacity behavior, set generation, initialize runtime fields, propagate status, apply continuation, create handles, perform currentness checks, or grade the result.

## One-slot guest state

Exactly one reusable slot contains:
- owner;
- generation;
- value;
- progress;
- continuation;
- waiting.

Separate small mechanism state may hold:
- stale handle generation;
- fresh handle generation;
- last-read observation.

No second slot, heap, process object, scheduler object, file object, manager, service, exception runtime, or dynamic container is allowed.

## Composed lifecycle

### 1. Acquire A cleanly

Starting free with generation 0, `acquire_checked(A,X)` must:
- reject if occupied;
- otherwise increment generation to 1;
- assign A/X;
- initialize progress, continuation, and waiting to 0;
- return `W`.

Snapshot generation 1 as the stale-handle generation.

### 2. Bind continuation and pressure missing status

Arm continuation target 2 and waiting=1.

`middle_request(U)` calls the leaf request layer from the P19 pattern:
- leaf returns `M` for U;
- middle checks status before any progress/continuation application;
- result remains `M`;
- progress remains 0;
- bound continuation remains 2.

### 3. Successful request applies the bound continuation

The same `middle_request(K)`:
- leaf returns `O` for K;
- middle sees success;
- while waiting is active, it applies progress = bound continuation 2 and clears waiting;
- returns `O`.

Progress must become 2.

### 4. One-slot capacity remains explicit

Before releasing A, attempt `acquire_checked(B,Y)`.

Because the only slot is occupied:
- return `F`;
- owner remains A.

### 5. Release and clean reuse for B

`release_slot` clears owner only.

Then `acquire_checked(B,Y)` reuses the same slot:
- increments generation from 1 to 2;
- assigns B/Y;
- explicitly resets progress, continuation, and waiting to 0;
- returns `W`.

Snapshot generation 2 as the fresh-handle generation.

### 6. Handle currentness after reuse

`checked_read(fresh_generation)` must return `W` and Y.

`checked_read(stale_generation)` must compare generation before value read, return `R`, and set observation to numeric 0.

`address_only_read(stale_generation)` is the negative control: it ignores generation, returns `W`, and reads Y from the reused slot.

## Exact raw guest observation contract

Compact keys are used to preserve the one-sector evidence ceiling:

```text
A_ACQ=W
A_GEN=1
MISS=M
M_PROG=0
M_CONT=2
OK=O
O_PROG=2
FULL=F
F_OWNER=A
B_ACQ=W
B_GEN=2
B_PROG=0
B_CONT=0
FRESH=W
F_READ=Y
STALE=R
S_READ=0
BAD=W
B_READ=Y
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

Require exact line equality and verify each composed seam:
- A clean acquisition W/gen1;
- missing request M with progress0 and continuation2 preserved;
- known request O with progress2;
- full B attempt F while owner remains A;
- B reuse W/gen2 with progress0/continuation0;
- fresh handle W/Y;
- stale checked handle R/0;
- address-only stale control W/Y.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- exactly one slot storage instance exists;
- `acquire_checked` tests occupancy before mutation, increments generation on successful acquire, and initializes progress/continuation/waiting;
- continuation 2 is explicitly stored before the missing request;
- middle request checks leaf status before progress application and reads the stored continuation on success;
- the full branch does not overwrite the occupied slot;
- release clears owner only;
- B reuse goes through the same checked acquire routine;
- checked read compares generation before reading value and reject path does not read Y;
- address-only bad read has no generation comparison and reads the same slot value.

## Evidence contract

Use the standard C003 freestanding contract: separate mechanism/fixture/linker/launcher/evaluator; stable run directory; exact source/tool hashes; 512-byte `55aa` image; exact QEMU PID/argv/times/exit; bounded timeout; debug/evaluator artifacts and hashes; durable receipt; non-mutating post-run closure. Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P20 succeeds only on exact preregistered output, QEMU success exit, independent evaluator pass, and static/source closure.

A build failure before execution is an engineering scar with no scientific consequence. A completed alternate matrix is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

P20 success would establish only that these already-earned bounded mechanisms can coexist in one one-slot lifecycle under this fixture and execution environment.

It would **not** establish:
- a final OS architecture;
- general scheduler/process/file/manager/service architecture;
- general memory safety;
- general pointer/capability safety;
- universal lifetime or generation policy;
- arbitrary workload support;
- physical-hardware proof;
- promotion of R3.1 over R6;
- replacement readiness.

## Campaign stop rule

After P20 is reconciled and durably closed:
- C003 SHALL be marked **CLOSED 20/20**;
- no C003/P21 preregistration, mechanism, run, or result may be created;
- any further work must enter a separately named campaign, audit, promotion gate, or other explicitly authorized phase.
