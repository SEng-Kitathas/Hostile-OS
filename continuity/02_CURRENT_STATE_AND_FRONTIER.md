# Current State and Frontier

**As-of:** 2026-08-30 live checkpoint
**Scientific campaigns closed:** C001, C002, C003
**C003 progress:** P01-P20 complete at bounded scientific scope; hard-stopped
**Scientific passes earned:** 60 total (20 + 20 + 20)
**HOSTILE-OS architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Active campaign:** NONE — C003 and I001 closed; target-boundary design clarification is next

## C001

`NARROWED_COMPLETE / NO ARCHITECTURE PROMOTION`.

C001 stripped Linux 0.01 and the pinned FreeDOS donor into responsibility and relation distinctions under the qualified workload. It separated identity, lineage, eligibility, arbitration, continuation, memory interpretation, wait/wake/resume, resource/access/backing, cursor, mode/applicability, persistence/history, and related distinctions. It did not prove ECS, schedulerlessness, or a final OS.

## C002

`CAMPAIGN CLOSED / WHOLE-P01 RELATION COMPOSITION SURVIVED AFTER REPAIR / NO ARCHITECTURE PROMOTION`.

A bounded Python descendant reproduced the whole-P01 consequence workload without primitive Process/Scheduler/File/Manager/Service nouns. The campaign earned this only after a real P17 mechanism failure (18/72 lost-wake ordering cases) and a separate P19 stale-evaluator failure. Final unchanged matrix: 72/72 after both repairs.

Exact final C002 Python mechanism/fixture/launcher/evaluator source remains unrecovered. Historical host-subsidy details that require those bytes remain UNKNOWN.

## C003 purpose

C003 is freestanding low-level embodiment and host-subsidy exposure. Its job is not to build a mature OS quickly. Its job is to make services previously supplied by Python or the host runtime become explicit, falsifiable machine state or be shown unnecessary for a bounded consequence.

The campaign remains noun-hostile and composition-first:
- donors are witnesses, not parents;
- historical subsystem labels are not primitives unless re-earned;
- missing behavior does not prove a missing historical mechanism;
- ontology cost belongs in the Pareto burden vector;
- each next pass is earned only after the previous consequence is reconciled.

## C003 results through P19

### P01 — source recovery / reconstruction
Exact final C002 Python source remained unrecovered after bounded exhaustive search. A freestanding reconstruction showed that the C002 current-completion distinction can be represented without Python object identity, dynamic allocation, or interpreter control for that slice.

### P02 — identity-bound policy history
Identity-bound history survived unrelated-member compaction while stale numeric/index history drifted.

### P03 — mutation coherence/currentness guard
A guarded path rejected stale mutation state while a raw path exposed the cut; no manager primitive was required for the bounded discriminator.

### P04 — restart persistence / volatile binding expiry
Durable bytes survived a fresh QEMU restart, while stale volatile runtime binding expired and explicit rebind restored use.

### P05 — asynchronous event / idle wake
A real QEMU virtual PIT/PIC IRQ woke a guest from `STI; HLT`; no scheduler architecture was claimed.

### P06 — bounded missing operation
An unknown operation returned bounded missing status without mutating the protected local state.

### P07 — failure locality / later progress
Local failure did not poison a distinct later activity; a deliberately global failure latch control did.

### P08 — selection separate from execution application
Selection chose B without mutating A/B; a separate apply step mutated only B. The bad select-and-apply control exposed the collapsed responsibility.

### P09 — parent-child return from lineage + generic wait/wake
Matching lineage, current wait target, and current completion woke the parent; wake itself did not apply parent progress; a separate application step did. Child completion bytes alone were insufficient.

### P10 — explicit continuation binding versus identity-only resume
One activity A explicitly bound logical continuation 2 before blocking. Generic wake changed wait/wake state only. A separate dispatcher consumed the continuation and produced progress 2. The identity-only control, with the same identity and wake but no continuation binding, resumed fixed step 1.

P10 therefore establishes only that explicit continuation identity can replace implicit logical control position for this bounded block/wake/resume case. It does not establish general call-stack preservation, register context switching, preemption, coroutine architecture, scheduler architecture, or architecture promotion.

### P11 — explicit bounds versus adjacent-state corruption
A two-slot relation layout with an immediately adjacent sentinel accepted checked valid index 1 and changed slot 1 to X. Checked invalid index 2 returned R and preserved sentinel S. After reset, the intentionally unchecked raw index-2 write changed the adjacent sentinel to X. Linked-symbol readback proved the sentinel was exactly `relation_slots + 2`.

P11 therefore exposes implicit host bounds safety as a real subsidy for this fixed layout. The bounded replacement cost was one explicit capacity check before indexed mutation, not a MemoryManager primitive.

### P12 — finite-width generation wrap versus stale-token alias
Under one shared 256-iteration history from generation zero, an 8-bit generation wrapped back to zero and a naive equality-only currentness check falsely accepted stale token zero. A 16-bit generation reached `0x0100`, accepted a freshly snapshotted token, and rejected stale zero.

P12 therefore exposes integer width/wrap as a real low-level burden hidden by Python arbitrary-width integer behavior. It does not establish that 16 bits is generally sufficient; it only avoids this exact 256-step alias.

### P13 — explicit initialization on fixed-slot reuse
One dirty fixed record was reused from owner A to owner B. Release cleared owner only and left A's waiting/continuation/progress residue. A good B acquire explicitly reset every load-bearing field to zero; an owner-only B acquire inherited A's `1/2/7` residue. Static closure confirmed one record only and the exact write sets.

P13 therefore exposes clean/default object construction as a real host subsidy on reused storage. The bounded replacement cost was explicit initialization of the fields that can affect future behavior, not an allocator or object framework.

### P14 — two-field transition coherence under real IRQ0
Using the real QEMU PIT/PIC IRQ0 path as a read-only observer, masking IRQ0 across owner/continuation writes produced coherent snapshot `B/2`. Enabling IRQ0 after only the owner write produced torn snapshot `B/1`; after wake the guest completed final `B/2`. Static closure proved the handler only observed the relation and the write/unmask order matched the preregistration.

P14 therefore exposes multi-field transition atomicity as a real host subsidy in this uniprocessor IRQ slice. The bounded replacement was IRQ masking across the coupled writes, with synchronization/latency cost explicitly visible.

### P15 — explicit fixed-capacity exhaustion
Exactly two slots admitted A and B. Checked C admission returned `F` and preserved A/B. The overwrite-on-full control admitted C only by clobbering A, producing C/B. Static closure proved there were only two slots and the checked full branch did not write storage.

P15 therefore exposes finite capacity as a real low-level behavior choice. A visible full result can be the smaller lawful behavior; this pass does not establish that dynamic allocation is required.

### P16 — shared backing lifetime
One backing X was shared by live bindings A and B at count 2. Releasing A to count 1 preserved X for B; releasing B to zero then cleared backing. The bad A release also left count 1 and B live but cleared backing immediately, so B read zero. Static closure proved the good zero-count guard and bad unconditional reclaim.

P16 therefore exposes shared lifetime/reference state as an explicit burden without earning a garbage collector or heap.

### P17 — stale handle after slot reuse
One slot was reused X/gen1 -> Y/gen2. Fresh gen2 read Y; checked stale gen1 returned R/0; address-only stale control silently read Y. Static closure proved one slot, generation compare before value read, no value read on stale reject, and no generation check in the bad path.

P17 therefore shows that current generation can prevent this bounded stale-handle retargeting without earning general pointer or capability safety.

### P18 — explicit two-byte serialization convention
Fixture supplied only logical word `0x1234`. The mechanism encoded exactly two bytes `34 12`; the canonical little-endian decoder reconstructed `1234`; a swapped decoder using the same bytes reconstructed `3412`. Static closure proved two encoded bytes and opposite byte roles in the two decoders.

P18 therefore exposes byte representation/order as an explicit low-level convention rather than a host conversion service. It does not earn a general serializer, ABI, or storage format.

### P19 — explicit nested status propagation
A leaf returned O for known K and M for missing U without touching progress. The same checked middle path propagated M with progress 0 and accepted O with progress 1. The bad middle ignored M, wrote progress 1, and reported O. Instruction-aware static closure verified the leaf/caller write and branch structure.

P19 therefore exposes nested failure propagation as an explicit control obligation without earning an exception runtime or error manager.

### P20 — final bounded lifecycle composition replay
One reusable slot composed checked one-slot admission/full behavior, explicit continuation across a missing request, success-only continuation application, release and clean reuse, generation advance, fresh/stale handle currentness, and an address-only stale negative control.

The controlling run `20260830T023700Z_p20_composition_05` completed QEMU with exit 33 and evaluator pass. Exact output showed A at generation 1; missing U preserved progress 0 and continuation 2; known K applied progress 2; B admission while occupied returned F without replacing A; release + checked reuse produced B at generation 2 with clean progress/continuation; fresh gen2 read Y; checked stale gen1 returned R/0; address-only stale control read Y. Static closure passed all preregistered one-slot/order/currentness checks.

P20 therefore shows that these already-earned bounded mechanisms can coexist in one small fixed-slot lifecycle without adding a new primitive species. It does not establish a final OS architecture, general memory/pointer safety, arbitrary workloads, physical-hardware proof, or authority promotion.

P20 close commit: `eb678fdfc8d352a3d8f1c21574181fc2744522ab`.

## Post-C003 audit

The campaign-wide audit is sealed at commit `e1f739e9a37ec8c14135acfd0a1a47ce9f265571` (`research/audits/C003_POST_CAMPAIGN_AUDIT_2026-08-30.md`).

Audit verdict: C003 provides broad bounded coverage plus partial composition, not one whole-workload integrated freestanding closure. Strong repeated distinctions include separation of decision/notification/application, explicit currentness beyond bare identity/location, local bounded failure, explicit reuse/lifetime state, and low-level replacement of hidden host conveniences.

Main promotion blocker: P20 composes only a subset of the campaign. Persistence/rebind, async IRQ/idle, parent-child lineage/wake, mutation-span currentness, shared lifetime, and serialization are not all exercised together in one executable workload. No architecture promotion is earned.

## POST-C003/R01 — P03 spanning-reader ABA/currentness revisit

Preregistration commit: `4c4142fd2de706c165a63a333932cffe55fb9e65`.
Science close commit: `06625b50a7dea968620dbb8022b98dc52634d87e`.

Controlling run `20260830T031800Z_post_c003_r01_p03_aba_02` completed QEMU exit 33; evaluator and static/source audits passed.

The exact bounded result is: a reader can see `mutation_active=0` before and after a complete mutation while combining old owner A with new history B. The active-flag-only rule accepted that mixed snapshot. Version 1 before and version 2 after rejected the same span. A later stable B/B read saw version 2 before and after and was accepted.

Therefore the P03 spanning-reader seam is resolved at bounded scope: clear/clear active flags are insufficient for this reader model; a changed version detects the tested span. P12 still controls finite-width wrap risk, so no universal version-equality currentness rule is earned.

R01 does not change the C003 pass count. C003 remains CLOSED 20/20.

## Post-C003 integration gate plan

The BUILD-PLAN artifact `research/plans/POST_C003_INTEGRATION_GATE_PLAN_2026-08-30.md` is sealed at commit `2a8f72258bee41966dd6d68fe07ca7379a3378b5`, SHA-256 `f6284745d17672fe55437dce7011d1ae6fcd3d844b63071eb83e70cec22d48e1`.

It is **not** a campaign preregistration. No new campaign name has been assigned.

The plan proposes a larger explicit evidence envelope rather than treating the 512-byte C003 probe limit as architecture law: a 512-byte stage-1 loader, fixed-size freestanding stage 2, and a separate durable sector. The candidate two-boot workload combines finite activities, wait/wake/lineage/continuation, real IRQ/idle, local missing failure, fixed-slot reuse/currentness, bounded coherence, shared backing lifetime, serialization, and restart/rebind.

The provisional version policy is fail-closed on wrap: reserve generation zero as invalid, refuse reuse with explicit generation-exhausted status rather than silently wrap, and keep durable identity separate from volatile runtime handles. This is a BUILD-PLAN candidate only and remains subject to exact width/reuse-horizon preregistration.

## I001 — whole-workload freestanding integration

I001 was preregistered before implementation at commit `e3dcaa6a246b58c97539a999eb973bdddb820278` and closed at commit `e53bea81b5a2b08a3dc27a79eb30c0d38b3e4b2f`. Result SHA-256: `41c52da7f2787be5bceafcb204e11f61ef18d4261a75f82c27221a6c974d0ef8`.

A separately qualified 512-byte stage 1 loaded a fixed 4,096-byte stage-2 extent to `0x8000`; BIOS sector 10 was reserved for durable bytes. The controlling run `20260830T042900Z_i001_integration_03` used two distinct fresh QEMU processes, both `COMPLETED` with exit 33. Boot 1 PID `10408` ended before Boot 2 PID `30608` started. Evaluator, static/source closure, and independent cross-check all passed.

One 2,478-byte freestanding stage 2 composed the main responsibility families in one executable: two-slot finite capacity/full result; P/C lineage and generation-qualified wait; explicit continuation; local missing-operation status; real IRQ0 + idle; separate completion/wake/application; later B progress; slot reuse/initialization/currentness; stale-handle negative control; spanning-read flag/version controls; shared-backing lifetime; little-endian durable serialization; clean restart/rebind; old-token epoch rejection; fail-closed generation exhaustion; and integrated negative controls. Runtime state was 51 bytes. The wait-binding critical region was six guest instructions.

I001 attempt 1 exposed a new integration scar: after guest IRQ0/PIC takeover, later BIOS INT 13h durable transport returned failure even though the durable bytes reached disk. Saving/restoring the firmware-visible IRQ0 vector and PIC masks before later BIOS transport removed this boundary failure. Attempt 2 then passed Boot 1 but failed after `REBIND=W` because a print helper clobbered AL before a redundant status check; the check was moved before printing. Attempt 3 is controlling.

I001 therefore resolves the post-C003 whole-workload integration gap **at bounded scope** and earns a separate architecture promotion review. It does not itself promote an architecture. Production generation/epoch sizing and exhaustion recovery, crash/partial-write behavior, SMP/NMI/DMA ordering, physical hardware, arbitrary capacity/workload behavior, firmware-boundary policy, and failed-run source-snapshot process debt remain open.


## D64 donor-scale target profile and A01 activity scaling

D64 target profile `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md` is sealed at `bb33e65cf9c88f79b84bc34021eb585ccef33c29`. It is a donor-scale qualification profile, not production telemetry. It fixes reference pressure of 64 activities, 20 binding references per activity, and 64 global live resources while keeping those counts configurable rather than architectural constants.

D64/A01 preregistration is sealed at `eca4069643d81a5415d677c494c4b5ef8c305c3e`. Science is CLOSED PASS at `ee2982d65fbecb2f8d0c73edc68212a45a092d12`; result SHA-256 `d65d3f92cae066f4e1d22ab5915faee67f3850a98ce12f78d8ed3cc402fea86e`.

Controlling run `20260830T044700Z_d64_a01_capacity_01`: QEMU PID 7532 COMPLETED exit 33; evaluator and static checker passed; independent run-local input/receipt audit passed. Exact consequence: all 64 configured slots filled through one generic acquire path, the 65th admission returned `F` without changing first/last occupants, generic release/reuse selected slot 31 and advanced generation 1->2, stale handle returned `R`, fresh handle returned `W` with identity `5A`. Stage 2 was 1,528 bytes; named runtime state 719 bytes.

A01 exercised the new run-input snapshot protocol end to end from its first build. Input-manifest SHA-256 `bb2ebdaec97d6a8111867608801282c6a8f38726f7ca960d076fac95b8f1f075`; receipt SHA-256 `879789754f53bf62b41e460b7eb3cc9afdf4e9155c610def3a9378d95b91e721`; independent audit SHA-256 `2af74ea61432d108e2a38b7541501e42a08ee6cc1ca102cde5e6be6b01b41590`. The built-in checker emitted one truthy manifest check as a commit string rather than JSON boolean; this typing scar is preserved and independent closure verified the actual predicate.

A01 resolves the hardcoded two-slot activity embodiment gap at bounded D64 scope. Resource-binding scale and long-running namespace renewal/rekey remain open.

## D64 RK01, SOP adoption, and 8 KiB qualification

D64/RK01 science is CLOSED PASS at `34123fbd89aa9c759dee5c58ec12e27b6dc7ea2f`; result SHA-256 `6b8833690083e83e78ea0bd59f0b1c79b1bc6a7f3c09e365faced69d1ee209c1`. The 64-slot checked quiescent rekey rejected live/current state, changed epoch only after quiescence, reset all activity fields, rejected immediate old handles, exposed generation-reset-without-epoch alias in the bad control, and qualified explicit checked epoch `255 -> 1`.

RK01 rule adoption is sealed at `762a4e7bd78c3d028afd26407febb17798fac790`. Quiescent activity-namespace rekey is the incumbent D64 shadow rule, with visible availability ceiling: a permanently live activity can prevent rekey.

D64 resource-binding BUILD-PLAN is sealed at `49a42cb45a6f89acbf158debcac4dcbf5e0b1d65`; plan SHA-256 `2775f5c4c9e4191f3c002fa44d7fdca24fb34a456733c336734906da7b76c02b`. It proposes 64 activities x 20 binding cells plus 64 global resource slots with explicit binding/resource currentness and live-count lifetime, without importing donor File/Manager ontology.

The required fixed 16-sector / 8,192-byte stage-2 evidence envelope is QUALIFIED at `734674f8a35974433fd6a213e2a2cf1e4de93b43`; result SHA-256 `cdd1b3bd083868067b6d8be2346aa413332f3d8888fcaa1e809cc48bc36610f6`. Guest success depended on observing marker `0xA5` at address `0x9FF0`, near the end of the loaded extent.

R3.1 operational SOP adoption is sealed at `b8912647a5a1fb1fc62cfa8fbe125d3f64b7bc5f`. R3.1 is `ADOPTED_IN_HOUSE_SOP`; `replacement_ready=true` only for the operational SOP surface; R6 remains parent lineage/fallback; foundation promotion remains false.

## D64 RB02 resource-binding scale

RB02 preregistration is sealed at `0d0305ebde56d7a9eb70a3db84b00fcf96b33c17`. RB01 was superseded before execution after the 64x20 matrix exposed that an 8-bit resource live count could not represent the declared 1,280-binding maximum; the corrected 16-bit-width lineage is preserved at `d031829` / `f920504`.

RB02 science is CLOSED PASS at `7d6b518c5198c6d062dd714e80631182bf897b77`. Controlling run `20260830T054900Z_d64_rb02_resource_binding_03` completed QEMU exit 33 and passed the exact evaluator matrix plus all 21 literal-boolean static checks. Built stage 2 is 6,432 bytes inside the qualified 8,192-byte extent; named runtime state is 3,658 bytes.

Bounded consequence: 64 activities x 20 binding cells = 1,280 cells are embodied; one resource reached live count 1,280 using the corrected 16-bit count; per-row and global-resource exhaustion stayed distinct/non-mutating; shared lifetime survived count 2->1->0; stale binding-cell and direct-resource handles rejected after reuse; intentionally weakened index/slot-only controls retargeted. No historical File/descriptor/inode/Manager primitive was required.

Open descendants are now resource-namespace renewal, activity rekey composed with binding rows/resources, resource/binding persistence, and asynchronous observation of coupled binding/resource mutation.

## D64 ARB01 + RR01 currentness composition

ARB01 science is CLOSED PASS at `cdc1aea963f37168e2fdbd317a0beff353ce42c1`; its binding-aware activity lifecycle rule is adopted at `184eb53f32b5b082c5b0ffa91b1d59bdf78a4032`. It proves that checked activity release requires an empty owned binding row and that activity rekey must include binding/resource quiescence. Successful activity rekey resets activity + binding namespace state while preserving resource epoch/generation history. Unsafe identity-only release allows a later occupant to inherit the old binding relation.

RR01 preregistration is sealed at `d293ecc46437a50fe642ea7dc944dc2213fe3b26`. Science is CLOSED PASS at `0615f4b2b80e3e7a9d8e6dd727e266d119a623c5`; result SHA-256 `c958531ff4b35bf168e1c650722d48fdb302bc80578ac7373ff45815bdcb449e`. Resource-rekey adoption is sealed at `5126bae647f9d2832262ada8d17ae4ee03e6b5f4`.

RR01 controlling run `20260830T055700Z_d64_rr01_resource_rekey_01`: QEMU exit33; evaluator/static/independent audit PASS; stage2 6,655 / 8,192 bytes; named runtime state 3,665 bytes. Live bindings/resources reject resource rekey. After detach, resource rekey changes resource epoch `1 -> 2`, resets resource generation/state, leaves activity A current at epoch1/gen1, and preserves binding generation1. New binding reuse advances binding generation to2 while resource reuse starts at resource generation1 in epoch2. Old direct resource and binding handles reject; fresh ones succeed. Generation reset without resource-epoch change aliases the old direct resource handle. Explicit checked resource epoch `255 -> 1` is also boundedly earned.

The activity/binding namespace and resource namespace are therefore separate incumbent currentness domains at D64 shadow scope. Both renewal rules remain cooperative/quiescent and retain explicit demotion triggers for higher availability or external persistent-handle requirements.

## Current frontier

HOSTILE-OS remains `INTEGRATED_SHADOW_CANDIDATE`. D64 activity capacity, activity/binding lifecycle composition, resource-binding scale, activity/binding namespace renewal, resource namespace renewal, maskable-IRQ coherence for bind/final-detach, and the 8 KiB evidence envelope are earned at their stated bounded scopes.

D64/IRQ01 science is CLOSED PASS at `c5c3fff717f49f35f6a5eaf6e1f41b75d8841e83`. A real IRQ0 observer saw the preregistered orphan/mixed resource-lifetime state when admitted inside unprotected bind publication and final detach. Masking IRQ0 across each current six-instruction coupled region prevented that observer from accepting the mixed state. The separate adoption review makes the coherence requirement incumbent at the current one-core maskable-IRQ scope; six instructions is current witness cost, not a universal constant.

The next P0 pressure is **clean-restart persistence for the expanded D64 relation**. I001 earned persistence/rebind for a smaller durable record, but the 64x20 binding/resource relation plus separate activity/resource namespace currentness has not been reconstructed across restart. The first persistence discriminator must keep durable identity/value separate from volatile bindings and fresh-runtime epochs, and must not bundle crash/partial-write durability, filesystem semantics, stronger concurrency, or native storage transport.

Quiescent rekey availability remains open: permanently live activity/binding/resource state can starve renewal. Native storage transport remains scope-dependent while firmware borrowing is allowed.

GitHub publication is now operational: the first verified publication bound canonical local HEAD `1ac99c83e5eaf99435a0d65601f2df931d4d36db` to remote publication HEAD `d10c6e398ed815b3042ff0f4beee960c2f16f458`, with research included and the oversized historical toolchain payload carried by LFS. Publication remains mandatory at substantive-pass end.

R3.1 remains the adopted in-house SOP surface with R6 parent lineage/fallback; SOP authority and HOSTILE-OS architecture authority remain separate.

## HOSTILE-OS architecture promotion

Separate promotion review `research/audits/HOSTILE_OS_ARCHITECTURE_PROMOTION_REVIEW_2026-08-30.md` is sealed at `eb3e0296339e3735880005e4e20163b31eadbe78`, SHA-256 `ba435ed10ea9ca4fdeb003cefaf6cc70b82767c7573b2d861b327c0259b8abaa`.

The strongest earned architecture posture is `INTEGRATED_SHADOW_CANDIDATE`. This makes the surviving relation/state lineage the incumbent integrated HOSTILE-OS research architecture candidate. It is explicitly not final, canonical, production-ready, or replacement-ready. It remains demotable under later evidence.

Dedicated posture surface: `research/architecture/HOSTILE_OS_ARCHITECTURE_POSTURE.md`.

Promotion commit: `46cbb52ba70a32bb0f6478ca189dcaf0ab992d6f`. Posture SHA-256: `8717bbed309888d689a47bff5b15d21c36e904f43084217ec3952e65ecd34fe8`.

This promotion does not modify R3.1/R6 workflow authority.

## Target-boundary decisions after promotion

`research/plans/HOSTILE_OS_TARGET_BOUNDARY_DECISIONS_2026-08-30.md` is sealed at `36efc0f49d995e08626bd0d6b9fdba85e61fb91b`, SHA-256 `0a8f71d1a7a29186ce46099bc5c25876471a840b3e2409d5f92e05bfbfba6fb5`.

Current target rules: firmware is an explicit borrowed boundary; higher device/storage posture prefers bootstrap-only firmware plus owned transport; capacity is finite/configured/observable; generation/epoch is width-parametric and fail-closed before wrap; current concurrency scope is single-core/maskable-interrupt; persistence scope is clean restart; physical hardware is a higher-assurance gate.

Future mutating experiments are governed by `research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md`, SHA-256 `7fa0ab4fa451ac30d5d28e6a8d8062fda0ef1af272e464eeb7939313712484f1`: run-local exact input snapshots and manifest must exist before build/execution.

## Authority state

- R3.1 is `ADOPTED_IN_HOUSE_SOP`.
- `replacement_ready=true` for operational SOP-surface replacement only.
- R6 remains preserved parent lineage/fallback authority; foundation promotion remains false.
- No campaign result has promoted a final architecture.

## Working communication rule

Plain language around the mechanism; proper language for the mechanism. Mechanism first, precision second, style third. Technical vocabulary stays when it names a real distinction.

## 2026-08-30 superseding frontier delta — PR01 and overnight closure

This section supersedes the older sentence that expanded D64 clean-restart persistence is the next P0 seam.

D64/PR01 is now CLOSED PASS at bounded clean-restart scope. Controlling run `20260830T065500Z_d64_pr01_persistence_04` passed two distinct QEMU boots, exact evaluator, static closure, and independent audit. A subsequent 240-iteration overnight replay completed 240/240 with zero failures. This is reliability evidence, not 240 additional science passes.

A separate 3304-cycle earned-chain overnight regression campaign produced 22463 passes and 660 failures, all in I001. Retained I001 failures completed both boots exit33 and passed static closure but observed `IRQ_EVENT=2` where the historical exact evaluator expects `IRQ_EVENT=1`. This is an open evaluator/timer-count semantic seam, not yet an architecture demotion.

The next P0 scientific pressure must be selected from the **current** open-seam set: I001 IRQ-count discriminator, quiescent-rekey availability, production epoch/generation exhaustion policy, crash/power-loss persistence, stronger concurrency, native transport, physical hardware, arbitrary workload scaling, or another newly justified pressure. Do not resume from the stale pre-PR01 frontier.

## 2026-08-30 superseding embodiment/reproducibility delta

`os/` is no longer intentionally empty. A bootable **RESEARCH PURPOSES ONLY** embodiment now exists at `os/research_only/i001_reference/`.

This embodiment is seeded from the whole-workload I001 integrated witness and is explicitly not final architecture/release promotion. Its repo-contained LF source rebuilds the controlling I001 machine bytes exactly on the qualifying local toolchain:

- stage1 512 bytes, SHA-256 `bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8`
- stage2 raw 2478 bytes, SHA-256 `2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be`
- initial disk SHA-256 `b9c79c821d0be352132e940201f23d1e2bcd0456d994a1a142fd01a183bc4218`

The new runner booted two distinct QEMU processes (PIDs 27432 and 27240), both completed exit33, with no host disk write between boots. `VERIFY_PACKAGE.py` / `verify.py` passed all required reproduction checks. The durable reproduction packet is under `research/reproduction/I001_RESEARCH_ONLY/20260830T195250Z_i001_reference_reproduction_01/`.

The historical I001 exact evaluator is unchanged. The research-only verifier reports `historical_exact_irq_event_one` but does not require exact-one; the 3304-cycle I001 `IRQ_EVENT=2` seam remains open science.

Root `.gitattributes` now establishes LF canonical text and binary `-text` rules. Historical RB02 source receipts were independently checked: all 12 snapshots still match sealed hashes, and all 12 canonical Git blobs are classified `CRLF_NORMALIZED` relative to those historical Windows receipt hashes.

GitHub durability is now explicitly whole-project: every unique project datum must be admitted into the canonical folder tree or losslessly archived/manifested before a meaningful turn closes. `os/` remains independently sparse-checkout/buildable and may not depend implicitly on R&D trees.

- The captured embodied reproduction also matched the historical I001 executable SHA-256 values for Clang, LLD, llvm-objcopy, QEMU, and Python exactly.- A clean fresh-output reproduction packet 02 is now the preferred reviewer record: ambient missing-tool discovery failed closed as designed; `HOSTILE_LLVM_BIN` then rebuilt exact historical machine bytes; QEMU PIDs 3596/13712 both exited33; verifier PASS. Packet 01 remains retained as the first reproduction capture.

## 2026-08-30 superseding IRQCOUNT01 closure

I001/IRQCOUNT01 is CLOSED PASS at tested one-core real-IRQ0 scope. Science close commit: `0614b06`.

Controlling run: `research/integration/I001_IRQCOUNT01/runs/20260830T203401Z_i001_irqcount01_01`.

The run used real PIT/PIC IRQ0 and produced:
- ONE: event 1, valid relation, semantic accept, wake 1, explicit progress 2, exact-one control accept;
- MULTI: event 2, same valid relation, same semantic accept/wake/progress, exact-one control reject;
- BADREL: event 2 with stale generation relation, semantic reject, wake/progress remain 0.

Evaluator 5/5, static closure 15/15, independent audit 11/11, QEMU COMPLETED exit33, all nine controlling inputs snapshotted including preregistration + Amendment A, originals unchanged.

A full reconciliation of the 660 historical I001 overnight reds found exactly one signature: Boot1 differs only at zero-based line 13 (`IRQ_EVENT=1` -> `IRQ_EVENT=2`); Boot2 is exact in all 660. They remain historical evaluator FAIL records, but are now interpreted as exact-evaluator overbinding for this tested consequence rather than mechanism regressions.

The living research-only verifier now accepts only the tested event-count set `{1,2}` and rejects `>2`; the historical exact-one evaluator remains sealed unchanged.

The previous I001 IRQ-count seam is therefore closed at tested count-1/count-2 scope. Counts >2, loss/coalescing, event-counter wrap, stronger concurrency, and physical hardware remain open.

The next P0 research candidate is faulted-restart durable-record integrity: distinguish newest complete durable meaning from torn/corrupt updates before attempting physical power-cut claims. See `research/plans/D64_FAULTED_RESTART_DURABLE_RECORD_PLAN_2026-08-30.md`.

## 2026-08-30 external-host reproduction and transplant portability delta

An operator-supplied Opus report states that I001 was independently reproduced from a clean clone on a different host/OS using Clang 18.1.3, different LLD, and QEMU 6.2.0. The outside report says the controlling stage1/stage2 machine bytes reproduced exactly and the two-boot workload completed in two distinct QEMU processes exit33 with no host disk write between boots. It observed `historical_exact_irq_event_one=true` in that one run.

Foreign raw build/run artifacts were not supplied in this thread, so the claim is recorded as **external full-rerun report**, not locally hash-verified foreign evidence. The raw supplied text and adjudication are preserved under `research/external_review/`; a compact external reproduction record is under `research/reproduction/external/OPUS_I001_2026-08-30/`.

The report exposed three portability defects. Two were independently verified directly in current repository code/archive state, and the third is a verified hermeticity dependency:
- `find_tool()` resolved tool paths before exec, which can destroy LLVM multi-call argv[0] identity on POSIX symlinks;
- the historical QEMU transplant wrapper omitted `QEMU_MODULE_DIR` even though PATCH_002 contains `accel-tcg-i386.so`;
- I001 `run.py` allowed QEMU's unrelated default NIC, adding option-ROM dependency to a workload with no networking responsibility.

Repairs are now implemented:
- invocation path preserved; separately resolved identity path/hash recorded;
- `run.py` supports/infer QEMU module directory and passes `-nic none`;
- deterministic `HOSTILE_OS_SMUGGLE_PATCH_003.zip` supersedes wrapper behavior without rewriting old packages;
- portability gate passes all seven repository checks;
- local exact-byte + two-boot I001 regression remains PASS.

Root LF `.gitattributes` was already present before this external report, so that donor recommendation was stale relative to current HEAD.

This strengthens reproduction maturity and infrastructure discipline but does not change sealed I001 science or architecture authority. The post-IRQCOUNT01 science frontier remains faulted-restart durable-record integrity.

## 2026-08-30 superseding FR01 faulted-recovery closure

D64/FR01 deterministic faulted durable-record recovery is CLOSED PASS. Science close commit: `78efb0e29f94b374c129f0e0ed936e4b84e6ed84`.

Controlling campaign:
`research/persistence/D64_FR01/runs/20260830T212145Z_d64_fr01_01`

Closure:
- 41 preregistered fixtures / 41 fresh QEMU processes;
- all QEMU `COMPLETED` exit33;
- evaluator PASS 8/8;
- static/source closure PASS 21/21;
- independent audit PASS 16/16;
- 16/16 run-local controlling inputs hash-clean, including Amendments A/B/C;
- stage1 512 bytes + `55 aa`;
- stage2 raw 1454 bytes inside 8192-byte envelope;
- every read-only fixture disk hash unchanged through guest execution.

Adopted tested shadow rule:
- two independent durable sector candidates;
- 24-byte durable payload + CRC-16/CCITT-FALSE + `CMIT`, 30 logical bytes total;
- validate structure/CRC/commit **before** sequence ordering;
- newest unambiguous valid record wins;
- invalid newer record falls back to older valid record;
- equal-sequence conflicting valid records fail closed `X`;
- no-valid fails `N`;
- selected prior epoch255 fails `G` before namespace wrap/reconstruction;
- successful recovery reconstructs fresh D64 runtime relation under fresh epochs and rejects historical handles.

Critical discriminators passed:
- F03: corrupt seq3 B -> checked `SELECT=A`, naive `NAIVE=B`;
- F06: balanced corruption kept simple additive sum 522 == 522 while CRC changed 13932 -> 6841; checked selector rejected B;
- F08: both invalid -> `N`, no value exposure;
- F10: equal-sequence conflicting valid records -> `X`, no value exposure;
- F11: epoch255 -> `G`, no runtime reconstruction;
- F12: every logical tear boundary0..29 rejected torn B and fell back to A/value71.

Three non-science/transport scars remain preserved:
- pre-QEMU launcher function-shadow failure;
- all-41 IO_FAIL campaign from invalid floppy CHS mapping;
- all-41 IO_FAIL campaign from trusting clobbered incoming DL rather than qualified stage1 saved boot drive at physical0x7c4b.

Authority ceiling remains deterministic preconstructed media-state recovery only. No real power-cut, sector atomicity, cache ordering, or physical-device claim is earned.

Next P0 candidate: controlled interruption of **actual guest durable writes**, using the FR01 reader/selector unchanged to classify resulting disk states. Build plan: `research/plans/D64_INTERRUPTED_DURABLE_WRITE_PLAN_2026-08-30.md`. It is not preregistered yet.

## 2026-08-30 original-thesis continuity audit

A frozen original-thesis/Commander’s-Intent monograph supplied by the operator was audited against the current C002/C003/I001/D64/PR01/FR01/WT01 lineage.

Audit artifact:
`research/audits/ORIGINAL_THESIS_TO_CURRENT_STATE_AUDIT_2026-08-30.md`

Verdict:
- `ORIGINAL_THESIS_CONTINUITY = STRONG`;
- `PROJECT_DRIFTED_INTO_DIFFERENT_MISSION = false`;
- `ARCHITECTURE_DEMOTION_REQUIRED = false`;
- `PROCESS_DOCTRINE_DRIFT_EXISTS = true` because post-C003 localized experiments no longer literally use a new 20-pass campaign for each seam;
- `NEW_ONTOLOGY_LOCK_IN_RISK = true` for repeated `activity/binding/resource` terminology;
- `EMBODIMENT_LAG_RISK = true` because the runnable I001 research body lags later D64/FR01 shadow science.

The strongest continuity evidence is that later pressure repeatedly **re-earned extra state** when simpler compositions failed: completion state, service history, bounds, generation/epoch, explicit initialization, shared lifetime, IRQ coherence, CRC/commit integrity, and validation-before-sequence. This is evidence against a one-way minimalist ideology.

New continuity guard:
`continuity/13_ORIGINAL_THESIS_GUARDS_AND_METHOD_REVISIT_2026-08-30.md`.

WT01 preregistration remains unchanged. Its currently untracked probe implementation is provisional/unsealed and has not been smoke-qualified or executed.

## 2026-08-30 WT01 closure and post-WT01 convergence

D64/WT01 controlled guest-write termination boundary is CLOSED PASS. Science close commit: `0553f3254c6a98e41f5f3c3a6ac519a271bf0a66`.

Controlling run:
`research/persistence/D64_WT01/runs/20260830T225457Z_d64_wt01_01`

Verified closure:
- 45 controlling QEMU processes total;
- 5/5 calibration runs measured the same first media-transition guest step `T=547`;
- every pre-transition inspected B state was exact ZERO;
- every first changed B state was exact FULL seq2/value72;
- K0 5/5 and KPRE 5/5 preserved ZERO B and sealed FR01 recovery selected A/value71;
- KPOST 5/5 and CLEAN 5/5 preserved FULL B and recovery selected B/value72;
- A remained unchanged in every controlling writer case;
- no controlling B state classified `OTHER`;
- every recovery overlay preserved exact A/B hashes;
- evaluator PASS 12/12; static PASS 16/16; independent audit PASS 13/13;
- 15/15 controlling run inputs verified from committed Git-object bytes.

WT01 earns only the tested QEMU/BIOS/raw-directsync observation boundary and recovery consequence. It does not earn actual torn-write impossibility, physical power-loss atomicity, physical-device guarantees, non-directsync cache semantics, or multi-sector ordering.

WT01 adoption is recorded at `research/persistence/D64_WT01/D64_WT01_ADOPTION.md`.

The original-thesis method revisit is now closed by `continuity/14_RESEARCH_CADENCE_DOCTRINE_2026-08-30.md`: broad open-ended domains retain exact 20-pass campaigns; already-localized seams may use preregistered targeted descendant experiments; at most 5 descendants may accumulate before mandatory reconciliation.

The post-WT01 embodiment convergence review decides the current I001 research-only body should remain immutable and a new versioned `os/research_only/d64_reference_v2/` is due. The build plan is `research/plans/D64_RESEARCH_OS_V2_EMBODIMENT_PLAN_2026-08-30.md`.

A separate ingress receipt records a remaining cross-plane durability seam for the two newly uploaded frozen intent/history files: filenames, sizes, hashes and derived audit are in Git, but their exact `/mnt/data` source bytes are not yet claimed to be inside the Windows Git worktree. See `research/audits/UPLOADED_FROZEN_INTENT_INGRESS_RECEIPT_2026-08-30.md`.

## 2026-08-30 D64 v2 current research reference admission

`os/research_only/d64_reference_v2/` is now admitted as **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**.

Admission commit: `9332d34ac7cf0043a5851632aab698fe61967eef`.

Final admitted-state Git tree:
`e7e9c08458bd9573ff4bcd60b9193d88adb26b21`.

Measured integrated body:
- stage1 512 bytes + `55 aa`;
- named state 3467 bytes;
- stage2 raw 3845 bytes;
- total linked stage2 memory 7440 / 8192 bytes;
- envelope headroom 752 bytes;
- one `run.py --mode all` invokes 8 QEMU boots;
- integrated verifier PASS 17/17.

Reviewer layers now embodied together:
- D64 finite activity/binding/resource capacity/currentness/shared lifetime;
- real IRQ0 count1/count2 semantics with stale-relation rejection;
- two-boot durable write/recovery with no host write between boots;
- FR01-compatible validation-before-sequence selection and fresh reconstruction;
- five bounded faulted-media reviewer cases.

An exact `git archive HEAD os` export from the admitted commit was built/run/verified in isolation. `research/`, `continuity/`, `authority/`, and `handoffs/` were absent. The final isolated suite again passed all eight QEMU boots and verifier17/17.

Final readback packet:
`research/embodiment/D64_REFERENCE_V2_FINAL_ADMISSION_READBACK_2026-08-30/`.

The historical `os/research_only/i001_reference/` Git tree remains exactly `bd641bcd658fbf558f15a9226f96058351d5794c`, equal to the pre-v2 anchor at `c407449`.

Admission does not change architecture posture. `FINAL_ARCHITECTURE=false`, `PRODUCTION_READY=false`, `GENERAL_PURPOSE_RELEASE=false`.

The v2 body uses only 752 bytes of remaining qualified stage2 headroom. Do not add mechanisms casually; future embodiment additions require explicit byte/Pareto pressure or a new loader-envelope qualification.

## 2026-08-30 Opus second reproduction / QEMU firmware-data closure

Opus reported a second independent I001 reproduction on the repaired tree and confirmed the prior tool-invocation, module-dir, NIC, IRQCOUNT/adjudication behavior. The foreign raw packet is still not supplied; authority remains `EXTERNAL REPRODUCTION REPORTED`, not locally hash-verified foreign evidence.

The reported remaining portability finding was audited and is technically correct with an important nuance:
- both Python runners had module-dir support and `-nic none` but no direct QEMU firmware/data-dir -> `-L` support;
- existing PATCH_003 wrapper already supplied `-L "$HERE/share/qemu"`;
- therefore the gap was `KNOWN_IN_WRAPPER / MISSING_IN_DIRECT_PYTHON_RUNNER`, not total project absence.

Current D64 v2 direct runner is now repaired at commit `5f57ad17d3daddd2ef26bc4eda4f98ebbaf91af5`:
- `HOSTILE_QEMU_DATA_DIR`;
- `HOSTILE_QEMU_FIRMWARE` alias;
- adjacent `share/qemu` / `share` discovery, requiring `bios-256k.bin` for auto-discovery;
- selected directory passed with `-L`;
- `qemu_data_dir` recorded in run receipt.

Exact committed `git archive HEAD os` isolated readback:
- no research/continuity/authority/handoffs roots;
- full v2 build + eight reviewer boots + verifier17/17 PASS;
- local QEMU data dir auto-selected `C:\Program Files\qemu\share`;
- all eight QEMU argv arrays include `-L` plus the selected data directory;
- v2 stage2 raw hash unchanged;
- historical I001 tree remains unchanged and uses PATCH_003 for transplanted execution.

Closure packet:
`research/reproduction/QEMU_DATA_DIR_CLOSURE_2026-08-30/`.

No science or architecture authority changes.

## 2026-08-30 D64/V2-PARETO01 and blind-comparison gate

Frontier-selection audit chose Pareto characterization over convenience growth, immediate hardware science, or premature mature-OS comparison.

D64/V2-PARETO01 CLOSED PASS as engineering characterization at source HEAD `d5c96891fbef796caac9b3070e29e63d8cb9352f` / v2 body tree `03af56020afe6d117836133c0e33092d098fc13e`.

Population:
- 10 clean builds;
- 20 core runs;
- 20 restart runs;
- 20 faulted-media runs;
- 20 all-mode runs;
- 20 verifier-only runs;
- exactly 320 QEMU boots.

Independent receipt adjudication found 80/80 reviewer runs and 320/320 boots exact: exit33, expected traces, and restart/fault semantic side conditions all PASS.

Measured static burden remains stage1 512, stage2 raw3845, named state3467, linked7440/8192, headroom752.

Median host command costs on this exact environment:
- clean build ~599 ms (first-build outlier ~8.85 s);
- core ~339 ms;
- restart ~512 ms;
- five-case faulted-media ~1.24 s;
- all-mode ~1.93 s (two host/QEMU outliers ~4.58 s and ~9.56 s);
- verifier ~42 ms.

The timing tails preserve exact guest traces and localize to host/QEMU/toolchain reproduction variance, not guest semantic instability. These are not architecture latency measurements.

No burden discriminator currently justifies optimizing the representation or enlarging the 8 KiB loader. The remaining 752 bytes are a pressure budget, not free feature space.

The previously deferred mature-OS blind-comparison maturity gate is now satisfied at governance level. Comparison is eligible to open under strict quarantine: external systems may supply responsibility comparison/questions, never architecture authority or copied answers. See `research/audits/MATURE_OS_BLIND_COMPARISON_MATURITY_GATE_2026-08-30.md`.

## 2026-08-31 C004 authority/protection campaign closure

C004 — mutually-untrusted authority/protection re-derivation — is **CLOSED 20/20**. P20 hard stop was obeyed; no P21 exists.

Campaign close: `research/authority/C004/C004_CAMPAIGN_CLOSE_2026-08-31.md`.
Adoption review: `research/authority/C004/C004_ADOPTION_REVIEW_2026-08-31.md`.

The adopted bounded grammar separates trusted caller provenance, operation-specific authority, attenuation, authority currentness/revocation, finite reusable authority storage, explicit reuse initialization, authority/resource lifetime, effect-time revalidation and restart authority epoch, all behind a non-bypassable enforcement boundary for actually untrusted code.

P19 composed these rules under two distinct ring3 caller selectors. P20 showed a B caller claiming A cannot replace CPU-supplied protected provenance; the bad trust-claim control wrote55.

Process scars remain explicit: P17 prereg was fixed before runtime but not Git-sealed before implementation; P18 first build failed pre-QEMU due duplicate loader signature; P19 first controlling attempt is UNKNOWN due caller-frame offset bug before Amendment A.

Current v2 research body remains runnable/current as an embodiment generation but now lags C004 authority science. Do not consume its remaining752 bytes casually.

The next broad comparison pressure is concurrency/coherence beyond one-core maskable IRQ scope.

## 2026-08-31 H1 first physical target adopted

The operator's HP Pavilion p2-1120 is adopted as H1, the first planned real HOSTILE-OS hardware target. Verified published constraints include AMD E2-1800 1.7GHz, AMD A45 FCH, 4GB DDR3-1333, 500GB SATA and Radeon HD7340.

A QEMU x86_64 constraint proxy is qualified at q35 + phenom proxy CPU + 2 vCPU + 4096MiB + 500GiB qcow2. Current d64_reference_v2 core+IRQ reviewer boots and exits33 under this profile. The proxy is not an exact hardware clone; A45/CPU/GPU/firmware/PCI identity remains physical-probe work.

Orthogonal donor architecture may now be used as adversarial donor material only after the HOSTILE-OS seam is stated locally. First-principles hostile derivation remains the architecture-generating method.

C005 actual frontier is P01/P02 CLOSED PASS; P03 preregistered with provisional unsealed implementation.

## 2026-08-31 per-turn semantic/hash freshness directive

Commander explicitly strengthened continuity: every meaningful turn must keep decisions, research, Commander's Intent and all continuity/reincarnation surfaces fresh.

Adopted policy: `continuity/15_PER_TURN_SEMANTIC_AND_HASH_FRESHNESS_POLICY_2026-08-31.md`.

Interpretation is append-only-safe: living indexes are semantically reconciled each turn; sealed/historical evidence is hash-attested rather than rewritten for timestamp theater. `continuity/CURRENT_TURN_FRESHNESS.json` is the machine-readable turn-close attestation.

Current science frontier at this checkpoint: C005/P01 and P02 CLOSED PASS; P03 preregistered and implementation sealed at `2f8d7967a1a11c4124f2b095feb7cb62832cfd44` (`Seal C005 P03 publication-order implementation`), science run not yet claimed at this freshness-policy checkpoint.

H1 remains first physical target; QEMU proxy qualified; Bochs3.1 installed as an independent x86 emulator/debug witness, not an exact H1 clone. Full Bochs device-surface qualification remains open.

## 2026-08-31 post-C005 / H1 SMP convergence / D64 v3 current state

This section supersedes earlier live-frontier paragraphs that still describe C005/P03 or P13 as active. Historical sections remain preserved for chronology.

### Campaign state

- C004 authority/protection: **CLOSED20/20**, hard stop obeyed, no P21.
- C005 multicore concurrency/coherence: **CLOSED20/20**, hard stop obeyed, no P21. Close/adoption: `research/concurrency/C005/C005_CAMPAIGN_CLOSE_2026-08-31.md` and `C005_ADOPTION_REVIEW_2026-08-31.md`.
- C005 adopted responsibilities include inter-CPU atomic/current transitions, publication order, safety/progress separation, lifetime participation, stale-writer recovery currentness, bounded wrap/exhaustion handling, fresh restart concurrency state, IRQ+CPU shared coherence, and trusted release provenance. The working compression remains responsibility vocabulary, not primitive ontology.

### Post-C005 representation/Pareto convergence

H1-SMP-MIN01 proved second-core transport/participation fits the existing8192-byte stage2 envelope: linked7811, headroom381, scratch50.

Candidate A / MIN02 (whole-operation atomic gate around legacy relation call) PASS: linked8189, headroom3, scratch60. It preserves direct trusted callers but is an unnecessarily brittle first-H1 fit.

Candidate B / MIN03 (BSP sole relation mutator + explicit AP request/result mailbox) PASS: linked8089, headroom103, raw4494, scratch62, semantic state3467. AP does not call the relation mutation function or write legacy relation-call scratch; payload is published before request and result before completion. QEMU S/C and Bochs core/restart/fault regressions passed.

Successor review selected **Candidate B** for the current H1 requirement because it buys100 linked bytes/headroom versus A while preserving the existing single-writer relation internals and does not add unrequired direct-multicore mutation capability. A remains a valid alternate; C is deferred/not disproven. Reopen triggers are recorded in `research/integration/H1_SMP_SUCCESSOR_ADMISSION_REVIEW_2026-08-31.md`.

### Current embodied research reference

`os/research_only/d64_reference_v3/` is now **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**.

Promotion commit: `af8a11eb055b486c38cefb3676066b3e6d808f32`.

Admitted machine-body source was independently built/run/verified from the os-only v3 package after runner Amendment A:
- stage1 512 bytes with55aa;
- stage2 raw4494 bytes;
- linked stage28089/8192;
- headroom103;
- named semantic state3467;
- implementation scratch62/128;
- exact H1 two-core S trace `IDS=0001 / OWNER=BSP / MAIL=WW11`;
- inherited core+IRQ exact;
- restart boot1 + fresh-process read-only boot2 exact;
- five faulted-media cases exact/read-only;
- verifier PASS20/20;
- no build/run dependency on research/continuity/authority/handoff trees.

The successful all-mode standalone run performed **nine QEMU boots**:1 SMP +1 core +2 restart +5 faulted-media. A prior statement of eight is corrected here.

The first standalone v3 run never reached guest execution because its new runner attached the auxiliary H1 target QCOW read-only on Q35 IDE; QEMU returned `Block node is read-only`. Scar A is retained. Amendment A changed only that auxiliary target-disk transport and did not change stage1/stage2 or guest criteria.

`d64_reference_v2/` and `i001_reference/` remain preserved prior lineage; v2 was not rewritten to create v3.

### Current H1 cross-emulator state

Current-reference cross-emulator replay is controlling at:
`research/targets/H1_EMULATOR_REPLAYS/runs/20260831T103212Z_h1_emulator_matrix_01`
with source Git HEAD `af8a11eb055b486c38cefb3676066b3e6d808f32`.

Result: QEMU H1 proxy PASS; Bochs independent core PASS; Bochs restart exact/invariants PASS; five Bochs faulted-media cases exact/read-only PASS.

The immediately preceding run `20260831T103138Z...` also passed but is non-controlling because it exercised uncommitted promotion/tool-pointer changes and its recorded source HEAD did not bind those runner bytes.

Current QEMU transplant portability gate follows v3 and PASS9/9.

### Current authority ceiling / open seams

- `QEMU_H1_PROXY_PASS + BOCHS_PASS != H1_PHYSICAL_PASS`.
- Physical H1 CPUID/PCI/BIOS/ACPI/storage/interrupt/multicore behavior remains unqualified.
- v3 closes the selected H1 C005 multicore embodiment gap but does **not** imply all C004 authority/protection rules are embodied.
- Candidate-B owner progress dependency is explicit; stalled-owner recovery/fairness are not current H1 guarantees.
- Arbitrary CPU count, weak-memory cross-architecture rules, DMA/IOMMU/NMI/SMI, production progress/timing and final ABI remain unearned.
- Foreign Opus raw packet remains externally reported rather than locally hash-verified.
- Exact uploaded frozen-intent source-byte ingress to Windows Git remains an open cross-plane seam.

### Immediate frontier

P0 local work after durable turn close: prepare a non-destructive physical-H1 qualification/boot/probe package around v3 so operator hardware touch is minimized and exact physical observations can replace VM assumptions.

P1 local convergence: representation/Pareto review of the still-unembodied C004 authority/protection shadow against v3; do not consume the remaining103-byte envelope by convenience.

No operator input is required until an actual H1 power/boot/probe action is ready or another genuinely external evidence seam becomes blocking.

## 2026-08-31 zero-re-explanation publication pass

Commander directed a full-project GitHub/reincarnation close such that the next thread can continue with **zero need for re-explanation**.

Current canonical base at pass start: `fa86af05b845765626c56e16124a6d2760d825ad` (`Refresh post-C005 D64 v3 continuity and reincarnation`), clean worktree.

New current ingress surfaces:
- `NEXT_THREAD_START_HERE.md`;
- `continuity/16_ZERO_REEXPLANATION_REINCARNATION_2026-08-31.md`.

These do not replace historical evidence. They bind the current D64-v3/H1 frontier to the complete historical/decision/scar/transcript tree and explicitly tell future threads how to distinguish current truth from older chronology.

No architecture/science promotion is implied by this continuity pass.

## 2026-08-31 publication scratch-space recovery

Zero-re-explanation checkpoint `4dccb659...` passed committed reincarnation81/81, freshness and durable-repository gates. First async publication wrapper call did not start (`EXECUTION_SUBMIT_FAILED / job not found`). Qualified detached publisher then reached exact immutable archive generation but failed with `Errno28` because E: lacked space for full archive+mirror expansion. Canonical content remained clean and remote success was not claimed.

Publication tooling now supports external scratch root via `HOSTILE_GITHUB_PUBLISH_SCRATCH_ROOT`; rerun uses D: with ~153GB free. This is infrastructure hardening only, not science/architecture change.

## 2026-08-31 zero-re-explanation publication verified

Canonical `d4292e55170d8f4457b2b6aceacc5d6ed6a17e6b` was fully published after the D:-scratch hardening. GitHub publication commit `9a573d63fb96a170db4801cc113ade1a96227324` carries4891 tracked files /3,183,252,214 pre-LFS bytes with research included and canonical-advanced=false. Independent `ls-remote` readback matched.

A fresh remote blob-filtered/depth1 sparse checkout of `os/` at `9a573d63fb96a170db4801cc113ade1a96227324` materialized D64 v3 while leaving `research/`, `continuity/`, `handoffs/`, and `authority/` absent. Therefore full-ledger publication and OS-only retrieval are both verified at the remote.

Close receipt: `continuity/17_ZERO_REEXPLANATION_PUBLICATION_CLOSE_2026-08-31.md`.

No science/architecture authority changes.

---

## 2026-08-31 — SOP/continuity control update (superseding method note)

No science, architecture, D64-v3 embodiment, or engineering frontier changed in this update.

The adopted R3.1 in-house SOP was reverified against the exact re-supplied archive (`4d205becc2413889bdb37c6b6ff7513d6f759a7dff1d9f9b8fddaddd8235a278`): 45 manifest payload entries matched the canonical extracted tree and ZIP bytes with zero missing/mismatch; the ZIP contains 46 files including its manifest.

New active SOP delta: inspect durable evidence first; if a load-bearing unknown remains, or unexplained traces cannot be identified, ask the commander rather than guessing or mutating across the gap. This is compatible with zero-re-explanation: ask only where durable evidence genuinely ends.

Current engineering frontier remains unchanged:
- P0: non-destructive physical-H1 boot/probe/qualification package around D64-v3;
- P1: C004-to-v3 authority/protection representation/Pareto review without convenience growth.


---

## 2026-08-31 superseding frontier delta — H1 probe instrument qualified / C004 Pareto review closed

This section supersedes the prior immediate-frontier paragraph that still listed physical-H1 package preparation and C004->v3 Pareto review as open local work.

### P0 physical-H1 preparation

The non-destructive H1 observation instrument is now **QUALIFIED FOR PHYSICAL-USE PREPARATION** under the emulator proxy. Physical H1 itself remains **UNQUALIFIED**.

Preregistration: `2828ee9b73b53c53c1c878d9ebf021957ec2f2c6`.
Amendment A: `a32da98938e96f62e698fc4418632fb231343019`.
Implementation: `51fafe6a61db701a592b6a0564b9b374d748d8b2`.
Controlling run: `research/targets/H1_PHYSICAL_PROBE/runs/20260831T180418Z_h1_physical_probe_qemu_01`.

Qualified instrument facts:
- QEMU PID 7940, exit67;
- required CPU/BOOT/FW/IRQ/E820/PCI/BEGIN/END markers all present;
- static safety gate PASS13/13;
- physical stage22460 bytes inside8192-byte probe envelope;
- physical image SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`;
- physical image has no QEMU debug-exit sequence and no target-disk write path;
- exact ready image and manifests are under `research/targets/H1_PHYSICAL_PROBE/package/`.

Preserved scars:
- Scar A: EFLAGS.ID CPUID-availability precheck incorrectly suppressed CPUID under the proxy; repaired before controlling qualification.
- Scar B: first static checker incorrectly banned all stage2 INT13 calls; repaired to admit only preregistered read-only AH=08/AH=41 calls.

No proxy observation is physical truth. Missing physical fields may not be filled from QEMU.

### P1 C004 -> D64-v3 authority/protection convergence

`research/audits/C004_TO_D64_V3_AUTHORITY_PARETO_REVIEW_2026-08-31.md` closes the local representation/Pareto seam.

Verified D64-v3 remains `.code16` and contains no current CR0/LGDT/LIDT/LTR/TSS/GDT/ring3/CPL or grant/right/delegation/revocation authority body. The H1 BSP-owner/AP-mailbox rule is trusted-body concurrency ownership, not C004 untrusted caller provenance.

C004/P20's final x86 enforcement witness uses a104-byte TSS alone. That already exceeds D64-v3's total103-byte linked-image headroom before descriptor/gate, rights/currentness, mediator and provenance-handling burden.

Selected Pareto rule:
- do **not** spend the103 bytes on cooperative policy-looking state without a non-bypassable boundary;
- keep C004's adopted grammar as a capability-triggered shadow obligation;
- when actually untrusted execution or direct privileged effects are admitted, qualify the minimum target-specific enforcement representation and either recover space by measured compression/reuse or explicitly qualify a successor envelope.

D64-v3 remains unchanged and current. C004 remains valid and not fully embodied. No C006 is opened by this review.

### Current immediate frontier

The next reality-authority step is the **physical H1 boot/probe packet** using the qualified removable-media image. That step requires operator hardware touch.

No broad new campaign is currently earned merely by campaign numbering pressure. A new campaign becomes lawful when physical H1 or another verified input exposes a new responsibility domain or contradiction that cannot be handled as a bounded integration/qualification descendant.
