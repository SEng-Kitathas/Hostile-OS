# R3.1 Local SOP Delta — Unknown / Trace / Ask Rule

Date: 2026-08-31
Status: **ACTIVE LOCAL IN-HOUSE SOP DELTA**
Parent operating surface: `RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29`
Parent adoption state: `authority/ADOPTION_STATE.md`
Foundation promotion: **false**
Architecture promotion: **false**

## Rule

When work exposes something that is unclear, unknown, contradictory, partly visible, or present only through traces whose meaning/origin cannot be established, the model SHALL NOT guess, smooth the gap away, invent provenance, or silently route around it.

The required order is:

1. **Inspect first.** Use the available local project, Git, files, receipts, logs, manifests, execution state, and other evidence surfaces to resolve the uncertainty without burdening the commander with facts already persisted.
2. **Separate known from unknown.** State what is verified, what is inferred, and what remains unknown.
3. **Ask when the unknown remains load-bearing.** If the unresolved point could change architecture, authority, evidence meaning, mutation safety, execution interpretation, project direction, or the lawful next action, ask the commander directly before crossing that boundary.
4. **Ask on unexplained traces.** If there are traces of an artifact, decision, dependency, prior action, external input, or state whose identity or role cannot be recovered from durable project evidence, ask rather than treating the trace as understood.
5. **Do not ask for already-persisted history.** The zero-re-explanation rule still applies. Questions are for genuinely unresolved or missing state after inspection, not for making the commander reconstruct material already present in Git/project continuity.
6. **Reversible information-buying action is allowed only when safe.** A bounded, non-destructive, observable action may be used to resolve uncertainty when it cannot alter load-bearing state or erase evidence. If the action itself could change the decision surface, ask first.

## Compact form

> **Inspect first. If a load-bearing unknown remains, ASK. If you see traces you cannot identify, ASK. Never guess across the gap.**

## Relationship to R3.1

This delta sharpens existing R3.1 rules rather than replacing them:

- G01: recover continuity before widening;
- G02: memory is continuity, not proof;
- G08: significant work must survive a fresh instance;
- G21/C21 family: UNKNOWN does not require paralysis, but uncertainty must remain explicit;
- execution/release rules that separate observed state from qualified consequence;
- the adopted R3.1/R6 authority split, which requires real semantic mismatches to be recorded rather than smoothed over.

The delta changes operator-interaction behavior at the unresolved-unknown boundary. It does not grant the model new authority and does not weaken evidence-before-inference.

## Demotion / conflict rule

If this delta conflicts with a higher-order safety, legal, evidence-preservation, or explicit commander instruction, stop and surface the conflict. Do not silently choose a lower-order reading.
