# C004/P08 preregistration — operation-specific authority across enforcement boundary

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P07 CLOSED PASS

## Question

Once direct mutation is blocked by a real privilege boundary, does the P02 READ-vs-WRITE authority distinction remain necessary inside the trusted mediator?

## Fixture

- ring3 caller B;
- ring0 resource X=7E;
- ring0 authority state gives B READ only;
- direct ring0-data selector acquisition remains forbidden.

## Good mediated operations

Ring3 issues explicit mediated requests:
1. READ X -> expected W/7E;
2. WRITE X=55 -> expected U; X remains7E.

## Bad mediator control

A separate mediated WRITE path checks only a binary `allowed` fact that is true because B is allowed to read X.

Expected:
- bad mediated WRITE55 -> W; X becomes55.

## Discriminator

One protected-mode boot must show:
- privilege boundary still active;
- good read succeeds;
- good write rejects and preserves X;
- binary-allow mediator over-authorizes the write.

## Ceiling

If observed, P08 establishes that hardware privilege enforcement and operation-specific authority solve different responsibilities and must not be collapsed. It does not prescribe the encoding of rights or the syscall/interrupt mechanism.
