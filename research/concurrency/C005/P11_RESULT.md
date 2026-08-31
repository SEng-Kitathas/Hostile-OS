# C005/P11 result — unchecked snapshot versus version-validated snapshot

Status: **CLOSED PASS**
Implementation commit: `94a0db0`
Controlling run: `P11/runs/20260831T050211Z_c005_p11_01`

The bad reader sampled A during the writer's in-progress interval and B only after completion, crossing one state transition without detecting it (`BAD_CROSSED=1`).

The good reader used one version byte: odd meant writer active, even meant quiescent; it retried after forced overlap and accepted only when pre/post versions matched and were even. It accepted33/44 at version02 (`GOOD_RETRY=1`, `GOOD_ACCEPT=1`).

Earned: read-only observation can avoid writer exclusion in this tested single-writer case if overlapping writes are detectable and the reader retries until a stable versioned snapshot. No multi-writer safety or lock-free progress is earned.
