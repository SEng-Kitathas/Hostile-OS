# C003 / P17 preregistration — stale handle after fixed-slot reuse

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P17 of 20
**Earned by:** C003/P16 bounded shared-lifetime success
**Architecture promotion:** FORBIDDEN

## Why P17 exists

P16 made shared backing lifetime explicit. After final release, fixed storage may be reused. Host object identity can hide a new low-level failure: an old reference does not normally become a reference to an unrelated new object merely because storage is reused.

P17 composes already-earned generation/currentness with one reused slot. It does not add a pointer manager or capability subsystem.

## Fixture responsibility

The fixture supplies facts only:
- old backing value X;
- new backing value Y;
- initial generation numeric 1.

The fixture SHALL NOT create handles, reuse the slot, compare generations, perform reads, or grade the result.

## Guest state

Exactly one backing slot contains:
- `slot_value`;
- `slot_generation`.

The mechanism also owns one stale-handle generation byte, one fresh-handle generation byte, and one observation byte.

## History

1. initialize the one slot to X at generation 1;
2. snapshot generation 1 into `stale_handle_generation`;
3. reuse the same slot by incrementing generation to 2 and replacing X with Y;
4. snapshot generation 2 into `fresh_handle_generation`.

No second backing slot is allowed.

## Checked currentness path

`checked_read(handle_generation)`:
- compare handle generation with current slot generation before reading slot value;
- if equal, read current value and return status `W`;
- if unequal, do not read slot value into the observation and return status `R`; observation becomes numeric zero.

Fresh generation-2 handle must therefore return `W` and Y.
Stale generation-1 handle must return `R` and observation zero.

## Address-only negative control

`address_only_read` uses the same fixed slot location but ignores handle generation.

When invoked for the old stale handle after reuse, it returns `W` and reads Y, demonstrating stale-handle retargeting to the new occupant.

## Exact raw guest observation contract

```text
OLD_GEN=1
NEW_GEN=2
FRESH_STATUS=W
FRESH_READ=Y
STALE_STATUS=R
STALE_READ=0
BAD_STATUS=W
BAD_READ=Y
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

Require exact line equality and verify:
- old generation is 1;
- reused slot generation is 2;
- fresh handle succeeds and reads Y;
- stale checked handle rejects and observation is 0;
- address-only stale control succeeds and reads Y.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- exactly one slot value and one slot-generation storage instance exist;
- checked read compares handle generation before its slot-value read;
- reject path does not copy slot Y into the observation;
- address-only bad read contains no generation comparison and reads slot value directly.

## Evidence contract

Use the standard C003 freestanding contract: separate mechanism/fixture/linker/launcher/evaluator; stable run directory; exact source/tool hashes; 512-byte `55aa` image; exact QEMU PID/argv/times/exit; bounded timeout; debug/evaluator artifacts and hashes; durable receipt; non-mutating post-run closure. Timeout or ambiguous process state = UNKNOWN.

## Authority ceiling

Success would establish only that one-byte generation currentness prevents this stale handle from silently retargeting to a new occupant of the same fixed slot.

It would not establish general pointer safety, arbitrary generation lifetime, capability security, memory protection, use-after-free safety in general, allocator design, ownership architecture, or architecture promotion.

## Stop rule

Reconcile P17 before deriving P18. P18-P20 remain unwritten until P17 consequence earns the next discriminator.
