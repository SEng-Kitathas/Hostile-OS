# H1-SMP-MIN02 Amendment A — bad-phase report timing

Status: **REPORTING-TIMING AMENDMENT AFTER NON-CONTROLLING RUN**
First run: `runs/20260831T060112Z_h1_smp_min02_01`

The first sealed run preserved all existing-body regressions and fit the envelope, but S-mode trace printed `BAD=W11` instead of expected `BAD=W01`.

Cause: the bad call status was saved, then the candidate reset/rebuilt state for the good phase. Only after the good phase did the reporter inspect row0/row1 to derive BAD bound bits, so those bits described the later good state.

Correction:
- print TEST/IDS after AP-ready;
- print BAD status/row-state immediately after the bad call and before good reset;
- print GOOD after the guarded phase;
- no relation transition, gate behavior, setup, AP coordination, expected trace or acceptance criterion changes.

The first run remains admitted as **NON_CONTROLLING REPORT-TIMING FAILURE**. It is not recolored as PASS.
