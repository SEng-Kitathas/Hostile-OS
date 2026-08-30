# Post-C003 Integration Gate Plan — 2026-08-30

**Mode:** BUILD-PLAN ONLY
**Status:** design gate; not a campaign preregistration
**C003 state:** CLOSED 20/20
**POST-C003/R01 state:** CLOSED
**Architecture promotion:** NONE
**New campaign name:** NOT YET ASSIGNED

## Purpose

C003 proved many responsibilities in separate freestanding slices and P20 composed a useful subset. POST-C003/R01 closed the exact spanning-reader active-flag seam at bounded scope.

The next question is no longer whether each responsibility can exist alone. It is whether the load-bearing families can coexist in one small, explicit, freestanding workload without hidden host control or a forced return to inherited subsystem nouns.

This document defines the gate that must be satisfied before a new integration campaign is named or preregistered.

## What the integration must combine

The minimum integrated workload must exercise these families in one coherent state model:

1. **boot / initialization boundary**
   - explicit freestanding entry;
   - explicit initialization of load-bearing runtime state;
   - no host-created relation objects.

2. **finite activities and progress**
   - at least parent P, child C, and one distinct later-progress activity B;
   - fixed capacity with explicit full result rather than silent overwrite.

3. **wait / wake / continuation / lineage**
   - parent P binds an explicit continuation before waiting;
   - child C completion is recorded separately from parent application;
   - lineage + current wait target + current completion determine wake eligibility;
   - wake does not itself apply parent progress;
   - separate application consumes the stored continuation.

4. **real asynchronous consequence and idle**
   - when no useful activity is runnable, guest enters explicit idle identity using `STI; HLT` or an equally explicit qualified mechanism;
   - real QEMU virtual IRQ0 supplies the asynchronous event that wakes the guest;
   - the harness must not fake the event or advance guest progress.

5. **bounded missing-operation failure and locality**
   - unknown request U returns explicit missing status;
   - protected local state and bound continuation remain unchanged;
   - a distinct later activity B still makes progress;
   - no global poison/error latch is allowed in the good path.

6. **fixed-slot reuse / initialization / currentness**
   - a released slot can be reused only through one checked acquire path;
   - every load-bearing field is explicitly initialized on reuse;
   - stale location-only access has an explicit negative control;
   - version-qualified access checks currentness before reading reused value.

7. **multi-field coherence**
   - any coupled relation transition that can be observed asynchronously must have an explicit coherence rule;
   - interrupt masking may be used only for the exact bounded region it protects;
   - interrupt-off length must be measured or instruction-counted as a Pareto cost.

8. **shared backing lifetime**
   - at least two live bindings share one backing value;
   - releasing one binding must not reclaim backing while another live binding remains;
   - final release may reclaim according to the explicit liveness rule.

9. **serialization and persistence across clean restart**
   - durable identity/value is encoded into explicit bytes using a declared byte order;
   - first QEMU process writes the durable record and exits completely;
   - second QEMU process reads the same durable record;
   - volatile runtime binding starts expired and must be explicitly rebound before use;
   - runtime handles from the prior boot are not treated as current merely because durable identity survived.

10. **bounds / capacity**
    - every indexed relation mutation checks capacity before write;
    - capacity exhaustion returns explicit bounded status;
    - no adjacent-state corruption or overwrite-on-full is allowed in the good path.

## Provisional finite-version policy for integration

R01 makes version/change detection necessary for the tested spanning-reader model. P12 proves that equality-only finite versions eventually alias if allowed to wrap silently.

The smallest candidate policy for the integration gate is therefore:

### Fail-closed-on-wrap candidate

- use a finite explicit version/generation field;
- generation zero is reserved as non-current / invalid;
- successful reuse increments generation;
- if the next increment would wrap to zero, reuse returns explicit `G` (`generation exhausted`) and does not mutate ownership/value;
- no silent modulo wrap is permitted inside the current runtime epoch;
- clean restart invalidates all volatile runtime handles independently of durable identity;
- durable resource identity and bytes remain separate from volatile handle generation.

This policy converts infinite-width host convenience into bounded capacity plus explicit failure rather than pretending finite width is infinite.

### Why this is only provisional

The candidate is not yet architecture doctrine. It trades silent alias risk for finite reuse capacity. A later target workload may justify a wider field, epoch+generation composition, explicit rekey, or another mechanism.

Before preregistration, the integration spec must state:

- exact generation width;
- exact maximum qualified reuse count per runtime epoch;
- exact behavior at exhaustion;
- whether restart/rekey resets the volatile epoch;
- which tokens are allowed to survive restart, if any.

No width may be called “enough” without a stated lifetime/reuse bound.

## Evidence-envelope decision

The 512-byte one-sector ceiling was useful pressure for C003, but P20 reached 511 linked bytes and R01 reached 509. Whole-workload integration should not confuse this test-envelope limit with architecture law.

Preferred integration evidence envelope:

### Stage 1 — 512-byte boot loader

Responsibilities only:

- establish the boot boundary;
- load a fixed, declared number of contiguous stage-2 sectors from the raw image;
- transfer control to stage 2;
- fail explicitly if the fixed load fails.

Any BIOS disk service used here must be declared as a platform/firmware dependency, not hidden as HOSTILE-OS mechanism.

### Stage 2 — fixed-size freestanding integration payload

Responsibilities:

- all relation state and workload logic;
- IRQ/idle behavior;
- wait/wake/lineage/continuation;
- failure locality;
- lifecycle/currentness/lifetime;
- serialization/persistence logic;
- debug trace.

Stage 2 remains static/fixed-size for the experiment. No heap or dynamic runtime is required merely because the evidence envelope is larger than one sector.

### Durable sector

Reserve a sector outside stage-1/stage-2 code for the persistent record. Its layout and byte order must be declared and independently inspected after Boot 1 and Boot 2.

## Candidate integrated workload

### Boot 1

1. Stage 1 loads stage 2 and transfers control.
2. Stage 2 initializes fixed runtime relation state explicitly.
3. Parent P and child C are admitted through checked fixed-capacity paths.
4. P binds continuation 2 and waits for current child C completion under explicit lineage/wait relation.
5. Unknown request U is issued through the same status path; it returns M and leaves P continuation/progress unchanged.
6. No useful work remains; guest enters explicit idle.
7. Real IRQ0 wakes the guest and causes the preregistered child-event path to become observable.
8. C completion is recorded; generic wait matching wakes P; wake alone does not advance P.
9. Separate application consumes continuation 2 and advances P to 2.
10. Distinct activity B performs later progress, proving U did not globally poison execution.
11. Two live bindings share backing X; one release preserves X for the remaining binding.
12. A fixed slot is released and reused through checked initialization/currentness logic.
13. A stale generation/address negative control remains unable to read the new occupant on the checked path.
14. Durable identity/value is serialized in declared byte order and written to the durable sector.
15. QEMU exits completely.

### Boot 2

1. Fresh QEMU process boots the same image and loads stage 2.
2. Durable record is read and decoded.
3. Durable identity/value must match Boot 1.
4. Volatile runtime binding starts expired.
5. Use before rebind returns bounded non-current result.
6. Explicit rebind establishes a fresh current runtime binding.
7. Current use succeeds after rebind.
8. Any prior-boot runtime token/handle is rejected rather than hydrated as current.
9. Final trace and durable-sector inspection agree.

## Required negative controls

At least these controls must survive into the eventual preregistration:

1. **flag-only spanning read control**
   - clear/clear active flag across a full mutation can accept mixed state;
   - version-qualified good path rejects changed version.

2. **address-only stale handle control**
   - same storage location after reuse can expose the new occupant if generation is ignored.

3. **global failure latch control**
   - demonstrates why local missing status must not block distinct later B progress.

4. **wake-applies-progress control**
   - demonstrates collapse if wake and continuation application are fused.

5. **restart-hydrates-volatile-binding control**
   - must fail the restart boundary by treating stale runtime binding as current without rebind.

6. **overwrite-on-full or unchecked-index control**
   - demonstrates capacity/bounds failure without adding a general memory manager.

Not every negative control has to run in the same branch, but all must share the same state representation and integration payload so the harness cannot compare unrelated toy systems.

## Pareto measurements required

The future integration result must report at least:

- stage-1 bytes;
- stage-2 linked text/data/bss bytes;
- durable-record bytes;
- runtime relation-state bytes;
- number and width of generation/version fields;
- fixed activity/slot capacity;
- longest interrupt-masked instruction region;
- number of explicit status values used;
- Boot 1 and Boot 2 QEMU wall time as harness data only;
- engineering scars/build failures;
- evaluator/static-inspection burden;
- ontology count: distinct primitive state species added beyond already-earned relation fields.

These numbers are evidence, not automatic optimization scores. Any Pareto claim must state which dimensions improved and which worsened.

## Harness boundary

The host may:

- build and link;
- launch QEMU;
- provide the raw disk image;
- collect debug output;
- inspect durable sectors;
- compare traces to preregistered expectations;
- hash artifacts.

The host must not:

- choose guest activity;
- inject relation state after boot;
- synthesize wake/application results;
- repair stale handles;
- perform guest serialization for the mechanism;
- decide missing-operation behavior;
- fake restart binding expiry/rebind;
- manufacture debug lines.

## Gate to future preregistration

A separately named integration experiment/campaign may be preregistered only after its spec fixes:

1. exact stage-1/stage-2 disk layout;
2. exact fixed activity/slot counts;
3. exact version width and fail-closed/exhaustion rule or a justified alternative;
4. exact Boot 1 and Boot 2 trace matrix;
5. exact negative-control matrix;
6. static/source closure rules;
7. evaluator independence rules;
8. Pareto measurements;
9. authority ceiling and nonclaims.

## Promotion ceiling

Even a fully passing integration would establish only a stronger integrated descendant under the preregistered workload.

It would not automatically establish:

- final HOSTILE-OS architecture;
- universal absence of scheduler/process/file abstractions;
- arbitrary workload support;
- SMP correctness;
- physical hardware proof;
- universal version/lifetime policy;
- R3.1 replacement readiness;
- R6 demotion.

Architecture or authority promotion would remain a separate explicit gate after integration evidence exists.

## Gate disposition

`BUILD_PLAN_READY / INTEGRATION_PREREGISTRATION_NOT_YET_CREATED / FAIL_CLOSED_VERSION_POLICY_PROVISIONAL / TWO_BOOT_STAGE2_WORKLOAD_PROPOSED / NO_PROMOTION`
