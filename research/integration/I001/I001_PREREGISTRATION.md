# I001 — Whole-Workload Freestanding Integration Preregistration

**Phase:** POST-C003 INTEGRATION
**Integration ID:** I001
**Campaign shape:** one bounded two-boot integration experiment, not a 20-pass campaign
**Parent evidence:** C001, C002, C003 20/20, POST-C003/R01, post-C003 campaign audit
**Architecture promotion:** FORBIDDEN BY I001 SUCCESS ALONE
**R3.1 authority promotion:** FORBIDDEN BY I001 SUCCESS ALONE

## Why I001 exists

C003 established broad bounded coverage and P20 composed a useful subset, but the post-campaign audit found no single freestanding executable that carries the main responsibility families together.

POST-C003/R01 also showed that a clear-before/clear-after active flag is insufficient for a reader that spans a complete mutation; changed version can detect that bounded span. P12 still proves finite wrap can alias if wrap is silent.

I001 therefore asks whether one small explicit state model can carry the main responsibilities together while keeping finite capacity, currentness, restart identity, failure, and asynchronous consequence visible.

## Qualified evidence envelope

The multi-sector boot envelope was separately qualified before this preregistration.

Qualification spec commit: `e8f3e9f6ad25ad610d20b75d34df60b2617bda70`.
Qualification close commit: `58e70a74ccf0640dc4a331d6511d34767e5f9d1d`.
Qualification result SHA-256: `3d36a10240b3f3acb001f6a8b8fe8b055b9b18fa206b15aa5e320fbf7ff026ea`.

Fixed disk layout:

- raw floppy image: 1,474,560 bytes;
- sector size: 512 bytes;
- BIOS sector 1 / zero-based 0: stage 1, exactly 512 bytes, signature `55aa`;
- BIOS sectors 2–9 / zero-based 1–8: stage 2, fixed 8-sector extent = 4,096 bytes;
- stage-2 load address: physical `0x8000`;
- stage-1 read: CHS 0/0/2, count 8;
- BIOS sector 10 / zero-based 9: durable sector;
- remaining sectors: zero fixture unless the guest writes them.

Stage 1 may use BIOS INT 13h as platform/firmware transport. BIOS transport is not HOSTILE-OS storage architecture.

## Fixed capacities and state

### Activity capacity

Exactly two runtime activity slots exist.

Main-path identities:

- `P` — parent activity;
- `C` — child activity;
- `B` — distinct later-progress activity.

P and C fill the two slots. B must first receive explicit full status `F`. After C completes and releases its slot, B must acquire that same slot through the same checked acquire path.

### Per-activity load-bearing fields

Each activity slot contains only the fields needed by the experiment:

- identity;
- 8-bit generation;
- progress;
- continuation;
- waiting flag;
- woken flag;
- lineage parent slot;
- lineage parent generation;
- wait-target slot;
- wait-target generation;
- runtime epoch.

Fields not applicable to an identity may be zero but must still be explicitly initialized on successful acquire/reuse.

### Shared backing

One runtime backing record exists:

- durable identity: `R`;
- value: `Z`;
- live count.

P and C begin as two live runtime bindings to R/Z. C release decrements live count from 2 to 1 and must preserve R/Z. P final release decrements 1 to 0 and must reclaim/clear the runtime backing.

The durable disk record may outlive runtime backing reclamation.

### Completion/event state

One bounded completion record exists:

- completed child slot;
- completed child generation;
- completion status.

One IRQ event state exists:

- event generation;
- IRQ relation-coherence observation.

No queue, heap, dynamic container, scheduler object, process object, file object, manager, service, exception runtime, or host-side guest state object is allowed.

## Finite currentness policy

### Activity generation

Activity generation is exactly 8 bits.

Rules:

- generation `0` is invalid/non-current;
- a free slot with generation `<255` may be acquired by incrementing generation, then writing identity and clean runtime fields;
- if a free slot already has generation `255`, acquire returns `G` (`generation exhausted`) and does not mutate owner/identity/value/runtime fields;
- modulo wrap to zero is forbidden;
- main path expected generations: P slot generation 1; C slot generation 1; B reuse of C slot generation 2.

I001 does not claim 8 bits are enough for a production lifetime. It proves only a fail-closed finite policy under this bounded workload.

### Runtime epoch across restart

Runtime epoch is exactly 8 bits and is stored as durable metadata only to distinguish clean-boot runtime-handle epochs.

Rules:

- durable epoch `0` means no prior qualified runtime epoch;
- Boot 1 creates epoch `1`;
- Boot 2 reads epoch `1` and rebinds at epoch `2`;
- an epoch increment that would wrap to zero must fail closed with `G` rather than silently alias;
- durable resource identity/value are separate from runtime epoch;
- a prior-boot runtime handle may be retained only as historical bytes for the negative/currentness check; it is never hydrated as current merely because its resource identity survived.

I001 does not establish crash-safe epoch update or universal epoch lifetime. Clean restart only.

## Durable sector record

The first 12 bytes of BIOS sector 10 are fixed:

| Offset | Meaning | Boot 1 expected | Boot 2 expected after rebind |
|---|---|---:|---:|
| 0..3 | magic | ASCII `H4I1` | unchanged |
| 4 | durable identity | ASCII `R` | unchanged |
| 5 | payload | ASCII `Z` | unchanged |
| 6 | serialized 0x1234 low byte | `0x34` | unchanged |
| 7 | serialized 0x1234 high byte | `0x12` | unchanged |
| 8 | runtime epoch metadata | `0x01` | `0x02` |
| 9 | historical handle slot | `0x00` | unchanged |
| 10 | historical handle generation | `0x01` | unchanged |
| 11 | historical handle epoch | `0x01` | unchanged |

Bytes 12..511 must remain zero.

The 0x1234 encoding is little-endian by explicit convention. The evaluator must inspect sector bytes directly; guest prose alone is not enough.

## Boot 1 required causal sequence

1. Stage 1 loads stage 2 and prints `S1_OK`.
2. Stage 2 detects absent durable magic and enters Boot 1.
3. Runtime state is explicitly initialized; runtime epoch becomes 1.
4. P acquires slot 0 at generation 1.
5. C acquires slot 1 at generation 1 with lineage pointing to P slot 0/gen1.
6. P and C create two live bindings to backing R/Z; live count becomes 2.
7. B acquisition while both activity slots are occupied returns `F`; C remains owner of slot 1.
8. P binds wait target C slot1/gen1 and continuation 2 through one bounded coherence region.
9. Unknown request U returns `M`; P progress stays 0 and continuation stays 2.
10. Guest prepares real PIT/PIC IRQ0 and enters explicit idle via `STI; HLT` while no useful main-path work is selected.
11. Real virtual IRQ0 wakes the guest. IRQ handler must observe the fully bound wait/continuation relation and record coherence success; it must not apply P progress.
12. Main path records C completion separately.
13. Generic lineage+wait+completion matching wakes P; P progress must still be 0.
14. Separate application consumes continuation 2 and advances P progress to 2.
15. A negative control using the same P slot demonstrates collapsed wake+apply by producing progress 2 at wake time.
16. C runtime binding releases: backing live count becomes 1 and value remains Z.
17. C activity slot releases.
18. B acquires released slot 1 through the same checked acquire path at generation 2 with clean runtime fields.
19. Known request K plus separate application advances B progress to 1, proving prior U did not globally poison later progress.
20. Checked use of stale C handle slot1/gen1/epoch1 returns `R` before reading B identity/value.
21. Address-only negative control on the same slot returns B, exposing silent stale retargeting when generation is ignored.
22. The R01-style spanning-read controls run inside the same payload/state discipline: clear/clear active-flag control accepts mixed state `S`; changed-version path rejects `R`; stable unchanged-version path accepts `C`.
23. Guest serializes durable R/Z + little-endian 0x1234 + epoch1 + historical P handle bytes and writes sector 10.
24. P runtime binding releases: backing live count becomes 0 and runtime backing value clears.
25. P activity may then release.
26. Generation-exhaustion control uses the same checked acquire routine on a free activity slot forced in guest code to generation 255; acquire returns `G` and leaves identity zero.
27. Global-latch negative control uses the same request/result vocabulary and demonstrates that a bad global poison path would block B with `X` after U.
28. Full/unchecked negative control uses the same two-slot representation after main-path observations and demonstrates that an overwrite-on-full path can replace C with B.
29. Guest exits QEMU success path.

## Boot 1 exact required debug trace

```text
S1_OK
BOOT=1
P_ACQ=W
P_GEN=1
C_ACQ=W
C_GEN=1
B_FULL=F
FULL_OWNER=C
WAIT_CONT=2
MISS=M
MISS_PROG=0
MISS_CONT=2
IDLE_ENTER=1
IRQ_EVENT=1
IRQ_REL=1
WAKE=1
WAKE_PROG=0
APPLY_PROG=2
BAD_WAKE_PROG=2
C_RELEASE=W
LIFE_C_COUNT=1
LIFE_C_VALUE=Z
B_ACQ=W
B_GEN=2
B_PROG=1
STALE_C=R
BAD_STALE=B
FLAG_CTL=S
VER_CTL=R
STABLE_CTL=C
DURABLE_WRITE=W
P_RELEASE=W
LIFE_P_COUNT=0
LIFE_P_VALUE=0
GEN_EXHAUST=G
GEN_OWNER=0
BAD_GLOBAL_B=X
BAD_FULL_OWNER=B
DONE
```

## Boot 2 required causal sequence

1. Fresh QEMU process boots the same disk and stage 1 prints `S1_OK`.
2. Stage 2 reads sector 10 and verifies exact durable magic/identity/value/serialization bytes from Boot 1.
3. Runtime state begins freshly initialized with no current binding.
4. Good use before rebind returns `R`.
5. Negative control that treats durable identity as if it were already a current runtime binding returns `W`.
6. Rebind validates epoch 1, advances durable/runtime epoch to 2 without zero-wrap, recreates runtime backing R/Z, and acquires current runtime handle slot0/gen1/epoch2.
7. Current use after rebind returns `W`.
8. Historical Boot-1 handle slot0/gen1/epoch1 is rejected as `R`; epoch is the discriminating field because slot/gen are intentionally reused.
9. Guest rewrites sector 10 with epoch byte 2 while preserving bytes 0..7 and 9..11 and all zero tail bytes.
10. Guest exits success path.

## Boot 2 exact required debug trace

```text
S1_OK
BOOT=2
DURABLE=PASS
PREBIND=R
BAD_RESTART_USE=W
REBIND=W
POSTBIND=W
OLD_TOKEN=R
EPOCH=2
DURABLE_REWRITE=W
DONE
```

## Required negative controls

All controls must live in the same stage-2 payload and use the same state representation or result vocabulary as the good path. Host-side comparison of unrelated toy executables is forbidden.

Required controls:

1. `BAD_WAKE_PROG=2` — wake+application collapse.
2. `BAD_STALE=B` — address-only stale retargeting.
3. `FLAG_CTL=S` versus `VER_CTL=R` and `STABLE_CTL=C` — spanning-reader currentness control.
4. `BAD_RESTART_USE=W` — durable-identity-as-current collapse across restart.
5. `BAD_GLOBAL_B=X` — global failure poisoning distinct later progress.
6. `BAD_FULL_OWNER=B` — overwrite-on-full collapse on the same two-slot representation.

## IRQ/coherence contract

IRQ0 must be a real QEMU virtual hardware consequence using guest PIT/PIC programming and a guest IVT handler.

The wait-target/continuation relation must be updated inside a named critical region with explicit begin/end labels. The IRQ handler must verify/snapshot the fully established relation after interrupts are enabled.

The result must report the instruction count between the critical-region labels and must not call that count a general latency bound.

No SMP, NMI, DMA, or general memory-ordering claim is allowed.

## Request/status contract

At minimum the result vocabulary includes:

- `W` — successful bounded operation/use/acquire/rebind;
- `F` — capacity full;
- `M` — missing operation;
- `O` — known operation success before application;
- `R` — rejected/non-current;
- `G` — finite generation/epoch exhausted;
- `X` — deliberately poisoned/blocked negative-control result.

Missing request U must not mutate P progress/continuation or the good-path global execution state.

## Static/source closure requirements

Independent post-run inspection must verify at least:

1. stage 1 reads exactly 8 sectors from CHS 0/0/2 to 0x8000 and jumps to 0000:8000;
2. exactly two activity slots exist;
3. one checked acquire routine is used for P, C, B reuse, and generation-exhaustion control;
4. checked acquire tests free/full and generation exhaustion before identity/runtime-field mutation;
5. successful acquire increments generation and explicitly initializes every listed runtime field;
6. C lineage identifies current P slot/generation;
7. P wait target includes C slot and generation;
8. wait binding stores target and continuation inside the named IRQ coherence region;
9. IRQ handler does not apply P progress;
10. completion recording, wait matching/wake, and progress application are separate routines or separately inspectable blocks;
11. missing request status is checked before progress application;
12. good path contains no global poison latch;
13. C release decrements live count but does not clear backing at count 1;
14. P final release clears backing only at count 0;
15. checked stale-handle use compares slot generation and runtime epoch before returning occupant identity/value;
16. address-only negative control omits generation comparison;
17. R01-style flag control omits version comparison while version control compares saved pre/post versions;
18. durable record bytes 0..11 are written by guest code in the declared order/convention;
19. Boot 2 prebind good path rejects before current binding exists;
20. Boot 2 rebind advances epoch 1->2 and old-token check includes epoch comparison;
21. generation/epoch increment paths fail before zero-wrap;
22. host launcher does not inject guest state after boot or manufacture debug lines;
23. evaluator reads guest traces and raw durable-sector extracts rather than rewriting guest state;
24. negative controls share the same stage-2 payload.

## Harness and two-process restart contract

The launcher may:

- compile/link stage 1 and stage 2;
- pad stage 2 to the fixed 4,096-byte disk extent;
- create the initial zero-filled raw floppy;
- launch Boot 1 QEMU;
- wait for Boot 1 process to exit completely;
- hash and extract the durable sector;
- launch a distinct fresh Boot 2 QEMU process on the resulting disk;
- hash and extract the durable sector again;
- run independent evaluator/static checks.

The launcher must record distinct Boot 1 and Boot 2 QEMU PIDs and times.

The launcher must not mutate the durable sector between the two QEMU processes.

Timeout or ambiguous QEMU state is `UNKNOWN`, never success or failure by assumption.

## Durable-sector evaluator requirements

After Boot 1:

- bytes 0..3 = `48 34 49 31` (`H4I1`);
- byte 4 = `52` (`R`);
- byte 5 = `5a` (`Z`);
- bytes 6..7 = `34 12`;
- byte 8 = `01`;
- bytes 9..11 = `00 01 01`;
- bytes 12..511 = zero.

After Boot 2:

- bytes 0..7 unchanged;
- byte 8 = `02`;
- bytes 9..11 unchanged `00 01 01`;
- bytes 12..511 = zero.

## Pareto measurements required

The final result must report:

- stage-1 raw bytes and signature;
- stage-2 linked text/data/bss and raw binary bytes;
- stage-2 fixed disk extent 4,096 bytes;
- durable logical record bytes = 12 and sector bytes = 512;
- runtime-state bytes between explicit `runtime_state_start` / `runtime_state_end` symbols;
- activity capacity = 2;
- activity generation width = 8 bits;
- runtime epoch width = 8 bits;
- main-path maximum observed slot generation = 2;
- formal per-slot valid generation values = 1..255 with fail-closed exhaustion before wrap;
- longest named IRQ-masked critical-region instruction count;
- explicit result-code set/count;
- Boot 1 and Boot 2 QEMU wall times as harness measurements only;
- all engineering scars before the controlling run;
- evaluator/static-check source and artifact hashes;
- explicit list of state-block species added in I001.

No single scalar “performance score” is allowed to hide tradeoffs.

## Success criterion

I001 passes only if one controlling built image and two fresh QEMU processes satisfy all of the following:

- exact Boot 1 trace;
- exact Boot 2 trace;
- both QEMU exits are 33 and processes are distinct;
- raw durable-sector bytes match both post-boot expectations;
- stage-1/stage-2 layout contract passes;
- static/source closure passes all required checks;
- negative controls show the specified bad consequences;
- good path still completes after all required interactions;
- source/run hashes and Pareto measurements are captured.

## Failure / unknown handling

- build/link/launcher defects before qualified execution are engineering scars unless they show the preregistered evidence envelope cannot hold the discriminator;
- timeout or ambiguous QEMU state = UNKNOWN;
- evaluator mismatch after qualified execution = scientific failure for that run;
- a passing trace with failed static/source closure is not success;
- later stronger evidence must append; it may not rewrite this preregistration.

## Authority ceiling / nonclaims

Even a full I001 pass may establish only that this bounded integrated descendant can carry the preregistered two-boot workload under the qualified QEMU/BIOS evidence envelope.

It does not establish:

- final HOSTILE-OS architecture;
- arbitrary workload support;
- production generation/epoch sizing;
- crash/partial-write consistency;
- SMP/NMI/DMA correctness;
- universal scheduler/process/file absence;
- general capability or memory safety;
- physical-hardware proof;
- R3.1 replacement readiness;
- R6 demotion;
- architecture promotion without a later separate gate.

## Preregistered disposition

`I001_READY_FOR_IMPLEMENTATION_AFTER_GIT_SEAL / TWO_ACTIVITY_SLOTS / 8_BIT_FAIL_CLOSED_GENERATION_AND_EPOCH / 4_KIB_STAGE2 / TWO_QEMU_BOOTS / NO_PROMOTION`
