# Bounded execution doctrine — 2026-08-30

Operator supplied a cross-thread recovery observation: dropped tool turns and incomplete return surfaces can affect both long-running work and the recovery/control path itself.

## Status

`ADOPTED_LOCAL_EXECUTION_DOCTRINE`

This is an execution/control doctrine. It does not alter HOSTILE-OS architecture authority or scientific results.

## Rules

1. Prefer one bounded server action at a time rather than chained tool bursts.
2. Use short synchronous timeouts for inspection, mutation, commit, status, and readback actions.
3. Persist intent/current state before expensive or failure-prone work.
4. Treat a missing, dropped, truncated beyond usefulness, or otherwise incomplete tool return as `UNKNOWN`; do not infer success from silence.
5. Do not silently retry the same failure-prone action pattern. Re-inspect state first and change the execution shape when needed.
6. Long whole-suite, broad scan, or otherwise expensive work SHALL be submitted as a server job when available, with journal/checkpoint surfaces enabled where useful.
7. After submitted work, read job status and output in separate bounded actions. Distinguish submitted, started, completed, failed, and registered.
8. Preserve large outputs server-side and bring back only bounded summaries/handles unless exact payload is load-bearing.
9. After mutation, commit, execution, publication, or registration, perform explicit readback before claiming success.
10. GitHub publication remains an end-of-substantive-pass obligation. Publication success requires remote `main` SHA readback equality with the publication-mirror commit.

## Failure interpretation

- Missing return != failure proof.
- Missing return != success proof.
- Missing return = `UNKNOWN` until state/readback establishes what actually happened.

## Interaction with experiment protocol

This doctrine strengthens but does not replace the existing run-input snapshot protocol. Scientific experiments still require their preregistered snapshot/manifest/receipt/evaluator/static/audit closure.

For long test suites, the preferred shape is:

1. persist preregistration / run intent;
2. submit server job with journal-on-submit and failure journaling;
3. read job status separately;
4. read bounded output separately;
5. register/load-bearing outputs only after completion is verified;
6. commit science/result/continuity separately;
7. publish the substantive pass to GitHub and verify remote SHA.

## Scope

Applies to this HOSTILE-OS PCMMAD thread from 2026-08-30 onward unless explicitly superseded.
