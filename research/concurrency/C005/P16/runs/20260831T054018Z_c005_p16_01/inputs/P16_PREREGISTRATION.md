# C005/P16 preregistration — bounded participation count wrap versus no users

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P15 CLOSED PASS
Cross-domain parent: P08 in-flight participation constrains reclaim

## Question

If concurrent lifetime protection uses a bounded participation count, may arithmetic wrap make a nonzero/full participation state look like zero users and therefore permit unsafe reclaim?

## Fixture

Use an 8-bit `users` field as the deliberately bounded representation. Resource generation1/value7E. The fixture starts with `users=FF`, representing the maximum encodable outstanding participation already admitted by the representation. AP attempts one additional use.

## Bad control

AP performs unchecked atomic increment `FF + 1 -> 00` and begins using the resource. BSP interprets users00 as no in-flight users and reclaims/reuses the resource as generation2/value00.

Expected: `BAD_WRAP=1`, `BAD_RECLAIM=1`, AP observes00 while active.

## Good witness

Reset usersFF. AP performs a checked acquire: if usersFF, acquisition fails explicitly and no wrap/state change occurs. BSP sees usersFF, so reclaim remains disallowed. Expected `GOOD_ACQUIRE=F`, `GOOD_USERS=FF`, `GOOD_RECLAIM=0`, value remains7E.

## Ceiling

PASS earns only `BOUNDED_PARTICIPATION_WRAP != NO_USERS` and that finite participation state needs explicit overflow/exhaustion behavior if zero carries reclaim meaning. It does not prescribe reference counting, field width, dynamic allocation or unbounded concurrency.
