# C003 / P16 preregistration — shared backing lifetime versus premature reclaim

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P16 of 20
**Earned by:** C003/P15 bounded capacity success
**Architecture promotion:** FORBIDDEN

## Why P16 exists

P15 exposed fixed capacity as an explicit behavior choice rather than silently assuming host container growth.

Another host service is **automatic lifetime/reference handling**. A host object may remain alive while references to it still exist. A freestanding backing byte shared by multiple bindings needs an explicit rule if one binding can be released before the other.

P16 pressures only one backing with two bindings. It does not introduce a heap, garbage collector, smart-pointer system, or manager.

## Fixture responsibility

The fixture supplies facts only:
- binding owner A;
- binding owner B;
- backing value X.

The fixture SHALL NOT establish bindings, set live count, release a binding, clear backing, or grade the result.

## Guest state

One shared record contains:
- `backing_value`;
- `live_count`;
- `binding_a_owner`;
- `binding_b_owner`.

`setup_shared` explicitly establishes A and B against the same backing X and sets live count to numeric 2.

## Good lifetime path

Starting count 2:
1. release A by clearing only A's binding and decrementing count to 1;
2. because count is nonzero, preserve backing X;
3. observe B is still owner B and reads X;
4. release B and decrement count to 0;
5. only when count reaches 0, clear backing to byte 0.

## Premature-reclaim negative control

Recreate the same A/B shared state with count 2 and backing X.

Bad A release:
- clears A binding;
- decrements count from 2 to 1;
- **unconditionally clears backing**, despite B remaining live.

The observation must show:
- live count 1;
- B owner still B;
- B read returns cleared byte 0 instead of X.

## Exact raw guest observation contract

```text
GOOD_START=2
GOOD_AFTER_A=1
GOOD_B_OWNER=B
GOOD_B_READ=X
GOOD_AFTER_B=0
GOOD_BACKING=0
BAD_START=2
BAD_AFTER_A=1
BAD_B_OWNER=B
BAD_B_READ=0
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

Require exact line equality and verify:
- good setup starts at count 2;
- good A release leaves count 1, B owner B, and backing read X;
- good B release reaches count 0 and backing becomes 0;
- bad setup also starts at count 2;
- bad A release leaves count 1 and B owner B, but B read is cleared 0.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- one backing storage byte exists;
- good A release decrements count but does not unconditionally clear backing;
- good B/final release clears backing only on zero count;
- bad A release clears backing while its resulting count is still 1.

## Evidence contract

Use the standard C003 freestanding evidence contract: separate mechanism/fixture/linker/launcher/evaluator; stable run directory; exact source/tool hashes; 512-byte `55aa` image; exact QEMU PID/argv/times/exit; bounded timeout; debug/evaluator artifacts and hashes; durable receipt; non-mutating post-run closure. Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P16 succeeds only on exact preregistered raw output, QEMU success exit, evaluator pass, and static/source closure.

## Authority ceiling

Success would establish only that this one backing value shared by two bindings needs an explicit lifetime condition to survive release of one binding.

It would not establish garbage collection, a heap, general reference counting, cycle handling, ownership types, concurrency lifetime safety, use-after-free protection in general, a Manager primitive, or architecture promotion.

## Stop rule

Reconcile P16 before deriving P17. P17-P20 remain unwritten until P16 consequence earns the next discriminator.
