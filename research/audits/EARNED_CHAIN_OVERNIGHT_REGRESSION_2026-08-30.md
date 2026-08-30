# Earned-Chain Overnight Regression Audit — 2026-08-30

Status: COMPLETED / MIXED RESULT / NEW REVISIT SEAM
Source campaign: `.pcmmad_sync_runs/overnight/campaign_20260830T063648Z`

## Terminal campaign result
- cycles: 3304
- passes: 22463
- failures: 660

Per fixture:
- A01: 3304 PASS / 0 FAIL
- RK01: 3304 PASS / 0 FAIL
- RB02: 3303 PASS / 0 FAIL
- ARB01: 3303 PASS / 0 FAIL
- RR01: 3303 PASS / 0 FAIL
- IRQ01: 3303 PASS / 0 FAIL
- I001: 2643 PASS / 660 FAIL

## I001 failure classification
All 660 observed failures classify to the I001 exact evaluator. Representative retained failure artifacts show:
- Boot1 scientific status `COMPLETED`, exit 33
- Boot2 scientific status `COMPLETED`, exit 33
- static closure PASS
- durable-state/readback checks PASS
- evaluator FAIL because observed trace contains `IRQ_EVENT=2` while the controlling exact expected trace encodes `IRQ_EVENT=1`

No other fixture produced a campaign failure.

## Current interpretation
The campaign demonstrates a long-replay sensitivity in I001 around the exact count/timing of real IRQ0 observations. It does **not**, by itself, establish an I001 mechanism failure because the boot/process/static/durable closure surfaces remain successful in the retained failures. Conversely, the 660 reds must not be erased as “just evaluator noise” without a new discriminator.

The correct status is unresolved: whether exactly one timer event is semantically required or merely incidental to the original trace must be preregistered and tested separately.

## Anti-regression rule
Do not:
- retroactively change the historical I001 evaluator and recolor the original controlling run;
- demote I001 solely because the count `660` is large;
- ignore the failures because most repetitions passed;
- reintroduce a simulator/fixture that removes the real IRQ timing pressure just to restore green output.

Do:
- preserve the campaign journal and representative/full failure evidence;
- create a dedicated discriminator if this seam becomes P0;
- distinguish timer-event cardinality from the load-bearing state transitions I001 was intended to qualify.
