# GitHub publication and bounded execution doctrine — 2026-08-30

## Operator directives

1. Publish HOSTILE-OS to `https://github.com/SEng-Kitathas/Hostile-OS.git`.
2. Treat the Git repository as a date/time-stamped project record, including research and continuity artifacts, not code alone.
3. Keep OS installation/code retrieval possible without forcing users to download the research corpus.
4. Push the repository at the end of each substantive pass.
5. Adopt the bounded-execution recovery doctrine reported from another PCMMAD thread:
   - one bounded action per control turn;
   - short timeouts / bounded waits;
   - no chained tool bursts as the default execution pattern;
   - persist intent/state before expensive work;
   - missing tool return => `UNKNOWN`, never silent success or blind retry;
   - whole-suite or long-running work should be submitted as a server job with journal/checkpoint surfaces and read back separately.

## Operational interpretation

- GitHub `main` is the external project-history surface.
- Research remains versioned in the same repository under `research/` and related continuity/evidence paths.
- A separate code/install export surface SHALL be provided so cloning/installing the OS does not require transferring the research history/tree when the user wants a minimal install-oriented checkout.
- End-of-substantive-pass procedure:
  1. reconcile current state;
  2. commit the bounded pass with exact lineage;
  3. push `main` to the configured GitHub remote;
  4. read back local HEAD and remote branch tip;
  5. report push status as VERIFIED / UNKNOWN / FAILED.
- A missing, dropped, or incomplete tool response is always `UNKNOWN` until separately read back.
- Long tests/suites should use `submitProjectExecution` with journaling/checkpointing, followed by a separate `waitForProjectExecution` / status/output readback.

## Scope

This is execution/publication doctrine. It does not promote HOSTILE-OS architecture, scientific results, or R3.1/R6 foundation authority.
