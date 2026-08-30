# C003 / P19 preregistration — explicit nested status propagation

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P19 of 20
**Earned by:** C003/P18 bounded serialization-convention success
**Architecture promotion:** FORBIDDEN

## Why P19 exists

P18 made byte-order convention explicit instead of relying on host conversion helpers.

Another host subsidy is **nested error/control-flow propagation**. Host exceptions, return conventions, or high-level call structure can hide the obligation to carry a failure through an intermediate layer before applying later state.

P19 pressures only one leaf + one middle caller. It does not add an exception runtime, error manager, scheduler, or global error state.

## Fixture responsibility

The fixture supplies facts only:
- known request byte: ASCII `K`;
- missing request byte: ASCII `U`.

The fixture SHALL NOT:
- return operation status;
- mutate progress;
- choose good versus bad middle behavior;
- grade the result.

## Guest state

The mechanism owns one progress byte, initialized to numeric 0 before each path.

## Leaf operation layer

`leaf_execute(request)`:
- if request is the known fixture request `K`, return status `O`;
- otherwise return bounded missing status `M`;
- leaf execution SHALL NOT write progress in either case.

## Good middle path

`middle_checked(request)`:
1. call `leaf_execute`;
2. inspect the returned status before any progress write;
3. if status is not `O`, return that status unchanged and leave progress 0;
4. if status is `O`, set progress to numeric 1 and return `O`.

Two observations use this same middle routine:
- missing request U -> status `M`, progress 0;
- known request K -> status `O`, progress 1.

The known success path prevents a reject-all implementation from satisfying the discriminator.

## Bad middle negative control

`middle_ignore_failure(request)`:
1. call `leaf_execute` with missing request U;
2. do not branch on the returned `M`;
3. set progress to numeric 1;
4. overwrite/report status `O`.

This demonstrates the consequence of failing to propagate the nested leaf status.

## Exact raw guest observation contract

```text
GOOD_MISS_STATUS=M
GOOD_MISS_PROGRESS=0
GOOD_OK_STATUS=O
GOOD_OK_PROGRESS=1
BAD_MISS_STATUS=O
BAD_MISS_PROGRESS=1
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

Require exact line equality and separately verify:
- good missing status is `M` with progress 0;
- good success status is `O` with progress 1;
- bad missing path reports `O` and progress 1.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- `leaf_execute` returns `M` for non-K request and `O` for K;
- `leaf_execute` does not write progress;
- `middle_checked` calls the leaf and checks status before its progress write;
- `middle_checked` returns the leaf's missing status unchanged on the failure branch;
- `middle_ignore_failure` calls the same leaf, contains no status branch after the call, writes progress 1, and reports `O`.

## Evidence contract

Use the standard C003 freestanding contract: separate mechanism/fixture/linker/launcher/evaluator; stable run directory; exact source/tool hashes; 512-byte `55aa` image; exact QEMU PID/argv/times/exit; bounded timeout; debug/evaluator artifacts and hashes; durable receipt; non-mutating post-run closure. Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P19 succeeds only on exact preregistered output, QEMU success exit, independent evaluator pass, and static/source closure.

## Authority ceiling

Success would establish only that this bounded two-layer call path needs an explicit status check to keep a missing leaf failure from being silently converted into success plus progress.

It would not establish an exception runtime, general error-handling architecture, stack unwinding, transactional rollback, global error manager, scheduler behavior, or architecture promotion.

## Stop rule

Reconcile and durably close P19 before deriving P20. P20 is the final C003 pass and remains unwritten until P19 consequence earns it. No C003/P21 is permitted.
