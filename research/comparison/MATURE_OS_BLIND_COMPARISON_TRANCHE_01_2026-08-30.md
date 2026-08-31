# Mature-OS blind comparison — tranche 01

Date: 2026-08-30
Mode: AUDIT / RESEARCH QUARRY
Status: BOUNDED COMPARISON COMPLETE / NON-AUTHORITATIVE
Architecture posture entering/leaving: `INTEGRATED_SHADOW_CANDIDATE`
Gate: `research/audits/MATURE_OS_BLIND_COMPARISON_MATURITY_GATE_2026-08-30.md`

## Quarantine statement

This comparison was opened only after independent HOSTILE-OS derivation, whole-workload embodiment, os-only reproduction, and Pareto characterization had closed the maturity gate.

External systems are quarry/comparison evidence only. They do not supply HOSTILE-OS primitives, algorithms, names, or promotion authority.

No source or mechanism from Linux, seL4, Plan 9, or FreeDOS was copied into `os/` during this tranche.

## Compared families

- Linux kernel — contemporary monolithic Unix lineage.
- seL4 — capability/microkernel lineage.
- Plan 9 from Bell Labs — message/file-protocol and per-process namespace lineage.
- FreeDOS — DOS compatibility lineage, deliberately retained as a radically different packaging witness even though an earlier pinned FreeDOS revision was already a C001 donor.

## Source basis

Authoritative/public documentation used in this tranche:

### Linux
- Linux kernel file-management documentation: `https://www.kernel.org/doc/html/latest/filesystems/files.html`
- Linux completion/wait documentation: `https://www.kernel.org/doc/html/latest/scheduler/completion.html`
- Linux scheduler documentation: `https://www.kernel.org/doc/html/latest/scheduler/`
- Linux kref documentation: `https://www.kernel.org/doc/html/latest/core-api/kref.html`
- Linux RCU documentation: `https://www.kernel.org/doc/html/latest/RCU/whatisRCU.html`
- Linux locking documentation: `https://www.kernel.org/doc/html/latest/kernel-hacking/locking.html`

### seL4
- Threads: `https://docs.sel4.systems/Tutorials/threads.html`
- Capabilities: `https://docs.sel4.systems/Tutorials/capabilities.html`
- IPC: `https://docs.sel4.systems/Tutorials/ipc`
- Notifications: `https://docs.sel4.systems/Tutorials/notifications.html`
- MCS scheduling contexts: `https://docs.sel4.systems/Tutorials/mcs.html`

### Plan 9
- Overview: `https://9p.io/plan9/about.html`
- Introduction/name spaces: `https://9p.io/magic/man2html/1/0intro`
- bind/mount: `https://9p.io/magic/man2html/2/bind`
- namespace files: `https://9p.io/magic/man2html/6/namespace`
- 9P service/fid model: `https://9p.io/magic/man2html/2/9p`
- 9P protocol introduction: `https://9p.io/magic/man2html/5/0intro`

### FreeDOS
- current kernel repository: `https://github.com/FDOS/kernel`
- current release record: `https://github.com/FDOS/kernel/releases`
- historical/current SFT development history as corroborating implementation evidence.

## Responsibility matrix

| Responsibility / consequence | Linux | seL4 | Plan 9 | FreeDOS | HOSTILE-OS current | Classification |
|---|---|---|---|---|---|---|
| Execution identity/context | tasks/threads carry execution context and state | TCB represents thread execution context | processes/process groups; process-visible `/proc` and rfork grouping | PSP/process execution/INT21 compatibility state | activity identity/currentness + bounded continuation/progress | `CONVERGENCE` + `REPRESENTATION_DIFFERENCE` |
| CPU arbitration/history | scheduler selects runnable tasks under explicit policies | priority/round-robin; optional scheduling contexts separate CPU budget from thread | scheduling exists but is less architecturally central to namespace/service model | DOS-compatible execution is largely serial/cooperative relative to modern multiprocess kernels | eligibility/history/selection/application separated in bounded research; no general scheduler primitive | `CONVERGENCE` + `POLICY_DIFFERENCE` |
| Wait/event/current condition | wait queues + completion object retain current done state; completion may precede waiter | endpoints/notifications maintain queues or pending signal state | notes/rendezvous/service request lifecycle provide event/wait relationships | DOS/BIOS/device/event compatibility mechanisms are differently bundled | explicit waiting/woken/current completion; IRQ event separated from relation validity/application | `CONVERGENCE` + `REPRESENTATION_DIFFERENCE` |
| Shared resource lifetime | `struct file`, fd tables, krefs/refcount/RCU lifetime | kernel objects referenced through capabilities; object lifecycle explicit | open descriptors/fids and server-side active-fid/request lifetime | SFT entries and handle/JFT compatibility state carry shared-open lifetime/reference facts | resource identity/currentness + u16 live count + final-detach reclaim | `CONVERGENCE` |
| Name/reference mapping | fd numbers, namespace/pid/mount mappings and object references | CSpace slots name capabilities to kernel objects | per-process mutable namespaces, bind/mount, 9P fids | handle/JFT -> SFT and DOS path/device conventions | checked binding cell -> resource slot/currentness | `CONVERGENCE` + `REPRESENTATION_DIFFERENCE` |
| Authority / allowed use of a valid reference | file permissions/credentials/capability checks are distinct from object liveness; descriptor access mode matters | capability possession + rights is explicitly the authority to invoke an object | namespace exposure plus file-server permissions/access mode govern reachable operations | DOS handles/modes/compatibility checks provide limited access mediation but weak mutual-untrust isolation | checked handles establish currentness/applicability but current reviewer body has no separately pressure-tested mutually-untrusted authority/protection boundary | **`MISSING_CAPABILITY_PRESSURE`** |
| Concurrency/coherence | SMP locks, IRQ locking, RCU removal/reclamation and memory-order rules | multicore-capable verified kernel mechanisms; scheduling/IPC synchronization explicit | server/process libraries require locks when data shared across service processes | comparatively weak/serial execution assumptions | one-core maskable-IRQ coherence only | `MISSING_CAPABILITY_PRESSURE` but already-known seam |
| Durable meaning/restart | spread across filesystems/block layers/journals rather than one kernel primitive | normally delegated to user/system software rather than kernel object persistence | file servers own durable state; namespaces can mount persistent or synthetic services | FAT/kernel filesystem services own durable bytes and compatibility recovery assumptions | explicit FR01 durable meaning + validation + fresh runtime reconstruction | `DIVERGENCE` / `REPRESENTATION_DIFFERENCE`; no missing primitive inferred |
| Compatibility surface | POSIX/Linux ABI bundles many historical semantics | intentionally small kernel ABI, substantial policy in user level | file/9P interface deliberately universalizes many resources | DOS/INT21 compatibility is primary architectural burden | no compatibility target promoted | `COMPATIBILITY_ONLY` / intentional scope difference |

## Strong convergences

### Currentness and lifetime are not incidental

Across very different systems, references and shared objects require some way to answer whether the referenced thing is still usable and whether it can be reclaimed. Linux uses refcounts/RCU plus object-specific rules; seL4 uses kernel-object lifetime and capability references; Plan 9 tracks active fids/requests and namespace bindings; FreeDOS uses SFT/handle structures; HOSTILE-OS independently re-earned generation/epoch currentness and shared live counts.

This supports the responsibility, not any one representation.

### Event occurrence is not the same as permission to proceed

Linux completions preserve a current completion condition even if completion precedes waiting. seL4 separates notification objects from threads and endpoints. HOSTILE-OS independently found that IRQ telemetry alone is not semantic authority and that wake/notification must remain separate from application/progress.

Again, this is convergence of consequence, not proof of identical mechanism.

### Resource access is relational

Linux fd tables, seL4 capabilities, Plan 9 fids/namespaces, FreeDOS handles/SFTs, and HOSTILE-OS bindings all put important state in a relation between an executing context and something used. The mature systems package more policy/compatibility around that relation, but none makes raw backing storage identity alone sufficient for use.

## Important divergences

### seL4 separates CPU budget from thread identity more aggressively

MCS scheduling contexts can carry CPU budget/period independently of a thread and may be bound/transferred under controlled rules. This is interesting convergence with HOSTILE-OS's historical refusal to identify selection/arbitration state with activity identity, but it does not license importing scheduling-context objects.

Classification: `REPRESENTATION_DIFFERENCE` / `CONVERGENCE`.

### Plan 9 makes namespace composition unusually central

Per-process mutable namespaces and bind/mount/9P composition push many resource-selection questions into namespace construction rather than distinct subsystem APIs. HOSTILE-OS currently has checked bindings but no comparable global naming/namespace objective.

Classification: `DIVERGENCE`; no capability pressure yet because HOSTILE-OS has not stated a need for distributed/user-composed naming.

### FreeDOS remains compatibility-heavy

Current FreeDOS still implements DOS program loading, file/device I/O, memory management and INT21 compatibility. Its packaging shows that compatibility obligations can dominate representation. That is evidence about burden, not a reason for HOSTILE-OS to inherit PSP/SFT/File primitives.

Classification: `COMPATIBILITY_ONLY` plus historical donor continuity.

## New missing-capability pressure: currentness is not authorization

This is the first tranche's most important discriminator.

Current HOSTILE-OS answers questions such as:
- is this activity/binding/resource handle current?
- is this relation locally present?
- is the shared resource still live?

It has **not yet hostilely established** the separate question:

> If activities are mutually untrusted, what prevents one activity from exercising or mutating a relation/resource merely because it can name or reconstruct the current state?

The mature systems disagree strongly on the answer:
- Linux distributes authority across credentials, permissions, descriptor modes and subsystem checks;
- seL4 makes capability possession/rights central;
- Plan 9 combines namespace reachability, access modes and server-side permission decisions;
- FreeDOS provides compatibility-oriented handle/mode mediation but is a weak witness for adversarial isolation.

That disagreement is exactly why no external answer should be imported.

What the comparison supplies is only the **question**: HOSTILE-OS currently conflates, or has not yet distinguished, `CURRENT_REFERENCE` from `AUTHORIZED_USE` under mutually untrusted execution.

Classification: **`MISSING_CAPABILITY_PRESSURE`**.

## Already-known missing pressure: stronger concurrency

Linux and seL4 carry mechanisms for multicore/SMP ordering and synchronization far beyond HOSTILE-OS's one-core maskable-IRQ scope. Plan 9 server libraries likewise require locking for shared data across service processes.

This is real missing capability pressure but not newly discovered; HOSTILE-OS already lists SMP/NMI/DMA/weak-memory as open.

Classification: `MISSING_CAPABILITY_PRESSURE / ALREADY_OPEN`.

## Tranche stop / reconciliation

Required labels are complete:
- `CONVERGENCE`: identity/context, wait/current event, shared lifetime, relational access;
- `DIVERGENCE`: namespace centrality, persistence placement;
- `MISSING_CAPABILITY_PRESSURE`: mutually-untrusted authority/protection; stronger concurrency (already open);
- `REPRESENTATION_DIFFERENCE`: thread/context carriers, scheduling budget, naming, lifetime machinery;
- `POLICY_DIFFERENCE`: CPU arbitration and access policies;
- `COMPATIBILITY_ONLY`: DOS/POSIX/9P compatibility bundles where they do not answer HOSTILE-OS's current question;
- `UNKNOWN`: no claim is made here about optimality, full security, full device models, or equivalent guarantees across systems.

The tranche therefore stops without modifying `os/`.

## Next hostile question

Open a new broad domain only around the newly exposed responsibility:

**When mutually untrusted activities coexist, is currentness/applicability alone sufficient, or is a separately enforced authority/protection distinction required to prevent unauthorized future-relevant state changes?**

External systems are now quarantined. The next work must derive the answer from hostile HOSTILE-OS experiments.
