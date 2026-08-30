# C003 / P12 — finite-width generation wrap versus stale-token alias

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P12 of 20
**Architecture promotion:** NONE
**P13 earned:** YES

## Question

After exactly 256 generation increments from zero, can a stale generation-0 token falsely appear current when the generation is stored in 8 bits, while a wider explicit generation representation under the same increments avoids that alias and rejects the stale token?

## Controlling preregistration

`C003_P12_PREREGISTRATION.md` was sealed at Git commit `a0814524b7e478c391549aaa083dbc8ac36a75e4` before any P12 mechanism code or execution existed.

## Controlling scientific run

Run: `20260830T021000Z_p12_generation_wrap_01`

QEMU:
- PID: `27720`
- started: `2026-08-30T02:10:29.969356+00:00`
- ended: `2026-08-30T02:10:30.178544+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator exit: `0`.
Evaluator stderr: empty.

## Exact raw observation

```text
COUNT_HI=1
COUNT_LO=0
STALE_TOKEN=0
NARROW_GEN=0
NARROW_STALE=A
WIDE_HI=1
WIDE_LO=0
WIDE_FRESH=A
WIDE_STALE=R
DONE
```

Evaluator version: `C003-P12-generation-wrap-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `6adea7b95872bb70c43106891fc4584fade0e8afcf62251d6a962289e0705e74`
- fixture: `ba5f4a1af0d0a734115ab522f6f1d9b6312fc381b5b6ec025c5ae0d281219251`
- linker: `cc617cc704034973a3af154f2c20f281f3dd97fdff8878754c77fadfad345d15`
- evaluator: `5832b866507beee908955a10601ccab9ab9e83c0d0244a8ea16bad9a63cf9558`
- launcher: `90edd6cb6bbe185cd9239eddd8d2ff4ec3c8df17422d38d5ee98acd2265a9ca2`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `2419585c416af69f1af6b3cec488c144dc1ce1eab2ac4ded2f6f8f198e4d0412`
- debugcon SHA-256: `f462f058c2880a1e555d9ccf22da1f57b214a16714028ad12a0bfca3c30ac836`
- evaluation SHA-256: `d6a0ee46ba20943e5f88b52a3c35420c7dcbb551efef05812385667d87e63958`
- receipt SHA-256: `3633d9866a47f73ad5dd6a9dccdde4a7ecd8a61565377ab5517b5ecd307067c3`
- evaluator stdout SHA-256: `400bd22ea413439706aa7383abaa939271b527a5ff04e7471f79a0023a314af1`
- all QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating closure matched all five source hashes, seven recorded run-artifact hashes, the exact raw matrix, evaluator pass state, and QEMU `COMPLETED/33` state.

Static source inspection also confirmed that `generation8` and `generation16` are incremented once each inside the same loop whose counter is loaded from `increment_count_fact`. The two widths therefore experienced the same 256-step history.

## Qualified consequence

For this exact 256-increment history from generation zero:

- the 8-bit generation wrapped modulo 256 back to `0`;
- stale token `0` therefore compared equal and was falsely accepted as current;
- the 16-bit generation reached `0x0100` under the same loop;
- a freshly snapshotted 16-bit token compared equal and was accepted;
- stale token `0` compared unequal to `0x0100` and was rejected;
- finite-width generation choice is therefore a real low-level burden that Python's arbitrary-width integer behavior can hide if wrap is not modeled explicitly.

The successful wide path was not a reject-all control because it accepted its fresh token before rejecting the stale token.

## Authority ceiling / nonclaims

P12 does **not** establish:
- that 16 bits is generally sufficient;
- wrap-free generations at arbitrary lifetime;
- general ABA freedom;
- monotonic-clock semantics;
- cryptographic uniqueness;
- a complete replacement for arbitrary-width integers;
- allocator, process, scheduler, or manager architecture;
- architecture promotion.

A 16-bit generation still wraps after 65536 increments unless another rule exists. P12 exposes the width/wrap design burden; it does not solve that burden universally.

## Pareto / ontology consequence

The tested 256-step history did not require a big-integer runtime. A wider fixed field was enough to avoid this specific alias, but that buys only a larger modulus, not infinity.

Future design therefore has to choose among bounded width, explicit rollover handling, stronger identity composition, or another mechanism based on actual lifetime/cost pressure. No such choice is promoted by P12 alone.

## P13 discriminator earned by P12

A high-value remaining host subsidy is **automatic/default initialization and clean object construction on reuse**.

Python object creation made fresh fields start from explicit constructor/default values rather than arbitrary stale bytes from a previously used record. A fixed freestanding slot can be reused without any such automatic reset.

P13 should pressure the smallest reuse discriminator:
- one fixed record slot is first owned by A and deliberately leaves non-default relation fields such as waiting, continuation, and progress;
- the slot is released without erasing those bytes;
- a good reuse path explicitly initializes every load-bearing field when assigning owner B and must observe clean defaults;
- an owner-only bad control assigns B but leaves the old relation fields intact and must expose stale-state carryover;
- no allocator or object system is required for the test.

P13 must remain a fixed-slot initialization/lifetime discriminator, not a general memory allocator or object-lifetime architecture claim. P14-P20 remain unwritten.
