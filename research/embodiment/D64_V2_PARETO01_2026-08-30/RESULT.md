# D64/V2-PARETO01 — converged-body reproduction burden characterization

Date: 2026-08-30
Status: **CLOSED PASS / ENGINEERING CHARACTERIZATION**
Science authority: **NONE ADDED**
Source HEAD: `d5c96891fbef796caac9b3070e29e63d8cb9352f`
Body tree: `03af56020afe6d117836133c0e33092d098fc13e`
Parent frontier audit: `research/audits/D64_V2_FRONTIER_SELECTION_AUDIT_2026-08-30.md`

## Purpose

Measure the current converged D64 v2 body across more of the original Pareto vector without mutating its mechanisms and without mislabeling host/QEMU wall time as architecture latency.

## Population

Executed exactly the preregistered engineering characterization:
- 10 clean builds;
- 20 core reviewer runs;
- 20 restart reviewer runs;
- 20 five-case faulted-media reviewer runs;
- 20 all-mode reviewer runs;
- 20 verifier-only runs.

Reviewer QEMU boots: **320** exactly.

Independent receipt adjudication:
- reviewer runs checked: **80/80**;
- QEMU boots checked: **320/320**;
- bad runs: **0**;
- bad boots: **0**;
- every checked boot completed exit33 and matched its exact expected trace;
- every restart/faulted-media semantic side condition matched.

## Static burden

- stage1: **512 bytes**;
- stage2 raw: **3845 bytes**;
- named v2 state: **3467 bytes**;
- linked stage2 memory: **7440 / 8192 bytes**;
- remaining qualified headroom: **752 bytes**.

No body source changed during characterization.

## Command-level wall-time distributions

These are **host/reviewer reproduction costs on this exact Windows/QEMU/toolchain envelope**, not guest architecture latency.

| Operation | n | min ms | median ms | mean ms | max ms |
|---|---:|---:|---:|---:|---:|
| clean build | 10 | 575.8 | 599.3 | 1422.0 | 8846.4 |
| core | 20 | 323.9 | 338.9 | 338.1 | 351.9 |
| restart | 20 | 492.1 | 511.7 | 512.2 | 531.4 |
| faulted-media | 20 | 1218.1 | 1242.4 | 1244.3 | 1273.0 |
| all | 20 | 1896.7 | 1929.6 | 2444.8 | 9562.9 |
| verifier only | 20 | 37.8 | 42.3 | 44.3 | 67.3 |

## Per-QEMU-process wall time

| Reviewer grouping | boots | median ms/boot | mean ms/boot | max ms/boot |
|---|---:|---:|---:|---:|
| core samples | 20 | 211.9 | 212.2 | 225.9 |
| restart samples | 40 | 185.9 | 185.4 | 194.3 |
| faulted-media samples | 100 | 181.2 | 180.9 | 192.1 |
| all-mode samples | 160 | 182.1 | 206.3 | 883.3 |

## Outlier adjudication

Two distributions contain large tails:

### Clean build

Nine builds clustered around roughly 0.58-0.62 s. The **first** clean build took about **8.85 s**, driving mean/stdev sharply upward.

No source/build output mismatch accompanied the event.

Disposition: **host/toolchain cold-start or host scheduling/cache effect; not OS mechanism jitter.**

### All-mode reviewer

Median command time was about **1.93 s**, but two runs took about **4.58 s** and **9.56 s**.

Those runs contained multiple individual QEMU process stretches (roughly 0.47-0.88 s) while still producing exact traces/exit33. Isolated core/restart/faulted-media populations remained tight.

Disposition: **reproduction-environment scheduling/runtime variance**. It is a real assurance/reproduction burden and should remain visible, but it is not evidence of guest semantic instability.

## Dependency / environment burden

Current characterization depends explicitly on:
- Python 3.12.10 orchestration;
- Android NDK LLVM/Clang21 toolchain (`clang`, `ld.lld`, `llvm-objcopy`, `llvm-nm`), each identity-hashed in the build manifest;
- QEMU i386 11.1.0, SHA-256 `dbbf7242e5b0d295e54336c69034a266ee1cc117d7ac6e3060e38bb61651200b`;
- QEMU data directory `C:\Program Files\qemu\share` for firmware;
- no current QEMU module directory was required on this local installation;
- explicit `-nic none` for non-network workloads.

Current body-level assurance surfaces include:
- integrated verifier: **17 checks / PASS**;
- current QEMU transplant portability gate: **9 checks / PASS**.

These counts are assurance/tooling burden, not OS primitives.

## What PARETO01 earns

At this exact host/reproduction envelope:

1. the converged v2 body remains semantically stable across the bounded 320-boot population;
2. its common reviewer modes have relatively tight median reproduction times;
3. large timing tails are presently dominated by host/QEMU/toolchain execution effects, not divergent guest traces;
4. byte/state burden remains the sharpest directly controlled scarcity: **752 bytes** remain in the qualified envelope;
5. no measurement creates a discriminator requiring immediate representation optimization or loader-envelope expansion.

## What it does not earn

PARETO01 does not measure or prove:
- guest-cycle latency;
- hardware interrupt latency;
- energy/power;
- cache/bandwidth efficiency;
- real hardware timing;
- production maintenance cost;
- global Pareto optimality.

## Frontier consequence

**Do not optimize or enlarge v2 yet.**

The current body has no observed capability failure and no measured burden discriminator that justifies consuming more complexity.

The earlier blind-comparison deferral condition is now satisfied: HOSTILE-OS has a converged, self-contained body and a first explicit burden baseline. The next sensible step is to define and close a **mature-OS blind-comparison maturity gate** before any external architecture is allowed back into the design conversation.
