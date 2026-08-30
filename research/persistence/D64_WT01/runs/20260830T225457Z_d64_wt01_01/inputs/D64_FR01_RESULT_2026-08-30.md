# D64/FR01 result — deterministic faulted durable-record recovery

Date: 2026-08-30
Status: **CLOSED PASS**
Architecture posture entering/leaving: `INTEGRATED_SHADOW_CANDIDATE`

## Lineage

- mechanism selection + preregistration: `b5cc73f` — `Preregister D64 faulted durable-record recovery`
- Amendment A / fixture-label isolation: `1fbce51`
- implementation: `8a916d8`
- retained pre-QEMU harness failure + launcher v2: `3bfa610`
- retained CHS transport failure + Amendment B: `f814e67`
- retained boot-drive handoff failure + Amendment C: `53c19cf`
- controlling run source HEAD: `53c19cfaa6bdc7055a721633ec621cf0a0c1af5d`

Parent science: D64/PR01 clean-restart persistence CLOSED PASS.

## Selected mechanism

FR01 uses two independent 512-byte durable sectors. Each logical record is 30 bytes:

- 24-byte durable payload;
- 2-byte CRC-16/CCITT-FALSE (`poly=0x1021`, init `0xFFFF`);
- 4-byte `CMIT` completion marker;
- zero tail through byte511.

The payload preserves durable identity/value/currentness history and adds a bounded 32-bit sequence. Volatile D64 activity/binding/resource topology is not serialized.

Mechanism selection rejected:
- 52-byte payload/complement duplication, which admits coherent paired mutation;
- same-size 16-bit additive checksum, which admits balanced multi-byte corruption.

## Attempt history

### Pre-science smoke defect

An abandoned duplicate assembly label was caught during compile smoke before any image/QEMU execution. Retained in `D64_FR01_IMPLEMENTATION_SCARS.md`.

### Attempt 1 — launcher failure before fixtures/QEMU

`runs/20260830T211815Z_d64_fr01_01`

Build completed, then launcher crashed because a local boolean shadowed the `build_fixtures()` function name. No fixture image or QEMU science process existed. Retained as no-science harness failure.

### Attempt 2 — invalid floppy CHS transport

`runs/20260830T211841Z_d64_fr01_01`

41/41 fresh QEMU processes produced exactly:

```text
S1_8K_OK
IO_FAIL
```

and exited35. Cause: LBA18/LBA19 were incorrectly addressed as CHS sectors19/20 on head0, but a 1.44MiB floppy has 18 sectors/track. Amendment B corrected:
- LBA17 -> C0/H0/S18;
- LBA18 -> C0/H1/S1;
- LBA19 -> C0/H1/S2.

No recovery mechanism executed.

### Attempt 3 — qualified boot-drive handoff failure

`runs/20260830T212018Z_d64_fr01_01`

Again 41/41 traces were `S1_8K_OK / IO_FAIL`, exit35. CHS was now correct, but stage2 trusted incoming `DL`; the qualified stage1 debug printer clobbers `DX` after saving the BIOS boot drive.

Existing PR01 lineage and independent `llvm-nm` readback establish qualified stage1 `boot_drive` at physical `0x7c4b`:

```text
00007c4b t boot_drive
```

Amendment C required FR01 to use that saved byte. No recovery mechanism executed in this attempt.

### Attempt 4 — controlling campaign PASS

`runs/20260830T212145Z_d64_fr01_01`

All 16 controlling inputs, including preregistration and Amendments A/B/C, were snapshotted before build/execution and hash-verified. The run's recorded Git HEAD equals the corrected source HEAD.

## Controlling campaign

- fixture count: **41**
- fresh QEMU process per fixture: **41**
- all QEMU statuses: `COMPLETED`
- all exits: **33**
- disks read-only during guest execution
- all disk hashes unchanged before/after QEMU
- stage1: **512 bytes**, valid `55 aa`
- stage2 raw: **1,454 bytes** within fixed 8,192-byte envelope
- evaluator: **PASS / 8 checks**
- static/source closure: **PASS / 21 checks**
- independent audit: **PASS / 16 checks**
- `all_pass=true`

## Fixture consequences

### F01 — valid A / empty B
Selected A seq1/value71. Historical handles reject; fresh checked binding/resource handles return value71.

### F02 — valid A / newer valid B
Selected B seq2/value72. Historical handles reject; fresh handles return value72.

### F03 — newer B with stale CRC
Observed:

```text
A_VALID=1
A_SEQ=00000001
B_VALID=0
B_SEQ=00000003
SELECT=A
NAIVE=B
DUR_VAL=71
```

This is the required highest-sequence negative control: the bad selector chooses corrupt newer B; the checked selector falls back to valid A.

### F04/F05 — missing or damaged commit marker
B rejects; A selected.

### F06 — balanced corruption invisible to additive checksum
Host control:
- original additive sum: `522`;
- corrupted additive sum: `522`;
- stored CRC: `13932`;
- CRC over corrupted payload: `6841`.

Guest observes B invalid, checked selector A, naive selector B. This directly discriminates the selected CRC from the rejected same-size additive checksum.

### F07 — invalid A / valid B
Selected B/value72.

### F08 — both invalid
Observed `SELECT=N`; no durable value, stale check, fresh handle, or reconstructed value is exposed.

### F09 — equal sequence / byte-identical valid records
Equivalent valid records select A and recover value72.

### F10 — equal sequence / conflicting valid payloads
Observed `SELECT=X`; fail closed with zero value exposure and no runtime reconstruction.

### F11 — selected record prior epoch255
Observed `SELECT=G`; fail closed before namespace wrap or runtime reconstruction.

### F12 — every logical byte-boundary tear
All **30** preregistered tear boundaries `0..29` executed in separate fresh QEMU processes.

Every torn B was invalid and recovery selected valid older A/value71. No torn newer value was exposed.

Representative late tear:

```text
CASE=F12_tear_29
A_VALID=1
A_SEQ=00000001
B_VALID=0
B_SEQ=00000002
SELECT=A
NAIVE=B
DUR_VAL=71
OLD_BIND=R
OLD_RES=R
FRESH_BIND=W
FRESH_BIND_VAL=71
FRESH_RES=W
FRESH_RES_VAL=71
DONE
```

## Reconstruction consequence

For every successful selection:
- the full D64-sized runtime arrays start empty;
- fresh activity/resource namespace epochs are selected durable epochs + 1;
- one current relation is explicitly reconstructed from durable identity/value;
- selected record historical binding/resource handles reject before value exposure;
- fresh checked binding/direct-resource handles accept and expose only the selected durable value.

The durable sectors contain no serialized D64 runtime-array image.

## Closure hashes

- campaign receipt: `f631e6a455a1e2e35102de54aab4cf387368c1c5f9bda288da8bec658e7dc3a6`
- evaluation: `72728c4f0a6a309c091416337503619818e90650b1ee5c5e168e0f24fd741b94`
- static closure: `726ec0d339619017c881c424b5f7f044042b016482cdd5ddc02f18802b8f8111`
- independent audit: `576214189e3189cf30e3e73000bff9c015f9a0142992fd71ba3da60d0ea31bee`
- input manifest: `9dd87bd82bb5a5cec11a7ddc5e08cbeee6631120566bc89a6fc127dad446a9e1`
- F06 control: `63a8a6f6dc0ee9182978cd6bd4e9ffc919d6b2a39b11ea0689dce2512bd4e232`
- stage1: `feecbbfdea750fc26f401c0e8eeeabcdd70953036bd60e287368e987ac1ed97d`
- stage2 raw: `7d162a43006d23b88c900b793f0bd965d4943fbc20721b79eae64e876e0dd53b`

## Earned consequence

At the tested deterministic two-sector media-state scope, HOSTILE-OS can:

> independently validate two durable candidates; reject the preregistered torn, incomplete, commit-damaged, checksum-collision, and CRC-corrupt newer records; select the newest unambiguous valid complete record; fall back to an older valid record; fail closed when no valid record, conflicting equal-sequence records, or epoch exhaustion prevents safe reconstruction; and rebuild fresh D64 runtime state while rejecting historical handles rather than hydrating persisted topology.

## Authority ceiling

FR01 does **not** establish:
- actual power-cut interruption semantics;
- BIOS/controller write ordering;
- sector atomicity;
- host/controller cache-flush guarantees;
- physical-hardware torn-write probabilities;
- cryptographic authenticity;
- sequence wrap ordering;
- filesystem or general journal semantics;
- SMP/NMI/DMA/weak-memory correctness;
- final/canonical architecture.

The next durability question may now move to controlled interruption of actual guest writes, with FR01's recovery format as the already-qualified reader/selector.
