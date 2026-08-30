# I001 — Whole-Workload Freestanding Integration Result

**Disposition:** PASS CLOSED / BOUNDED INTEGRATION SUCCESS
**Preregistration commit:** `e3dcaa6a246b58c97539a999eb973bdddb820278`
**Architecture promotion:** NONE
**R3.1 authority promotion:** NONE

## Controlling evidence envelope

The eight-sector stage-2 loader was separately qualified before I001 implementation.

- qualification close commit: `58e70a74ccf0640dc4a331d6511d34767e5f9d1d`
- stage 1: 512-byte boot sector
- stage 2: fixed 4,096-byte disk extent loaded to `0x8000`
- durable sector: BIOS sector 10 / zero-based 9
- image: 1,474,560-byte raw floppy

BIOS INT 13h remains platform/firmware transport evidence only.

## Run history and scars

### Attempt 1 — qualified failed run

Run: `20260830T042200Z_i001_integration_01`

The build and stage-2 transfer succeeded. Boot 1 reached the integrated main path through:

- two-slot P/C admission;
- explicit full rejection for B;
- wait/continuation binding;
- missing-operation preservation;
- real IRQ0 idle wake;
- separate completion/wake/application;
- backing live-count preservation;
- C-slot reuse by B;
- stale-handle rejection/address-only negative control;
- R01-style flag/version controls.

It then printed `IO_FAIL` and exited QEMU through the failure path (`35`) when durable BIOS transport followed guest PIC/IRQ takeover.

Important cross-mechanism scar: the extracted durable sector after the failed run had SHA-256 `ca8bf03a22f505e0d2048fd2e4f55f7003a9fc44cd24bfdd7aaaae5e10eecbee`, the same exact expected Boot-1 durable sector later observed in the controlling success. Therefore bytes reached the disk while the guest BIOS call still returned failure/carry under the modified interrupt environment.

This run is not counted as success. It exposed that the isolated IRQ and persistence mechanisms did not compose cleanly while firmware-visible interrupt/PIC state remained captured by the guest.

Repair: save the pre-takeover IRQ0 vector and PIC masks, then restore them before later BIOS disk transport. This is platform-boundary cleanup, not a new HOSTILE-OS manager/subsystem.

Provenance limit: the launcher version used for early attempts did not snapshot source text into each failed run directory. Attempt-1 executable/object/trace artifacts are preserved, including stage-2 raw SHA-256 `b4db7ca2b32c3408b40a6725751e52d2f0c9c013639d92caa19c05f8ac98c654`, but its exact pre-repair source text is not separately preserved. This does not affect controlling-run source closure; it limits forensic source reconstruction of the failed scar.

### Attempt 2 — qualified failed run

Run: `20260830T042500Z_i001_integration_02`

Boot 1 matched the complete preregistered Boot-1 trace and exited 33.

Boot 2 reached:

```text
S1_OK
BOOT=2
DURABLE=PASS
PREBIND=R
BAD_RESTART_USE=W
REBIND=W
STATE_FAIL
```

- Boot 1: PID `33360`, `COMPLETED`, exit `33`
- Boot 2: PID `20032`, `COMPLETED`, exit `35`
- receipt SHA-256: `98d8eab1c9cd237bb7535ed3c3fba8bda0258c0cf31dc28fa9a9961a0cc67ee2`
- stage-2 raw SHA-256: `0845e71ee7e030ac44986bd8badb794defb00b86a5c2ede2994421905d88f561`

Cause: after `rebind_boot2` returned `W`, the trace helper printed `REBIND=W` and changed `AL` to newline before a redundant status check. The subsequent check therefore failed even though the rebind result had already been observed as W.

Repair: move the status check before the print helper. The preregistered mechanism and trace were not weakened.

This run is not counted as success.

The same failed-run source-snapshot limitation applies to attempt 2; executable/object/trace artifacts and receipt are preserved, but exact pre-repair source text is not separately copied into the run directory.

## Controlling run

Run: `20260830T042900Z_i001_integration_03`

### QEMU process evidence

Boot 1:
- PID: `10408`
- status: `COMPLETED`
- exit: `33`
- start: `2026-08-30T04:23:03.077072+00:00`
- end: `2026-08-30T04:23:03.291861+00:00`
- harness wall time: `214.7672 ms`

Boot 2:
- PID: `30608`
- status: `COMPLETED`
- exit: `33`
- start: `2026-08-30T04:23:03.300933+00:00`
- end: `2026-08-30T04:23:03.502495+00:00`
- harness wall time: `201.5494 ms`

The PIDs are distinct and Boot 1 ended before Boot 2 started.

### Exact Boot 1 trace

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

### Exact Boot 2 trace

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

Independent evaluator `I001-integrated-two-boot-v1`: PASS.
Static/source checker `I001-static-source-v1`: PASS.
Independent cross-check `I001-independent-crosscheck-v1`: PASS.

## Durable-sector evidence

After Boot 1, first 16 bytes:

```text
48 34 49 31 52 5A 34 12 01 00 01 01 00 00 00 00
```

Interpretation:

- `H4I1`
- durable identity `R`
- value `Z`
- little-endian 0x1234 = `34 12`
- runtime epoch metadata `01`
- historical handle `slot0/gen1/epoch1`

Bytes 12..511: all zero.

After Boot 2, first 16 bytes:

```text
48 34 49 31 52 5A 34 12 02 00 01 01 00 00 00 00
```

Only the runtime epoch metadata changed from `01` to `02`; durable identity/value/serialization and historical-handle bytes remained unchanged. Bytes 12..511 remained zero.

## Controlling source hashes

- stage1.S: `6213425390d4e498f65d6593b2f7f4591611ed5c2ca1a315d0e0c5fa88693edf`
- stage1.ld: `2fbb3c273a06fa4fddfe9d4400fc42e6d102cb977b92cabd2866b258f1ba7d86`
- stage2.S: `1bcfb7dde2e0af6835799b8dab5a47c6511f591696f6bb77d11cd1aad7a7dd5f`
- stage2.ld: `88e361a072059eef80dc009093e95ff415eb107ff09e2991421bf824a8a0fe08`
- evaluator: `c213e2bf35f92d34c56069ccc7be014530ba0855036d99f6251eab9069e77c6c`
- static checker: `9ae80c0c7ba243374e524ca6632441ef29899fce38262c841fed69a02b09e74f`
- launcher: `bf4be387c0cd29d662283caa960a7a29619ad9764090c8f05fcfb19a4c25a6a0`

## Controlling artifact hashes

- stage1.bin: `bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8`
- stage2.raw.bin: `2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be`
- stage2.padded.bin: `4ffea35b376e3213aff118cc5d904a9a18f73c2aa473bdbb4b388be99205856b`
- final disk.img: `6daeefdaf115b1520b6bfc0edd4f535d52e29f236c671d92fc063edb4b54b499`
- Boot-1 trace: `1ba2238b939d4bdd7402319f25a4d77ba43217621aa8249b6f83f2cc3193514d`
- Boot-2 trace: `0ca75e946913a08d6ef65b74f0e17d8ec633a7366fe468cf25f0f486837d4a6f`
- durable after Boot 1: `ca8bf03a22f505e0d2048fd2e4f55f7003a9fc44cd24bfdd7aaaae5e10eecbee`
- durable after Boot 2: `17ef271c1b31ef810bf342d6cb7a709741e365f373fe4f1dd4c9c48ca4d009e4`
- evaluation: `679d7d4fa6b18f9c5d39a3bca4a3f36dc4eb38f03489bbd37633de57badd400b`
- static closure: `94f83df59302a1549e226efe756b255fb341c4dba2c8695cd64c1fdb62a247ea`
- receipt: `be4d30941f2c0eac0620a9ab9eae35a9fbc69ba3e6d70d49c7618a876b3ad775`
- independent cross-check: `b5a3687796e0c69b624f35655d6c724b7797af90ab9003c501370bd6d962077c`

## Static/source closure

All preregistered source checks passed, including:

- exact stage-1 eight-sector load and jump;
- exactly two activity slots;
- one checked acquire path reused across P/C/B/exhaustion cases;
- full and generation-exhaustion checks before mutation;
- explicit runtime-field initialization on successful acquire;
- current parent lineage and generation-qualified wait target;
- named six-instruction wait-binding critical region;
- IRQ handler observes relation coherence but does not apply parent progress;
- completion recording, wake matching, and application are separate;
- missing result is checked before later progress application;
- good path contains no global poison latch;
- backing survives count 2->1 and clears only at 1->0;
- checked handle compares generation and epoch before success;
- address-only stale control ignores generation;
- R01 flag/version controls coexist in the same stage-2 payload;
- guest code writes the declared 12 durable bytes;
- Boot-2 prebind rejection occurs before rebind;
- generation and epoch paths fail before zero-wrap;
- old-token check includes epoch;
- all negative controls live in the same stage-2 payload;
- launcher does not synthesize guest debug output or mutate the disk between Boot 1 and Boot 2.

Independent cross-check additionally verified source hashes, artifact hashes, process ordering, exact sector bytes, read-only host behavior between boots, and restoration of firmware-visible IRQ/PIC state before Boot-1 durable BIOS I/O.

## Pareto / burden surface

- stage 1: 512 bytes, signature `55aa`
- stage 2 linked/raw: 2,478 bytes
- stage-2 fixed disk extent: 4,096 bytes
- logical durable record: 12 bytes inside one 512-byte sector
- runtime state: 51 bytes between `runtime_state_start` and `runtime_state_end`
- activity capacity: 2 slots
- activity generation: 8 bits
- runtime epoch: 8 bits
- main-path maximum slot generation: 2
- formal valid finite generation values: 1..255, with `G` before zero-wrap
- wait-bind critical region: 6 guest instructions
- explicit result-code set: `W F M O R G X` (7 codes)
- state-block species reported by static audit: activity slots, shared backing, completion record, IRQ event, runtime epoch, coherence control (6)

The 4,096-byte stage-2 envelope is an experiment boundary, not architecture law.

## Qualified integrated consequence

For this bounded QEMU/BIOS workload, one freestanding stage-2 state model successfully composed all of the following in one executable across two fresh QEMU processes:

1. fixed two-slot capacity and explicit full result;
2. P/C lineage and generation-qualified wait target;
3. explicit continuation across waiting;
4. missing-operation status without progress/continuation mutation;
5. real virtual-hardware IRQ0 consequence and explicit idle;
6. completion recording separate from generic wake matching;
7. wake separate from continuation application;
8. distinct later B progress after local failure;
9. C-slot release/reuse with clean initialization and generation advance;
10. stale C handle rejection before occupant use;
11. address-only stale-retarget negative control;
12. clear/clear flag spanning-read failure and version-qualified rejection/stable acceptance;
13. shared backing live-count preservation and final reclaim;
14. explicit little-endian durable serialization;
15. clean restart persistence across two distinct QEMU processes;
16. pre-rebind non-current rejection;
17. explicit rebind with runtime epoch advance;
18. old prior-boot token rejection despite intentional slot/gen reuse;
19. fail-closed generation exhaustion before modulo wrap;
20. negative controls for fused wake/application, global failure poisoning, and overwrite-on-full.

No Process, Scheduler, File, Manager, Service, heap, dynamic container, exception runtime, or host-side guest state object was needed for the preregistered workload.

## New interaction learned from integration

The most important new result is not merely that the final run passed.

Combining asynchronous PIC/IRQ ownership with later BIOS persistence exposed a boundary debt that the isolated P04/P05/P14 probes could not show: firmware transport may require restoration of firmware-visible interrupt/PIC state before reuse.

In I001 attempt 1, durable bytes were written but BIOS transport still returned failure under the captured interrupt environment. Restoring the saved IRQ0 vector and PIC masks before later INT 13h transport removed the ambiguity and allowed the same integrated workload to complete cleanly.

This is evidence for explicit platform-boundary ownership/restore discipline when the experiment chooses to reuse firmware services after taking over interrupt state. It is not evidence for a new general OS manager.

## Remaining ceilings and open seams

I001 does not close:

- production generation/epoch sizing;
- epoch/generation exhaustion recovery beyond fail-closed `G`;
- crash/partial-write consistency;
- torn-write recovery;
- SMP/NMI/DMA ordering;
- arbitrary activity/resource capacity;
- physical hardware behavior;
- general memory/capability safety;
- arbitrary workload behavior;
- whether BIOS should exist in the eventual post-boot target at all.

The failed-run source-snapshot gap should also be corrected in future experimental launchers: future runs should copy exact source inputs into each run directory before build/execution.

## Promotion posture

I001 is materially stronger than C003/P20 because it integrates the main responsibility families in one stage-2 executable and carries persistence/rebind across two distinct QEMU processes.

That earns a **separate architecture promotion review**.

It does **not** itself promote the architecture.

R3.1 remains `SHADOW_USE_CANDIDATE`; `replacement_ready=false`; R6 remains parent authority unless a separate authority adjudication changes that state.

## Final disposition

`I001_CLOSED_PASS / WHOLE_WORKLOAD_BOUNDED_INTEGRATION_EARNED / PLATFORM_IRQ_TO_BIOS_RESTORE_DEBT_EXPOSED / PROMOTION_REVIEW_EARNED_NOT_PROMOTION`
