# C005/P12 result — versioned readers versus multiple writers

Status: **CLOSED PASS**
Implementation baseline commit: `3fa5e22`
Reporting Amendment A commit: `0979598`
Controlling run: `P12/runs/20260831T050353Z_c005_p12_01`

Bad phase deliberately overlapped two writers. While both were active (`BAD_ACTIVE_WRITERS=02`), independent version increments produced even version02 (`BAD_EVEN_WHILE_ACTIVE=1`), invalidating P11's single-writer interpretation that even means quiescent.

Good phase atomically serialized writers. Maximum simultaneous writers remained1; both writers completed and final version04.

Earned: the P11 versioned-reader protocol requires a separately enforced single-writer condition when multiple CPUs may write. The first run's debug-print register-lifetime defect is retained and non-controlling.
