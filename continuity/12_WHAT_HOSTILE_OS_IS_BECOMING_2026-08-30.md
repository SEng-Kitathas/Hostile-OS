# What HOSTILE-OS Is Becoming — 2026-08-30

Status: interpretive synthesis grounded in the current earned experiment chain. This is not a final architecture promotion.

## Short version

HOSTILE-OS is shaping up to be a very small operating substrate built from a few explicit relationships rather than a pile of inherited OS subsystem names.

The strongest surviving pattern is:
- activities are current participants in the machine;
- activities hold checked bindings to resources;
- bindings and resources have explicit identity/currentness protection through generation/epoch domains;
- resource lifetime is counted explicitly when shared;
- finite capacity is normal and observable rather than hidden behind an allocator;
- wake/notification is separate from actual progress/application;
- coupled state changes are protected only where observation can catch them half-written;
- durable storage preserves durable meaning and enough currentness history to reject old handles after restart, but does not serialize the entire live runtime graph;
- restart rebuilds fresh runtime topology from durable meaning instead of trying to resurrect stale in-memory structure.

This is not yet an installable OS. The install tree is intentionally not populated with research mechanisms until an architecture/release gate adopts them.

## What has been earned

### Responsibility extraction
C001 closed 20/20 after stripping donor systems down to responsibilities and relationships. Linux 0.01 and FreeDOS remain witnesses/donors, not architecture parents.

### Whole-consequence composition
C002 closed 20/20 in a bounded descendant. It exposed an actual lost-wake mechanism failure and a separate stale-evaluator failure, teaching the project not to confuse missing behavior with missing mechanism.

### Freestanding embodiment
C003 closed 20/20 in low-level freestanding work. It earned bounded mechanisms for identity/history, currentness, persistence/rebind, IRQ wake, local missing-operation failure, failure locality, selection/application separation, lineage/wake, explicit continuation, finite bounds/exhaustion, generation width/wrap handling, explicit initialization, IRQ coherence, shared lifetime, stale-handle rejection, serialization convention, nested status propagation, and lifecycle composition.

### Integrated workload
I001 closed PASS across two fresh QEMU boots. It composed capacity, lineage/wait/continuation, local failure, real IRQ0 plus idle, separate wake/application, reuse/currentness, spanning-read controls, shared backing, durable serialization, clean restart/rebind, old-token epoch rejection, and fail-closed generation exhaustion in one workload.

### D64 scale pressure
The current donor-scale target qualified 64 activities, 20 binding cells per activity, 64 globally live resources, one core, maskable IRQ scope, clean restart, and firmware borrowing.

D64/A01 earned explicit finite activity capacity and stale/fresh handle discrimination.
D64/RK01 earned quiescent activity namespace rekey and showed epoch is load-bearing across generation reset.
D64/RB02 earned 1280 binding cells, 64 resources, separate row/global exhaustion, shared lifetime, and stale binding/resource rejection.
D64/ARB01 earned binding-aware activity release/rekey and showed identity-only release can transfer old relation state to a later occupant.
D64/RR01 earned separate activity/binding and resource currentness domains.
D64/IRQ01 earned the need to protect the exact coupled bind/final-detach mutation windows against a real IRQ0 observer at the tested one-core scope.
D64/PR01 earned clean-restart persistence of durable meaning with fresh runtime reconstruction and stale-handle rejection across restart epochs.

### Reliability pressure
PR01 then survived 240/240 consecutive overnight repetitions with zero failures. That is reliability evidence, not 240 additional architecture passes.

A broader 3304-cycle chain campaign produced zero failures in A01/RK01/RB02/ARB01/RR01/IRQ01 and 660 I001 exact-evaluator reds. The retained I001 reds still completed both boots exit33 and static closure, but observed `IRQ_EVENT=2` instead of the historical evaluator's exact `IRQ_EVENT=1`. This is an open timer-event-count semantic/evaluator seam, not currently an earned mechanism demotion.

## What the research is saying

### 1. Identity is not location
A slot/index can be reused. Therefore a bare slot number is not enough to mean “the same thing.” Generation/epoch information is load-bearing wherever stale references could otherwise retarget.

### 2. Runtime topology is disposable; durable meaning is not
The best persistence result so far does not save the whole runtime. It saves a tiny durable record containing meaning/currentness history, then reconstructs fresh runtime relationships after restart. This looks materially cheaper and cleaner than serializing the machine's transient graph.

### 3. Finite capacity is not automatically a defect
The experiments show a fixed/configured table can be lawful if full/exhausted is explicit, nonmutating, and recoverable. Dynamic allocation has not earned automatic primitive status.

### 4. Currentness domains should follow real independence
Activity/binding currentness and resource currentness proved separable. One global generation clock would be simpler on paper but would erase a real independence the experiments exposed.

### 5. Shared lifetime has to be explicit
When multiple bindings can point to one resource, the machine needs a real rule for when the resource is still live. The current tested answer is an explicit live count.

### 6. Waking something is not the same as making progress
Notification/wake and application/progress are separate responsibilities in the surviving design. Collapsing them hides failure modes.

### 7. Protect only the state that can actually be observed half-written
IRQ01 showed that a real interrupt can catch a coupled relation mid-publication. The answer was not a giant global lock; it was a very small protected region around the coupled writes. That is the project's general direction: spend synchronization only where an observer can witness an invalid intermediate state.

### 8. Restart must invalidate stale authority
If the machine intentionally reuses the same slot and generation after restart, an old handle still must not become valid again. Restart epochs currently carry that boundary.

### 9. Evaluators are not reality
C002/P19 and the I001 overnight timer-count seam both show that a red test can be a stale/overbound evaluator, while a green test can also be too weak. The evaluator itself must be qualified.

## What the machine is beginning to look like

The emerging shape is closer to a compact relation engine than a conventional subsystem stack.

A rough conceptual picture is:

`activity -> checked binding -> resource`

with explicit currentness attached to each namespace and explicit lifetime attached to shared resources.

An activity can be thought of as “something currently able to participate in the machine,” but that wording is intentionally broader than importing a historical process/thread definition. A binding is the checked relationship through which an activity reaches a resource. A resource is something with identity/value/lifetime that can be shared and rebound. Those meanings are still subject to future promotion review; they are the strongest current working shape, not final constitutional nouns.

Instead of making a large scheduler/file/process/device-manager hierarchy first and then trying to simplify it, HOSTILE-OS is growing upward from the minimum relationships required to make work, waiting, sharing, reuse, failure, interrupt observation, and restart correct.

## Likely personality if the current direction survives

- small fixed or explicitly bounded tables rather than invisible unlimited allocation;
- explicit status for full/exhausted/stale/missing rather than hidden fallback behavior;
- checked handles rather than bare indexes/pointers as authority;
- very small critical regions rather than broad locking where one-core IRQ observation is the problem;
- reconstructive restart rather than memory-image resurrection;
- persistent identity/meaning separated from volatile execution placement;
- minimal borrowed firmware at bootstrap, with pressure toward owned/native transport later;
- mechanisms that compose, with subsystem names only introduced if they earn their burden.

## What is not earned yet

- installable/releasable OS;
- final architecture;
- physical-hardware qualification;
- SMP/weak-memory/NMI/DMA correctness;
- crash/power-loss/partial-write persistence;
- filesystem semantics;
- unlimited restart/reuse lifetime;
- production generation/epoch widths;
- non-quiescent namespace renewal under permanently live state;
- native storage/device transport replacing firmware borrowing;
- arbitrary workload/capacity scaling beyond the tested D64 profile;
- final user/program interface, protection model, memory-management model, or device model.

## Present project phase

The project is past “interesting idea” and past isolated toy mechanisms. It has an integrated freestanding shadow candidate with a growing set of stress-qualified relationships and explicit scars.

It is not yet at the point where those mechanisms should simply be copied into `os/` and called the operating system. The next architecture work is deciding which tested relationships deserve promotion, what still needs harder pressure, and which missing responsibilities require new mechanisms rather than familiar historical subsystem names.

The strongest current posture remains `INTEGRATED_SHADOW_CANDIDATE`.

## Embodiment update — research OS now exists

The project now has a concrete reviewer/contributor embodiment under `os/research_only/i001_reference/`. This changes the practical maturity of the project but not its architecture authority. A reviewer can clone only `os/`, rebuild the controlling I001 machine bytes, boot the result twice, and run a reproduction verifier without checking out the multi-gigabyte R&D ledger.

That embodiment is deliberately a **reference body**, not the final body. Later D64/PR01 mechanisms remain separate research until a future embodied revision integrates them deliberately. The project therefore now has three clearly separated layers:

1. sealed historical science under `research/`;
2. a living research-only embodied OS under `os/research_only/` for inspection and contribution;
3. no promoted user release yet.

## IRQ-count result — telemetry versus meaning

I001/IRQCOUNT01 sharpened an important design rule: a measured counter value can be useful telemetry without being the meaning of the operation. At tested real IRQ0 counts 1 and 2, the same valid wait relation produced the same wake/progress consequence; a stale relation rejected even with two events. So the meaningful condition is not “the timer fired exactly once.” It is that an event occurred within the tested count range **and** the relation authorizing the wake remained current.

That distinction fits the broader HOSTILE-OS direction: state relationships carry authority; incidental timing observations should not become architecture law unless a discriminator earns them.

## Outside reproduction echoed the identity rule in tooling

The first reported independent-host I001 reproduction exposed a useful infrastructure echo of the OS research. A path named `ld.lld` carried dispatch meaning that was lost when tooling resolved it to a generic multi-call binary before execution. Likewise a transplanted QEMU executable was not enough without the module/runtime environment that made the binary usable.

Those observations support two engineering rules for the laboratory: `TOOL_PATH != TOOL_IDENTITY` and `TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT`. They are not new HOSTILE-OS mechanism proof, but they are a concrete reminder of the same broader discipline already earned inside the OS: location/name alone does not carry all of a thing's current meaning or usable state.

## Durable meaning now has a tested fault-recovery shape

FR01 adds a stronger form to the earlier “remember meaning; rebuild where it lives” result. HOSTILE-OS now has a tested shadow record in which two small durable candidates are judged independently for completeness/integrity before sequence order matters. A newer number does not grant authority to corrupt bytes.

At the tested deterministic scope, recovery prefers the newest **valid complete** meaning, falls back to an older valid meaning, or refuses to invent a state when the records are ambiguous/invalid. Only after that decision does the machine rebuild fresh runtime relationships under fresh epochs.

This makes the emerging pattern more concrete:

`durable meaning -> validate/currentness -> select -> reconstruct fresh relations`

rather than:

`persist live runtime graph -> reload it and hope old authority still means what it used to mean`.

The next pressure is whether actual interrupted guest writes produce media states this reader can safely classify.

## Original-thesis audit — the successful vocabulary is now under hostile watch

A frozen original Commander’s-Intent audit found the current project still strongly aligned with the initial thesis, but it also exposed a predictable new danger: `activity`, `binding`, and `resource` are becoming convenient enough that repetition itself could make them feel fundamental.

They are therefore explicitly demoted from any implicit constitutional reading. The current shorthand

`activity -> checked binding -> resource`

remains the best working compression of the tested relation family, but every one of those words can still be split, merged, or replaced when future-relevant behavior proves a cheaper grammar.

The audit also makes the embodiment boundary explicit: the runnable I001 research body is a reference body, not the full current shadow architecture, because D64/FR01 science has advanced beyond it.

## WT01 — actual writer termination now reaches the recovery chain

WT01 extends the persistence story one step beyond host-constructed bad media. A real freestanding guest issued the BIOS one-sector durable write; QEMU was stopped and force-terminated at measured instruction boundaries around the first observed backing-sector transition; the unchanged FR01 reader then recovered from the bytes actually left behind.

At the tested QEMU/directsync scope, the media appeared whole-old through the boundary immediately before the transition and whole-complete-new immediately after it. Recovery selected A/value71 for the old state and B/value72 for the new state. No controlling run exposed an intermediate `OTHER` sector.

The important rule is still not “sector writes are atomic.” The earned rule is narrower: **recovery follows validated persisted meaning, and the current emulated one-sector transport exposed only the two whole states at the controlled observation boundary.** Physical power loss and multi-sector ordering remain open.

The project is now due for a new versioned research-only embodiment that integrates the adopted D64-era mechanism family while preserving the historical I001 body unchanged.

## The current shadow now has a converged reviewer body

The D64-era adopted mechanism family now exists together in one self-contained bootable research body rather than only as a chain of separate experiments. `d64_reference_v2` combines finite checked relations, shared lifetime, real IRQ observation/current-wait validation, durable meaning selection, and fresh restart reconstruction inside the previously qualified 8 KiB stage2 envelope.

That convergence is important but should not be confused with a new ontology proof. The body is a **compression of already-earned mechanisms**. `activity`, `binding`, and `resource` remain working names, and the body can be split/replaced if later pressure exposes a cheaper grammar.

The integrated body currently consumes 7440 of8192 linked bytes. That makes future growth visible: the next 752 bytes are no longer an abstract implementation detail; they are a concrete Pareto pressure surface.
