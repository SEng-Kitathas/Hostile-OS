# HOSTILE-OS Target Workload Profile D64 — 2026-08-30

**Mode:** BUILD-PLAN
**Profile class:** donor-scale reference qualification profile
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Production profile:** false
**New experiment:** not created by this document

## Purpose

Close the current P0 ambiguity around target scale without turning I001 witness numbers into architecture law or pretending the project has product telemetry it does not have.

This profile uses historical donor capacities as **pressure numbers**, not architectural authority. It asks whether the HOSTILE-OS state model can scale to a real small-machine general-purpose order of magnitude while keeping capacity finite, configured, observable, and explicit.

## Target machine / assurance class

Current D64 target:

- x86 PC-compatible execution class;
- single core;
- maskable interrupts are in scope;
- SMP, NMI coherence, DMA coherence, and weak-memory multiprocessor ordering are out of scope;
- QEMU is sufficient for this shadow qualification class;
- physical hardware remains a higher-assurance gate;
- BIOS/firmware may remain an explicit borrowed bootstrap/transport boundary under the current shadow posture;
- clean restart persistence is in scope;
- crash/partial-write/power-loss recovery is out of scope.

These boundaries come from the already-sealed target-boundary decisions and are not changed here.

## Workload scale

### Activity capacity

`ACTIVITY_CAP = 64`

Reason: Linux 0.01 used `NR_TASKS=64`. D64 adopts that only as a donor-scale qualification pressure point. It does not claim 64 is universally optimal.

Requirement:

- the same activity representation and admission semantics must be configurable to 64 slots;
- checked admission occurs before mutation;
- slot 65 admission under full occupancy returns explicit full status;
- release/reuse/currentness behavior must not depend on hardcoded slot 0/1 logic.

### Per-activity binding-reference pressure

`BINDING_REFS_PER_ACTIVITY = 20` as a qualification interface ceiling.

Reason: Linux 0.01 used `NR_OPEN=20`, and a DOS/FreeDOS-compatible PSP carries a default 20-entry Job File Table.

This does not import a File primitive. It means one activity may need up to 20 simultaneous references to separately identified resources/bindings under the donor-scale pressure profile.

### Global live resource pressure

`GLOBAL_LIVE_RESOURCE_PRESSURE = 64`

Reason: Linux 0.01 used `NR_FILE=64` as a global open-file object limit. D64 uses the count only as global resource pressure.

No HOSTILE-OS resource-object layout is selected by this profile. I001's single shared-backing record is therefore **not sufficient evidence** for D64 resource scaling.

### Donor-only comparison values

Linux 0.01 also used `NR_INODE=32` and `NR_SUPER=8`.

D64 records those values but does not translate them into HOSTILE-OS primitive tables. A future resource/storage ontology must earn any corresponding state species.

## Static cost projection from the current I001 activity representation

I001's runtime activity state is a structure-of-arrays with eleven one-byte fields per slot:

1. identity
2. generation
3. progress
4. continuation
5. waiting
6. woken
7. parent slot
8. parent generation
9. wait slot
10. wait generation
11. runtime epoch

I001 therefore uses:

- 22 bytes for two activity slots;
- 29 bytes of other named runtime state;
- 51 bytes total named runtime state.

Mechanical D64 projection, keeping the same one-byte field widths and only scaling activity arrays:

- activity state: `64 * 11 = 704` bytes;
- fixed non-activity named state: `29` bytes;
- projected named runtime state: `733` bytes.

I001 stage 2 is 2,478 bytes. If code size and every non-activity byte stayed unchanged, activity-array growth alone would add `62 * 11 = 682` bytes, giving a rough stage-2 size of `3,160` bytes inside the existing 4,096-byte extent.

**This is a static lower-bound projection, not a built result.** Generic 64-slot scan/admission/release code may change text size and timing.

The projection does establish one useful point: 64 activity records are not obviously blocked by raw state bytes inside the current evidence envelope. The current gap is hardcoded two-slot embodiment and generic indexing, not a demonstrated memory impossibility.

## Lifetime/currentness assumption

D64 does **not** declare a credible finite maximum number of slot reuses or namespace advances over the life of a long-running general-purpose runtime.

Therefore:

- I001's 8-bit fail-closed generation/epoch is valid witness evidence but cannot be treated as D64 sizing;
- correctness must not depend on the operator rebooting before a small counter exhausts;
- a higher D64 embodiment needs an explicit rekey/new-namespace path or another currentness mechanism before a finite namespace aliases;
- generation/epoch width remains configurable until rekey cost and target availability policy are pressure-tested.

This is a derived requirement, not an invented numeric lifetime bound: **no credible bound -> rekey required** under the existing target-boundary law.

## Restart namespace rule

For D64:

- durable identity/bytes may survive clean restart;
- volatile runtime handles do not become current merely because durable identity survived;
- clean restart creates a fresh volatile namespace;
- D64 does not require persistent external runtime handles to survive reboot;
- any later target that persists/export runtime handles must reopen that seam explicitly.

This keeps durable identity separate from volatile currentness and avoids pretending a runtime token is a durable name.

## Firmware/device boundary

D64 is a **current-shadow** profile, not the higher storage/device posture.

Therefore explicit BIOS/firmware borrowing after state restoration remains lawful for this profile. Native post-takeover storage transport is not required merely to satisfy D64.

That seam remains open only for a later profile that claims stable owned device/storage transport after takeover.

## What D64 exposes as real gaps

### Gap 1 — activity capacity is configured in doctrine but hardcoded in I001 embodiment

I001 has exactly two arrays entries and direct two-slot control flow. D64 requires 64 configured slots and generic checked scan/index behavior.

This is a real embodiment gap and is small enough for a focused next discriminator.

### Gap 2 — donor-scale resource binding is largely unembodied

I001 has one shared-backing record. D64 asks for up to 20 references from one activity and 64 global live-resource pressure.

No resource-binding representation should be invented in this profile. The gap is recorded for later derivation after activity scaling is pressure-tested.

### Gap 3 — long-running namespace renewal/rekey is unembodied

I001 proves fail-closed exhaustion but not continued operation after exhaustion. D64's lack of a credible fixed reuse horizon makes explicit rekey/new-namespace behavior a real later seam.

## Next discriminator selection

The smallest next discriminator is **generic activity-capacity scaling**, before resource-binding or rekey work.

Reason:

- it directly tests an already-promoted rule: capacity is configured, finite, checked, and observable;
- current state arrays show that 64-slot byte cost is plausible;
- it does not require a new resource ontology;
- it can test whether hardcoded two-slot assumptions are hiding in admission, release, wait targeting, generation currentness, or indexing;
- it can exercise the new run-input snapshot protocol on a real experiment rather than a dummy run.

The next experiment should not claim general workload support. It should only ask whether the current activity state model and checked lifecycle semantics survive configuration from 2 to 64 slots without adding a new primitive species.

## Profile disposition

`D64 = DONOR_SCALE_REFERENCE / ACTIVITY_CAP_64 / BINDING_REF_PRESSURE_20 / GLOBAL_RESOURCE_PRESSURE_64 / SINGLE_CORE_IRQ / CLEAN_RESTART / FIRMWARE_BORROW_ALLOWED / NO_CREDIBLE_REUSE_BOUND -> REKEY_REQUIRED / NEXT_SEAM = GENERIC_ACTIVITY_CAPACITY_SCALING`
