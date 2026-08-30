# C003 / P15 — fixed-capacity exhaustion versus overwrite-on-full

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P15 of 20
**Architecture promotion:** NONE
**P16 earned:** YES

## Controlling preregistration

`C003_P15_PREREGISTRATION.md` was sealed at Git commit `9b15d9150f22cc19225250056c2b13fe96b90f9d` before P15 source or execution existed.

## Controlling run

Run: `20260830T021800Z_p15_capacity_01`

QEMU:
- PID `27952`
- start `2026-08-30T02:17:37.226741+00:00`
- end `2026-08-30T02:17:37.455387+00:00`
- status `COMPLETED`
- exit `33`

Evaluator exit `0`; QEMU/evaluator stderr empty.

## Exact raw observation

```text
GOOD_A=W
GOOD_B=W
GOOD_C=F
GOOD_SLOT0=A
GOOD_SLOT1=B
BAD_A=W
BAD_B=W
BAD_C=W
BAD_SLOT0=C
BAD_SLOT1=B
DONE
```

Evaluator `C003-P15-fixed-capacity-v1`: `passed=true`.

## Exact source hashes

- mechanism `0b91facc90b2f018e9b852b882eeaf6dace4ffc1372c42fe840afd06cbbd86af`
- fixture `8b402bdaa16e70b5a041c702ed0dcf4d257dc755e3c7f24f1f87e84602c4e0e7`
- linker `7dd4bc9077c0c6fc6f8642c3b6afb8d6430dc2684962bd0cc1aa76c25a1ec309`
- evaluator `a0e30b91dc7cce6a5ca5745804319e09e8e73faeac8edcb534feeda35c6f4578`
- launcher `c42d4d239e6ac0b14df24dfc757a0129e31c4645c8547234992c22cb3edc4022`

## Exact run hashes

- boot `15ad2e31f3bd903fcbd485a4c7e60cf09b54c24d987384267e7071be2798dfe5`
- debugcon `49cdd4be7fc889d6eab18e22acf9c5a9968c1b42261b73a0bd268593e66c09b5`
- evaluation `ee8e275e7c3a47118be7c2ed0bea7c73f52c11bf755b74abe3961e2719b2f05e`
- receipt `8d8077d1a95bfcedabd6d24ba3221469ba66a4222644c3dc6f6d90f0a7e637b2`
- evaluator stdout `bd16dae08f7b846389ed52eb0bb4723f5f28ed01ed3e7150cd2fa01738c1b577`

Post-run closure matched every recorded source/run hash, exact raw output, evaluator pass, and QEMU `COMPLETED/33` state.

## Static/source closure

Inspection confirmed:
- exactly two slot bytes exist;
- no slot 2 exists;
- checked admission compares count to fixture capacity before indexed write;
- the checked full branch writes no slot;
- the bad full branch explicitly writes C to slot 0.

## Qualified consequence

For this two-slot store:
- A and B were admitted successfully;
- checked C admission returned bounded `F` and preserved A/B;
- the same full A/B state under overwrite-on-full admitted C only by destroying A, producing C/B;
- a hard capacity boundary therefore needs explicit behavior in freestanding state;
- dynamic growth is not automatically required for the bounded workload: explicit full failure is a coherent smaller result.

## Authority ceiling

No claim is earned about universal fixed capacity, heap/allocator requirement, dynamic arrays, eviction policy, arbitrary workload sizing, Process tables, Manager primitives, or architecture promotion.

## P16 discriminator earned by P15

A high-value remaining host subsidy is **automatic lifetime/reference handling**.

P16 should use one fixed backing value with two live bindings A and B:
- good path explicitly records live reference count 2;
- releasing A decrements to 1 and must preserve backing value X so B still reads X;
- releasing B decrements to 0 and may then clear/reclaim the backing byte;
- bad release-first control starts with the same two bindings but clears backing as soon as A releases, so B subsequently observes missing/cleared backing despite still being live.

The fixture may supply identities A/B and backing value X only. The mechanism must establish the two bindings and lifetime count. P16 must remain a fixed one-backing/two-binding lifetime discriminator, not a general GC, allocator, ownership language, or manager architecture. P17-P20 remain unwritten.
