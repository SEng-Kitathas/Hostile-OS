# D64/WT01 adoption — controlled guest-write termination boundary

Date: 2026-08-30
Status: ADOPTED AT TESTED SHADOW SCOPE
Science close commit: `0553f3254c6a98e41f5f3c3a6ac519a271bf0a66`
Science result: `D64_WT01_RESULT_2026-08-30.md`

## Adopted rule

At the tested QEMU i386 TCG + BIOS floppy + raw `cache=directsync` scope:

- the actual one-sector guest durable write exposes a repeatable guest-instruction observation boundary between exact old and exact complete-new backing states;
- force-termination while the guest is stopped before that observed transition preserves the old/empty B state;
- force-termination while stopped after that transition preserves the complete new B state;
- the unchanged sealed FR01 recovery reader follows the bytes actually persisted, selecting A/value71 before the transition and B/value72 after it.

## What is incumbent

The durability shadow now has two separately earned layers:

1. **FR01 reader/selector:** validates candidate structure+CRC+commit before sequence and recovers/fails closed from deterministic damaged media states;
2. **WT01 writer-boundary evidence:** an actual guest BIOS one-sector write under this QEMU/directsync envelope persisted as whole-old or whole-new at the controlled observation boundary, and FR01 recovered accordingly after forced process termination.

## What is not adopted

WT01 does not make the one-sector write universally atomic.

Do not infer:
- physical power-loss atomicity;
- real disk/controller atomicity;
- interruption inside QEMU host-side device action;
- torn-write impossibility;
- cache behavior outside directsync;
- multi-sector ordering;
- filesystem/journal guarantees.

The measured `T=547` is fixture/environment telemetry, not architecture state.

## Revisit triggers

Reopen or demote if:
- another qualified QEMU/device/cache envelope exposes `OTHER` media states;
- physical hardware exposes torn/ambiguous states;
- multiple durable sectors must be updated as one logical transition;
- writeback/caching makes terminal process state insufficient to identify persisted media;
- a different transport invalidates the current boundary assumptions.
