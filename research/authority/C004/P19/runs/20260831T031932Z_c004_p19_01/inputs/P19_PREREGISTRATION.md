# C004/P19 preregistration — protected two-caller whole-workload composition

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P18 CLOSED PASS

## Question

Can the independently earned authority distinctions compose in one protected workload with two actually distinct ring3 caller domains, without collapsing into a Process/credential/security-manager bundle?

## Fixture
- caller A executes from one ring3 code selector; caller B executes from a different ring3 code selector;
- mediator derives caller provenance from the CPU-saved user CS on the privilege transition, not a caller-supplied ID;
- resource X current/value7E/live-count2;
- A starts READ+WRITE;
- B starts with no authority.

## Sequence / required consequences
1. A direct kernel-data access attempt -> #GP.
2. A READ -> W/7E.
3. A attenuates/delegates READ-only to B -> D; B rights01.
4. A queues delayed WRITE55 while WRITE-current -> Q with authority provenance.
5. A WRITE authority is revoked/currentness advances.
6. queued apply revalidates -> U; X remains7E.
7. mediator switches to B by changing the protected return frame.
8. B direct kernel-data access attempt -> #GP.
9. B READ -> W/7E.
10. B WRITE -> U; X remains7E.
11. mediator switches back to A.
12. A revokes B authority only; resource live count remains02.
13. A READ remains W/7E despite B's earlier denied write/revocation.
14. clean exit33.

## Bad/weak consequences embodied in the sequence
- operation attenuation matters because B WRITE must stay unauthorized;
- request-time authorization cannot survive A's revocation into delayed application;
- B authority revocation must not reclaim X;
- B's denied operation must remain local and not poison A's later valid read;
- caller identity comes from the protected boundary, not an untrusted claim.

## Ceiling
PASS would show bounded composition of the current authority grammar under one two-caller protected workload. It would not establish completeness, optimality, SMP/IOMMU/DMA/NMI security, a final ABI, or architecture promotion.
