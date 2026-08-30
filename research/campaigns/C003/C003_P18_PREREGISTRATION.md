# C003 / P18 preregistration — explicit two-byte serialization convention

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P18 of 20
**Earned by:** C003/P17 bounded stale-handle success
**Architecture promotion:** FORBIDDEN

## Why P18 exists

P17 closed one fixed-slot reuse alias by making current generation explicit.

Another host subsidy is **serialization/conversion convention**. A host integer and helper library can hide the exact stable byte representation. Freestanding persistence or interchange needs explicit bytes and an explicit decode rule.

P18 isolates only a two-byte representation convention.

## Fixture responsibility

The fixture supplies one logical 16-bit word only:
- `logical_word = 0x1234`.

The fixture SHALL NOT supply encoded bytes, decoded results, byte order, or grading.

## Canonical encoder

`encode_le` loads the fixture word and writes exactly two serialization bytes:
- byte 0 = low byte `0x34`;
- byte 1 = high byte `0x12`.

The encoded storage is exactly two bytes.

## Good decoder

`decode_le` reconstructs a 16-bit word from the same encoded bytes by taking:
- low byte from encoded byte 0;
- high byte from encoded byte 1.

Result must be `0x1234`.

## Swapped negative control

`decode_swapped` uses the same two encoded bytes but reverses their roles:
- high byte from encoded byte 0;
- low byte from encoded byte 1.

Result must be `0x3412`.

## Exact raw guest observation contract

Hex output uses uppercase hexadecimal digits with no prefix:

```text
ENC0=34
ENC1=12
GOOD=1234
BAD=3412
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

Require exact line equality and verify:
- encoded bytes are exactly 34/12;
- good decode is exactly 1234;
- bad swapped decode is exactly 3412.

## Static/source closure requirement

Post-run inspection SHALL confirm:
- exactly two encoded storage bytes exist;
- encoder derives both bytes from the one fixture word;
- good decoder reads encoded byte 0 into low position and byte 1 into high position;
- bad decoder reads the same two bytes in the opposite roles.

## Evidence contract

Use the standard C003 freestanding contract: separate mechanism/fixture/linker/launcher/evaluator; stable run directory; exact source/tool hashes; 512-byte `55aa` image; exact QEMU PID/argv/times/exit; bounded timeout; debug/evaluator artifacts and hashes; durable receipt; non-mutating post-run closure. Timeout or ambiguous process state = UNKNOWN.

## Authority ceiling

Success would establish only that this one two-byte logical value requires an explicit representation convention and that swapping the convention changes the decoded value.

It would not establish a general serializer, filesystem format, ABI, network protocol, cross-architecture portability, disk format, schema system, or architecture promotion.

## Stop rule

Reconcile P18 before deriving P19. P19-P20 remain unwritten until P18 consequence earns the next discriminator.
