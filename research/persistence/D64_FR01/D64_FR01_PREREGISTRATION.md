# D64/FR01 — deterministic faulted-restart durable-record recovery preregistration

Date: 2026-08-30
Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent science: D64/PR01 clean-restart persistence CLOSED PASS
Mechanism selection: `D64_FR01_INTEGRITY_MECHANISM_SELECTION.md`
Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`
Architecture promotion: forbidden by this experiment alone

## Question

Given two durable-record sectors containing an older candidate A and a newer candidate B, can HOSTILE-OS select the newest **valid complete** durable meaning, reject torn/corrupt/incomplete candidates, fail closed when no unambiguous valid record exists, and then reconstruct fresh runtime state without hydrating stale runtime topology?

This experiment uses deterministic host-constructed media states **before guest boot**. It does not simulate or claim actual physical power-cut behavior.

## Evidence envelope

Use the qualified 8 KiB loader layout:

- BIOS sector1: stage1;
- BIOS sectors2..17: fixed 8192-byte stage2 extent loaded at `0x8000..0x9FFF`;
- BIOS sector18 / LBA17: durable record A;
- BIOS sector19 / LBA18: durable record B;
- remaining disk bytes fixture-zero;
- QEMU i386 / TCG / one core;
- no network responsibility;
- debug port `0xE9`;
- `isa-debug-exit` success exit33.

BIOS INT13 is transport evidence only.

## Durable record format

Each durable sector contains one 30-byte logical record and zero tail.

### Payload bytes0..23

| Offset | Meaning |
|---|---|
| 0..3 | ASCII magic `H4F1` |
| 4 | durable identity |
| 5 | durable value |
| 6 | last activity epoch |
| 7 | last resource epoch |
| 8 | historical activity slot |
| 9 | historical activity generation |
| 10 | historical activity epoch |
| 11 | historical binding index |
| 12 | historical binding generation |
| 13 | historical resource slot |
| 14 | historical resource generation |
| 15 | historical resource epoch |
| 16..17 | marker `0x1234` little endian |
| 18 | record version `1` |
| 19 | reserved `0` |
| 20..23 | little-endian 32-bit durable sequence |

### Integrity/completion bytes

- bytes24..25: CRC-16/CCITT-FALSE over bytes0..23, polynomial `0x1021`, init `0xFFFF`, no reflection, no xor-out;
- bytes26..29: ASCII commit marker `CMIT`;
- bytes30..511: zero.

A record is valid only if all of these hold:
- magic exact `H4F1`;
- marker exact `0x1234`;
- version exact `1`;
- reserved exact `0`;
- commit exact `CMIT`;
- CRC matches bytes0..23.

Tail bytes are not part of the logical integrity calculation but must remain zero in all launcher-produced fixtures.

## Selection rule

For each boot, the guest reads A and B, validates both independently, then selects:

1. neither valid -> fail closed `N`;
2. only A valid -> A;
3. only B valid -> B;
4. both valid and sequence A > sequence B -> A;
5. both valid and sequence B > sequence A -> B;
6. both valid, equal sequence, identical bytes0..29 -> A may be selected as equivalent;
7. both valid, equal sequence, different bytes0..23 -> fail closed ambiguous `X`.

FR01 uses only sequences1,2,3 and does not test wrap.

## Runtime reconstruction rule

If exactly one durable meaning is selected:

- runtime activity/binding/resource arrays begin empty;
- current activity epoch is selected durable last-activity-epoch + 1;
- current resource epoch is selected durable last-resource-epoch + 1;
- if either selected durable prior epoch is255, recovery fails `G` rather than wrapping;
- historical handles from the durable record are treated only as negative-control scalars;
- ordinary checked stale binding/resource reads using selected record's historical epochs must reject before value exposure;
- a fresh activity/binding/resource relation is explicitly rebuilt from selected durable identity/value under fresh epochs;
- fresh checked binding/resource reads return `W` and selected durable value.

No runtime topology is loaded from durable storage.

## Fixture matrix

The launcher constructs each complete disk image before QEMU starts. It performs no host mutation while a guest is running.

All valid baseline records use durable id `0x51`. Sequence1 A uses value `0x71`, epochs1/1. Sequence2 B uses value `0x72`, epochs2/2. Sequence3 B uses value `0x73`, epochs3/3 unless a fixture says otherwise.

### F01 — A valid / B empty

- A: valid seq1/value71;
- B: all zero.

Expected: select A; recovery value71; fresh epochs2/2.

### F02 — A valid / B valid newer

- A: valid seq1/value71;
- B: valid seq2/value72.

Expected: select B; recovery value72; fresh epochs3/3.

### F03 — A valid / B higher sequence but stale CRC

Start from valid B seq3/value73, then mutate value byte after CRC creation.

Expected: B invalid; select A/value71.

Naive highest-sequence control that ignores integrity must select B and therefore visibly disagree with checked selection.

### F04 — A valid / B missing commit

Valid B seq2/value72 with commit bytes zeroed.

Expected: B invalid; select A/value71.

### F05 — A valid / B bad commit

Valid B seq2/value72 with one commit byte changed.

Expected: B invalid; select A/value71.

### F06 — A valid / B additive-checksum collision corruption

Construct valid B seq2/value72 under CRC16, then alter two payload bytes with balanced +1/-1 changes chosen so a simple additive byte sum is unchanged while stored CRC becomes invalid.

Expected: B invalid under CRC16; select A/value71.

The launcher/evaluator must record that the rejected additive checksum would have remained equal for the mutated payload.

### F07 — A invalid / B valid

- A: corrupt CRC;
- B: valid seq2/value72.

Expected: select B/value72.

### F08 — A invalid / B invalid

Both records corrupt.

Expected: fail closed `N`; no runtime relation is constructed; no durable value is exposed.

### F09 — equal sequence / identical records

A and B are byte-identical valid seq2/value72 records.

Expected: equivalent selection A; recovery succeeds value72.

### F10 — equal sequence / conflicting valid payloads

A and B both valid seq2 but values differ (`0x72` vs `0x73`) and each has a correct independent CRC/commit.

Expected: ambiguous fail closed `X`; no runtime relation/value exposure.

### F11 — epoch exhaustion

Selected valid record has activity epoch255 and resource epoch3.

Expected: recovery fails `G`; no runtime relation/value exposure.

### F12 — torn newer record at every meaningful boundary

For each cut `k` from0 through29 inclusive, start from a valid B seq2/value72 record and replace bytes `k..29` with zero while leaving tail zero. A remains valid seq1/value71.

The launcher executes one QEMU process for every cut fixture.

Expected for every torn B that is not byte-identical to a complete valid B:
- B invalid;
- select A/value71;
- no torn B value is exposed.

If a cut would leave the record byte-identical to the complete valid record, that case is excluded as not a tear.

## Guest debug contract

For each fixture, guest output must contain exactly:

```text
S1_8K_OK
TEST=D64_FR01
CASE=<case-id>
A_VALID=<0|1>
A_SEQ=<8hex>
B_VALID=<0|1>
B_SEQ=<8hex>
SELECT=<A|B|N|X|G>
NAIVE=<A|B|N>
DUR_VAL=<2hex-or-00>
OLD_BIND=<R|->
OLD_RES=<R|->
FRESH_BIND=<W|->
FRESH_BIND_VAL=<2hex-or-00>
FRESH_RES=<W|->
FRESH_RES_VAL=<2hex-or-00>
DONE
```

`-` means the operation is deliberately not attempted because recovery failed closed before runtime reconstruction.

For F12, `<case-id>` includes the tear boundary.

## Naive-control rule

The guest contains a deliberately bad selector that:
- ignores CRC and commit validity;
- considers any record with `H4F1` magic as a candidate;
- chooses the larger sequence.

It exists only as a negative control.

At minimum F03 must show:
- checked `SELECT=A`;
- `NAIVE=B`.

The bad selector must not drive actual runtime reconstruction.

## Host-side additive-checksum control

For F06, launcher metadata must show:
- original simple additive payload sum;
- corrupted payload simple additive sum;
- sums equal;
- stored CRC does not match corrupted payload.

This demonstrates why the selected CRC mechanism beats the rejected same-size additive checksum for the preregistered corruption.

## Run-input snapshot requirement

Before any build or fixture execution, snapshot and hash at least:

- this preregistration;
- integrity mechanism selection;
- parent faulted-restart plan;
- D64/PR01 preregistration and result;
- qualified stage1 source/linker;
- FR01 stage2 source/linker;
- launcher;
- evaluator;
- static checker;
- independent audit.

Build only from run-local snapshots. Fixture-generation logic must also come from the snapshotted launcher.

## Process requirements

The launcher must record for every fixture:
- case id;
- disk image path and pre-QEMU SHA256;
- QEMU PID;
- start/end/status/exit/wall time;
- debug trace path/hash;
- no host mutation while QEMU is active.

Each fixture uses a fresh disk copy and a fresh QEMU process.

A timeout/ambiguous process state is `UNKNOWN`, never inferred PASS/FAIL.

## Evaluator requirements

Evaluator must require:
- exact line order/values for F01..F11;
- exact expected line order/values for every F12 tear boundary;
- F03 checked/naive discriminator;
- F06 additive-sum collision metadata;
- no failed-closed case exposes fresh or durable value;
- every successful recovery rejects historical binding/resource handles before exposing value;
- every successful recovery exposes the selected value only through fresh checked handles.

Every field under `checks` must be a literal JSON boolean.

## Static/source closure requirements

Verify at least:

1. stage1 loads fixed eight-sector stage2 extent and does not overlap sectors18/19;
2. stage2 reads BIOS sectors18 and19 using saved boot drive;
3. record buffers are separate 512-byte sectors;
4. record validator checks magic, marker, version, reserved, commit marker, and CRC16;
5. CRC implementation uses polynomial0x1021 and init0xFFFF over exactly24 payload bytes;
6. checked selector consults validity before sequence;
7. equal valid identical records may select A;
8. equal valid conflicting payloads fail ambiguous `X`;
9. neither-valid fails `N`;
10. epoch255 fails `G` before runtime reconstruction;
11. naive selector exists separately and does not drive reconstruction;
12. runtime arrays are initialized empty before reconstruction;
13. historical handles are checked stale before value exposure;
14. fresh relation is explicitly reconstructed from selected durable id/value;
15. durable sectors contain no serialized D64 runtime arrays;
16. launcher creates fixtures before QEMU and does not mutate their disk while QEMU runs;
17. F12 includes every meaningful byte-boundary tear over bytes0..29;
18. F06 host metadata demonstrates equal simple additive sums but invalid CRC;
19. all run inputs including preregistration are snapshotted before build/execution;
20. all checker values are literal JSON booleans.

## Independent audit requirements

Independently verify at least:
- input-manifest hashes;
- stage1 512 bytes and `55 aa`;
- stage2 <=8192 bytes;
- all fixture QEMU processes terminal with expected exit33;
- fresh disk per fixture;
- no host mutation while a guest was active;
- evaluator PASS;
- static closure PASS;
- F03 discriminator;
- F06 checksum-collision metadata;
- F12 full tear-boundary coverage;
- failure cases expose no value;
- success cases reject stale handles and accept fresh handles;
- exact artifact/trace hashes.

## Success criterion

FR01 passes only if one controlling campaign from one immutable run-input snapshot:
- builds successfully within the qualified loader envelope;
- executes F01..F11 and every F12 tear-boundary fixture in fresh QEMU processes;
- every fixture terminates exit33 with exact expected trace;
- evaluator/static/audit all pass;
- F03 proves naive highest-sequence selection can choose invalid newer data;
- F06 proves same-size additive checksum can miss a corruption that CRC16 rejects;
- every torn/corrupt/incomplete newer candidate falls back to valid older A;
- conflicting equal-valid candidates fail closed;
- no-valid and epoch-exhausted cases fail closed;
- successful recovery rebuilds fresh runtime relation and rejects historical handles.

## Earned consequence if PASS

At this deterministic two-sector media-state scope, HOSTILE-OS can distinguish valid complete durable records from the preregistered torn/corrupt/incomplete states, choose the newest unambiguous valid record, fall back to an older valid record, and fail closed when no unambiguous valid durable meaning exists, while reconstructing fresh runtime state rather than hydrating persisted topology.

## Authority ceiling

Even PASS does not establish:
- actual power-cut interruption semantics;
- BIOS/controller write ordering;
- sector atomicity;
- cache flush guarantees;
- physical-disk/torn-sector probabilities;
- cryptographic authenticity;
- arbitrary sequence wrap/order;
- filesystem/journal semantics;
- SMP/NMI/DMA/weak-memory correctness;
- final/canonical architecture.

A later fault-injection experiment may kill QEMU during actual guest writes only after FR01 closes this deterministic recovery-format question.
