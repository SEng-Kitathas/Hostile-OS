# D64 / A01 — generic activity-capacity scaling preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Purpose:** test whether the current activity-state/lifecycle model survives configuration from 2 to 64 slots without hardcoded two-slot behavior or a new primitive species
**Architecture promotion:** forbidden by this experiment alone

## Question

Can the current structure-of-arrays activity representation be configured to exactly 64 slots, fill all 64 through one generic checked-acquire path, return explicit full status on a 65th admission without mutation, release and reuse a non-edge slot through generic indexed code, and preserve generation-qualified stale/fresh handle behavior?

## Evidence envelope

Use the already-qualified post-C003 stage-1 loader shape:

- one 512-byte stage 1;
- stage 1 loads exactly eight contiguous sectors (4,096 bytes) to `0x8000`;
- one fixed 4,096-byte freestanding stage-2 extent;
- QEMU i386, single core, TCG;
- debug port `0xE9`;
- deterministic `isa-debug-exit` success exit 33.

No durable sector or second boot is needed because A01 tests runtime activity capacity only.

## Required run-input snapshot discipline

The launcher must obey `research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` from the first run.

Before compilation it must create `<run>/inputs/`, snapshot all controlling inputs, and write/hash `inputs_manifest.json`.

At minimum snapshot:

- this preregistration;
- D64 target workload profile;
- stage-1 source/linker;
- stage-2 source/linker;
- launcher;
- evaluator;
- static checker;
- any configuration file if used.

A run executed before the snapshot/manifest exists cannot become controlling science.

## Fixed activity representation

A01 must preserve the same eleven logical activity field species used by I001:

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

`ACTIVITY_CAP = 64` must be a named build/source constant.

The experiment may use structure-of-arrays storage as I001 did. It may not add a Process/Scheduler/Manager object merely to scale the table.

Generation and epoch remain 8-bit **for this discriminator only**, because the main path uses generations 1 and 2 and does not test long-lifetime sizing. D64's rekey/lifetime seam remains open.

## Required good path

### Fill

1. Start with all 64 activity identities zero/free.
2. Call the same generic `acquire_next` routine 64 times.
3. Each successful acquire must:
   - find a free slot by scanning within `ACTIVITY_CAP`;
   - increment that slot generation from 0 to 1;
   - store the supplied nonzero identity;
   - initialize progress/continuation/waiting/woken/parent/wait target fields to zero;
   - store runtime epoch 1;
   - return `W`.
4. Identities for the fill may be byte values `1..64` so slot 0 should contain `01` and slot 63 should contain `40` in hex.

### Full

5. A 65th `acquire_next` call with identity `0x41` must scan the same 64-slot table, find no free slot, return `F`, and mutate no activity field.
6. Slot 0 must still be identity `01`, generation `01`.
7. Slot 63 must still be identity `40`, generation `01`.

### Release/reuse

8. Call one generic indexed release routine for slot index 31 (`0x1F`).
9. Release must return `W` and clear only occupancy/identity for that slot; generation remains 1 until next successful acquire.
10. Call the same generic `acquire_next` with identity `0x5A` (`Z`).
11. It must choose the first free slot, which is index 31, increment generation to 2, initialize the other runtime fields, and return `W`.

### Currentness

12. Checked handle `(slot=31, generation=1, epoch=1)` must return `R` before exposing current occupant state.
13. Checked handle `(slot=31, generation=2, epoch=1)` must return `W` and observe identity `0x5A`.

## Exact required debug matrix

Values are hexadecimal where two digits are shown.

```text
CAP=40
FILL_COUNT=40
FIRST_ID=01
FIRST_GEN=01
LAST_ID=40
LAST_GEN=01
FULL=F
POST_FULL_FIRST=01
POST_FULL_LAST=40
RELEASE=W
REUSE=W
REUSE_SLOT=1F
REUSE_ID=5A
REUSE_GEN=02
STALE=R
FRESH=W
FRESH_ID=5A
DONE
```

The evaluator must require exact line order and exact values.

## Static/source closure requirements

Post-run source inspection must verify:

1. `ACTIVITY_CAP` is exactly 64 / `0x40` and is a named constant;
2. all eleven activity field arrays are sized from the same capacity constant or expand to exactly 64 entries each;
3. there is one generic acquire routine rather than separate per-slot acquire routines;
4. acquire scans or indexes only within the declared capacity and checks bounds before mutation;
5. full return occurs only after the scan reaches capacity and the full branch does not write activity arrays;
6. one generic release routine checks index `< ACTIVITY_CAP` before mutation;
7. the release/reuse path uses slot 31 through the generic routines, not a slot-31 special function;
8. generation increments only on successful acquire and returns `G` rather than silently zero-wrapping if a selected free slot is already generation 255;
9. checked handle validation compares slot bounds, generation, and epoch before exposing identity;
10. no hardcoded two-slot capacity compare from I001 remains in the good-path activity routines;
11. the launcher snapshots controlling inputs before build and receipt hashes bind to the run-local snapshots;
12. host launcher/evaluator does not mutate guest activity state or synthesize debug lines.

## Success criterion

A01 passes only if one qualified run satisfies all of:

- pre-build input snapshot/manifest exists and verifies;
- build/link fit the qualified 4 KiB stage-2 extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- static/source closure passes all 12 requirements;
- source/run/input-manifest hashes are captured;
- engineering failures remain visible and are not counted as scientific failure unless they expose a true inability to meet the preregistered envelope.

## Authority ceiling

A passing A01 may establish only:

> the I001 activity-state/lifecycle representation and checked acquire/release/currentness semantics scale from a hardcoded two-slot witness to one configured 64-slot freestanding table for this bounded fill/full/reuse workload.

It does **not** establish:

- arbitrary or dynamic activity capacity;
- donor Process architecture;
- scheduling policy;
- donor-equivalent workload support;
- resource-binding scale;
- long-lifetime generation sizing;
- rekey/new-namespace behavior;
- SMP/NMI/DMA correctness;
- physical hardware behavior;
- architecture promotion;
- R3.1/R6 authority change.
