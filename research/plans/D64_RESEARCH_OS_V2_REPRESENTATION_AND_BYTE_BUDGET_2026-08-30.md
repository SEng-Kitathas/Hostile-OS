# D64 research-only OS v2 — representation and byte budget

Date: 2026-08-30
Status: REPRESENTATION-FIRST BUILD PLAN / NO V2 STAGE2 IMPLEMENTATION YET
Parent plan: `D64_RESEARCH_OS_V2_EMBODIMENT_PLAN_2026-08-30.md`
Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`

## Decision

The first v2 embodiment state layout closes inside the already-qualified 8 KiB stage2 envelope **without** importing every historical fixture field and without packing independent earned meanings merely to save bytes.

Selected image-resident architectural/reviewer state budget: **3467 bytes**.

Qualified stage2 envelope: **8192 bytes**.

Provisional engineering allowances before implementation:
- temporary/local implementation scratch in image: **128 bytes**;
- read-only labels/tables/evidence-mode metadata: **256 bytes**;
- resulting initial code target: **<= 4341 bytes**.

These allowances are planning gates, not architecture constants. Actual linker/map readback will replace them.

## Representation law

This layout is a composition of already-earned relations. It is **not** a declaration that `activity`, `binding`, or `resource` are primitive species.

The body keeps separate state where parent evidence showed separate reachable futures. It omits historical fields where the v2 reviewer workload has no adopted responsibility requiring them.

## Selected image-resident state

| State | Bytes | Why it exists |
|---|---:|---|
| `activity_identity` | 64 | live/admitted identity marker |
| `activity_generation` | 64 | activity-handle currentness within current activity epoch |
| `activity_epoch` | 64 | per-slot epoch carried by checked activity/binding handles |
| `activity_progress` | 64 | current applied progress/result state |
| `activity_pending_progress` | 64 | continuation/application value kept separate from wake |
| `activity_waiting` | 64 | current wait relation present |
| `activity_woken` | 64 | notification/wake state, separate from application |
| `activity_wait_slot` | 64 | wait target slot |
| `activity_wait_generation` | 64 | wait target generation discriminator |
| `activity_epoch_global` | 1 | current activity namespace epoch |
| `binding_resource_plus1` | 1280 | binding applicability/backing slot, zero means empty |
| `binding_generation` | 1280 | binding-cell currentness |
| `resource_identity` | 64 | live resource identity marker |
| `resource_generation` | 64 | resource-handle currentness within resource epoch |
| `resource_value` | 64 | bounded reviewer backing value |
| `resource_live_count_u16` | 128 | shared lifetime count up to 1280 bindings |
| `resource_epoch_global` | 1 | current resource namespace epoch |
| `irq_event_count_u8` | 1 | real IRQ0 observation count; telemetry/semantic input only at tested 1/2 scope |
| `irq_relation_ok` | 1 | IRQ observer result for current wait relation |
| `irq_phase_target` | 1 | bounded reviewer phase target: tested count1 or2 |
| `saved_irq0_vector` | 4 | saved offset+segment for reviewer IRQ installation/restoration |
| `saved_pic_masks` | 2 | saved master/slave PIC masks |


**Total: 3467 bytes.**

## Activity-side adjudication

### Retained

The v2 layout keeps nine 64-byte activity-side arrays:

- identity;
- generation;
- epoch;
- applied progress;
- pending continuation/application;
- waiting;
- woken;
- wait target slot;
- wait target generation.

`waiting` and `woken` remain separate even though they could be packed into bits. The 64-byte saving is not worth hiding a distinction that C002/I001 had to earn or adding bit-manipulation/assurance burden.

`pending_progress` remains separate from `progress`. Hard-coding a single continuation value would make wake/application separation a fixture trick rather than an embodied mechanism.

### Omitted from the shared v2 baseline

The historical D64 arrays `parent_slot` and `parent_generation` are omitted from the first v2 common body because the required reviewer workloads do not currently exercise parent/child lineage as an adopted D64-era integration responsibility.

They remain valid historical evidence and can be reintroduced if a future v2 workload explicitly needs lineage consequences.

No claim is made that lineage is generally unnecessary.

## Binding representation

Each configured activity owns 20 binding cells. The baseline uses two byte arrays across 1280 cells:

- `binding_resource_plus1[1280]` — zero means empty, otherwise resource slot+1;
- `binding_generation[1280]` — checked binding-cell currentness.

Total binding state: **2560 bytes**.

This is the dominant state cost. It is retained because D64/RB02 explicitly qualified the 64x20 relation load and stale/current behavior. Compressing it would change the reviewer capacity profile or introduce denser encoding machinery that has not earned its burden.

## Resource representation

For 64 global resource slots:

- identity: 64 bytes;
- generation: 64 bytes;
- bounded reviewer value: 64 bytes;
- live count: 128 bytes (`u16` per resource).

Total resource-table state: **320 bytes**, plus one global resource epoch.

The 16-bit live count remains because a resource may be shared through up to 1280 binding cells. An 8-bit count would silently under-represent the configured reference profile.

## IRQ / wait reviewer state

Only the small cross-cutting platform/phase state is global:

- event count: 1 byte;
- current-relation observer result: 1 byte;
- phase target 1 or2: 1 byte;
- saved IRQ0 vector: 4 bytes;
- saved PIC masks: 2 bytes.

Exact event count remains telemetry/current phase input, not architecture authority. The semantic gate is still `event observed + current relation`, bounded to the tested count1/count2 reviewer modes.

## Durable-state scratch placement

Two 512-byte sector buffers are **not** charged to image-resident D64 state. Use the already-exercised low-memory scratch region below stage2:

- A buffer: `0x7000..0x71ff`;
- B buffer: `0x7200..0x73ff`.

Proposed stage2 stack top remains `0x7a00`, growing downward. This leaves `0x7400..0x79ff` (1536 bytes) between the durable buffers and initial stack pointer as a guard/scratch gap.

The scratch buffers are transport/workspace, not durable runtime topology. They must be cleared/overwritten by the active mode and must never be serialized as D64 runtime state.

## Durable on-media representation

Reuse the adopted FR01 candidate format, not a new v2-specific storage schema:

- 24-byte durable meaning/currentness payload;
- 2-byte CRC-16/CCITT-FALSE;
- 4-byte `CMIT` marker;
- 30 logical bytes per 512-byte candidate sector.

The v2 body may read/write the two candidate sectors but does not treat the 1024 physical bytes as image-resident runtime state.

## Historical-union comparison

The mature RB02/PR01 family commonly carried eleven 64-byte activity arrays:

`identity, generation, progress, continuation, waiting, woken, parent_slot, parent_generation, wait_slot, wait_generation, epoch`

plus the D64 binding/resource tables.

A literal historical union is therefore about **3586 bytes** before experiment-specific temporaries/platform state.

The v2 candidate does **not** blindly union those fixtures. It retains pending continuation but omits the two parent-lineage arrays, then adds only the IRQ platform/phase bytes required by the integrated reviewer workload.

Selected baseline: **3467 bytes**.

This is a representation reduction of roughly **119 bytes** versus the 3586-byte historical table union before experiment-specific extras, achieved by responsibility selection rather than bit packing.

## Envelope gates before stage2 implementation

The first implementation must fail closed if any of these are violated:

1. linked stage2 end address exceeds `0xa000`;
2. image-resident named state exceeds **3467+128 = 3595 bytes** before explicit adjudication;
3. code+rodata exceeds the remaining envelope without a measured reason;
4. durable scratch overlaps stage2 image or expected stack guard;
5. any omitted historical field is silently recreated under a new aggregate struct/object;
6. runtime state introduces dynamic allocation or hidden container machinery;
7. reviewer modes require the research tree at build/run time.

## Initial implementation order

To avoid ontology smuggling through code order:

1. create directory/docs/evidence map and fixed constants;
2. declare the selected state arrays exactly as budgeted;
3. add a linker/map budget checker before mechanism code;
4. implement checked activity/binding/resource helpers;
5. implement finite admission/reuse/lifetime/core workload;
6. add wait/wake/application and IRQ path;
7. add durable candidate validation/reconstruction;
8. add bounded writer/restart/faulted-media reviewer modes;
9. only then optimize size if actual linker pressure requires it.

Do **not** pre-optimize by packing state before the unoptimized composed body has a measured size.

## Admission meaning of this document

This closes only the representation-first planning gate:

`V2_STATE_LAYOUT_FITS_ON_PAPER = true`

It does not establish:

`V2_BODY_BUILDS = true`
`V2_BODY_RUNS = true`
`V2_BODY_MATCHES_PARENT_SCIENCE = true`
`CURRENT_RESEARCH_REFERENCE = true`
