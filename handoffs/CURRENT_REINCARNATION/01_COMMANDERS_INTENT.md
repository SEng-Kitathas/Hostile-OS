# Commander's Intent

## Mission

Re-derive a general-purpose operating substrate from reality-facing responsibilities and invariants rather than inheriting modern OS nouns as primitive truth.

Linux 0.01 and FreeDOS are competing historical donors. Prior Rahl projects and outside systems are quarries. The job is not to make a cleaner Linux, a stranger DOS, or a renamed holonic/ECS OS. The job is to discover which distinctions reality actually forces, which mechanisms buy capability, which historical bundles are convenience/scar tissue, and what the smallest powerful whole can be.

## Supreme design pressure

**Pareto-optimal size/power subject to required capability.** There is no single global scalar. Bytes, memory, cycles, latency, jitter, energy, bandwidth, privilege, dependency surface, concept count, synchronization, failure/recovery burden, assurance burden, compatibility burden, and maintenance burden all count. Larger machinery is lawful only when the extra burden buys a real capability or guarantee.

## Research attitude

`MISSING_BEHAVIOR != MISSING_MECHANISM`.

Before creating a primitive, localize the failure and test composition. Before calling a familiar subsystem inevitable, strip its noun and ask what responsibility/invariant it carries. Before trusting a successful experiment, attack the harness, launcher, evaluator, fixture, provenance, and hidden host services.

## End state sought

A substrate that is small because its causal structure is small, not because capability was cut away; powerful because mechanisms compose; explicit about authority/currentness; able to adapt to substrate without runtime adaptation rewriting governance; and capable of moving across machines while requalifying what reality changed.

The current work is still research. No final HOSTILE-OS architecture has been promoted.

## Continuity / reincarnation intent

The project SHALL be able to survive thread loss, operator absence, model replacement, machine restart, and repository re-clone without requiring the commander to reconstruct project meaning from memory.

Every meaningful turn therefore refreshes the living intent/state/decision/research/continuity surfaces and hash-attests the continuity tree. Historical evidence remains immutable; current interpretation is appended and indexed rather than rewritten.

A decision, research result, caveat, scar, blocker, target constraint, or method change that matters enough to affect future work matters enough to enter durable project state that turn.

GitHub remains the remote reincarnation ledger for the whole admitted project, while `os/` remains independently retrievable for OS-only use.

## Current execution intent — post-C005 / D64 v3

The first physical target remains H1, the HP Pavilion p2-1120. Virtual and cross-emulator work exists to reduce physical-port uncertainty, not to replace real-machine authority.

The current embodied reviewer is `os/research_only/d64_reference_v3/`. Its selected H1 two-core topology keeps one current relation mutator on BSP and lets AP publish an explicitly ordered request/result mailbox. That topology is a scoped representation choice for the current H1 capability, not a declaration that “mailbox,” “owner,” or any familiar IPC/server noun is a primitive.

Continue to prefer the smallest mechanism that preserves earned futures. Candidate A (direct multicore relation callers behind a whole-operation atomic gate) remains a valid alternate; Candidate C (per-CPU scratch + narrower transition gate) remains deferred/not disproven. Reopen only when a required capability or measured pressure justifies the extra burden.

Current reality pressure is physical H1 qualification and remaining science/embodiment mismatch. In particular, C004 authority/protection science is not silently considered embodied merely because v3 is current. Prepare as much of the physical probe/boot/replay path locally as possible before requiring operator hardware touch.

No QEMU/Bochs result may be promoted into physical H1 truth. No `CURRENT_RESEARCH_REFERENCE` label may be promoted into final architecture, production readiness, or general-purpose release by tone.

## Zero-re-explanation continuity intent

A future HOSTILE-OS thread must be able to take over without requiring the commander to restate project history, intent, nuance, engineering reasons, current state, rejected paths, or open seams.

All load-bearing project meaning therefore belongs in durable Git/GitHub state. Continuity must preserve both **then** and **now**: historical evidence stays intact, while living documents explicitly mark which older frontiers have been superseded.

A fresh thread SHALL rehydrate from the repository and continue. Asking the commander to reconstruct already-persisted project context is a continuity failure.


## Unknown / unclear / trace escalation intent — 2026-08-31

When a load-bearing point is unclear, unknown, contradictory, or visible only through traces whose meaning cannot be recovered, inspect durable project evidence first and then **ask the commander** if the uncertainty remains.

Do not guess across the gap. Do not invent provenance. Do not silently treat an unexplained trace as understood. Do not mutate around a load-bearing unknown merely to preserve momentum.

This does not weaken zero-re-explanation. A fresh thread must still recover everything already persisted in Git/project state before asking. The ask rule starts where durable evidence genuinely stops.

Controlling local SOP delta: `authority/R3_1_LOCAL_SOP_DELTA_UNKNOWN_TRACE_ASK_2026-08-31.md`.
