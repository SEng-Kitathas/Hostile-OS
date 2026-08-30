# Post-WT01 research-only OS embodiment convergence review — 2026-08-30

**Mode:** AUDIT / BUILD-PLAN
**Role:** R4 Convergence Refiner + R1 Conservative Auditor
**Current runnable body:** `os/research_only/i001_reference/`
**Current science posture:** `INTEGRATED_SHADOW_CANDIDATE` through adopted WT01 durability scope

## Decision

**A new research-only embodiment convergence pass is now due.**

Do **not** rewrite the existing I001 reference body in place.

Preserve it as a reproducible historical embodiment of the I001 integrated witness. Build a new versioned research body beside it so reviewers can compare lineage and reproduce both.

Recommended target path:

`os/research_only/d64_reference_v2/`

This is a build-plan decision, not architecture or release promotion.

## Why refresh is now due

The current body is materially behind adopted shadow science. Since I001, the research has added/qualified:
- D64 64-activity capacity and explicit full behavior;
- 64x20 binding matrix and 64 shared resources;
- separate activity/binding and resource currentness domains;
- quiescent namespace rekey rules;
- binding-aware activity lifecycle;
- shared resource lifetime up to 1280 bindings;
- IRQ0 coherence around coupled bind/final-detach mutation;
- clean restart reconstruction of durable meaning;
- tested IRQ count1/2 semantics;
- FR01 two-candidate CRC+commit faulted-media recovery;
- WT01 actual guest one-sector write termination boundary with sealed-reader recovery.

A reviewer who only runs `i001_reference` can no longer inspect much of the incumbent shadow baseline.

## Convergence constraints

The new body must remain **RESEARCH PURPOSES ONLY** and must not imply final architecture.

It should:
- live entirely under `os/` and remain sparse-checkout/buildable without the R&D tree;
- contain inspectable source, build, run, verify and provenance surfaces;
- carry a compact selection of **adopted mechanisms**, not copy every historical fixture;
- include a clear mapping from each embodied mechanism to its sealed research result/authority ceiling;
- retain current working-noun guard: `activity/binding/resource` are not constitutional primitives;
- avoid importing donor source or research scripts as runtime dependencies;
- keep historical I001 body unchanged;
- independently rebuild exact body bytes from repo-contained source where practical;
- provide one or more bounded end-to-end reviewer workloads rather than a pile of disconnected demos.

## Suggested embodiment scope

The v2 body should integrate, at minimum:
- D64 configured capacities;
- checked activity/binding/resource handles with generation+epoch currentness;
- shared lifetime/live counts;
- explicit local status for full/missing/stale/exhausted;
- separate wake/notification/application semantics from I001/IRQCOUNT01;
- one-core maskable-IRQ coherence rule around load-bearing coupled updates;
- restart reconstruction from durable meaning;
- FR01 validity-before-sequence durable candidate recovery.

WT01's GDB-controlled termination harness itself does not belong inside the OS body. The body only needs the writer/reader behavior that WT01 qualified; the laboratory control remains research infrastructure.

## What should remain outside v2 for now

- SMP/NMI/DMA/weak-memory machinery;
- physical-device claims;
- filesystem semantics;
- production memory management;
- general user ABI;
- final scheduling policy;
- modern compatibility layers;
- uncontrolled wall-clock kill stress.

## Promotion ceiling

Successful v2 embodiment would mean:

`CURRENT_SHADOW_MECHANISMS_HAVE_A_REVIEWABLE_INTEGRATED_BODY = true`

It would **not** mean:

`FINAL_ARCHITECTURE = true`
`INSTALLABLE_GENERAL_PURPOSE_OS = true`
`PRODUCTION_READY = true`

## Recommended next engineering step

Before opening another durability science seam, build a bounded v2 embodiment plan that chooses the smallest set of current adopted mechanisms that can coexist in one reviewer workload without importing historical test fixtures as architecture.

The build should use the new two-level cadence doctrine: this is integration/embodiment work, not automatically a new 20-pass scientific campaign unless new open-ended ontology questions appear during design.
