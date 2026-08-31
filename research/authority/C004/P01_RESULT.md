# C004/P01 result — currentness is not caller authority

Date: 2026-08-30 local / run timestamp `20260831T022408Z_c004_p01_01` UTC
Status: **CLOSED PASS**
Implementation commit: `91d6688`
Controlling run: `P01/runs/20260831T022408Z_c004_p01_01`

## Result

One freestanding QEMU boot completed exit `33` and evaluator PASS 4/4.

Exact discriminator:

```text
OWNER_CHECKED=W
OWNER_VAL=7E
B_CALLER_AWARE=U
B_CALLER_AWARE_VAL=00
B_CURRENT_ONLY=W
B_CURRENT_ONLY_VAL=7E
```

A and B were both current. B had no binding of its own. When the checked path carried a separate caller handle and required the caller to match the activity whose relation was being exercised, B was rejected. When the bad control validated only A's target/binding currentness, B could supply A's exact current tuple and read the value.

## Earned consequence

At this bounded cooperative-API scope:

`CURRENT_REFERENCE != CALLER_AUTHORITY`

A current target handle proves currentness/applicability, not that the current caller is permitted to exercise it.

## Authority ceiling

P01 does **not** prove protection from arbitrary untrusted machine code. All code still executes in one privilege/address domain and could potentially bypass the checked function entirely. P01 therefore earns a semantic distinction inside mediated use, not an enforcement boundary.

## Next discriminator

A binary authorized/not-authorized relation may still be too coarse. P02 asks whether read and mutation authority must remain independently future-relevant when one caller is deliberately allowed to observe but not modify a resource.

## Provenance

Run-local inputs: 8/8 snapshotted before build/execution.
Stage2: 587 bytes, SHA-256 `c7f12ccd76360efb5f4349a83e326e382a363c66dedd33cdd091e163ec8785f7`.
