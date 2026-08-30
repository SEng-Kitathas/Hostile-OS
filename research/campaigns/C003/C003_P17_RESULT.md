# C003 / P17 — stale handle after fixed-slot reuse

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P17 of 20
**Architecture promotion:** NONE
**P18 earned:** YES

## Controlling preregistration

`C003_P17_PREREGISTRATION.md` was sealed at `2e2b74652661bbbfc4da7b55d2923ded1ada5f7e` before source or execution.

## Controlling run

Run `20260830T022100Z_p17_stale_handle_01`; QEMU PID `34348`, start `2026-08-30T02:21:11.500202+00:00`, end `2026-08-30T02:21:11.798337+00:00`, `COMPLETED`, exit `33`; evaluator exit `0`; stderr empty.

## Exact raw observation

```text
OLD_GEN=1
NEW_GEN=2
FRESH_STATUS=W
FRESH_READ=Y
STALE_STATUS=R
STALE_READ=0
BAD_STATUS=W
BAD_READ=Y
DONE
```

Evaluator `C003-P17-stale-handle-v1`: passed.

## Exact hashes

Source:
- mechanism `1291fe5182372ee4089b4d27625c794cf1c81e964625157beafd87256c8cc184`
- fixture `49d7c4bbacbac2aa9afe8407bf24a4d325a92f28005cff9735868bb0590676d4`
- linker `eb65418398fc6924c16cc19a1a62f35c6a50941debf6f49cb4537f86f10a5cf7`
- evaluator `897c1abf3dfa36bf5d5a382700acaf3f7c7febad897a020792b0f1812a510526`
- launcher `9e189f4b092dad657b669ca270444645fa1c8c58b9ff6d15e75c0771e86634ea`

Run:
- boot `62c8692e921341ab0037e0595c3b7f3c8c6a77700d380f33ce4c789ec5e7c6b2`
- debugcon `0c5bc7ca8467d32f851f9d20889155988d46933b2a901bf817fdc94c72c25ab0`
- evaluation `942726c5f535b3f79b2ca2da3dceae574997f297593df945b7a827e8892d3113`
- receipt `6ac1636a55eec10b950e602f449a6c1bb248947d06ee27ad6b5192ea50c7572f`
- evaluator stdout `af33e32773c89b1554e0aa2fa503081346d59fe9f442960640eac8cb04ad7f68`

## Static/source closure

Inspection confirmed one slot/value-generation pair, compare-before-read in `checked_read`, no slot-value read on the stale reject branch, and no generation comparison in the address-only bad read.

## Qualified consequence

For one slot reused X/gen1 -> Y/gen2:
- fresh gen2 handle read Y;
- stale gen1 handle was rejected and did not observe Y;
- address-only stale control silently read the new Y from the same slot location;
- generation currentness therefore prevented this bounded stale handle from retargeting to the new occupant.

## Authority ceiling

No general pointer safety, arbitrary generation lifetime, capability security, memory protection, universal use-after-free safety, allocator design, ownership architecture, or architecture promotion is earned.

## P18 discriminator earned by P17

A remaining host subsidy is **serialization/conversion convention**. Host-language integers and conversion helpers can hide how a logical multi-byte value becomes stable bytes.

P18 should isolate one 16-bit value `0x1234`:
- fixture supplies the logical word only;
- mechanism explicitly serializes canonical little-endian bytes `[0x34, 0x12]`;
- good decoder reconstructs `0x1234` from that byte order;
- bad swapped decoder reconstructs `0x3412` from the same bytes;
- raw debug output should expose encoded bytes and both decoded values in hexadecimal.

This remains a two-byte representation-convention discriminator. It does not earn a filesystem format, general serializer, ABI, protocol stack, or architecture promotion. P19-P20 remain unwritten.
