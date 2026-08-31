# C005/P12 Amendment A — debug-print register lifetime

Status: REPORTING-ONLY AMENDMENT AFTER NON-CONTROLLING RUN

First science attempt `P12/runs/20260831T050327Z_c005_p12_01` reached the intended bad state and recorded `BAD_ACTIVE_WRITERS=02` and `BAD_VERSION_WHILE_ACTIVE=02`, but printed `BAD_EVEN_WHILE_ACTIVE=0`.

Cause: the implementation computed the even-version predicate in AL, then called `puts`, whose character loop legitimately clobbers AL, before calling `bit`.

Correction: preserve the computed predicate in BL across `puts`, then restore AL for `bit`.

No concurrency state transition, barrier, writer behavior, good control, expected evaluator trace, or scientific question changes. The first attempt remains retained and non-controlling.
