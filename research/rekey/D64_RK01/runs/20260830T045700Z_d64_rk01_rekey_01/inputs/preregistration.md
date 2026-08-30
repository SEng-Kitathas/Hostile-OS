# D64 / RK01 — quiescent activity-namespace rekey preregistration

**Mode:** BUILD-COMMIT
**Parent profile:** `research/plans/HOSTILE_OS_TARGET_WORKLOAD_PROFILE_D64_2026-08-30.md`
**Parent plan:** `research/plans/D64_ACTIVITY_NAMESPACE_REKEY_PLAN_2026-08-30.md`
**Parent scale evidence:** D64/A01 CLOSED PASS
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Architecture promotion:** forbidden by this experiment alone

## Question

Can the configured 64-slot activity namespace continue safely after finite generation exhaustion pressure by using one explicit checked quiescent rekey that revokes the old activity-handle namespace, changes the activity epoch, resets all per-slot activity state, rejects old handles, and permits fresh activity admission — while rejecting rekey whenever live or activity-owned state prevents quiescence?

## Evidence envelope

Use the already-qualified stage-1/stage-2 envelope:

- one 512-byte stage 1;
- stage 1 loads exactly eight contiguous sectors / 4,096 bytes to `0x8000`;
- one fixed 4,096-byte freestanding stage 2;
- QEMU i386, one core, TCG;
- debug port `0xE9`;
- deterministic `isa-debug-exit` success exit 33.

No durable sector or second boot is required. RK01 is a runtime activity-namespace discriminator only.

## Run-input snapshot requirement

`research/infrastructure/EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` is mandatory from the first attempt.

Before compilation the launcher must snapshot at least:

- this preregistration;
- D64 profile;
- D64 rekey plan;
- stage-1 source/linker;
- stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

The receipt must bind to the run-local input manifest. Build must use the snapshotted source inputs, not later working-tree bytes.

## Fixed activity state

`ACTIVITY_CAP = 64`.

Preserve the same eleven per-slot activity field species:

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
11. activity epoch

Additional already-earned currentness/quiescence state allowed for this discriminator:

- one current `activity_epoch` byte;
- one `completion_status` byte;
- one `backing_live` byte;
- one `relation_active` byte.

No manager, allocator, dynamic container, Process, Scheduler, File, or capability subsystem may be introduced.

## Handle form

A checked activity handle is exactly:

`(slot, generation, epoch)`

Validation order must check:

1. slot `< ACTIVITY_CAP`;
2. slot occupied;
3. generation equality;
4. per-slot epoch equals handle epoch;
5. current global activity epoch equals handle epoch;
6. only then expose identity.

## Quiescence rule

`rekey_checked` may mutate namespace state only after all of these pass:

1. every one of the 64 `identity` entries is zero/free;
2. `completion_status == 0`;
3. `backing_live == 0`;
4. `relation_active == 0`.

If any check fails:

- return `R`;
- do not change current epoch;
- do not change any per-slot generation or activity field;
- do not clear the blocking state.

## Successful rekey transition

After all quiescence checks pass:

1. if current epoch is `1..254`, next epoch = current+1;
2. if current epoch is `255`, next epoch = `1`;
3. zero all eleven per-slot activity arrays across all 64 slots;
4. clear completion/currentness scratch belonging to the retired activity namespace;
5. publish/store the new current epoch;
6. return `W`.

Epoch zero is invalid and must never become current.

The `255 -> 1` transition is allowed only inside this explicit checked rekey. Ordinary acquire/runtime operation may not silently wrap generation or epoch.

## Runtime path A — live-state rejection

1. Reset to empty state, epoch 1.
2. Generic acquire identity `0x41` (`A`) -> slot 0, generation 1, epoch 1.
3. Save old handle `(0,1,1)`.
4. Call `rekey_checked` while A is live.
5. Required result `R`.
6. Required epoch remains 1.
7. Required slot-0 identity remains `0x41`, generation remains 1.
8. Release A through the generic release path -> `W`.

## Runtime path B — other quiescence guards

With all identities free and epoch still 1:

1. Set `completion_status='S'`; `rekey_checked` must return `R`; clear fixture byte afterward.
2. Set `backing_live=1`; `rekey_checked` must return `R`; clear fixture byte afterward.
3. Set `relation_active=1`; `rekey_checked` must return `R`; clear fixture byte afterward.

These fixture writes create blocking conditions only. They may not synthesize the rekey result.

Before the successful rekey, also place stale residue in free slot 63:

- generation = `7`;
- continuation = `2`.

## Runtime path C — successful quiescent rekey

1. Call `rekey_checked` with all four quiescence conditions satisfied.
2. Required result `W`.
3. Required new epoch = 2.
4. Required slot-63 generation = 0.
5. Required slot-63 continuation = 0.
6. Acquire identity `0x42` (`B`) through the same generic acquire path.
7. Required slot = 0, generation = 1, per-slot epoch = 2.
8. Old saved handle `(0,1,1)` must return `R` before exposing identity.
9. Fresh handle `(0,1,2)` must return `W` and identity `0x42`.

## Runtime path D — bad generation reset without epoch change

Reset to an independent identical state, epoch 1:

1. acquire A -> `(slot0,gen1,epoch1)` and save the old handle;
2. release A;
3. intentionally bad control zeros per-slot generations **without changing epoch**;
4. acquire B -> `(slot0,gen1,epoch1)`;
5. present the old saved `(0,1,1)` handle;
6. required bad-control result = `W` and observed identity = `0x42`.

This negative control demonstrates numerical stale-token alias when generation is reset without a namespace change.

The bad control must be a separate explicitly named routine and must not be used by the good rekey path.

## Runtime path E — explicit epoch wrap at quiescence

Reset to independent state with current epoch `255`:

1. acquire identity `0x43` (`C`) -> slot 0, generation 1, epoch 255;
2. save `(0,1,255)`;
3. release C and reach full quiescence;
4. call `rekey_checked`;
5. required result `W`;
6. required new epoch = 1, never 0;
7. acquire identity `0x44` (`D`) -> slot 0, generation 1, epoch 1;
8. old `(0,1,255)` must return `R`;
9. fresh `(0,1,1)` must return `W` and identity `0x44`.

This proves one explicit checked 255->1 namespace transition. It does not test or claim safety for arbitrary externally retained tokens from an epoch-1 namespace hundreds of rekeys earlier; such retention is outside the current cooperative in-scope revocation contract.

## Exact required debug matrix

Hex values use two digits.

```text
CAP=40
LIVE_REKEY=R
LIVE_EPOCH=01
LIVE_ID=41
LIVE_GEN=01
RELEASE=W
COMP_REKEY=R
BACKING_REKEY=R
ACTIVE_REKEY=R
QUIESCENT_REKEY=W
NEW_EPOCH=02
TAIL_GEN=00
TAIL_CONT=00
NEW_ACQ=W
NEW_SLOT=00
NEW_GEN=01
OLD=R
NEW=W
NEW_ID=42
BAD_OLD=W
BAD_READ=42
WRAP_REKEY=W
WRAP_EPOCH=01
WRAP_OLD=R
WRAP_NEW=W
WRAP_ID=44
DONE
```

Evaluator must require exact line order and values.

## Static/source closure requirements

Post-run inspection must verify all of the following as strict booleans:

1. `ACTIVITY_CAP` is exactly 64 and all eleven activity arrays use that same capacity;
2. one generic acquire and one generic release routine are used in the tested paths;
3. `rekey_checked` scans all identities for nonzero before its first namespace mutation;
4. `rekey_checked` checks completion status, backing live count, and relation-active before its first namespace mutation;
5. every reject branch returns before changing epoch or any activity array;
6. successful rekey resets all eleven activity arrays using a loop bounded by `ACTIVITY_CAP`, not slot-0/slot-63 special writes;
7. successful rekey changes epoch before returning and never publishes zero;
8. epoch 255 maps to 1 only in the explicit rekey routine;
9. ordinary acquire still fails closed with `G` if a free slot generation is 255, rather than wrapping generation to zero;
10. checked handle validates slot, occupancy, generation, per-slot epoch, and current global epoch before identity exposure;
11. bad reset routine zeros generation without changing epoch and is not called by `rekey_checked`;
12. good rekey and bad reset operate on the same activity arrays and handle checker;
13. run-local input snapshot/manifest existed before build and all receipt source hashes match run-local snapshots;
14. launcher/evaluator/static checker do not mutate guest activity state or synthesize debug lines;
15. every checker field under `checks` is JSON boolean, repairing the A01 checker-output typing scar.

## Measurements required

Receipt/result must record:

- stage-2 raw bytes;
- named runtime-state bytes;
- activity capacity = 64;
- activity field species = 11;
- rekey identity-scan iterations for successful quiescent rekey;
- rekey activity-reset iterations;
- generation/epoch width used in the discriminator;
- input-manifest SHA-256;
- exact source/artifact hashes;
- QEMU wall time as harness data only.

## Success criterion

RK01 passes only if:

- one controlling run has a complete pre-build input snapshot/manifest;
- build fits the 4 KiB stage-2 extent;
- QEMU completes exit 33;
- exact debug matrix matches;
- evaluator exits 0;
- all 15 static/source closure booleans are literal `true`;
- an independent closure audit verifies manifest/receipt/run-local-source lineage;
- engineering scars remain visible.

## Authority ceiling

A passing RK01 may establish only:

> under a cooperative in-scope quiescence/revocation contract, the configured 64-slot activity namespace can explicitly retire one namespace, change epoch, reset generations/state, reject immediate old handles, resume fresh admission, and perform a checked epoch-255->1 transition without silent ordinary-operation wrap.

It does **not** establish:

- general external capability revocation;
- safety for arbitrarily retained uncooperative handles across unlimited namespace cycles;
- live/non-quiescent rekey;
- wait-free or lock-free renewal;
- arbitrary resource-handle rekey;
- cryptographic identity;
- SMP/NMI/DMA correctness;
- production availability policy;
- final architecture;
- R3.1/R6 authority change.
