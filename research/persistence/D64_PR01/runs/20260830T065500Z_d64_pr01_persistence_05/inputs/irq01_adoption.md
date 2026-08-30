# D64 IRQ01 binding/resource IRQ-coherence adoption review — 2026-08-30

**Mode:** PROMOTION / bounded architecture-rule adoption
**Science result:** `research/irq_coherence/D64_IRQ01/D64_IRQ01_RESULT.md`
**Science close:** `c5c3fff717f49f35f6a5eaf6e1f41b75d8841e83`
**Architecture posture before review:** `INTEGRATED_SHADOW_CANDIDATE`
**Higher architecture promotion:** NO

## Question

Does IRQ01 earn a load-bearing rule for coupled binding/resource publication and final detach at the current single-core, maskable-interrupt D64 boundary?

## Evidence admitted

IRQ01 controlling run `20260830T060500Z_d64_irq01_coherence_01` is closed with:

- QEMU `COMPLETED`, exit 33;
- exact evaluator PASS;
- 16 static/source checks, all literal boolean true;
- 14-check independent closure PASS;
- exact preregistration lineage `0c14b605e6b29c4767d9fbf6a03e5ee1bcd4b36f`;
- 4,773-byte stage-2 payload inside the qualified 8 KiB envelope;
- 3,615 bytes named runtime state;
- real IRQ0 observer using the same tested binding/resource arrays.

The unprotected bind path admitted IRQ0 after resource identity/live-count became visible but before the binding reference was published. The IRQ observer saw:

`binding=0 / resource_identity=0x51 / live_count=1`

The unprotected final-detach path admitted IRQ0 after the binding reference was withdrawn but before resource lifetime/reclaim completed. The IRQ observer saw the same mixed/orphan state.

The protected paths masked IRQ0 across the coupled transition and exposed only coherent post-state to the observer.

Measured protected regions in the controlling witness:

- bind publication: 6 instructions / 6 tested-memory writes;
- final detach: 6 instructions / 4 tested-memory writes.

## Decision

**ADOPT for the current D64 integrated-shadow single-core maskable-IRQ scope.**

The incumbent rule is:

> A transition that couples binding-reference visibility with resource identity/value/live-count lifetime state SHALL be one maskable-IRQ-coherent mutation region at the current single-core boundary. IRQ observation may occur before or after that region, but not at a point where the observer can accept a binding/resource state that the transition itself treats as intermediate.

For the currently earned operations this means:

1. **new binding/resource publication** — resource generation/identity/value/live-count and binding-generation/reference publication belong to one IRQ-coherent region;
2. **final detach/reclaim** — binding withdrawal, live-count decrement, and zero-count identity/value reclaim belong to one IRQ-coherent region;
3. observation outside the region may see the coherent old state or coherent new state;
4. ordinary source order without an IRQ boundary is not enough, because IRQ01 directly observed the intermediate state when IRQ0 was admitted there.

## What is and is not architectural

The architectural rule is the **coherence requirement**, not the literal instruction count.

The six-instruction regions are current implementation evidence and a current cost measurement. They are not universal constants. A later embodiment may use a smaller or different region if it preserves the same verified observer invariant.

Current Pareto posture therefore records:

- protected bind witness cost: 6 instructions;
- protected final-detach witness cost: 6 instructions;
- cost is small and bounded in the current witness;
- any larger future region carries fresh latency/bloat burden and must be justified rather than inherited automatically.

## Scope ceiling

This adoption covers only:

- one core;
- maskable IRQ observation;
- the tested binding/resource publication and final-detach relation;
- the current D64 bounded representation.

It does not establish:

- SMP synchronization;
- NMI or DMA coherence;
- weak-memory ordering;
- general transactions;
- general linearizability;
- lock-free/wait-free behavior;
- a physical interrupt-latency budget;
- persistence/durability;
- arbitrary resource operations;
- final/canonical/production architecture.

## Demotion / reopen triggers

Reopen or demote this rule if:

1. physical-hardware timing shows the protected region violates a later interrupt-latency target;
2. SMP/NMI/DMA or weak-memory scope is admitted and the IRQ-mask boundary no longer supplies the required observer exclusion;
3. a smaller verified mechanism provides the same coherence with a materially better size/latency/power vector;
4. later composition introduces additional resource/binding fields whose visibility is not covered by the current transition boundary;
5. a new observer class can accept an intermediate state despite the current maskable-IRQ exclusion.

## Frontier consequence

The immediate D64 one-core maskable-IRQ coherence seam for new bind publication and final detach is resolved at bounded shadow scope.

The project should not widen to stronger concurrency by momentum. The remaining high-value seams are now:

1. expanded binding/resource persistence across clean restart;
2. quiescent activity/resource rekey availability when state remains live indefinitely;
3. stronger hardware/concurrency boundaries only when target scope requires them.

For the current target, clean-restart persistence is the next strongest discriminator because I001 earned persistence only for a smaller record, while the adopted D64 relation now carries activity, binding, resource, currentness, and rekey state that has not been reconstructed across restart.

## Disposition

`IRQ01_RULE_ADOPTED_AT_D64_SINGLE_CORE_MASKABLE_IRQ_SCOPE / COUPLED_BIND_RESOURCE_TRANSITIONS_REQUIRE_ONE_IRQ_COHERENT_REGION / SIX_INSTRUCTIONS_IS_CURRENT_WITNESS_COST_NOT_UNIVERSAL_CONSTANT / NO_HIGHER_ARCHITECTURE_PROMOTION`
