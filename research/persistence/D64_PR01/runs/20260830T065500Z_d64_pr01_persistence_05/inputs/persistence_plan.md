# D64 expanded-relation clean-restart persistence plan — 2026-08-30

**Mode:** BUILD-PLAN
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Parent persistence evidence:** I001 CLOSED PASS
**Parent D64 relation evidence:** A01 / RK01 / RB02 / ARB01 / RR01 / IRQ01 CLOSED at bounded scopes
**Higher architecture promotion:** forbidden by this plan alone

## Pressure

I001 earned clean-restart persistence/rebind for a much smaller integrated runtime model. D64 has since earned:

- 64 activity slots;
- 20 binding cells per activity / 1,280 total binding cells;
- 64 resource slots;
- 16-bit resource live counts;
- separate activity/binding and resource namespace epochs;
- checked quiescent activity/binding rekey;
- checked quiescent resource rekey;
- binding-aware activity release;
- real-IRQ coherence for coupled bind publication/final detach.

None of those later experiments carried the expanded relation across two fresh QEMU processes. Do not infer persistence by composition.

## Smallest candidate

Persist **durable meaning**, not volatile runtime topology.

The durable record should contain only:

1. a fixed magic/version;
2. durable resource identity;
3. durable payload/value;
4. the last qualified activity namespace epoch;
5. the last qualified resource namespace epoch;
6. boot-1 activity/binding/resource handle bytes retained only as historical negative-control data;
7. one fixed serialization marker.

Do **not** persist:

- the 64 activity arrays;
- the 1,280 binding-resource cells;
- the 1,280 binding-generation cells;
- the 64 resource identities/generations/values/live counts as a runtime table image;
- IRQ observer scratch;
- current completion/relation-active scratch.

Runtime relation state is reconstructed explicitly on each clean boot.

## Storage/evidence envelope

Use the qualified fixed 8 KiB stage-2 layout:

- BIOS sector 1: stage 1;
- BIOS sectors 2..17: 8,192-byte stage-2 extent loaded at `0x8000..0x9FFF`;
- BIOS sector 18: one 512-byte durable sector;
- remaining sectors: fixture zero unless guest writes them.

BIOS INT 13h is firmware/platform transport evidence only, not HOSTILE-OS storage architecture.

This discriminator does not need to take over IRQ0. Therefore it should avoid adding IRQ/PIC ownership merely to test persistence. The I001 scar still applies generally: if a later integrated fixture reuses firmware after taking over firmware-visible interrupt state, ownership must be restored before firmware transport.

## Durable record candidate

First 20 bytes of BIOS sector 18:

| Offset | Meaning | Boot 1 | Boot 2 after rebind |
|---|---|---:|---:|
| 0..3 | magic | ASCII `H4P1` | unchanged |
| 4 | durable identity | `0x51` | unchanged |
| 5 | durable value | `0x7E` | unchanged |
| 6 | last activity epoch | `0x01` | `0x02` |
| 7 | last resource epoch | `0x01` | `0x02` |
| 8 | historical activity slot | `0x00` | unchanged |
| 9 | historical activity generation | `0x01` | unchanged |
| 10 | historical activity epoch | `0x01` | unchanged |
| 11 | historical binding index | `0x00` | unchanged |
| 12 | historical binding generation | `0x01` | unchanged |
| 13 | historical resource slot | `0x00` | unchanged |
| 14 | historical resource generation | `0x01` | unchanged |
| 15 | historical resource epoch | `0x01` | unchanged |
| 16 | serialization marker low | `0x34` | unchanged |
| 17 | serialization marker high | `0x12` | unchanged |
| 18 | record version | `0x01` | unchanged |
| 19 | reserved | `0x00` | unchanged |

Bytes 20..511 remain zero.

Historical handle bytes are test evidence only. They are never hydrated as current merely because durable identity/value survived.

## Boot 1 candidate sequence

1. Fresh runtime arrays start empty.
2. Activity epoch = 1; resource epoch = 1.
3. Acquire A through the generic activity-acquire path -> slot0/gen1/epoch1.
4. Bind new durable resource identity `0x51`, value `0x7E` -> binding index0/gen1 and resource slot0/gen1/epoch1.
5. Read through the ordinary checked binding path -> `W / 0x7E`.
6. Serialize the 20-byte durable record including the boot-1 historical handles and epochs.
7. Guest writes BIOS sector18.
8. Explicitly detach binding0; resource live count reaches zero and runtime resource identity/value reclaim.
9. Checked activity release succeeds only after the binding row is empty.
10. Exit the first QEMU process.

The durable record must outlive runtime relation reclamation.

## Boot 2 candidate sequence

1. Start a **fresh QEMU process** on the same disk image.
2. Read BIOS sector18 and verify exact magic/version/identity/value/serialization marker.
3. Fresh runtime arrays remain empty before rebind.
4. Compute next activity epoch from durable last activity epoch: `1 -> 2`.
5. Compute next resource epoch independently: `1 -> 2`.
6. If either durable last epoch is `255`, fail closed with `G`; do not silently wrap in ordinary restart setup.
7. Before rebind, old boot-1 binding/resource handles reject because no current runtime relation exists.
8. Acquire A through the same generic activity path. Intentionally reuse slot0/gen1, now under activity epoch2.
9. Explicitly rebind durable identity/value through the ordinary relation operations. Intentionally reuse binding index0/gen1 and resource slot0/gen1, now under resource epoch2.
10. Old boot-1 binding handle must still return `R` because activity epoch1 is stale even though slot/gen/index/binding-generation values were intentionally reused.
11. Old boot-1 direct resource handle must return `R` because resource epoch1 is stale even though slot/resource-generation values were intentionally reused.
12. Fresh binding and fresh direct resource handles must return `W / 0x7E`.
13. Two deliberately weakened negative controls that ignore the corresponding namespace epoch should retarget to the boot-2 relation, proving why the fresh restart epochs are load-bearing.
14. Rewrite only the durable last-activity-epoch and last-resource-epoch fields to `2`; durable identity/value and historical boot-1 handle bytes remain unchanged.
15. Exit Boot 2.

## Currentness rule under clean restart

Activity/binding and resource namespaces remain distinct domains.

A clean restart may initialize both from durable prior-epoch metadata, but it must advance and validate them independently. Equality of their numeric values (`1`, then `2`) does not fuse the namespaces.

The candidate only earns bounded two-boot behavior. It does not claim an 8-bit epoch is sufficient for unlimited reboot lifetime. Ordinary restart setup fails closed at 255 rather than silently aliasing a retained historical token.

## Negative-control pressure

The discriminator should include both post-rebind controls:

- **epochless binding control:** validates current slot/generation/index/binding-generation but omits activity epoch -> incorrectly reads boot-2 value;
- **epochless resource control:** validates current resource slot/generation but omits resource epoch -> incorrectly reads boot-2 value.

These controls show that plain slot/generation reuse is insufficient across restart once old tokens may be retained as historical bytes.

## Host/launcher discipline

The launcher must:

- snapshot all controlling inputs before build;
- build stage1/stage2 only from run-local snapshots;
- create one raw floppy image;
- launch Boot 1 QEMU and wait for terminal completion;
- launch Boot 2 as a distinct QEMU process on the same disk;
- never mutate the durable sector between boots;
- permit read-only extraction/hash checks between boots;
- preserve exact PIDs/start/end/status for both processes;
- require both exits to be the preregistered success code;
- independently verify the durable sector after each boot.

Longer whole-suite execution should use the bounded/job doctrine where the server route is reliable; missing process/tool return is `UNKNOWN`, never implied success.

## Pareto pressure

The experiment should record:

- stage-2 raw bytes within the qualified 8 KiB extent;
- named runtime-state bytes;
- durable record = 20 logical bytes inside one 512-byte sector;
- full D64 relation capacities linked into the witness;
- no persisted runtime-table image;
- two QEMU process wall times as harness data;
- exact durable-sector hashes after Boot 1 and Boot 2.

The plan prefers explicit rebind over persistence of thousands of volatile relation bytes because that is the smaller state surface unless evidence proves reconstruction insufficient.

## What a passing discriminator could earn

Only:

> under clean restart across two fresh QEMU processes, the tested durable identity/value can outlive runtime relation reclamation; fresh activity/resource namespace epochs prevent boot-1 runtime binding/resource handles from becoming current after intentional slot/generation reuse; explicit boot-2 rebind reconstructs the D64 relation without persisting the volatile activity/binding/resource tables.

## Nonclaims

A pass would not establish:

- crash/partial-write durability;
- power-fail atomicity;
- filesystem semantics;
- arbitrary durable object graphs;
- unlimited reboot epoch lifetime;
- external capability revocation;
- SMP/NMI/DMA/weak-memory correctness;
- native post-takeover storage transport;
- final/canonical/production architecture;
- R3.1/R6 authority change.

## Next gate

Seal a separate preregistration with exact Boot-1/Boot-2 traces, static/source closure, durable-sector bytes, snapshot/receipt lineage, and negative controls **before** creating persistence mechanism source.
