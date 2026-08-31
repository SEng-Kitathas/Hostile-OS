# C004/P01 preregistration — currentness is not caller authority

Status: PREREGISTERED BEFORE IMPLEMENTATION

## Question

If a checked relation API accepts a target activity handle but carries no separate caller identity/authority relation, can another activity that knows the target's current handle exercise the target's current binding even though the relation is not its own?

## Minimal fixture

- activity A: slot0, generation1, epoch1;
- activity B: slot1, generation1, epoch1;
- resource X: slot0, generation1, epoch1, value `0x7e`;
- binding row for A cell0 -> X, binding generation1;
- B has no binding to X;
- both A and B are current.

## Good mechanism candidate

The checked read receives two independently represented facts:
- caller activity handle;
- target/binding activity handle.

Before reading the binding, it requires caller handle to be current **and** caller identity to equal the activity whose binding row is being exercised.

Expected:
- A calling A's binding -> `W`, value `7E`;
- B calling A's binding -> `U` (unauthorized), value `00`.

`U` is a local experiment status meaning only “caller relation not authorized for this operation.” It is not an architecture-level error taxonomy.

## Bad control

A currentness-only read validates only the supplied target activity/binding/resource handles and has no caller relation.

Expected:
- B supplying A's exact current target/binding handle -> `W`, value `7E`.

## Discriminator

P01 passes scientifically only if all three consequences appear in one freestanding run:

1. owner/current call succeeds;
2. separate-current B call is rejected by the caller-aware path;
3. the same B context succeeds through the currentness-only bad control using A's exact current handle.

## Interpretation ceiling

If observed, P01 earns only:

`CURRENTNESS_ALONE_DOES_NOT_ENCODE_CALLER_AUTHORITY` for this bounded cooperative API fixture.

It does **not** prove security against arbitrary untrusted machine code, because all code may still share one privilege/address domain and bypass the checked API. That enforcement question must remain open for a later pass.
