# C004/P06 preregistration — cooperative checked authority versus raw same-domain bypass

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P05 CLOSED PASS

## Question

Do the authority distinctions earned in P01-P05 actually prevent unauthorized mutation when mutually untrusted machine code shares the same privilege/address domain and can bypass the checked API?

## Fixture

- resource X begins7E;
- B is current but has READ only, no WRITE;
- checked write path enforces B's operation authority.

## Good/API consequence

B calls checked write55:
- expected U;
- X remains7E.

## Hostile bypass control

A separate code path representing arbitrary same-domain B code performs a direct machine store to the exact resource byte without calling the authority checker.

Expected:
- direct store executes;
- X becomes55.

No attempt is made to hide the address or encode a software secret. The point is to test whether the enforcement boundary exists at all.

## Discriminator

P06 passes if the checked mutation is denied but the raw same-domain store succeeds in the same freestanding boot.

## Interpretation

If observed, P06 establishes a hard ceiling on P01-P05:

`COOPERATIVE_AUTHORITY_CHECKS != PROTECTION_FROM_UNTRUSTED_CODE`.

That result would force the next pass to test an actual enforcement boundary (e.g. privilege/address/I/O separation or another mechanism that untrusted code cannot simply bypass). It does not preselect x86 rings, paging, a microkernel, or any historical protection architecture.
