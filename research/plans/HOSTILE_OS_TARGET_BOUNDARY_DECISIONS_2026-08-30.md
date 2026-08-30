# HOSTILE-OS Target Boundary Decisions — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Purpose:** close the immediate target-boundary ambiguities exposed by I001 without freezing witness numbers into architecture law
**New experiment:** none required by this document

## Decision 1 — firmware is a borrowed platform boundary, not architecture state

### Current shadow-candidate rule

HOSTILE-OS may use BIOS/firmware services only through an explicit borrowed-platform boundary.

A firmware call is lawful only when the implementation either:

1. has not yet taken ownership of machine state that the firmware service depends on; or
2. explicitly restores the firmware-visible state required by that service before the call, then re-establishes HOSTILE-OS-owned state afterward if execution continues.

The I001 IRQ0-vector/PIC save-and-restore repair is the current bounded witness for rule 2.

### Target direction above shadow-candidate level

For a stronger post-shadow target, prefer:

> **firmware for bootstrap; owned transport after takeover.**

Once the target claims stable ownership of interrupt/device state, post-takeover firmware I/O should be removed from the load-bearing architecture rather than repeatedly borrowing firmware by save/restore.

This is a direction, not yet an embodied native-storage claim.

### Consequence

The current candidate is not demoted because I001 uses BIOS after explicit restore. BIOS is classified as platform transport, not a hidden Scheduler/File/Manager mechanism.

A future higher promotion that includes storage/device ownership should either:

- embody native post-takeover transport; or
- state a narrower target where explicit firmware borrowing remains part of the platform contract.

## Decision 2 — capacity is finite, configured, and observable

General-purpose does not mean unbounded.

The architecture rule is:

- each finite state collection has a declared capacity;
- capacity is a build/platform/workload configuration input, not a magic architecture constant;
- checked admission happens before mutation;
- exhaustion has an explicit result such as `F`;
- no overwrite-on-full, adjacent-state corruption, or hidden host growth is allowed in the good path;
- dynamic allocation is not forbidden, but it must be earned by a workload/cost discriminator rather than imported as a default Manager/heap assumption.

### I001 witness versus target rule

I001 uses exactly two activity slots because two slots are enough to compose P/C occupancy, B-full rejection, C release, and B reuse.

`2` is a witness capacity, **not** the HOSTILE-OS architecture capacity.

Future embodiments should expose capacity as a named build/platform constant and report:

- number of slots/records;
- bytes per slot/record;
- total static state cost;
- exhaustion behavior;
- workload reason for the chosen capacity.

## Decision 3 — generation and epoch width come from a declared lifetime bound

The architecture rule is width-parametric and fail-closed:

- zero is invalid/non-current unless a later design explicitly earns a different sentinel rule;
- successful reuse/epoch advance is monotonic within the current namespace;
- silent modulo wrap into a value that may alias a live/stale token is forbidden;
- before wrap/alias, the operation returns explicit exhaustion (`G`) or enters an explicitly designed rekey/new-namespace operation;
- durable identity remains separate from volatile runtime currentness.

### Width selection rule

For a finite `w`-bit nonzero generation namespace without rekey, the declared maximum number of advances in that namespace must satisfy:

`max_advances <= (2^w - 1) - starting_generation`

with additional margin if tokens may remain live across more than one reuse domain.

A width is not "enough" because it feels large. The design must name the reuse/restart horizon that makes it enough.

### If no credible bound exists

If the target cannot state a credible maximum advance/reuse horizon, then one of these must be designed before a higher posture:

- explicit rekey/new namespace;
- wider compound identity such as epoch + generation;
- non-reusing identity space for the relevant lifetime;
- another currentness mechanism with a tested failure model.

### I001 witness

I001's 8-bit generation and 8-bit epoch remain valid bounded evidence because the main path uses generations 1 and 2 and epochs 1 and 2, with `G` before zero-wrap.

They are not promoted as target production widths.

## Decision 4 — current target concurrency envelope is single-core and interrupt-bounded

The current `INTEGRATED_SHADOW_CANDIDATE` claims only a single-core x86/QEMU-style execution envelope with explicit maskable-interrupt interactions.

Therefore the following are **not current target claims**:

- SMP correctness;
- NMI coherence;
- DMA coherence;
- weak-memory multiprocessor ordering;
- general lock-free progress.

They are not blockers for the current posture because the current target does not claim them.

If a later target adds them, they become new responsibility surfaces and must be earned rather than assumed.

## Decision 5 — persistence target remains clean-restart unless stronger durability is explicitly requested

Current load-bearing persistence means:

- declared bytes survive a completed write and fresh restart;
- volatile runtime bindings do not silently survive;
- rebind/currentness is explicit.

Crash consistency, torn writes, partial writes, journaling, and power-loss recovery are not current target requirements.

They must not be added merely because mature filesystems often need them. If later product intent requires those consequences, they become a new seam and must be specified then.

## Decision 6 — physical hardware is a higher-assurance gate, not a prerequisite for continued architecture work

QEMU evidence is sufficient for the current integrated shadow posture.

Physical hardware becomes required before claims about:

- physical interrupt/device timing;
- firmware variation;
- device-controller quirks;
- physical boot portability;
- hardware-qualified release posture.

Do not use "not yet on physical hardware" to erase valid freestanding/QEMU evidence, and do not use QEMU evidence to make physical-hardware claims.

## Decision 7 — next experiment must attack a declared target seam

No new experiment should be created merely because I001 passed.

A new experiment is justified only when one of these is true:

- a target boundary has been chosen and lacks embodiment;
- a workload forces a capacity/lifetime mechanism not yet tested;
- a candidate simplification can remove state/cost while preserving consequences;
- a demotion trigger needs pressure;
- a higher posture requires a specific assurance surface.

The likely future hardware/storage seam is **native post-takeover transport**, but it is not automatically next. It should be selected only when the target decides that firmware borrowing is no longer acceptable.

## Current disposition

`FIRMWARE = EXPLICIT_BORROWED_BOUNDARY; HIGHER_TARGET_PREFERS_BOOTSTRAP_ONLY`

`CAPACITY = FINITE_CONFIGURED_AND_EXPLICITLY_EXHAUSTIBLE`

`GENERATION_EPOCH = WIDTH_PARAMETRIC_FAIL_CLOSED_NO_SILENT_WRAP`

`CONCURRENCY_SCOPE = SINGLE_CORE_MASKABLE_INTERRUPT`

`PERSISTENCE_SCOPE = CLEAN_RESTART`

`PHYSICAL_HARDWARE = HIGHER_ASSURANCE_GATE`

`NEXT_EXPERIMENT = NONE_UNTIL_REAL_TARGET_SEAM_SELECTED`
