# Per-turn semantic and hash freshness policy

Adopted: 2026-08-31
Status: **ACTIVE / COMMANDER-DIRECTED**
Extends: `continuity/11_PER_TURN_GITHUB_CONTINUITY_POLICY.md`

## Commander's directive

Every meaningful turn SHALL keep current:
- every newly load-bearing decision;
- every new piece of research or adjudication that changes project belief;
- the living Commander's Intent surface;
- all active continuity/reincarnation surfaces;
- the recoverable chronological thread.

The objective is that a fresh thread or future operator can resume from Git without asking the commander to reconstruct missing intent, nuance, decisions, research state, or frontier.

## Freshness means reconciliation, not historical rewriting

Two classes are mandatory.

### A. Living semantic surfaces

These SHALL be reconciled on every meaningful turn and rewritten/extended when truth changed:
- `continuity/01_COMMANDERS_INTENT.md`;
- `continuity/02_CURRENT_STATE_AND_FRONTIER.md`;
- `continuity/10_ENGINEERING_DECISION_LEDGER_2026-08-30.md`;
- `continuity/LIVE_SHADOW.md`;
- `continuity/DESIGN_THREAD_STREAM.md`;
- `handoffs/THIS_CONVERSATION.md`;
- current revisit/trace/next-step/doctrine surfaces when present;
- `handoffs/CURRENT_REINCARNATION/` copies and manifest.

A turn with no semantic delta MAY leave a living file's bytes unchanged only after explicit reconciliation. The per-turn freshness manifest records that as `verified_unchanged`, not silently ignored.

### B. Sealed/historical surfaces

Sealed experiment packets, historical receipts, scars, prior campaign results, frozen original intent, and prior evidence SHALL NOT be rewritten merely to carry a new timestamp.

Instead each meaningful turn SHALL hash-attest the continuity tree and record that historical surfaces were present and unchanged. New interpretation is append-only: add an adjudication, supersession, adoption, demotion, or current-state pointer.

Therefore:

`FRESHNESS != REWRITE_EVERYTHING`

and:

`HISTORICAL_IMMUTABILITY + CURRENT_INDEX_REFRESH = PER_TURN_CONTINUITY`

## Mandatory turn-close sequence

Before a meaningful assistant turn is considered closed:
1. re-read canonical Git HEAD/status and current Live Shadow;
2. reconcile the current user request with recent thread and current project state;
3. identify decision delta, research delta, Commander's Intent delta, frontier delta and blockers;
4. update the relevant living semantic surfaces;
5. append the user/assistant exchange or high-fidelity operational record to DTS and conversation handoff;
6. refresh the reincarnation package from canonical living sources;
7. generate `continuity/CURRENT_TURN_FRESHNESS.json` containing exact hashes of the full `continuity/` file set and explicit semantic-status entries;
8. run `tools/check_per_turn_freshness.py`;
9. stage exact paths, run `git diff --cached --check`, commit;
10. verify reincarnation hashes from committed Git objects;
11. run durable-repository gate;
12. publish complete admitted delta to GitHub and independently read back remote SHA;
13. report canonical SHA, remote publication SHA, unresolved blockers and any UNKNOWN tool surface.

If publication is impossible, local canonical commit remains authoritative and publication is explicitly FAILED/UNKNOWN until later recovery.

## Required machine-readable semantic fields

`CURRENT_TURN_FRESHNESS.json` SHALL include:
- schema/version;
- UTC generation time;
- pre-turn canonical HEAD;
- turn intent summary;
- mode and role;
- current frontier;
- decision deltas;
- research deltas;
- Commander's Intent deltas;
- blockers;
- living-surface status;
- SHA-256 + byte count for every file currently under `continuity/` except the manifest itself.

## Anti-regression

- Never use a fresh timestamp to imply a stale document was semantically reviewed unless it was actually reconciled.
- Never rewrite sealed research/evidence merely to satisfy freshness theater.
- Never let a new decision exist only in chat.
- Never let a research result exist only in a run directory without current-state/index admission.
- Never let Commander intent changes live only in conversation.
- Never close a meaningful turn with a known stale Live Shadow, DTS, handoff or reincarnation package.
