# C003 Post-Campaign Audit — 2026-08-30

**Mode:** AUDIT
**Role:** R1 Conservative Auditor
**Campaign under review:** C003 — freestanding low-level embodiment / host-subsidy exposure
**Campaign state:** CLOSED 20/20
**Architecture promotion:** NOT EARNED
**R3.1 replacement promotion:** NOT EARNED BY THIS CAMPAIGN

## Audit question

What does C003 actually establish when P01-P20 are read together, which results narrow or limit other results, what costs became explicit, and what is the smallest lawful next phase?

## Evidence integrity

Verified from the live Git repository:

- exactly 20 C003 preregistration artifacts exist;
- exactly 20 C003 result artifacts exist;
- every result close follows its preregistration in Git history;
- no preregistration/result ordering anomaly was found;
- P20 is the hard stop and no P21 artifact exists;
- current C003 close state is committed and tracked;
- exact final C002 Python source remains unrecovered, so the historical Python subsidy inventory is not exhaustive.

C003 itself forbade architecture promotion by campaign success alone. The audit keeps that ceiling.

## What survived repeated pressure

### 1. Decision, notification, and application are different jobs

This distinction survived several independent tests:

- P08: selection can choose B without mutating A or B; application is separate.
- P09: child completion plus lineage/wait matching can wake a parent without applying parent progress; application is separate.
- P10: wake does not supply logical control position; explicit continuation identity does.
- P19: a nested caller must inspect returned status before applying progress.
- P20: missing status preserves progress and continuation; success alone applies the stored continuation.

**Audit posture:** strong bounded design distinction. It appears in several different failure shapes, not one fixture only.

### 2. Bare location or identity is often not enough; currentness has to be explicit

This family also survived repeated pressure:

- P02: identity-bound history survives compaction where stale numeric/index history drifts.
- P03: an observer at the tested mutation cut needs explicit mutation currentness to reject incoherent intermediate state.
- P04: durable bytes may survive restart while volatile runtime binding must expire and be rebound.
- P12: finite generation width can wrap and make a stale token compare current again.
- P17: generation-qualified access rejects a stale handle after slot reuse; address-only access retargets silently.
- P20: the same checked-generation idea still works inside a larger one-slot lifecycle composition.

**Audit posture:** strong family of requirements, but **not one universal mechanism**. Mutation-in-progress, generation/lifetime, restart binding, and interrupt atomicity are different failure shapes.

### 3. Failure can stay local and explicit

- P06: missing operation returns bounded missing status without mutating protected local state.
- P07: local failure does not poison a distinct later activity; a deliberately global latch does.
- P15: capacity exhaustion can return explicit full status without overwrite.
- P19: nested missing status can propagate without progress mutation.
- P20: missing request and full slot both remain explicit bounded results inside composition.

**Audit posture:** strong bounded result. No ErrorManager or exception runtime was required for the tested cases.

### 4. Reuse and lifetime create real state obligations

- P13: reused fixed storage needs explicit initialization of every load-bearing field.
- P16: shared backing needs explicit live-count/current-liveness state for the tested two-binding case.
- P17: reused location needs current generation to stop stale retargeting.
- P20: acquisition, release, clean reuse, generation advance, and stale rejection compose in one slot.

**Audit posture:** repeated evidence that lifetime is behavior, not cleanup detail. No general allocator, garbage collector, ownership type system, or capability design is earned.

### 5. Host conveniences become explicit low-level contracts

C003 exposed several Python/runtime conveniences as real low-level choices:

- P11: bounds checking versus adjacent-state corruption.
- P12: integer width and wrap.
- P13: default/clean initialization.
- P14: multi-field transition atomicity under real IRQ0.
- P15: finite capacity and exhaustion behavior.
- P16: shared backing lifetime.
- P18: byte serialization convention.
- P19: nested status propagation.

**Audit posture:** the campaign successfully did its main job of moving hidden host help onto an explicit burden surface.

## Cross-pass limits and contradictions that must not be smoothed away

### A. P03 currentness flag is not general ABA protection

P03 proved that one active/currentness byte rejects an observer that lands during the tested mutation cut. It did **not** test a reader that begins before the mutation and finishes after the mutation, observing the flag clear at both ends while mixing old and new fields.

P12 does not close this seam. A wider generation helps only if the reader actually snapshots and validates the relevant version around the read. P14 also does not close it; IRQ masking prevents one interrupt observer from seeing a particular two-byte transition, but that is a different mechanism and boundary.

**Status:** OPEN, already present in `C003_REVISIT_LEDGER.md`.

### B. P17/P20 generation currentness is bounded by P12 wrap

P17 and P20 correctly reject gen1 after reuse to gen2. P12 proves that equality-only finite generations can alias after wrap.

Therefore the safe claim is:

> generation-qualified access prevents stale retargeting only within the tested non-aliasing generation history, unless an explicit rollover/lifetime rule is added.

Do not promote `generation == current_generation` as a universal stale-handle solution.

### C. P14 atomicity is local and has visible latency cost

P14 proves IRQ masking can protect one coupled two-byte update from one maskable IRQ0 observer on the tested uniprocessor QEMU slice.

It does not cover SMP, NMI, DMA, broader memory ordering, or long critical sections. The mechanism also grows interrupt-off time as coupled transitions grow.

The campaign therefore exposes synchronization as a Pareto cost, not a free correctness switch.

### D. P04 persistence is clean-restart persistence only

P04 proves durable bytes across a fresh QEMU restart plus expiry/rebind of volatile runtime binding.

It does not prove crash consistency, partial-write recovery, torn-write handling, journaling, or transaction recovery. C002 explicitly did not earn crash/partial-write recovery, so this gap must not be upgraded into an inherited requirement without a later reason.

### E. P16 lifetime count is a bounded two-binding discriminator

P16 shows that a live count can prevent premature reclaim in one two-binding case. It does not establish overflow behavior, cycles, concurrent release safety, arbitrary fan-out, or a general reference-count architecture.

### F. P20 is composition evidence, not whole-campaign integration

P20 composes several important earned mechanisms in one fixed slot:

- checked acquisition/full behavior;
- explicit continuation;
- missing-status preservation and success-only application;
- release/reuse initialization;
- generation advance;
- fresh/stale checked access;
- address-only negative control.

But P20 does **not** integrate all C003 obligations. It leaves out, among other things:

- clean restart persistence/rebind from P04;
- real asynchronous IRQ/idle wake from P05;
- parent-child lineage/wait matching from P09;
- P03 mutation-span ABA/currentness seam;
- P14 IRQ-protected coupled transition;
- shared backing lifetime from P16;
- explicit two-byte serialization from P18.

This is the main promotion blocker. C003 has **broad bounded coverage plus partial composition**, not one whole-workload freestanding closure.

## Burden / Pareto surface exposed by C003

The important result is not that every feature costs many bytes. It is that each correctness property now has a visible price and boundary.

| Burden | Evidence | Explicit cost exposed | Ceiling |
|---|---|---|---|
| mutation coherence | P03 | currentness state + retry/reject rule | not general ABA/linearizability |
| persistence boundary | P04 | durable representation + volatile rebind state | clean restart only |
| asynchronous wake | P05 | IVT/PIC/PIT/IRQ state + idle identity | QEMU virtual hardware only |
| local failure | P06/P07/P19 | status value + branch discipline | bounded status model only |
| selection/application split | P08/P09/P10 | explicit selected/woken/continuation state + separate apply | no scheduler/context architecture |
| bounds | P11 | explicit capacity compare before indexed mutation | fixed-layout discriminator only |
| generation currentness | P12/P17/P20 | generation field + compare + wrap policy burden | no universal width/lifetime rule |
| reuse initialization | P13/P20 | explicit reset writes for load-bearing fields | fixed-slot lifecycle only |
| multi-field atomicity | P14 | interrupt masking + latency budget | one IRQ0/uniprocessor slice |
| finite capacity | P15/P20 | capacity state + explicit full result | no arbitrary-load support |
| shared lifetime | P16 | live-count/current-liveness state | no GC/general ownership system |
| serialization | P18 | explicit byte order/width convention | two-byte convention only |

### Size observations

For tracked qualified later passes where linked ELF artifacts are present, the complete probe text+data remained below one 512-byte boot sector. These sizes include test/output machinery and are **not** pure mechanism costs.

Examples from `llvm-size`:

- P05: 295 bytes text+data
- P10: 369 bytes
- P11: 331 bytes
- P12: 337 bytes
- P14: 449 bytes
- P17: 342 bytes
- P19: 301 bytes
- P20: 511 bytes

P20 nearly fills the sector. That is useful pressure evidence: composition is consuming the tiny evidence envelope. It is not proof that a future architecture must fit one sector.

## What C003 does not support

The following promotions would overstate the evidence:

- `relation model == final OS architecture`;
- `no scheduler/process/file abstractions are ever useful`;
- `generation tags solve stale references generally`;
- `IRQ masking solves atomicity generally`;
- `fixed capacity is always preferable to allocation`;
- `live count == general ownership/lifetime solution`;
- `QEMU success == physical hardware proof`;
- `20/20 == replacement readiness`;
- `P20 == integrated closure of the whole C002 workload`.

## R3.1 authority fit

The current R3.1 adoption state is an engineering/research SOP shadow candidate whose parent authority is R6. C003 is primarily evidence about HOSTILE-OS mechanism and execution discipline, not a broad decision-equivalence test of R3.1 versus R6.

C003 supplies another positive observation that the shadow workflow can preserve preregistration, execution scars, readback, bounded claims, and hard stops. It does **not** test enough R3.1/R6 authority cases to make `replacement_ready=true`.

**Audit decision:** keep R3.1 `SHADOW_USE_CANDIDATE`; keep R6 parent; no authority promotion artifact should be created from C003 closure.

## Promotion gate result

**FAIL / NOT READY**, in the constructive sense.

The blocker is not lack of successful passes. The blocker is that the campaign deliberately tested many responsibilities in separate bounded slices, while architecture promotion needs stronger evidence about their interaction under one workload and one state model.

Before any architecture promotion review, at minimum:

1. close or explicitly accept the P03 spanning-reader ABA/currentness seam;
2. define the intended finite-generation rollover/lifetime rule or bound;
3. build one integrated freestanding workload that combines the load-bearing responsibility families rather than only a P20 subset;
4. carry async wake/idle and persistence/rebind through that composition or state clearly why they are outside the target architecture;
5. measure the resulting Pareto vector, including synchronization/latency and ontology burden, not only bytes;
6. preserve negative controls so a green run cannot be explained by a dead or reject-all path.

## Smallest lawful next phase

Do **not** start C004 by momentum.

The smallest justified next phase is a named **POST-C003 REVISIT** focused on the already-open P03 spanning-reader ABA/currentness seam.

Reason:

- it is the only explicit open C003 revisit currently on the ledger;
- it directly limits currentness claims reused later in the campaign;
- it can be tested with a small bounded discriminator before committing to a larger integrated architecture campaign;
- its outcome will tell the next integration effort whether a simple active flag is enough, whether a generation/version snapshot is needed around multi-field reads, or whether the target reader model makes the seam irrelevant.

No revisit result may rewrite P03. It must be appended as new evidence.

## Audit disposition

`C003_CLOSED_20_OF_20 / BROAD_BOUNDED_COVERAGE / PARTIAL_COMPOSITION / NO_ARCHITECTURE_PROMOTION / POST_C003_ABA_REVISIT_EARNED`
