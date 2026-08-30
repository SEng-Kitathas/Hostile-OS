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
