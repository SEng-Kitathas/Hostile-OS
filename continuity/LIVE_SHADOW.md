# LIVE SHADOW — HOSTILE-OS

## Thread Identity
- Thread: HOSTILE-OS / PCMMAD
- Last Updated: 2026-08-31T19:09:00Z
- Mode: CHECKPOINT
- Role: R4 Convergence Refiner with R1 audit pressure
- Dominant Objective: preserve the qualified H1 probe + splash transport and stop at the physical-H1 evidence boundary until real hardware earns the next campaign.

## Active User Intent
- Continue from persisted state with zero re-explanation.
- Inspect first; if a load-bearing unknown remains, ASK. Never guess across unexplained traces.
- Use the commander-supplied HOSTILE-OS artwork as the boot splash for the physical H1 probe.

## Current Authoritative State
- R3.1 is the adopted normal in-house SOP; R6 remains ancestry/fallback authority; no foundation promotion.
- C004 CLOSED20/20; C005 CLOSED20/20; no P21 for either; no C006 open.
- `os/research_only/d64_reference_v3/` remains CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY.
- D64-v3 remains 8089/8192 linked bytes with 103 bytes headroom; it was not modified for the splash.
- Selected H1 topology remains BSP sole relation mutator + ordered AP request/result mailbox participant.
- Physical H1 remains UNQUALIFIED.
- Underlying H1 observation probe remains qualified under QEMU and Bochs independent proxies using physical probe image SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`.
- Splash wrapper is QUALIFIED under QEMU legacy BIOS in both floppy-like CHS and hard-disk-like EDD presentations.
- Splash prereg/assets commit: `2d0cfee539aab66b65cc61a65fedec24046b15c9`.
- Final wrapper transport/provenance repair: `600d8ad30c656ee5b558a2ac3469c05d90cdfc6c`.
- Qualification evidence commit: `a76578c4a716ab91dbecd2d2728832fa15abde58`.
- Controlling splash run: `research/targets/H1_PHYSICAL_PROBE_SPLASH/runs/20260831T190606Z_h1_splash_wrapper_qemu_01`; floppy PID16260 exit67; IDE PID8648 exit67; both framebuffer checks PASS.
- Recommended physical thumb-drive image: `research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`, SHA-256 `bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`.
- Wrapper stage1 is512 bytes; splash loader704/4096; VGA asset32 colors +64000 indexed pixels; exact underlying physical probe stage2 remains `c12ea44714fd2c4d7dd3590c259e0f196cd38b8a979af8618ddaf79ac31f677d`.
- Static wrapper gate PASS15/15. No disk-write BIOS function, PCI config write, PIC/APIC programming, or QEMU exit port exists in the physical wrapper.
- Both QEMU frame captures normalize exactly to expected RGB SHA-256 `c738ace07e0ca80894678e199853c71f300b030d323bc6d4cb7209fc2ca25c1c`.
- C004->D64-v3 Pareto review remains CLOSED: do not spend the103 bytes on partial authority theater; C004 becomes an embodiment gate when untrusted execution/direct privileged effects are admitted.

## Active Constraints
- Historical/sealed evidence is append-only; failures remain visible.
- Emulator agreement does not become physical-H1 truth.
- The splash wrapper changes presentation/boot transport only; it does not change probe science or D64-v3.
- Physical USB writing is destructive to the selected USB device. Never infer the target disk; enumerate, identify, confirm, then raw-write and read back.
- A new campaign must be earned by a new responsibility domain or verified physical contradiction. Campaign numbering is not a progress meter.

## Decisions Locked In
- Human-facing recommended image is now the qualified splash wrapper; the no-splash image remains preserved as earlier qualified lineage.
- The wrapper supports both CHS/floppy-like and EDD/hard-disk-like legacy BIOS presentations.
- All wrapper disk reads occur before VGA graphics mode; frame/probe are staged in conventional RAM first.
- Physical H1 remains the next authority boundary; no C006 by momentum.

## Open Loops
- Create/write the bootable thumb drive with fail-closed physical-disk selection and post-write readback.
- Boot physical HP Pavilion p2-1120 and capture continuous video through splash + full probe output.
- Reconcile physical CPU/PCI/BIOS-ACPI/storage/interrupt/SMP observations against proxy assumptions.
- Open a new campaign only if physical evidence earns one.

- Physical H1 splash transport failure is preserved at `research/targets/H1_PHYSICAL_PROBE_SPLASH/PHYSICAL_H1_SPLASH_NO_SIGNAL_RESULT_2026-08-31.md`. Exact failing instruction remains unlocalized; VGA mode 13h is the leading discriminator.
- Text-only H1 wrapper is QUALIFIED under QEMU dual BIOS paths from source `9d3c70a47467252161a6763fac526342a10c6696`; static PASS15/15; no explicit video-mode set/DAC/framebuffer writes.
- Text-only physical image SHA-256 `5f90b22ad6264d2e2afb7c0155454b635a7bd4aa4ed22da6be879d14d3c26b42`.

- Physical H1 durable-log descendant is now emulator-qualified: text-mode preserving, raw USB journal LBAs 256..383, full transcript durable under CHS+EDD, physical image SHA-256 `ddf9ceec0b97ed8014874e11e804716867ad0956eaa980085373bb803e9a6cca`. Physical H1 retest pending.

## Immediate Next Step
- Prepare the guarded clone -> D: staging -> USB-write command block using splash image SHA-256 `bcd49e64...ca31`, then perform physical H1 boot when the commander is ready.

## Delta Since Previous Shadow
- Commander-supplied artwork converted to exact 32-color VGA payload and sealed.
- Splash wrapper qualified in CHS and EDD legacy-BIOS paths with exact framebuffer proof.
- Recommended physical USB image changed from plain probe `809e70bf...` to splash wrapper `bcd49e64...`; underlying probe bytes unchanged.
- Physical H1 remains UNQUALIFIED; no new campaign opened.
