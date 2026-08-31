# HOSTILE-OS — NEXT THREAD START HERE

This repository is the durable project/reincarnation ledger. A new thread should **not ask the operator to re-explain HOSTILE-OS**.

Read, in order:
1. `continuity/LIVE_SHADOW.md`
2. `continuity/16_ZERO_REEXPLANATION_REINCARNATION_2026-08-31.md`
3. `continuity/01_COMMANDERS_INTENT.md`
4. `continuity/02_CURRENT_STATE_AND_FRONTIER.md` — newest superseding section wins
5. `continuity/10_ENGINEERING_DECISION_LEDGER_2026-08-30.md`
6. `continuity/12_WHAT_HOSTILE_OS_IS_BECOMING_2026-08-30.md`
7. `scars/ACTIVE_NEVER_REINTRODUCE_CURRENT.md`
8. `scars/EXECUTION_AND_INFERENCE_SCARS.md`
9. `handoffs/CURRENT_REINCARNATION/00_READ_FIRST.md`
10. `handoffs/THIS_CONVERSATION.md` or `continuity/DESIGN_THREAD_STREAM.md` only when chronology/nuance is needed

Current high-level state: C004 and C005 are both CLOSED20/20. `os/research_only/d64_reference_v3/` is CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY. Selected H1 two-core representation is BSP sole relation mutator + ordered AP request/result mailbox. Current body is8089/8192 linked bytes with103 bytes headroom. Isolated verifier PASS20/20; current QEMU+Bochs replay PASS. Physical H1 is still unqualified. Architecture posture remains `INTEGRATED_SHADOW_CANDIDATE`, not final/release/production.

Immediate local frontier: prepare non-destructive physical-H1 qualification/boot/probe package; then run C004-to-v3 representation/Pareto convergence. Do not spend v3 headroom by convenience. Do not run C005/P21.

Repository rule: all unique project data belongs in Git/GitHub, but OS-only users may sparse-checkout `os/`; research/history is never an implicit OS install dependency.


## Mandatory unknown/trace rule — 2026-08-31

R3.1 is the adopted normal in-house engineering/research SOP surface. Also read `authority/R3_1_LOCAL_SOP_DELTA_UNKNOWN_TRACE_ASK_2026-08-31.md` during ingress.

Rule: inspect durable project evidence first. If a load-bearing unknown remains, **ASK**. If traces of an artifact, decision, dependency, prior action, or state remain but their meaning/origin cannot be established, **ASK**. Never guess across the gap.

This starts only after zero-re-explanation recovery has been attempted; do not ask the commander to restate material already persisted in Git/project continuity.

## Unknown / trace rule added 2026-08-31

Do not ask the commander to reconstruct persisted project history. Inspect Git/project state first.

If, after inspection, a load-bearing point is still unknown/unclear/contradictory, or you see traces of something whose identity or role cannot be recovered, **ASK the commander** instead of guessing, inventing provenance, or silently routing around it.

Controlling SOP delta: `authority/R3_1_LOCAL_SOP_DELTA_UNKNOWN_TRACE_ASK_2026-08-31.md`.


## 2026-08-31 current frontier update — physical probe instrument ready

P0 local preparation is no longer open. The non-destructive H1 observation instrument is qualified under the H1 QEMU proxy and packaged at `research/targets/H1_PHYSICAL_PROBE/package/h1_probe_physical.img`, SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`. Physical H1 itself remains UNQUALIFIED until a real boot packet is captured.

P1 C004->D64-v3 representation/Pareto review is also closed. D64-v3 remains unchanged at8089/8192 with103 bytes headroom. Do not add partial authority state without a non-bypassable untrusted boundary. C004 remains a capability-triggered obligation; a separately qualified enforcement representation/envelope becomes mandatory when actually untrusted execution or direct privileged effects are admitted.

No C006 is open. The next reality-authority step is the physical H1 boot/probe packet. Do not invent a new campaign merely to keep numbering moving.


## 2026-08-31 second-proxy qualification update

The exact physical H1 probe image has now passed under both the QEMU H1 proxy and Bochs 3.1, with the Bochs run using the same unchanged physical image and a separately sealed preregistration.

Bochs qualification result: `research/targets/H1_PHYSICAL_PROBE/H1_PHYSICAL_PROBE_BOCHS_QUALIFICATION_RESULT_2026-08-31.md`.

This strengthens the instrument only. Physical H1 remains UNQUALIFIED. No C006 is open. The next real evidence boundary is still the physical H1 boot/probe packet.


## 2026-08-31 splash-wrapper update

Recommended physical thumb-drive image is now `research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`, SHA-256 `bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`. It shows the commander-supplied HOSTILE-OS artwork for about three seconds, returns to text mode, then runs the exact qualified H1 probe.

Wrapper qualification passed both floppy/CHS and hard-disk/EDD QEMU presentations with exact framebuffer equality and full `H1PROBE_END` chain. Physical H1 remains UNQUALIFIED until the HP is actually booted.


## 2026-08-31 current transport update — splash wrapper

The recommended physical thumb-drive image is now `research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`, SHA-256 `bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`. It is a qualified presentation/boot wrapper around the exact existing H1 probe stage2.

Expected physical flow: HOSTILE-OS VGA splash (~3 seconds or key skip) -> text mode -> `H1PROBE_BEGIN` ... `H1PROBE_END`. Wrapper passed both QEMU CHS/floppy and EDD/hard-disk legacy BIOS paths with exact framebuffer proof.

Physical H1 itself is still UNQUALIFIED. Do not open C006 merely because the wrapper is complete.


## 2026-08-31 physical H1 first-failure / text-only retest

First splash-wrapper physical boot on H1 caused the attached TV to report NO SIGNAL immediately after boot handoff. No USB log is expected. Do not treat this as a hidden completed probe run.

Next physical image is `research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER/package/h1_probe_text_physical.img`, SHA-256 `5f90b22ad6264d2e2afb7c0155454b635a7bd4aa4ed22da6be879d14d3c26b42`. It uses the hardened EDD/CHS transport, preserves firmware video mode, has no explicit VGA mode set/DAC/framebuffer writes, and chains the exact qualified probe. Emulator dual-mode qualification PASS.


## 2026-08-31 durable-log physical retest frontier

Use `research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG/package/h1_probe_durable_log_physical.img`, initial SHA-256 `ddf9ceec0b97ed8014874e11e804716867ad0956eaa980085373bb803e9a6cca`, for the next H1 boot. It preserves firmware-selected text mode and writes only boot-USB journal LBAs 256..383. After the HP boot, recover the raw journal before rewriting the SanDisk. The last valid durable line is the execution boundary even if the TV is `NO SIGNAL`.
