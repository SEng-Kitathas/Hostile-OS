# D64 / RB01 — supersession before execution

**Status:** SUPERSEDED BEFORE EXECUTION
**RB01 preregistration:** `76fb008cb5e6c3ad16a8e3497dc8b781fd06cfee`
**Superseding plan correction:** `d03182995dd882a7bebdf7ff76fe8fd9785be803`
**Scientific consequence:** NONE

## Why RB01 cannot control

RB01 was sealed before the resource-binding live-count width correction. Its fixed representation used one byte for `resource_live_count`.

The later pre-execution capacity check proved that D64's declared binding matrix contains 64 * 20 = 1,280 binding cells, so one resource may lawfully have up to 1,280 live bindings. An 8-bit count cannot represent that state.

The append-only correction therefore changes the current candidate to a 16-bit live count and requires a max-sharing path that reaches `0x0500`.

## Execution state

No RB01 run directory exists. No RB01 guest executed. No result was produced.

One untracked stage-2 draft had been written after the stale preregistration. It was never built or run. It is quarantined at:

`research/resource_binding/quarantine/20260830_rb01_preexecution_superseded/stage2.S`

SHA-256:

`8e4b03205867cf8c8ec45cbef1ac7e1d4e441f8143c9db68c0f9b03ef2af2d54`

## Rule

Do not edit RB01 in place and do not execute it. A new preregistration must inherit the corrected 16-bit live-count plan.

## Disposition

`RB01_SUPERSEDED_PREEXECUTION / NO_SCIENCE / STALE_ONE_BYTE_LIVE_COUNT / RB02_REQUIRED`
