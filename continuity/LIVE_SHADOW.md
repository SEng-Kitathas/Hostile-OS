# LIVE SHADOW — HOSTILE-OS

## Thread Identity
- Thread: HOSTILE-OS / PCMMAD
- Last Updated: 2026-08-30
- Mode: BUILD-COMMIT
- Dominant Objective: advance durability research from deterministic faulted-media recovery to actual interrupted guest-write pressure without overclaiming physical power-loss behavior

## Active User Intent
- Proceed with research as makes scientific/engineering sense.
- Preserve all unique project data and per-turn GitHub durability.
- Keep reviewer/contributor research-only OS and reproduction surfaces current while science remains separately gated.

## Current Authoritative State
- Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`; no final/canonical/production release.
- D64/PR01 clean restart CLOSED PASS; 240/240 overnight replay PASS.
- I001/IRQCOUNT01 CLOSED PASS at tested real IRQ0 counts1/2; historical 660 exact-count reds reconciled without recoloring.
- D64/FR01 deterministic faulted durable-record recovery CLOSED PASS; science close `78efb0e29f94b374c129f0e0ed936e4b84e6ed84`.
- FR01 controlling campaign `20260830T212145Z_d64_fr01_01`: 41/41 fresh QEMU fixtures exit33; evaluator8/8; static21/21; audit16/16; 16/16 controlling snapshots hash-clean; stage2 1454 bytes.
- Adopted FR01 shadow record: two sectors; 24-byte payload + CRC16/CCITT-FALSE + `CMIT`; validity before bounded sequence; conflict/no-valid/epoch255 fail closed; fresh D64 reconstruction rejects historical handles.
- F03 proves naive highest-sequence selection can choose invalid newer data; F06 proves additive16 collision that CRC rejects; F12 covers tear boundaries0..29.
- FR01 authority ceiling: deterministic host-constructed media states only, not real power-cut/sector atomicity/cache ordering.
- External I001 reproduction portability repairs remain closed/published.
- Last verified GitHub publication before this research pass: `254b1322e0c22e6f67d7e29d183597064a3a6987`.

## Active Constraints
- Historical evidence is append-only/supersession-based; failed campaigns remain visible.
- Transport/fixture failure != mechanism failure.
- Run-local controlling inputs, including amendments, must be snapshotted before build/execution.
- Timeout/ambiguous process state = `UNKNOWN`.
- Research-only embodiment is not release promotion.
- `os/` remains independently sparse-checkout/buildable.

## Decisions Locked In
- Deterministic faulted-recovery incumbent = validate each candidate (structure+CRC+commit) before sequence ordering.
- Durable meaning/currentness survives; volatile topology is reconstructed.
- Equal-sequence conflicting valid candidates fail closed.
- Next P0 candidate = actual guest-write interruption around durable sector B, followed by independent FR01 recovery boot.

## Open Loops
- Commit FR01 adoption/continuity + next build-plan candidate.
- Publish full turn and verify GitHub remote SHA.
- Before preregistering interrupted-write experiment, inspect QEMU/floppy/BIOS write visibility and whether marker/timing control can produce scientifically meaningful state classes.

## Immediate Next Step
Durably close FR01 adoption, then perform non-scientific writer-path feasibility inspection for the interrupted-write P0.

## Last 10 Turn Reinforcement Window
1. Opus external I001 full reproduction reported; transplant portability defects repaired/published.
2. User authorized proceeding as makes sense.
3. Faulted-restart plan re-grounded from PR01.
4. Pareto pressure selected CRC16+commit over complement-copy and additive16.
5. FR01 preregistered before implementation; Amendment A isolated fixture labels.
6. Guest/launcher/evaluator/static/audit implemented; pre-science duplicate label retained.
7. First launcher failed before QEMU from function-name shadow; retained/fixed.
8. First 41-QEMU campaign failed transport from invalid CHS; Amendment B retained/fixed.
9. Second 41-QEMU campaign failed transport from boot-drive handoff; Amendment C retained/fixed.
10. Final controlling 41-QEMU campaign passed all evaluator/static/audit gates; science sealed at `78efb0e`.

## Delta Since Previous Shadow
- Deterministic faulted durable-record recovery is now experimentally closed/adopted at tested scope.
- Next durability pressure moved from media-state construction to actual guest-write interruption feasibility.
