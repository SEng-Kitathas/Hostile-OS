# LIVE SHADOW — HOSTILE-OS

## Thread Identity
- Thread: HOSTILE-OS / PCMMAD
- Last Updated: 2026-08-30
- Mode: BUILD-COMMIT
- Dominant Objective: continue research while hardening independent reproduction and keeping evidence/tooling authority separate from OS science

## Active User Intent
- Proceed with HOSTILE-OS research.
- Preserve all unique project data and per-turn GitHub durability.
- Keep research-only OS independently reproducible for reviewers/contributors.
- Treat external donor/reviewer findings as pressure to verify, not authority by source name.

## Current Authoritative State
- Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`; no final/canonical/production release.
- D64/PR01 clean restart CLOSED PASS; 240/240 overnight replay PASS.
- I001/IRQCOUNT01 CLOSED PASS at tested real IRQ0 counts 1 and 2; counts >2 unearned.
- Historical 660 I001 reds remain evaluator FAIL records but are reconciled as exact-count overbinding for tested consequence.
- Operator-supplied Opus report states first clean-clone independent-host I001 full reproduction: different OS/Clang/LLD/QEMU, exact controlling machine bytes, two QEMU boots exit33, no host write; one outside observation had exact IRQ count1.
- Foreign raw artifacts were not supplied, so outside result is an external reported reproduction, not locally hash-verified foreign packet.
- Three transplant defects adjudicated/repaired: tool invocation symlink identity, QEMU module search environment, unrelated default NIC/ROM dependency.
- `tools/check_i001_reproduction_portability.py` PASS 7/7.
- Local post-fix I001 regression reproduces exact stage1/stage2 bytes and two QEMU boots exit33; living verifier PASS.
- Deterministic `HOSTILE_OS_SMUGGLE_PATCH_003.zip`: 1455 bytes, SHA-256 `c8e29d61b299a4a515b5b381682c0e8fd9be92cbcd815c6dd300706b687fa615`.
- Last verified GitHub publication before this turn: `b5bacf886ee3c8f4bee5e6ad4a20b46d9e290464`.

## Active Constraints
- External report != locally verified raw external packet unless artifacts arrive.
- Historical science/evaluators remain sealed; portability fixes do not rewrite I001 consequence.
- Invocation path and resolved binary identity are separate in manifests/execution.
- Scientific runners disable unrelated environment/default devices where not part of the workload.
- Run-local controlling inputs must be snapshotted before science build/execution.
- `os/` remains independently sparse-checkout/buildable; R&D is not an implicit build dependency.

## Decisions Locked In
- `TOOL_PATH != TOOL_IDENTITY` for reproduction tooling.
- `TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT` for packaged runtimes.
- QEMU transplant historical ZIPs remain immutable; PATCH_003 supersedes wrapper behavior.
- I001 runner is network-hermetic (`-nic none`) because I001 has no networking responsibility.
- Root LF policy was already closed before the new Opus report.

## Open Loops
- Commit/publish external reproduction record + portability repairs.
- If Opus foreign raw reproduction packet becomes available, ingest/manifest it separately.
- Resume next science P0: deterministic faulted-restart durable-record integrity.

## Immediate Next Step
Close this portability/reproduction turn durably, then return to faulted-restart durable-state research.

## Last 10 Turn Reinforcement Window
1. I001 IRQ-count seam was preregistered and experimentally closed for counts1/2.
2. 660 historical I001 reds reconciled without recoloring evidence.
3. Living verifier narrowed to tested set {1,2}; count3 fails.
4. Next P0 selected: deterministic faulted-restart durable-record integrity.
5. User supplied Opus outside-host full-rerun report.
6. Report claims clean clone, different OS/Clang/LLD/QEMU, exact machine bytes and two-boot PASS.
7. Opus exposed symlink/multi-call identity, QEMU module-path, and default-NIC ROM portability failures.
8. Repo inspection verified `.resolve()` issue and historical wrapper omission; NIC hermeticity defect confirmed.
9. Build/run tooling repaired; local exact-byte + two-boot regression remains PASS; portability gate PASS7/7.
10. Deterministic append-only smuggle PATCH_003 created; external report preserved with evidence ceiling.

## Delta Since Previous Shadow
- First independent-host full reproduction is now externally reported.
- Reproduction infrastructure gained explicit invocation-identity/runtime-environment rules.
- Science frontier itself remains faulted-restart durable-record integrity.
