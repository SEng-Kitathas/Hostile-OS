# I001/IRQCOUNT01 adoption — tested IRQ event-count semantics

Date: 2026-08-30
Status: ADOPTED AT TESTED SHADOW SCOPE
Science close: `0614b06` — `Close I001 IRQ event-count discriminator`

## Adopted rule

For the tested I001 real-IRQ0 wake/progress consequence, **exact count `1` is not load-bearing**.

The incumbent shadow rule is:

- event count must be within the tested set `{1, 2}`;
- the wait relation must be current/coherent;
- wake remains separate from explicit progress application.

Counts greater than 2 are not accepted by the living research verifier because IRQCOUNT01 did not test them. This is deliberately narrower than the preregistered mechanism predicate “nonzero event” and respects the authority ceiling of the actual experiment.

## Historical evidence disposition

The historical I001 exact evaluator remains unchanged and continues to require literal `IRQ_EVENT=1`.

The 660 overnight I001 exact-evaluator FAIL runs remain FAIL in their original records. Post-IRQCOUNT01 reconciliation adds the interpretation that all 660 differ from the expected Boot-1 trace only by `IRQ_EVENT=2`, with Boot 2 exact, and therefore do not demonstrate a mechanism regression for this tested consequence.

No evidence is recolored or deleted.

## Embodied research-OS effect

`os/research_only/i001_reference/verify.py` now accepts only event counts 1 or 2 as the tested semantic set and keeps `historical_exact_irq_event_one` as an informational field.

This is a reviewer/reproduction policy update, not a change to sealed historical science.

## Demotion / revisit triggers

Reopen if:
- count >2 appears in a meaningful replay;
- repeated IRQs change relation, wake, or progress behavior;
- event-counter wrap/saturation becomes relevant;
- IRQ loss/coalescing is introduced;
- stronger concurrency changes observation semantics;
- physical hardware behaves differently.

## Living verifier pressure test

After updating the research-only verifier, scratch receipt variants were used to test the policy boundary without changing sealed science:

- `IRQ_EVENT=1` -> verifier PASS;
- `IRQ_EVENT=2` -> verifier PASS while `historical_exact_irq_event_one=false`;
- `IRQ_EVENT=3` -> verifier FAIL on `irq_event_count_tested_1_or_2`.

This confirms the living reviewer gate implements the actual authority ceiling rather than silently generalizing “nonzero” to arbitrary multiplicity.
