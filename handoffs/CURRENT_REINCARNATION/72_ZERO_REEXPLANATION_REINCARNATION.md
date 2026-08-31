# HOSTILE-OS Zero-Re-Explanation Reincarnation Contract

Date: 2026-08-31
Generated from canonical base HEAD: `fa86af05b845765626c56e16124a6d2760d825ad`
Status: **CURRENT CONTINUITY / REINCARNATION CONTRACT**
Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`
Current embodied reviewer: `os/research_only/d64_reference_v3/` — **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**

## Why this file exists

A fresh HOSTILE-OS thread must be able to continue without asking the operator to restate the mission, project history, research findings, engineering reasons, rejected paths, active caveats, current embodiment, or next frontier.

This file is the interpretive bridge between the historical corpus and the living state. It does not replace exact experiments, receipts, Git history, the Live Shadow, or the Design Thread Stream. If they conflict, use the newest verified artifact and state the conflict.

The rule is:

> **No load-bearing project meaning may exist only in the operator's memory or only in chat.**

## 1. Read order for a new thread

Read these in order before proposing architecture or mutating the project:

1. `NEXT_THREAD_START_HERE.md`
2. `continuity/LIVE_SHADOW.md`
3. this file
4. `continuity/01_COMMANDERS_INTENT.md`
5. `continuity/02_CURRENT_STATE_AND_FRONTIER.md` — read the newest dated/superseding section as current; older sections are chronology
6. `continuity/10_ENGINEERING_DECISION_LEDGER_2026-08-30.md`
7. `continuity/12_WHAT_HOSTILE_OS_IS_BECOMING_2026-08-30.md`
8. `scars/ACTIVE_NEVER_REINTRODUCE_CURRENT.md`
9. `scars/EXECUTION_AND_INFERENCE_SCARS.md`
10. `authority/ADOPTION_STATE.md` and R3.1 SOP materials
11. `handoffs/CURRENT_REINCARNATION/00_READ_FIRST.md`
12. `handoffs/THIS_CONVERSATION.md` or `continuity/DESIGN_THREAD_STREAM.md` when chronology/nuance is needed
13. inspect canonical Git HEAD/status and GitHub `main` readback before mutation

Do not ask the operator to restate material already present in these surfaces.

## 2. Commander's intent

HOSTILE-OS is a hostile re-derivation of the operating-system problem from required consequences and observed mechanisms rather than inherited subsystem names.

Linux 0.01, pinned FreeDOS, mature/orthogonal OSes, external reviews, and prior projects may supply evidence, counterexamples, and mechanisms to pressure. They do **not** become architecture authority by prestige, ancestry, similarity, or convenience.

Core rule:

> **Donors supply evidence. Reality supplies authority. Familiar architecture supplies no exemption from proof.**

The design pressure is Pareto-optimal capability: the smallest causal machinery that preserves every required future. Burden includes bytes, state, cycles, latency, jitter, synchronization, energy, privilege, dependency surface, failure/recovery cost, assurance burden, maintenance burden, and concept count.

`MISSING_BEHAVIOR != MISSING_MECHANISM`.

A test, evaluator, launcher, fixture, environment, mechanism, observed trace, and promoted consequence are separate things. A green test is not reality; a red test is not automatically a mechanism failure.

## 3. Vocabulary doctrine

General prose uses plain roughly 1991-era 9th/10th-grade English. Hard thinking belongs in the engineering, not in ornamental vocabulary.

- plain language around the mechanism;
- proper technical language for the mechanism;
- mechanism first, precision second, style third;
- technical terms such as invariant, provenance, currentness, idempotence, attenuation, epoch, or atomicity remain when they compress real distinctions;
- never replace a useful technical term with baby talk;
- no academic camouflage or sophisticated-synonym contests.

Working HOSTILE-OS nouns such as `activity`, `binding`, `resource`, `owner`, and `mailbox` are **compression vocabulary, not constitutional primitives**. They remain eligible to split, merge, or disappear under later evidence.

## 4. Project then → now

### Original thesis

The project began by stripping early Linux and FreeDOS for responsibilities, mechanisms, scars, and disagreement while refusing to assume Process/Scheduler/File/Device/Service/Manager as primitives. The desired result was never predetermined: conventional-looking structures could reappear if independently re-earned.

### C001 — donor responsibility extraction

CLOSED20/20. Established the first responsibility/relationship pressure surface. No architecture promotion.

### C002 — whole-consequence composition

CLOSED20/20. Exposed a real lost-wake mechanism failure and a separate stale-evaluator failure. Major lesson: missing behavior can be fixture/evaluator/composition failure rather than absent mechanism.

### C003 — freestanding embodiment

CLOSED20/20. Earned bounded low-level mechanisms for identity/history, currentness, IRQ wake, failure locality, explicit continuation, capacity/exhaustion, generation/wrap behavior, initialization, shared lifetime, stale-handle rejection, serialization, and lifecycle composition.

### I001 — first integrated bootable workload

CLOSED PASS across two fresh QEMU boots. Composed the main early relation/currentness/wake/restart mechanisms. Later long replay produced 660 exact-evaluator reds caused by `IRQ_EVENT=2` vs historical exact `1`; IRQCOUNT01 showed counts1 and2 preserve the same tested semantics. Historical reds remain preserved.

### D64 line — donor-scale pressure

A01/RK01/RB02/ARB01/RR01/IRQ01/PR01 progressively earned finite 64-activity / 20-binding-cell / 64-resource behavior, namespace currentness, safe reuse/rekey, shared lifetime, IRQ-coherent coupled mutation, and clean-restart reconstruction. PR01 survived240/240 soak repetitions.

FR01 then earned a two-candidate durable-record recovery rule: validate candidate integrity/completeness before sequence ordering; fail closed on ambiguity. WT01 pushed actual guest writes under controlled QEMU interruption and found whole-old/whole-new at that tested transport boundary without generalizing to physical atomicity.

### D64 v2 — first converged D64 reviewer body

`d64_reference_v2` integrated adopted D64-era mechanisms inside the qualified8KiB stage2 envelope. It remained research-only. It closed at7440/8192 linked bytes with752 bytes headroom.

### C004 — authority/protection

CLOSED20/20. Earned a bounded authority grammar including trusted caller provenance, operation-specific rights, attenuation, independent authority currentness/revocation, finite reusable authority state, authority/resource lifetime separation, delayed-effect revalidation, restart authority epoch, local failure, and non-bypassable enforcement for genuinely untrusted code.

The x86 ring/TSS/gate mechanisms used are witnesses, not universal architecture.

### C005 — multicore concurrency/coherence

CLOSED20/20. Earned distinctions including local IRQ exclusion vs inter-CPU exclusion, atomic claim/update transitions, publication order, exclusion safety vs progress, acquisition-order composition, in-flight lifetime participation, stale-writer recovery currentness, IRQ+second-CPU shared coherence, version-validated read snapshots with explicit single-writer condition, and recovery authority/currentness separation.

No C005/P21 exists.

### Post-C005 H1 convergence

H1 is the operator's HP Pavilion p2-1120 and first planned physical target.

Three measured successor shapes were pressured:
- MIN01 proved two-core transport fits the existing envelope;
- Candidate A / MIN02 used a whole-operation atomic gate and passed at8189/8192 linked bytes, leaving3 bytes;
- Candidate B / MIN03 kept BSP as sole relation mutator and gave AP an ordered request/result mailbox; it passed at8089/8192, leaving103 bytes.

Candidate B was selected because current H1 requirements do not need direct multicore relation mutation. Candidate A remains a valid alternate. Candidate C is deferred, not disproven.

### D64 v3 — current embodied reviewer

`os/research_only/d64_reference_v3/` is **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**.

Promotion commit: `af8a11eb055b486c38cefb3676066b3e6d808f32`.

Current measured body:
- stage1:512 bytes,55aa signature;
- stage2 raw:4494 bytes;
- linked stage2:8089/8192;
- headroom:103 bytes;
- named semantic state:3467 bytes;
- implementation scratch:62/128 bytes;
- exact H1 SMP trace includes `IDS=0001 / OWNER=BSP / MAIL=WW11`;
- isolated os-only verifier: PASS20/20;
- successful standalone all-mode admission:9 QEMU boots;
- current H1 QEMU + Bochs replay: PASS.

The first v3 standalone runner attempt failed host-side before guest due a read-only auxiliary Q35 target disk; that scar is retained and the runner was amended without changing guest body/science criteria.

## 5. What the OS has become

The project is no longer merely an OS-design argument. It has a real, bootable, independently reproducible research substrate plus a sealed experimental lineage.

The strongest current compression is a small evidence-derived state-transition machine with explicit distinctions around:
- identity and currentness;
- checked relationships/applicability;
- shared lifetime and in-flight use;
- authority/provenance and effect-time validity;
- durable meaning vs volatile runtime topology;
- event/wake vs actual progress/application;
- IRQ and multicore coherence;
- recovery authority vs stale actor currentness.

It remains intentionally noun-hostile. Similarity to capabilities, microkernels, seqlocks, actor/mailbox systems, RCU, multikernels, or conventional kernels does not grant imported architecture authority.

## 6. Current embodiment vs current science

D64 v3 closes the selected H1 C005 two-core embodiment gap. It does **not** silently embody every C004 authority/protection rule.

Therefore:

`CURRENT_RESEARCH_BODY != COMPLETE_CURRENT_RESEARCH_SHADOW`.

The next representation/Pareto review must decide how much C004 authority state belongs in a successor body and whether it can fit/compress without convenience growth.

Do not spend the remaining103-byte v3 headroom merely because bytes exist.

## 7. H1 physical-target status

H1 = HP Pavilion p2-1120, AMD E2-1800 / A45-era machine, first planned physical HOSTILE-OS target.

Current emulator policy:
- QEMU = primary coarse H1 constraint/SMP proxy;
- Bochs3.1 = independent x86 semantic/restart/fault witness;
- neither equals H1 hardware.

`QEMU_H1_PROXY_PASS + BOCHS_PASS != H1_PHYSICAL_PASS`.

Physical CPUID/PCI/BIOS/ACPI/storage/interrupt/AP-start/cache/device behavior remains unqualified until the machine itself is probed/booted.

## 8. What must not silently return

Never reintroduce a mechanism merely because its historical noun is familiar.

Specific anti-regressions include:
- Process/Scheduler/File/Device/Manager/Service as primitive ontology without a discriminator;
- vector/index/location as identity;
- bare generation without restart/currentness domain where alias can recur;
- cached authorization as effect-time authority;
- caller-supplied identity as trusted provenance;
- local `cli` as inter-CPU exclusion;
- ordinary read-then-store as atomic claim;
- publication flag as proof associated payload is published;
- safe exclusion as proof of progress;
- timeout/retry budget as recovery authority;
- recovery authority as proof an old actor cannot resume;
- evaluator exactness as semantic law without qualification;
- QEMU/Bochs success as physical hardware proof;
- research resemblance as architecture adoption;
- working nouns becoming sacred by repetition;
- growing the loader/body merely because headroom exists;
- hiding historical red/UNKNOWN runs or rewriting sealed evidence.

Read the canonical scar files for the complete list.

## 9. Evidence and execution discipline

Always distinguish:
- preregistered;
- implemented;
- Git-sealed;
- submitted/launched;
- started;
- completed;
- evaluated;
- adopted;
- embodied;
- published;
- remotely verified.

A timeout or dropped control response is `UNKNOWN`, not success/failure by tone.

Long work should use durable jobs, journals/checkpoints, separate status/readback calls, and server-side result storage. Do not dump giant logs into chat when the project server can persist them.

## 10. Repository contract

GitHub is the durable ledger for **all unique project data**: source, science, failures, receipts, audits, raw evidence, research, decisions, continuity, transcript/handoff, SOP/authority packages, historical archives, and scars.

The OS-only surface remains `os/`. It SHALL NOT depend implicitly on `research/`, `continuity/`, `authority/`, `handoffs/`, transcripts, or bulk R&D evidence. Sparse/blobless checkout with LFS smudge disabled remains the supported way to obtain only the OS surface.

Scratch/caches are not project data unless they contain unique evidence. Unique scratch evidence must be admitted or losslessly archived before durable turn close.

## 11. Current open seams

P0:
- prepare a non-destructive physical-H1 qualification/boot/probe/replay package around D64 v3;
- get real H1 CPUID/PCI/BIOS/ACPI/storage/interrupt/SMP observations when operator hardware touch is ready.

P1:
- C004-to-v3 representation/Pareto convergence review;
- do not add authority machinery by convenience or by copying donor architecture.

Still unearned:
- physical H1 qualification;
- arbitrary CPU count / cross-architecture weak-memory proof;
- DMA/IOMMU/NMI/SMI guarantees;
- production fairness/stalled-owner recovery;
- final ABI/interface/filesystem/device model;
- final architecture/general-purpose release/production security;
- foreign Opus raw-packet hash verification;
- exact uploaded frozen-intent byte ingress into tracked Windows Git.

## 12. User-dependent blockers

Do not stop local work for these until they actually block progress:
- physical H1 power/boot/probe action;
- foreign external raw artifacts if evidence authority must be upgraded;
- exact source-byte bridge for uploaded frozen historical documents.

Stack them for the operator at the end when local runnable work is exhausted.

## 13. Exact resume rule

A new thread should:
1. verify project server health;
2. read the declared continuity order above;
3. inspect `git status`, HEAD and latest log;
4. verify `handoffs/CURRENT_REINCARNATION/MANIFEST_SHA256.json`;
5. verify GitHub `main` readback before mutation;
6. restate only Mode, Role, Verified/Provisional, Baseline/Open seams, Next actions;
7. continue P0 physical-H1 preparation locally without asking the operator to re-explain the project.

If local Git is newer than a narrative file, prefer the newer verified artifact and repair continuity before widening.

## 14. Current publication-transport scar

The first publication attempt for the zero-re-explanation checkpoint exposed source-drive scratch exhaustion after producing a ~3.19GB immutable archive. No remote success was claimed. Publisher now supports `HOSTILE_GITHUB_PUBLISH_SCRATCH_ROOT`; this machine uses D: for publication transport. See `scars/GITHUB_PUBLICATION_SCRATCH_SPACE_SCAR_2026-08-31.md`.

Do not solve future disk pressure by omitting research/history from GitHub.
