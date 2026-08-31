# C004/P13 preregistration — unauthorized failure locality under protected mediation

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P12 CLOSED PASS

## Question

After B receives a local unauthorized result for WRITE, can a later independently authorized READ still proceed, or does a global authority-failure latch incorrectly poison later progress?

## Fixture
- protected ring3 B context;
- B READ only to X=7E.

## Good mediator
1. B WRITE55 -> U, X7E;
2. later B READ -> W/7E.
Unauthorized failure is local to the rejected operation.

## Bad control
1. bad WRITE denial also sets `global_auth_failure=1`;
2. bad later READ checks the latch first -> `G`/00 despite B still having READ authority.

## Ceiling
If observed, P13 earns local authority failure propagation for this bounded sequence. It does not rule out system-wide failure states for genuinely global faults.
