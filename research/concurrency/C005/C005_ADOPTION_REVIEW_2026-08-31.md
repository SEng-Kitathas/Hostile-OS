# C005 adoption review — multicore concurrency/coherence grammar

Date: 2026-08-31 UTC
Status: **ADOPT SHADOW RULES / NO FINAL ARCHITECTURE PROMOTION**
Campaign: C005 CLOSED 20/20

## Adopted shadow rules

At the tested C005 scopes, the incumbent shadow SHALL preserve these distinctions when the corresponding responsibility exists:

- local interrupt masking and inter-CPU exclusion are different boundaries;
- inter-CPU ownership/update transitions that race require atomicity at the transition, not merely atomic individual loads/stores;
- publication indicators and payload publication order are distinct protocol state;
- reusable ownership and bounded snapshot tokens require currentness across reuse/wrap;
- safety and progress are separate responsibilities;
- multiple safe claims require an explicit composition/progress rule when participants need more than one;
- in-flight participation must constrain reclaim for uses that must remain valid through completion;
- effect-time authority revalidation remains required across CPU boundaries when revocation can intervene;
- IRQ observers and CPU mutators of one coupled relation must share one coherence protocol;
- read-only observation may use validated retry instead of exclusive ownership only where overlap detection, writer constraints and retry semantics actually hold;
- wait/retry exhaustion does not create recovery authority;
- recovery that supersedes a writer must also make the old writer's later effects non-current/rejectable;
- bounded participation/version fields fail closed on exhaustion/wrap rather than aliasing zero/current semantics;
- runtime concurrency ownership/participation is reconstructed fresh after restart unless a separate durable contract earns otherwise;
- release authority depends on trusted participant provenance, not an untrusted claimed owner ID.

## Working compression

`trusted participant provenance + atomic/current transition state + publication/lifetime/recovery protocol -> coherent shared effect`

These are relations/responsibilities, not a declaration that HOSTILE-OS now has or needs Lock, Thread, Scheduler, RCU, Seqlock, Fence, or Manager primitives.

## Embodiment consequence

`os/research_only/d64_reference_v2/` remains the CURRENT_RESEARCH_REFERENCE for its embodied generation, but it now materially lags both C004 authority and C005 multicore science.

Do not squeeze C004+C005 into the remaining752-byte v2 envelope by convenience. A separate representation/Pareto convergence review must determine whether the grammar can be compressed, whether state can be derived, whether responsibilities should be split, or whether a larger envelope must be explicitly requalified.

## H1 consequence

C005/P20 passed on the H1 QEMU constraint proxy. This makes the campaign's final discriminator target-shaped, but the authority ceiling remains:

`QEMU_H1_PROXY_PASS != H1_PHYSICAL_PASS`

Physical CPUID/PCI/BIOS/ACPI/storage/interrupt behavior remains unqualified until the actual HP Pavilion p2-1120 is probed/booted.

## Promotion ceiling

No general SMP, weak-memory, DMA/IOMMU/NMI, production-progress, final ABI, final architecture or physical-hardware claim is promoted here.
