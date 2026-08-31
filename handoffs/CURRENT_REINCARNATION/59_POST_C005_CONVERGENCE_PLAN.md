# Post-C005 representation/Pareto convergence plan — 2026-08-31

Status: **BUILD-PLAN / NO NEW SCIENCE CAMPAIGN**
Parents: C004 CLOSED20/20, C005 CLOSED20/20, `d64_reference_v2`, H1 target profile and emulator matrix.

## Problem

The current body has8192 linked bytes of qualified stage2 envelope, uses7440 bytes, and therefore has752 bytes headroom. It materially lags C004 authority and C005 multicore science.

The job is not to copy every witness mechanism into the body. The job is to embody only responsibilities required by the next target capability while preserving all already-promised guarantees.

## Immediate H1 capability increment

For the first physical target, the next useful capability is:

> bring up the second E2-1800 core and let both cores participate without allowing concurrent relation operations to violate the already-earned relation/currentness/lifetime rules.

This does **not yet require** untrusted ring3 execution, a user authority ABI, forced stalled-holder recovery, lockless/versioned readers, arbitrary core count, or scheduler/fairness guarantees. Those C004/C005 rules remain mandatory if/when those capabilities are admitted.

## Existing representation seam

`d64_reference_v2` currently has shared global relation-call scratch:10 input bytes,5 output bytes and1 returned-value byte. Therefore an internal mutation-only lock is insufficient for two direct callers unless caller argument preparation/result capture is also protected or the scratch is made per-CPU/register-local.

## Candidate ordering

### Candidate A — whole-operation gate — FIRST

One shared atomic gate serializes the entire trusted relation operation, including global argument preparation, call and result capture. Existing relation representation remains unchanged.

Expected new persistent state: approximately1 gate byte plus a few AP handshake/provenance bytes.

Advantages: smallest representation delta; no relation-table duplication; no per-CPU scratch refactor. C005/P02 atomic claim and P20 trusted-release responsibility can be satisfied structurally because only trusted body code manipulates/releases the gate.

Costs/ceiling: relation operations serialize globally; progress depends on holder completion; no fairness or stalled-holder recovery; callsites must obey the whole-operation gate contract.

### Candidate B — single-writer relation owner + mailbox

One core owns relation-table mutation; other cores submit explicit requests/results. This preserves current single-writer internals and isolates shared scratch, but adds mailbox publication/currentness state and central progress dependency.

### Candidate C — per-CPU scratch + narrow gate

Duplicate/index the16-byte call interface per CPU and protect only coupled relation transition state. This permits direct multicore calls and narrower serialization but has larger refactor/code burden.

## Measured transport budget

From C005/P20's H1-QEMU witness:
- INIT/SIPI + APIC-delivery wait code:147 bytes;
- AP trampoline body:220 bytes;
- subtotal:367 bytes.

This is witness cost, not a universal constant, but it is below the current752-byte v2 headroom. A minimal AP bring-up + global gate deserves an in-envelope prototype before any loader expansion.

## Prototype sequence

### H1-SMP-MIN01 — AP bring-up fit test

Copy exact `d64_reference_v2` source into a research integration candidate. Add one `S` reviewer mode that copies a real-mode AP trampoline to low memory, INIT/SIPI starts AP1, records BSP/AP local APIC IDs and AP-ready handshake, and exits cleanly.

Acceptance: linked runtime footprint <=8192; existing C/R/F behavior remains semantically exact; H1 QEMU proxy sees BSP00/AP01/ready1; Bochs one-CPU C/R/F replay remains exact. S mode is outside installed Bochs's one-CPU capability.

### H1-SMP-MIN02 — whole-operation gate fit/composition

Only after MIN01 passes, add one atomic gate and exercise a real existing relation operation with argument preparation + call + result capture inside the gate. Use both CPUs in S mode. Compare a deliberately unguarded control with the guarded path.

This is embodiment qualification of already-earned C005 rules, not a new20-pass science campaign.

## Envelope rule

Do not enlarge the8192-byte envelope until an exact candidate build proves the minimal required capability cannot fit after reasonable local compression. If MIN01/MIN02 exceed8192, identify burden by section/symbol before preregistering a larger loader envelope.

## Promotion rule

Passing MIN01/MIN02 does not automatically replace `d64_reference_v2`. A separate successor-body admission review must verify existing reviewer behavior, H1 QEMU qualification, Bochs one-core replay, exact body identity and burden delta.
