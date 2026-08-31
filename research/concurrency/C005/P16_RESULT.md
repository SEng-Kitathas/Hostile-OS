# C005/P16 result — bounded participation count wrap versus no users

Status: **CLOSED PASS**
Implementation commit: `f87ff89`
Controlling run: `P16/runs/20260831T054018Z_c005_p16_01`

Bad path started usersFF and performed one unchecked atomic increment, wrapping to00 (`BAD_WRAP=1`). BSP interpreted00 as no in-flight users, reclaimed, and active AP observed value00.

Good path treated usersFF as explicit finite exhaustion: acquisition returnedF, users remainedFF, reclaim stayed disallowed, and value remained7E.

Earned: `BOUNDED_PARTICIPATION_WRAP != NO_USERS`. If zero authorizes reclaim, finite participation accounting needs explicit overflow/exhaustion behavior rather than arithmetic wrap.
