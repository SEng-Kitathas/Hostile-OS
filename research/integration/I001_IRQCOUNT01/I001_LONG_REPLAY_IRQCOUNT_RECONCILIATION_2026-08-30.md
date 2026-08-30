# I001 long-replay IRQ-count reconciliation — 2026-08-30

Status: RECONCILED AFTER I001/IRQCOUNT01 PASS
Source campaign: earned-chain overnight campaign `campaign_20260830T063648Z`

## Historical campaign population

The campaign journal contains 3303 I001 test executions:
- exact-evaluator PASS: 2643
- exact-evaluator FAIL: 660

All 660 retained I001 failure directories were inspected after IRQCOUNT01 closed.

## Failure-signature result

There is exactly **one** failure signature across all 660.

For every one of the 660:
- Boot 1 has the same line count and ordering as the historical expected Boot-1 trace;
- exactly one line differs: zero-based line index 13, historical `IRQ_EVENT=1`, observed `IRQ_EVENT=2`;
- every other Boot-1 line is exact;
- Boot 2 is exact with zero differences;
- historical evaluator is false because it requires the literal exact trace;
- static closure passed in the campaign record.

Machine reconciliation result:

```text
I001_FAILURE_DIRS 660
SIGNATURES 1
ONLY_IRQ1_TO_2_AND_BOOT2_EXACT True
COUNT 660 DIFFS (((13, 'IRQ_EVENT=1', 'IRQ_EVENT=2'),), ())
```

## Post-IRQCOUNT01 interpretation

IRQCOUNT01 independently demonstrated with real IRQ0 that count 1 and count 2 can produce the same accepted wait-relation/wake/progress consequence, while a two-event stale-relation negative control rejects.

Therefore the 660 historical reds are no longer an unresolved mixed “maybe mechanism, maybe evaluator” population for this consequence. They are **historical exact-evaluator overbinding** on the event-count field.

The original records remain unchanged:
- historical evaluator FAIL remains FAIL;
- campaign failure count remains 660;
- no run is recolored or deleted.

The new statement is interpretive and additive:

> At the now-tested count-1/count-2 semantic scope, the 660 traces do not demonstrate an I001 mechanism regression; their only trace difference is an event-count value that IRQCOUNT01 showed is not load-bearing when relation validity and downstream consequence remain correct.

## Scope ceiling

This reconciliation does not say any positive interrupt count is always acceptable. IRQCOUNT01 exercised counts 1 and 2 only. Counts greater than 2, interrupt loss/coalescing, saturation/wrap of the event counter, and stronger concurrency remain untested.
