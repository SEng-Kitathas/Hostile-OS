# D64 v2 frontier-selection audit — 2026-08-30

**Mode:** AUDIT -> BUILD-PLAN
**Role:** R5 Reality Pressure Engine + R4 Convergence Refiner
**Current body:** `os/research_only/d64_reference_v2/`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`

## Question

After D64 v2 converged into a 7440/8192-byte current research reference with 752 bytes of qualified headroom, what next work most strongly tests the original HOSTILE-OS thesis rather than merely extending the embodiment?

## Candidate frontiers

### A. Add another mechanism to v2

**Reject for now.**

No current discriminator says the body is missing a mechanism required by an exercised capability. Consuming the remaining 752 bytes because they exist would invert the research method: implementation space would become the driver of ontology.

### B. Open physical-hardware qualification immediately

**Defer.**

Physical hardware remains scientifically important, especially for durability/cache/device claims, but the current local environment does not yet present a controlled hardware-cut/recovery instrument comparable to the QEMU boundary work. Planning is lawful; calling it the next executable science frontier would currently be premature.

### C. Open blind comparison against mature OS architectures

**Defer one gate.**

The original method intentionally kept mature systems behind glass during independent derivation. D64 v2 is mature enough that this comparison is now visible, but opening it before measuring the current body's own burden would make comparison arguments depend on an incompletely characterized baseline.

### D. Pareto characterization of the converged v2 body

**SELECT.**

The original Commander’s Intent makes Pareto burden—not byte minimization alone—the supreme design pressure. Current evidence measures bytes/state/capacity/critical regions well, but explicitly carries debt in latency, jitter, dependency, maintenance and assurance burden.

The converged body is the right moment to measure those costs because:
- its mechanism set is currently stable;
- the reference body is self-contained and reproducible;
- no new mechanism is required to collect the measurements;
- results can pressure future representation choices without architecture contamination;
- the remaining 752-byte headroom gives a concrete burden boundary against which future additions can be judged.

## Selected next work

Create **D64/V2-PARETO01**, an engineering characterization packet, not a scientific campaign.

Measure at minimum:
- exact stage1/stage2/named-state/linked-memory/headroom bytes;
- clean build wall time distribution;
- `core` reviewer wall time distribution;
- `restart` two-boot reviewer wall time distribution;
- `faulted-media` five-boot reviewer wall time distribution;
- full `all` eight-boot reviewer wall time distribution;
- verifier wall time distribution;
- QEMU process count per reviewer mode;
- explicit external tool/runtime dependency identities;
- current assurance-surface count and checker count;
- current remaining loader-envelope headroom.

Do not claim host wall time is architecture latency. Label it as **reviewer/reproduction burden in this exact host/QEMU/toolchain envelope**.

Do not attempt energy claims without an instrumented energy source.

## Bounded characterization design

Use the current admitted Git body unchanged.

- 10 clean builds;
- 20 `core` reviewer runs;
- 20 `restart` reviewer runs;
- 20 `faulted-media` reviewer runs;
- 20 `all` reviewer runs;
- 20 verifier-only runs against a valid all-mode receipt.

Record every sample, summary statistics, environment/tool identities and exact source commit.

This produces 10 builds and 320 QEMU boots total:
- core: 20 x 1 = 20;
- restart: 20 x 2 = 40;
- faulted-media: 20 x 5 = 100;
- all: 20 x 8 = 160.

Total QEMU boots = 320.

## Stop rule

Stop after the bounded characterization and reconcile whether the measured burden suggests:
- representation optimization;
- loader-envelope requalification;
- mature-OS blind comparison maturity gate;
- physical-hardware qualification planning;
- or a genuinely new broad science domain.

No v2 mechanism mutation is authorized by this characterization plan.
