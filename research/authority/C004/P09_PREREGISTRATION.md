# C004/P09 preregistration — caller identity must not be an untrusted claim

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P08 CLOSED PASS

## Question

If the mediator enforces correct per-operation rights but chooses the caller identity from an untrusted request field, can ring3 B claim to be A and obtain A's WRITE authority?

## Fixture

- trusted authority table: A has READ+WRITE, B has READ only;
- the only ring3 execution context in the test is B;
- resource X starts7E;
- privilege boundary from P07/P08 remains active.

## Good mediator

The trusted gate derives caller identity from trusted entry context for this fixture (`caller=B`) and ignores an untrusted claimed identity field.

B requests WRITE55 while claiming A:
- expected U;
- X remains7E.

## Bad mediator control

The bad gate indexes the same correct authority table using ring3's supplied `claimed_caller=A`.

Expected:
- WRITE55 -> W;
- X becomes55.

## Discriminator / ceiling

If observed, P09 earns that authority checks require caller provenance anchored in the enforcement context, not merely an identity value supplied by untrusted code.

It does not determine the general representation of execution identity, authentication, credentials, or process structure.
