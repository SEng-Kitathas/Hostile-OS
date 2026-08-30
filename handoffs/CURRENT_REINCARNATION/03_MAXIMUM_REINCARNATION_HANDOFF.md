# HOSTILE-OS Maximum Reincarnation Handoff — 2026-08-30

Status: CURRENT HANDOFF SURFACE
Project posture: `INTEGRATED_SHADOW_CANDIDATE`
Purpose: allow a fresh thread/model/operator session to continue from the present engineering frontier without asking the operator to reconstruct project history from memory.

## 0. First principle

Do not treat this document as magical authority. Rehydrate from the exact Git state, then reconcile this handoff against the current Live Shadow, Design Thread Stream, current-state file, scars, authority state, and the exact experiment/result artifacts it cites. If these surfaces conflict, prefer the newest verified artifact and state the conflict instead of smoothing it away.

## 1. Commander's intent

Re-derive a general-purpose operating substrate from reality-facing responsibilities and invariants rather than inheriting historical OS nouns as primitive truth. Linux 0.01 and FreeDOS are donors/witnesses, not parents. Prior Rahl/PCMMAD work and external systems are quarries, not architecture authority.

The supreme design pressure is Pareto-optimal size/power subject to required capability. Burden includes bytes, memory, cycles, latency, jitter, energy, bandwidth, privilege, dependency surface, synchronization, failure/recovery burden, assurance burden, compatibility burden, maintenance burden, and concept count. Machinery is justified only when it buys a real capability/guarantee.

`MISSING_BEHAVIOR != MISSING_MECHANISM`.

Before introducing a primitive, localize the failure and test composition. Strip familiar nouns and ask what responsibility/invariant they carry. Mechanism, fixture, launcher, evaluator, environment, provenance, and observed consequence are distinct planes.

Desired end state: a substrate small because its causal structure is small, not because capability was removed; powerful because mechanisms compose; explicit about authority/currentness; able to adapt to substrate without runtime adaptation silently rewriting governance; able to move across machines while requalifying what reality changed.

No final HOSTILE-OS architecture has been promoted.

## 2. Authority split

- R3.1 is `ADOPTED_IN_HOUSE_SOP` for the operational SOP surface.
- R6 remains preserved parent lineage/fallback.
- `replacement_ready=true` applies only to the operational SOP surface.
- foundation promotion remains false.
- HOSTILE-OS architecture authority is separate from SOP/process authority.
- strongest architecture posture remains `INTEGRATED_SHADOW_CANDIDATE`.
- no experiment may silently promote a final/canonical/production architecture.

Exact original R3.1 archive:
`authority/archives/RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29.zip`
SHA-256: `4d205becc2413889bdb37c6b6ff7513d6f759a7dff1d9f9b8fddaddd8235a278`
Exact extracted package: `authority/R3_1_SOP_EXACT/`.

## 3. Campaign/history spine

### C001
CLOSED 20/20. Responsibility/relationship extraction from Linux 0.01 and pinned FreeDOS donor. No architecture promotion.

### C002
CLOSED 20/20. Whole-P01 consequence composition in bounded Python descendant. Important scars: P17 was a real mechanism failure (18/72 lost-wake orderings) repaired by current completion state; P19 was a stale evaluator failure. Exact final Python mechanism/fixture/launcher/evaluator source remains unrecovered, so host-subsidy claims requiring those exact bytes remain UNKNOWN.

### C003
CLOSED 20/20. Freestanding low-level embodiment. Exposed host subsidies and earned bounded mechanisms for identity/history, currentness, persistence/rebind, IRQ wake, local missing operation, failure locality, selection/application separation, lineage/wake, explicit continuation, bounds, generation width/wrap, explicit initialization, IRQ coherence, finite exhaustion, shared lifetime, stale-handle rejection, serialization convention, nested status propagation, and bounded lifecycle composition. Never run C003/P21.

### POST-C003/R01
Bounded spanning-reader ABA/currentness revisit. Clear/clear mutation flags alone can miss a complete mutation; changed version detected the tested span. Does not earn universal version-equality currentness because finite-width wrap remains load-bearing.

### I001 whole-workload integration
CLOSED PASS. Two fresh QEMU boots; stage1 + 4096-byte stage2; 2478-byte stage2, 51-byte runtime state. Composed capacity, lineage/wait/continuation, local missing failure, real IRQ0 + idle, separate wake/application, reuse/currentness, spanning-read controls, shared backing, durable serialization, clean restart/rebind, old-token epoch rejection, fail-closed generation exhaustion.

Important I001 scars: firmware-visible IRQ0/PIC state had to be restored before later BIOS INT13h use; a print helper once clobbered AL before a redundant status check. Controlling run is attempt 3.

### D64 scale/currentness lineage
Target pressure: 64 activities, 20 binding cells/activity, 64 global live resources, single core, maskable IRQ scope, clean restart, firmware borrowing allowed, no credible finite lifetime reuse bound.

- D64/A01 CLOSED PASS: 64 activity capacity; 65th full/nonmutating; checked release/reuse; stale/fresh handle discrimination.
- D64/RK01 CLOSED PASS/adopted: checked quiescent activity namespace rekey; epoch is load-bearing across generation reset; permanently live activity can starve rekey.
- 8 KiB stage2 envelope QUALIFIED: stage1 512 bytes, stage2 sectors 2..17 to `0x8000..0x9FFF`, sector18 reserved.
- D64/RB02 CLOSED PASS: 64x20 = 1280 binding cells; 16-bit resource live count; 64 resources; separate row/global exhaustion; shared lifetime; stale binding/resource handles reject; weakened index-only/slot-only controls retarget.
- D64/ARB01 CLOSED PASS/adopted: activity release requires empty owned binding row; activity rekey includes binding/resource quiescence; unsafe identity-only release can transfer old binding relation to later occupant.
- D64/RR01 CLOSED PASS/adopted: activity/binding namespace and resource namespace are distinct currentness domains; resource rekey requires quiescence; old handles reject across resource-epoch change.
- D64/IRQ01 CLOSED PASS/adopted: real IRQ0 observer sees mixed/orphan coupled bind/final-detach state without protection; masking IRQ0 across the exact current six-instruction regions yielded coherent tested observations. This is one-core maskable-IRQ evidence only; six instructions is witness cost, not universal constant.

### D64/PR01 clean-restart persistence
CLOSED PASS. Controlling run: `research/persistence/D64_PR01/runs/20260830T065500Z_d64_pr01_persistence_04`.

Earned at tested scope: durable meaning survives across two distinct fresh QEMU processes while volatile runtime topology is discarded. Activity/resource namespace epochs independently advance 1->2. Old boot1 binding/resource handles reject before and after intentional slot/gen reuse. Explicit rebind restores durable identity/value. Fresh handles succeed. Epochless negative controls demonstrate epoch is load-bearing.

Authority ceiling: clean restart only. No crash consistency, power-failure atomicity, filesystem semantics, unlimited-reboot guarantee, SMP/NMI/DMA claim, or final architecture promotion.

Overnight reliability replay: 240/240 consecutive PR01 repetitions PASS, zero failures. Repetition strengthens reliability only; it is not 240 new architecture passes.

## 4. New overnight broad-chain finding

A separate earned-chain regression campaign completed 3304 cycles with 22463 passes and 660 failures.

Per fixture:
- A01 3304/3304 PASS
- RK01 3304/3304 PASS
- RB02 3303/3303 PASS
- ARB01 3303/3303 PASS
- RR01 3303/3303 PASS
- IRQ01 3303/3303 PASS
- I001 2643 PASS / 660 FAIL

All 660 observed failures are I001 exact-evaluator rejections with the same shape: both QEMU boots completed exit33, static closure passed, but the trace contained `IRQ_EVENT=2` where the historical exact evaluator expected `IRQ_EVENT=1`.

Current interpretation: this is an unresolved long-replay evaluator/timing sensitivity around real timer event count, not established architecture/mechanism failure. Do not rewrite the historical evaluator retroactively. Do not demote I001 merely from the integer 660. A new discriminator must decide whether the exact count is semantically required or incidental. Preserve the failure artifacts and reopen only that seam under explicit preregistration.

## 5. Active architectural rules

- durable identity/meaning is distinct from volatile runtime binding/topology.
- currentness requires explicit generation/epoch domains where reuse/restart can alias bare location/identity.
- generation/epoch width is parametric and must fail closed before silent wrap; no fixed width is yet production-proven.
- capacity is finite/configured/observable, not silently infinite and not necessarily dynamic allocation.
- shared backing/resource lifetime requires explicit live-state accounting at tested scopes.
- selection/notification/wake and application/progress are separate responsibilities unless a discriminator earns collapse.
- current one-core IRQ coherence uses the smallest qualified protection around coupled mutations; do not generalize to SMP/NMI/DMA/weak-memory.
- firmware is an explicit borrowed boundary; higher device/storage posture prefers bootstrap-only firmware plus owned transport.
- future mutating experiments build from run-local exact input snapshots created before build/execution.

## 6. Things that must not silently come back

Historical nouns are not banned forever, but resurrection requires a discriminator that defeats the old reason for rejection. Never silently reintroduce Process/Scheduler/File/Manager/Service as primitive architecture merely because the problem is commonly named that way.

Also do not silently reintroduce: KarnOS schedulerlessness by ancestry; ECS/holons by attraction; global ternary state; append-only-everything; universal semantic filesystem/brain; ternary-as-compression proof; Hilbert locality as universal security/layout; universal branchless/thread-per-core/busy-spin/zero-syscall dogma; fixed optimum thresholds; Landauer as instruction-cost oracle; hash/parity/address binding as correctness/security; cardinality as topology; vector/index as identity; rollback attempt as atomicity; control-flow determinism as bit determinism; one-process-per-holon; process/microservice boundaries that do not pay; UI as authority; cached history as current after reboot; IDs as independence; descendant restatement as corroboration; resemblance as shared architecture; green tests as external truth; FINAL/SEALED/aerospace-grade/Omega labels as evidence; emulation as physical-hardware proof outside scope; rejected mechanisms under new names; research result auto-mutating architecture; CSC/runtime promotion authority; narrative handoff over exact state; naive foreground long launches; silent source/runtime splits; unbounded journal/cache without economics; “smaller always better”; or “capability excuses bloat.”

## 7. Execution scars that remain live

- command success != qualified consequence.
- timeout/ambiguous process status = UNKNOWN.
- mechanism/fixture/launcher/evaluator/environment/provenance/source identity/observed consequence are separate.
- long foreground tool windows can die while guest/build continues; durable launch + independent status/readback is required.
- invalid evidence is retained and labeled; do not delete scars to make a clean story.
- verifier/evaluator bugs are possible and must be qualified before specimen/mechanism blame.
- GitHub publication is not complete until remote SHA readback equals the publication commit.
- publication uses immutable captured canonical commits, isolated mirror workspaces, and LFS transport for oversized payloads; canonical science Git history is not rewritten to satisfy GitHub limits.
- two numeric untracked files `27376` and `29312` were inspected as stray PID/path breadcrumbs and are not admitted project evidence.
- old `logs/C002_SOURCE_RECOVERY_SCAN_2026-08-29.txt` remains unrelated/unadmitted unless separately adjudicated.

## 8. Current open seams

P0 scientific seam after PR01 is no longer “expanded D64 clean-restart persistence”; that is closed at bounded scope. The next thread must re-evaluate P0 from the current evidence, not from the stale older frontier prose.

Open pressure includes:
- I001 long-replay `IRQ_EVENT=1` versus `IRQ_EVENT=2` semantic/evaluator discriminator.
- quiescent namespace renewal availability under permanently live state.
- production generation/epoch sizing and exhaustion recovery.
- crash/partial-write/power-loss persistence behavior, separately from clean restart.
- stronger concurrency beyond one core/maskable IRQ: NMI/DMA/SMP/weak-memory.
- owned/native storage/device transport if firmware borrowing is reduced.
- physical hardware qualification.
- arbitrary workloads/capacities beyond D64 donor-scale qualification.
- eventual architecture promotion only after explicit review, not by momentum.

## 9. Continuity and publication doctrine

Chat is a control surface. Persisted Git state is the recovery authority.

Maintain paired continuity:
- `continuity/LIVE_SHADOW.md` = compact active truth.
- `continuity/DESIGN_THREAD_STREAM.md` = chronological recovery spine.
- `handoffs/THIS_CONVERSATION.md` = complete recoverable conversation artifact built from the DTS plus later thread supplements, with fidelity labels.

As of this handoff, GitHub publication becomes per-turn continuity policy: every meaningful turn that changes intent, state, evidence, decisions, risks, scars, next actions, or authority must update continuity, commit the delta, publish the captured canonical commit, and verify remote `main` readback before that turn is considered durably closed. Tiny turns with truly no state change may record/retain a no-load-bearing-change state rather than manufacturing fake engineering changes.

## 10. OS-only checkout contract

The full GitHub repository is the project ledger: code + research + continuity + SOP + scars + history + evidence.

The install/build surface is `os/` and MUST NOT require `research/`, `authority/`, `continuity/`, handoffs, transcripts, or historical R&D payloads. Use partial/blobless clone + sparse checkout and skip LFS smudge before materializing `os/`. If a released OS needs something, it must live under `os/` or be fetched explicitly/versioned by `os/` tooling.

## 11. Exact continuation order for a new thread

1. Read `handoffs/CURRENT_REINCARNATION/00_READ_FIRST.md`.
2. Read `continuity/LIVE_SHADOW.md`.
3. Read this maximum handoff.
4. Read `continuity/01_COMMANDERS_INTENT.md`.
5. Read `continuity/02_CURRENT_STATE_AND_FRONTIER.md`, but note its historical sections may be superseded by the appended 2026-08-30 handoff delta.
6. Read `continuity/10_ENGINEERING_DECISION_LEDGER_2026-08-30.md`.
7. Read `scars/ACTIVE_NEVER_REINTRODUCE_CURRENT.md` and `scars/EXECUTION_AND_INFERENCE_SCARS.md`.
8. Read `authority/ADOPTION_STATE.md` and the R3.1 reincarnation/adoption documents.
9. Read `handoffs/THIS_CONVERSATION.md` backward from the tail if chronology/nuance is needed.
10. Inspect canonical Git HEAD/status and GitHub publication metadata/readback before mutation.
11. Resume from the newest open seam; do not ask the operator to restate history already present here.

## 12. Post-handoff embodiment/repository delta

Operator clarified that GitHub must carry **all unique project data**, properly separated in the canonical folder tree, and that HOSTILE-OS needs a real embodied research-only OS for reviewers/contributors even before release promotion.

Implemented:
- `PROJECT_TREE.md` durable folder contract;
- `continuity/13_DURABLE_REPOSITORY_AND_RESEARCH_OS_POLICY_2026-08-30.md`;
- root `.gitattributes` LF/binary policy;
- raw + adjudicated Opus reproducibility donor review;
- normalization-aware historical receipt verifier;
- bootable `os/research_only/i001_reference/` with build/run/verify wrappers;
- exact I001 machine-byte reproduction and two-QEMU-boot reproduction packet;
- explicit scratch/partial-archive disposition scar.

Do not regress either direction: do not empty `os/` back to README-only merely because release promotion is not finished, and do not mistake `os/research_only/` for a promoted release/final architecture.
