# D64 / PR01 — expanded relation clean-restart persistence result

**Disposition:** PASS / BOUNDED TWO-BOOT D64 PERSISTENCE EARNED
**Controlling preregistration:** `0f1146f5782b729f77cfa8d4292e956f5c5f28a8`
**Controlling run:** `20260830T065500Z_d64_pr01_persistence_05`
**Architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Higher architecture promotion:** NONE

## Controlling execution

Boot 1:
- PID `29376`
- `COMPLETED`
- exit `33`
- wall time `213.418 ms` as harness data

Boot 2:
- PID `18244`
- `COMPLETED`
- exit `33`
- wall time `203.953 ms` as harness data

Process contract:
- distinct QEMU PIDs: true
- Boot 2 started after Boot 1 terminal completion: true
- same raw disk image: true
- no host disk mutation between boots: true

## Exact outcome

Boot 1 created the D64 relation under activity epoch1/resource epoch1, read durable identity/value `51/7E`, wrote the 20-byte durable record, detached the relation to resource live count zero, reclaimed runtime resource identity/value, and released the activity only after its binding row became empty.

Boot 2 was a fresh QEMU process. It read the durable record, reset the full runtime relation to empty, independently advanced activity/resource epochs to2, and rejected retained Boot-1 binding/resource handles before rebind. It then intentionally reused activity slot0/gen1, binding index0/gen1, and resource slot0/gen1 while reconstructing the relation under fresh namespace epochs. Old Boot-1 handles still returned `R`; fresh handles returned `W / 7E`; controls omitting the corresponding namespace epoch retargeted to the reconstructed Boot-2 relation as preregistered.

## Verification closure

- exact Boot-1 trace: PASS
- exact Boot-2 trace: PASS
- evaluator exit: `0`
- static checker exit: `0`
- static checks: `27/27` literal booleans true
- independent audit: PASS
- stage2 raw: `3,057 / 8,192` bytes
- named runtime state: `3,653` bytes
- durable logical record: `20` bytes inside one 512-byte BIOS sector

Durable sector after Boot 1 SHA-256:
`81f0ef773233ec321a7d649294bf0a6fc549342f2d013486afcc405689f1e004`

Durable sector after Boot 2 SHA-256:
`d97723fc58f0288736881b2f05b2814d9fd41eb512863cd91d5bfb192134241e`

Input manifest SHA-256:
`ff2cf6a21292600f1bcc7ccde8c50f91432397e32b775c1ddea41eee06c5d426`

Receipt SHA-256:
`ca7c5884879644245e408cc377de988fcc08f0424f5189e9e899c2c85b80c02a`

Independent audit SHA-256:
`1222dee825f43c2a3568bdca35acf4872e3251eb82c6c24949d75cad5b6240f0`

Stage2 raw SHA-256:
`fc99dbf98f10762dd3e469e35d9e50077863083aa18d3ef88c1fc3ff3fe49885`

## Earned rule

At the tested clean-restart boundary:

> durable identity/value may outlive runtime relation reclamation without persisting the D64 activity/binding/resource table image. A fresh boot reconstructs the relation explicitly under independently advanced activity/resource namespace epochs. Retained old runtime handles remain stale even when slot/generation/index values are intentionally reused; omitting the relevant namespace epoch allows the expected retargeting failure.

The runtime relation is therefore reconstructed from durable meaning, not hydrated as a persisted volatile topology.

## Nonclaims

PR01 does not establish:
- crash or partial-write durability;
- power-fail atomicity;
- filesystem semantics;
- arbitrary durable object graphs;
- unlimited reboot epoch lifetime;
- external capability revocation;
- native post-takeover storage transport;
- SMP/NMI/DMA/weak-memory correctness;
- final/canonical/production architecture;
- any R3.1/R6 authority change.

BIOS INT13 remains fixture/platform transport evidence only.

## Disposition

`D64_PR01_PASS / TWO_FRESH_QEMU_PROCESSES / DURABLE_MEANING_SURVIVES_RUNTIME_RECLAMATION / FULL_D64_RUNTIME_TABLE_NOT_PERSISTED / EXPLICIT_REBIND_UNDER_FRESH_ACTIVITY_AND_RESOURCE_EPOCHS / OLD_HANDLES_REJECT_AFTER_INTENTIONAL_SLOT_GEN_REUSE / EPOCHLESS_CONTROLS_RETARGET / NO_CRASH_DURABILITY_PROMOTION`
