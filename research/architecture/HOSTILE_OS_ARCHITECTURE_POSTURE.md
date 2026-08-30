# HOSTILE-OS Architecture Posture

**Last updated:** 2026-08-30
**Current posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Final architecture:** `false`
**Production ready:** `false`
**Canonical replacement:** `false`

## Promotion basis

This posture is authorized by the separate architecture promotion review:

- review artifact: `research/audits/HOSTILE_OS_ARCHITECTURE_PROMOTION_REVIEW_2026-08-30.md`
- review Git commit: `eb3e0296339e3735880005e4e20163b31eadbe78`
- review SHA-256: `ba435ed10ea9ca4fdeb003cefaf6cc70b82767c7573b2d861b327c0259b8abaa`

The review considered the surviving C001 -> C002 -> C003 -> POST-C003/R01 -> I001 evidence lineage.

The promotion is earned primarily because I001 removed the prior bounded integration blocker: one freestanding stage-2 executable carried the main responsibility families together across two distinct fresh QEMU processes under a preregistered workload, exact negative controls, raw durable-sector inspection, static/source closure, and independent cross-check.

I001 science close:

- commit: `e53bea81b5a2b08a3dc27a79eb30c0d38b3e4b2f`
- result: `research/integration/I001/I001_RESULT.md`
- result SHA-256: `41c52da7f2787be5bceafcb204e11f61ef18d4261a75f82c27221a6c974d0ef8`

## Meaning of this posture

`INTEGRATED_SHADOW_CANDIDATE` means:

- this is the incumbent integrated HOSTILE-OS research architecture candidate;
- new HOSTILE-OS design work should start from this candidate unless a stronger branch earns replacement;
- its relation/state distinctions are load-bearing research defaults, not merely speculative vocabulary;
- it may guide implementation and further pressure tests;
- it remains demotable when evidence changes.

It does **not** mean:

- final architecture;
- production readiness;
- universal minimality;
- arbitrary workload support;
- physical-hardware proof;
- general memory/capability safety;
- SMP/NMI/DMA correctness;
- crash-consistent persistence;
- universal rejection of Process/Scheduler/File-style descriptive abstractions;
- R3.1 replacement readiness;
- R6 demotion.

## Incumbent architecture rules

These rules have repeated evidence and survived integrated pressure:

1. **Separate decision/eligibility, notification/wake, and state application.**
2. **Treat currentness as part of runtime identity when reuse, restart, or spanning reads can make bare names stale.**
3. **Keep failure local and explicit unless a global consequence is actually earned.**
4. **Treat reuse, initialization, lifetime, and release as load-bearing behavior.**
5. **Make platform ownership boundaries explicit; restore borrowed firmware-visible state before reusing firmware, or stop borrowing the service.**
6. **Do not promote historical subsystem nouns to primitive architecture species without a discriminator that earns them.**
7. **Expose finite capacity and finite-version exhaustion rather than silently relying on host infinity.**
8. **Keep durable identity/bytes separate from volatile runtime binding/currentness.**

These are incumbent rules, not universal laws. A later verified branch may revise or demote them.

## Current bounded embodiment

I001 controlling embodiment uses:

- one 512-byte stage 1;
- one fixed 4,096-byte stage-2 disk extent;
- 2,478-byte stage-2 raw/linked payload;
- 51 bytes of named runtime state;
- exactly two activity slots;
- 8-bit activity generations with `G` before zero-wrap;
- 8-bit runtime epochs with fail-closed zero-wrap policy;
- one shared-backing record;
- one completion record;
- one real IRQ0 event path;
- one six-instruction wait-binding critical region;
- explicit result codes `W F M O R G X`;
- one 12-byte logical durable record inside a 512-byte sector;
- two fresh QEMU processes for clean restart/rebind.

These numbers describe the current integrated witness. They are not frozen architecture constants unless separately promoted.

## D64 donor-scale qualification pressure

The target-workload ambiguity is now partially closed by `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md`, sealed at commit `bb33e65cf9c88f79b84bc34021eb585ccef33c29`.

D64 is a donor-scale reference profile, not production telemetry. It uses historical donor pressure of 64 simultaneously represented activities, 20 binding references per activity, and 64 global live-resource pressure without importing donor Process/File ontology.

D64/A01 then tested the first concrete scale seam. It is science-closed at commit `ee2982d65fbecb2f8d0c73edc68212a45a092d12`. One generic configured table filled all 64 activity slots, returned explicit `F` on the 65th admission without mutation, released/reused slot 31 through generic code, rejected stale generation 1, and accepted fresh generation 2. The stage-2 witness was 1,528 bytes with 719 bytes of named runtime state.

This resolves the hardcoded-two-slot activity embodiment gap at bounded D64 scope. It does not establish arbitrary capacity, resource-binding scale, or long-running namespace renewal.

A01 is also the first real experiment after I001 to exercise `EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` from the first build. Its run-local input manifest and receipt closure independently verified. A minor static-checker JSON typing scar remains recorded: one truthy manifest predicate was emitted as the preregistration commit string rather than literal `true`; an independent audit recomputed and passed the underlying closure.

## D64 activity-namespace renewal

D64/RK01 is science-closed at `34123fbd89aa9c759dee5c58ec12e27b6dc7ea2f`, result SHA-256 `6b8833690083e83e78ea0bd59f0b1c79b1bc6a7f3c09e365faced69d1ee209c1`. It tested a configured 64-slot activity namespace under an explicit cooperative quiescence/revocation contract.

Verified bounded consequence: live activity, pending completion, live backing, or active relation mutation each reject rekey without namespace mutation; full quiescence permits epoch change plus reset of all eleven activity arrays; immediate pre-rekey handles are rejected; fresh handles succeed; generation reset without epoch change aliases an old token to a new occupant; explicit checked epoch `255 -> 1` works only at the revocation boundary.

The separate adoption review at `762a4e7bd78c3d028afd26407febb17798fac790` made checked quiescent activity-namespace rekey the incumbent D64 shadow rule. This is not live rekey and not general external capability revocation. A permanently live activity may starve rekey; that availability cost remains visible.

## D64 resource-binding frontier and 8 KiB evidence envelope

`research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md` is sealed at `49a42cb45a6f89acbf158debcac4dcbf5e0b1d65`, SHA-256 `2775f5c4c9e4191f3c002fa44d7fdca24fb34a456733c336734906da7b76c02b`. The plan translates D64's 20-reference-per-activity and 64-global-resource pressure into a bounded relation design rather than a donor File/Manager ontology.

Candidate state uses 64 activities, 20 binding cells per activity, 1,280 binding cells total, one binding-resource byte plus one binding-generation byte per cell, and a 64-entry global resource table carrying identity/generation/value/live-count arrays. Core projected relation state is about 3,521 bytes before code/observation state.

Because that state makes the old 4 KiB stage-2 image an artificial evidence limit, a fixed 16-sector / 8,192-byte stage-2 loader was separately qualified. Qualification spec commit `ca21370643b8526ce2d66b4de1f2aec2c78a008d`; qualification close `734674f8a35974433fd6a213e2a2cf1e4de93b43`; result SHA-256 `cdd1b3bd083868067b6d8be2346aa413332f3d8888fcaa1e809cc48bc36610f6`. Controlling run observed a required `0xA5` marker at linked address `0x9FF0`, proving guest visibility near the end of the full 8 KiB loaded extent.

The 8 KiB envelope is infrastructure only. It does not establish resource-binding semantics.

## Target-boundary decisions now in force

Target-boundary plan: `research/plans/HOSTILE_OS_TARGET_BOUNDARY_DECISIONS_2026-08-30.md`, sealed at commit `36efc0f49d995e08626bd0d6b9fdba85e61fb91b`, SHA-256 `0a8f71d1a7a29186ce46099bc5c25876471a840b3e2409d5f92e05bfbfba6fb5`.

The current architecture rules are now clearer:

- firmware is an explicit borrowed platform boundary; after machine-state takeover, firmware reuse requires explicit restore, while a higher target should prefer bootstrap-only firmware plus owned transport;
- capacity is finite, configured, checked before mutation, and has visible exhaustion; I001's two slots are witness capacity only;
- generation/epoch currentness is width-parametric, monotonic within a namespace, and fail-closed before aliasing wrap; no width is "enough" without a declared lifetime bound;
- current concurrency claims are single-core and maskable-interrupt bounded; SMP/NMI/DMA/weak-memory claims are outside the current target;
- persistence claims remain clean-restart only unless stronger durability is explicitly required;
- physical hardware is a higher-assurance gate, not a prerequisite for continued architecture work.

Experiment-provenance hardening is also now specified by `research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md`, SHA-256 `7fa0ab4fa451ac30d5d28e6a8d8062fda0ef1af272e464eeb7939313712484f1`. Future mutating runs must snapshot exact controlling inputs before build/execution.


## D64 resource-binding scale result

D64/RB02 is science-closed at `7d6b518c5198c6d062dd714e80631182bf897b77`. Result SHA-256 `634edb4185e20388f3c80b13b32b5140b35b7ff0be257aa56dd59fc32094767c`. The append-only independent-audit pointer correction is sealed at `28913ad`; correction SHA-256 `cadc77152613553c037f22dcbf1fc3d56acb369013b4dd685cb9d371f7f97a7c`.

RB02 establishes at bounded D64 shadow scope that one generic relation representation can carry 64 activities, 20 binding cells per activity, 1,280 total binding cells, and 64 global resource slots. It also reached the maximum sharing case where all 1,280 binding cells target one resource and the corrected 16-bit live count observed exactly `0x0500`.

The result separates per-activity row exhaustion from global resource exhaustion, preserves shared lifetime across two bindings, rejects stale binding-cell and direct-resource handles after reuse, and shows the weakened index/slot-only controls retarget. No donor File/descriptor/inode/manager ontology is earned.

Controlling stage 2 is 6,432 bytes inside the qualified 8,192-byte envelope; named runtime state is 3,658 bytes.

The science history preserves three attempts: attempt 1 assembly syntax failure before QEMU; attempt 2 exact guest/evaluator success but two static-checker false positives; attempt 3 identical guest source with corrected checker semantics and full closure pass. The tracked `12_independent_audit.json` is a failed local audit scar caused by a wrong receipt key; `13_independent_audit.json`, SHA-256 `a3747b1b850ed31021775346a2add8fb40ed139c70fae710cd9c9e2c541ba5ae`, is the controlling independent audit.


## D64 activity-rekey + binding-state composition result

D64/ARB01 is science-closed at `cdc1aea963f37168e2fdbd317a0beff353ce42c1`, result SHA-256 `4dc29d3ec73edace379fd4200bb5e0e34569429b8f6fb7a9487eba594c629ede`. The controlling run used a 6,591-byte stage 2 with 3,665 bytes of named runtime state.

ARB01 exposes the composition failure if activity identity is cleared while its binding row remains live: a later occupant of the same activity slot can use its own current activity handle and inherit/read the prior occupant's binding relation. Checked activity release therefore now requires an empty binding row.

The composed rekey path rejects orphan binding/resource residue, succeeds only after explicit detach and checked release, resets the 64-slot activity namespace plus all 1,280 binding cells/generations, and preserves the separate resource epoch/generation history. Fresh activity/binding state succeeds after rekey; old activity/binding and direct-resource handles reject under their respective currentness fields.

## D64 resource-namespace rekey result

D64/RR01 is science-closed at `0615f4b2b80e3e7a9d8e6dd727e266d119a623c5`, result SHA-256 `c958531ff4b35bf168e1c650722d48fdb302bc80578ac7373ff45815bdcb449e`. The controlling run used a 6,655-byte stage 2 with 3,665 bytes of named runtime state.

RR01 shows that resource namespace renewal can occur while activity A remains current: live binding/resource state rejects rekey; after explicit detach, resource rekey changes resource epoch `1 -> 2`, resets resource generation/state, and preserves activity epoch/state plus binding-generation history. The old direct resource handle rejects under the new resource epoch; fresh resource and binding handles succeed.

The required negative control resets resource generation without changing resource epoch and causes the saved old direct resource handle to alias the new occupant. RR01 also qualifies one explicit checked resource-epoch `255 -> 1` transition at resource quiescence.

The adoption review at `5126bae647f9d2832262ada8d17ae4ee03e6b5f4` makes checked quiescent resource-namespace rekey the incumbent D64 shadow rule. This is not live rekey and does not cover externally persistent resource handles across namespace retirement.

## D64 binding/resource IRQ-coherence result and adopted rule

D64/IRQ01 is science-closed at `c5c3fff717f49f35f6a5eaf6e1f41b75d8841e83`. Its controlling real-IRQ0 run directly observed the preregistered orphan/mixed binding/resource state when IRQ0 was admitted inside unprotected bind publication and final detach. The protected variants exposed only coherent post-state.

The adoption review `research/architecture/D64_IRQ01_COHERENCE_ADOPTION_REVIEW_2026-08-30.md` adopts, at the current single-core maskable-IRQ D64 scope, the rule that coupled binding-reference visibility and resource lifetime state must form one IRQ-coherent mutation region. The current witness uses six instructions for bind publication and six instructions for final detach; those counts are current implementation cost, not universal architecture constants.

No SMP/NMI/DMA/weak-memory, physical latency, general transaction, persistence, or higher architecture claim follows.

## Open architecture seams

### Resolved at bounded scope — maskable-IRQ observation of binding/resource publication and detach

IRQ01 directly replayed the full D64 binding/resource relation under real QEMU IRQ0 and exposed the mixed-state failure in the unprotected paths. The adopted current rule requires one maskable-IRQ-coherent mutation region for bind publication and final detach. Stronger observer classes remain outside scope.

### P0 — quiescent rekey availability ceiling

Both adopted activity/binding rekey and resource rekey depend on cooperative quiescence. Permanently live state can starve renewal. This remains a demotion/extension trigger for higher availability targets.

### P1 — resource/binding persistence across clean restart

I001 earned clean-restart persistence/rebind for a smaller durable record. The 64x20 binding/resource relation has not been carried across restart. Do not infer persistence semantics for the expanded state by composition alone.

### P0 — native post-takeover transport for higher storage/device posture

Still scope-dependent because current D64 permits explicit firmware borrowing.

### Scope-dependent higher-assurance seams

Physical hardware, arbitrary/dynamic capacity, SMP/NMI/DMA/weak-memory correctness, crash/partial-write persistence, and general capability/memory safety remain unearned unless explicitly targeted.

## Demotion triggers

Demote this posture if verified evidence shows:

1. a load-bearing I001 consequence depended on hidden host mutation or harness synthesis;
2. controlling I001 replay fails under the same qualified environment without an explained environment change;
3. a required target responsibility cannot compose without materially replacing the state model;
4. currentness/lifetime policy silently aliases inside the declared target lifetime;
5. platform ownership/restore is insufficient for the intended target boundary;
6. a simpler candidate provides the same required consequences at a clearly better Pareto vector with equal or stronger assurance;
7. source/provenance integrity of a load-bearing controlling result is invalidated.

## Separate workflow authority state

This architecture posture does not modify PCMMAD engineering/research SOP authority.

Current workflow authority is now:

- R3.1 status: `ADOPTED_IN_HOUSE_SOP`
- R3.1 replacement ready: `true` for operational SOP-surface replacement only
- R6: preserved parent lineage and fallback authority
- foundation promotion: `false`

Adoption commit: `b8912647a5a1fb1fc62cfa8fbe125d3f64b7bc5f`. The sealed R3.1 package retains its original historical metadata and assurance ceiling. Do not merge SOP authority with HOSTILE-OS architecture authority by wording or file placement.

## Next posture gate

The next lawful pressure is **expanded D64 binding/resource clean-restart persistence**. I001 earned clean-restart persistence/rebind for a smaller durable record; the adopted 64x20 binding/resource relation, separate activity/resource epochs, and their currentness rules have not yet been reconstructed across restart.

Keep the first persistence discriminator narrow: distinguish durable identity/value from volatile runtime bindings/currentness, preserve explicit fresh-runtime namespace semantics, and do not bundle crash/partial-write durability, filesystem semantics, native storage transport, or stronger concurrency into the same pass.
