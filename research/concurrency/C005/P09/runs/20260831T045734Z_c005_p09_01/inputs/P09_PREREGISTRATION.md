# C005/P09 preregistration — cross-CPU revocation versus delayed effect

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P08 CLOSED PASS
Cross-domain parent: C004/P17 request-time versus effect-time authorization

## Question

Does the C004 rule `REQUEST_AUTHORIZED != EFFECT_CURRENTLY_AUTHORIZED` still carry when authorization is accepted on one CPU and another CPU revokes that authority before effect application?

## Fixture

Resource X begins7E. AP acts as the delayed-effect executor. BSP owns the authority state.

AP first observes current WRITE authority generation1 and records request accepted for value55.

BSP then revokes WRITE and advances authority generation to2 before signaling AP to apply.

## Bad control

AP trusts only its cached request-time authorized bit and applies55. Expected `BAD_APPLY=W`, `BAD_VALUE=55`.

## Good witness

Reset X=7E and authority generation1/WRITE. AP again accepts request, BSP revokes+advances generation, and only then signals application. AP revalidates current generation+WRITE at effect time. Expected `GOOD_APPLY=U`, `GOOD_VALUE=7E`.

## Ceiling

PASS primarily reinforces C004/P17 under tested QEMU x86 SMP. It earns no new authority primitive unless the multicore fixture exposes an additional distinction. It does establish that the temporal revalidation responsibility is not merely a one-core scheduling artifact at tested scope.
