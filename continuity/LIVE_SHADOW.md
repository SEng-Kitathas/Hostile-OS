# LIVE SHADOW

## Thread Identity
- Thread: HOSTILE-OS PCMMAD reincarnation
- Last Updated: 2026-08-30T06:14Z
- Mode: BUILD-PLAN after RR01 close/adoption
- Dominant Objective: derive the smallest real-IRQ coherence discriminator for coupled binding/resource publication and detach without widening architecture scope

## Active User Intent
- Proceed continuously from live persisted state.
- R3.1 is adopted as normal in-house engineering/research SOP; preserve R6 ancestry/fallback.
- Work around prior action/transport stalls with small bounded server calls and explicit readback.
- Keep science/provenance exact; do not duplicate concurrent writer work.

## Current Authoritative State
- GitHub bootstrap scar: first publication attempt did not push; mirror cleanup hit a Windows lock on ignored `.pcmmad_sync_runs`. Repair preserves mirror runtime scratch during cleanup. Scar: `continuity/07_GITHUB_PUBLICATION_BOOTSTRAP_SCAR_2026-08-30.md`.
- C001/C002/C003 closed at their bounded scopes; C003 remains hard-stopped 20/20.
- HOSTILE-OS posture remains `INTEGRATED_SHADOW_CANDIDATE`; final=false; production-ready=false; canonical replacement=false.
- R3.1 is `ADOPTED_IN_HOUSE_SOP` at `b8912647a5a1fb1fc62cfa8fbe125d3f64b7bc5f`; operational SOP replacement-ready=true; R6 remains parent lineage/fallback; foundation promotion=false.
- Adopted R3.1 ZIP SHA-256: `4d205becc2413889bdb37c6b6ff7513d6f759a7dff1d9f9b8fddaddd8235a278`; assurance ceiling remains structure/source-class/body/coverage/integrity only; Windows nested-path verifier portability scar is preserved.
- Public GitHub project surface `SEng-Kitathas/Hostile-OS` is recorded in continuity; local repo was last observed without a configured remote. No remote/push mutation is part of current science state.
- D64 workload pressure: 64 activities, 20 binding references/activity, 1,280 total binding cells, 64 resources. These are qualification pressure values, not donor ontology.
- D64/A01 CLOSED PASS: generic 64-slot activity lifecycle scaling earned.
- D64/RK01 CLOSED PASS and adopted: checked quiescent activity-namespace rekey.
- Fixed 16-sector / 8,192-byte stage-2 evidence envelope QUALIFIED at `734674f8a35974433fd6a213e2a2cf1e4de93b43`.
- D64/RB02 CLOSED PASS at `7d6b518c5198c6d062dd714e80631182bf897b77`: 64x20 binding matrix, 64 resources, 16-bit live count up to 1,280, separate row/global exhaustion, shared lifetime, binding/resource stale-handle currentness.
- D64/ARB01 CLOSED PASS at `cdc1aea963f37168e2fdbd317a0beff353ce42c1`; binding-aware activity lifecycle rule adopted at `184eb53f32b5b082c5b0ffa91b1d59bdf78a4032`.
- ARB01 incumbent rule: checked activity release requires an empty owned 20-cell binding row; activity rekey requires complete activity/binding/resource quiescence; successful activity rekey resets activity+binding namespace state and preserves resource epoch/generation. Unsafe identity-only release lets a later occupant inherit the old binding relation.
- D64/RR01 preregistration sealed at `d293ecc46437a50fe642ea7dc944dc2213fe3b26`.
- D64/RR01 CLOSED PASS at `0615f4b2b80e3e7a9d8e6dd727e266d119a623c5`; result SHA-256 `c958531ff4b35bf168e1c650722d48fdb302bc80578ac7373ff45815bdcb449e`.
- RR01 controlling run `20260830T055700Z_d64_rr01_resource_rekey_01`: QEMU PID 33952, COMPLETED exit33; evaluator/static/independent audit PASS; stage2 6,655/8,192 bytes; named runtime state 3,665 bytes.
- RR01 incumbent resource-rekey rule adopted at `5126bae647f9d2832262ada8d17ae4ee03e6b5f4`: live bindings/resources block rekey; after quiescence, resource epoch changes and resource generation/state reset while activity state/epoch and binding-generation history remain current; generation-only reset without resource-epoch change aliases a stale direct resource handle; explicit checked resource epoch 255->1 is boundedly earned.
- Exact final C002 Python source remains UNRECOVERED; source-dependent historical subsidy details remain UNKNOWN.

- GitHub publication policy is now load-bearing: full tracked project/research snapshots publish to `https://github.com/SEng-Kitathas/Hostile-OS.git` at the end of each substantive pass; canonical local Git history remains unchanged, GitHub uses a publication mirror with LFS for oversized payloads, and each publication records the exact canonical local HEAD.
- Future install/build surface is `os/`; `research/` is intentionally included in full project publication but SHALL NOT be an install dependency. Code-only sparse/partial checkout is documented in `INSTALL_FROM_GIT.md`.

## Active Constraints
- Git/runtime evidence outranks chat narrative and stale continuity text.
- Check HEAD/status before mutation because concurrent writers actively advance the repo.
- Bounded execution doctrine is adopted at `continuity/06_BOUNDED_EXECUTION_DOCTRINE_2026-08-30.md`: one bounded server action at a time, short synchronous waits, persist intent before expensive work, missing/incomplete tool return = `UNKNOWN`, re-inspect before retry, and use submitted server jobs with journal/checkpoint surfaces for long whole-suite work.
- Run-local controlling-input snapshot/manifest is mandatory before mutating experiment builds.
- No `git add .`; stage exact paths.
- Donor counts are workload pressure only; no Process/File/inode/Manager ontology is imported by count.
- Activity/binding and resource namespaces are separate currentness domains; rekey of one must not silently reset the other.
- Both incumbent rekey mechanisms are cooperative/quiescent and may be starved by permanently live state.
- Externally persistent handles across namespace retirement are not covered.
- RB02/ARB01/RR01 coupled binding/resource transitions ran with maskable interrupts disabled; do not infer asynchronous coherence.
- Resource/binding persistence for the expanded D64 relation is not earned by I001's smaller durable record.
- R3.1 SOP authority and HOSTILE-OS architecture authority are separate planes.

- End-of-substantive-pass discipline now includes GitHub publication + remote HEAD readback. Do not claim publication until the remote SHA matches the publication mirror SHA.

## Decisions Locked In
- GitHub publication remains end-of-substantive-pass law; full tracked research is included while `os/` stays independently sparse-checkout/installable.
- R3.1 is the normal engineering/research SOP; R6 is fallback ancestry.
- D64 activity release may not clear identity while its binding row is nonempty.
- D64 activity rekey resets activity+binding namespace only at full relation quiescence and preserves resource namespace history.
- D64 resource rekey resets resource namespace only at binding/resource quiescence; current activities and binding generations survive.
- Generation reset without the corresponding namespace-epoch change is unsafe for both activity/resource currentness families.
- No architecture promotion beyond `INTEGRATED_SHADOW_CANDIDATE` follows from A01/RK01/RB02/ARB01/RR01.

## Open Loops
- P0 publication bootstrap: make the first GitHub publication snapshot and verify remote `main` readback; thereafter repeat at every substantive pass end.
- P0: asynchronous observation of binding/resource publication and detach under real IRQ0.
- P0: quiescent rekey availability ceiling if state remains live indefinitely.
- P1: resource/binding persistence across clean restart for the expanded D64 relation.
- P1: native post-takeover storage/device transport only if a later target disallows firmware borrowing.
- Scope-dependent: physical hardware, SMP/NMI/DMA/weak-memory, crash/partial-write durability, general capability/memory safety.
- P1 process scar: sealed R3.1 Windows path-separator verifier portability issue remains visible.

## Immediate Next Step
- Commit the GitHub publication cleanup repair + bootstrap scar, then retry publication from the new canonical HEAD. Require remote `main` SHA readback before success. After publication closes, resume the already-preregistered D64 IRQ01 real-IRQ coherence pass from its preserved untracked probe/run state, using bounded/job-style execution.

## Last 10 Turn Reinforcement Window
1. User ordered R3.1 SOP adoption and continuation; adoption was verified already durable at `b891264...` after thread/action stalls.
2. RB02 was found already closed at `7d6b518...`; continuity was repaired from resource-binding frontier to composition frontier.
3. Three overlapping composition preregistrations appeared concurrently; newest/strongest ARB01 was made controlling and AR01/AB01 were superseded before execution at `dbd969c...`.
4. ARB01 controlling run/close at `cdc1aea...` proved unsafe activity identity-only release transfers binding relation and good release/rekey composition preserves separate resource namespace history.
5. ARB01 binding-aware lifecycle rule was adopted at `184eb53...`.
6. Resource-rekey plan was sealed at `eb32e0f...`; RR01 preregistration sealed at `d293ecc...`.
7. RR01 attempt 1 used pre-build snapshots and completed exact QEMU/evaluator/static matrix: live resource blocks rekey; quiescent rekey changes resource epoch only; activity/binding namespace survives.
8. RR01 independent audit passed all 13 checks; 17 static checks were literal boolean true.
9. RR01 science closed at `0615f4b...`; result SHA `c958531f...`.
10. RR01 resource-rekey rule was adopted at `5126bae...`; leading frontier moved to real-IRQ observation of binding/resource mutation.

## Delta Since Previous Shadow
- First GitHub publication attempt failed before push on a Windows lock inside mirror `.pcmmad_sync_runs`; no remote success claimed.
- Patched publication cleanup to preserve ignored mirror runtime scratch.
- Added explicit publication bootstrap scar; next action is commit repair, retry, and verify remote SHA before resuming IRQ01.
