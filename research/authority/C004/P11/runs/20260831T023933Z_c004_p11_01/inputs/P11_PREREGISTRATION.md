# C004/P11 preregistration — revocation/currentness inside protected mediator

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P10 CLOSED PASS

## Question

Does authority generation/currentness remain necessary once authority state is protected and all use is mediated?

## Fixture
- ring3 context trusted as B;
- ring0 B authority record: READ, generation1;
- resource X current/value7E;
- first mediated READ supplies B authority generation1 and succeeds;
- trusted fixture revokes B by clearing rights and advancing authority generation to2 without changing resource currentness.

## Good mediator after revoke
Old generation1 READ -> U/00; resource generation/epoch remain1/1.

## Bad mediator control
Ignores authority generation/rights and checks only current resource -> W/7E.

## Ceiling
If observed, P11 confirms authority currentness/revocation is independent of both resource currentness and the protection boundary. It does not fix generation width or revocation graph semantics.
