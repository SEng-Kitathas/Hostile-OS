# D64 research-only OS v2 embodiment plan — 2026-08-30

Status: BUILD-PLAN / NOT SCIENCE / NOT RELEASE
Trigger: post-WT01 embodiment convergence review
Target path: `os/research_only/d64_reference_v2/`
Historical body preserved: `os/research_only/i001_reference/`

## Goal

Build a new, versioned, bootable **RESEARCH PURPOSES ONLY** HOSTILE-OS body that lets reviewers and contributors inspect the current adopted D64-era mechanism family without checking out or depending on the multi-gigabyte research ledger.

This body is an embodiment of the incumbent shadow architecture candidate. It is not a new science result and does not promote final architecture.

## Why a new body instead of mutating I001 reference

The I001 body is already an independently reproducible historical reference tied to a specific integrated witness. Rewriting it would destroy that clean lineage.

The science has since advanced through D64 capacity/currentness/resource work, IRQ01, PR01, IRQCOUNT01, FR01 and WT01. A new body can converge to those adopted rules while keeping I001 reproducible as its own generation.

## Governing rule

`sealed research evidence > adopted shadow rules > embodied research body > convenience API`

The body must never be used to retroactively reinterpret the sealed experiments it came from.

## Working vocabulary guard

The body may use the names `activity`, `binding`, and `resource` for code clarity, but these remain **working nouns, not constitutional primitives**.

Code organization must not claim those bundles are irreducible. Where practical, implementation state should remain visibly decomposable into the already-earned relations: identity/currentness, continuation/wait, binding/currentness, resource identity/lifetime, and durable meaning.

## Required repository shape

Proposed minimum tree:

```text
os/research_only/d64_reference_v2/
    README.md
    STATUS.md
    ARCHITECTURE_MAP.md
    TOOLCHAIN.md
    build.py
    run.py
    verify.py
    stage1.S
    stage1.ld
    stage2.S
    stage2.ld
    build/                 # generated, ignored unless current policy says otherwise
    evidence_map.json
```

The directory must be sufficient to clone/sparse-checkout `os/`, build the body, run the bounded reviewer workloads, and verify its own output without requiring `research/`, `continuity/`, `authority/`, or `handoffs/` at runtime/build time.

## Qualified loader envelope

Use the already-qualified fixed 8 KiB stage2 loader shape unless the integrated body proves it insufficient.

Current expectation:
- stage1 exactly 512 bytes with `55 aa`;
- stage2 loaded to `0x8000..0x9fff` from sectors2..17;
- durable candidate sectors remain outside that extent;
- no hidden dynamic loader/runtime.

If the body exceeds the envelope, do not silently enlarge it. Record the exact burden and decide whether the larger envelope buys enough reviewer/architecture value to justify a new qualification.

## Minimum embodied mechanism set

### 1. D64 configured finite capacity

Expose/configure:
- 64 activity slots;
- 20 binding cells/activity;
- 64 globally live resource slots;
- explicit row/global/full/exhausted status.

These are reference-profile configuration values, not architecture constants.

### 2. Checked currentness

Embodied handles must preserve the adopted separate currentness domains:
- activity/binding currentness;
- resource currentness.

Bare slot/index/address-only use may exist only as deliberate reviewer negative controls, never as the normal authority path.

### 3. Binding-aware lifecycle and shared lifetime

Include:
- activity release blocked by non-empty owned binding row;
- shared resource live count;
- detach/reclaim only at zero live count;
- explicit initialization on reuse;
- stale-handle rejection after reuse.

### 4. Wait / wake / application separation

Include one bounded asynchronous path where:
- current wait relation is explicit;
- real IRQ0/event observation is separate from relation validation;
- wake/notification is separate from progress application;
- tested IRQ event counts1/2 are accepted only where the relation remains current;
- stale relation rejects regardless of event presence.

Do not make exact event count1 architecture law.

### 5. One-core IRQ coherence

Protect only the currently load-bearing coupled bind/final-detach mutation windows at one-core maskable-IRQ scope.

The body may retain the current small protected regions or re-derive an equivalent implementation, but documentation must say the exact instruction count is witness cost, not constitutional law.

### 6. Durable meaning + fresh reconstruction

Embodied persistence should use the adopted conceptual rule:

`durable meaning/currentness history -> validate -> select -> reconstruct fresh runtime relations`

Do not serialize the full live 64x20 runtime graph.

### 7. FR01 durable candidate validation

Include two durable candidates with:
- 24-byte payload;
- CRC-16/CCITT-FALSE;
- `CMIT` marker;
- validation before bounded sequence ordering;
- fail-closed no-valid/equal-conflict/epoch-exhaustion behavior.

This is a research-format incumbent, not a final filesystem/journal format.

### 8. WT01 writer/readback relationship

The body may include a normal one-sector durable writer compatible with the adopted FR01 record format.

It should not include GDB orchestration as OS logic. GDB-controlled process termination remains laboratory infrastructure.

Documentation should state that WT01 observed whole-old/whole-new persistence at the tested QEMU/directsync instruction boundary, not universal sector atomicity.

## Reviewer workloads

The v2 body should expose a small number of end-to-end modes rather than dozens of historical experiment replicas.

Recommended modes:

### `core`

One boot exercises:
- finite admission/full;
- binding/resource sharing;
- stale/fresh handles;
- local missing failure;
- wait/wake/application;
- real IRQ0 observation;
- coherent bind/detach.

### `restart`

Two fresh QEMU boots:
- Boot1 establishes/writes durable meaning;
- Boot2 validates/selects durable meaning, rejects prior runtime handles, reconstructs fresh relation, and proves selected value.

### `faulted-media`

Host runner constructs a small fixed set of deterministic A/B media states drawn from FR01's adopted categories (not all 41 historical fixtures):
- valid old / empty new;
- valid old / valid newer;
- corrupt newer fallback;
- equal-sequence conflict fail closed;
- both invalid fail closed.

These are reviewer demonstrations of already-sealed science, not new scientific evidence.

## Evidence mapping

`evidence_map.json` must map every embodied rule to:
- sealed parent result path;
- adoption path if any;
- exact bounded authority statement;
- known demotion/revisit trigger.

Example categories:
- activity capacity -> D64/A01;
- shared binding/resource scale -> D64/RB02;
- lifecycle/rekey -> ARB01/RK01/RR01;
- IRQ coherence -> IRQ01;
- clean restart -> PR01;
- event-count semantics -> IRQCOUNT01;
- durable fault recovery -> FR01;
- controlled write termination -> WT01.

This prevents the body from becoming a source of stronger claims than its parents.

## Build/reproduction requirements

- repo-contained LF source;
- explicit tool discovery with invocation-path vs resolved-identity separation;
- no author-local absolute path requirement;
- explicit `-nic none` for non-network workloads;
- QEMU module/runtime environment support consistent with the portability scar;
- deterministic build where practical;
- stage1/stage2 hashes emitted;
- `verify.py` returns literal-boolean checks;
- clean build from sparse `os/` checkout must not require R&D files.

## Pareto receipt for the body

Record at least:
- stage1 bytes;
- stage2 raw bytes;
- named runtime-state bytes;
- durable logical bytes/sectors;
- protected-region instruction counts;
- configured capacity values;
- wall time for reviewer workloads;
- QEMU/firmware dependencies;
- toolchain identities;
- number of distinct primitive state categories used by the implementation.

This does not make the whole Pareto vector complete, but it improves the dimensions the original-thesis audit found under-measured.

## Admission gate

The v2 body may be called `CURRENT_RESEARCH_REFERENCE` only after:
- build succeeds from its own directory;
- all reviewer modes pass;
- verifier passes;
- sparse-checkout/no-R&D-dependency test passes;
- architecture/evidence map is complete;
- independent audit confirms no hidden research-tree dependency;
- the old I001 reference remains unchanged.

Even then:
- `FINAL_ARCHITECTURE=false`;
- `PRODUCTION_READY=false`;
- `GENERAL_PURPOSE_RELEASE=false`.

## First implementation step

Before writing stage2 code, derive the smallest shared state layout needed to compose the adopted D64 mechanisms in one body and calculate its static byte budget against the 8 KiB envelope. This is representation-first integration work, consistent with the original thesis guard against implementation-order ontology smuggling.
