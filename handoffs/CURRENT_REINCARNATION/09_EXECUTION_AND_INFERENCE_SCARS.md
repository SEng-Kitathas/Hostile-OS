# Execution and Inference Scars — High Priority

These scars are active because this project repeatedly demonstrated that a plausible result can be manufactured by the wrong execution path.

## Core law

`action / command / trace / test output != qualified consequence`

Mechanism, fixture, launcher, evaluator, environment, source identity, and observed consequence are separate failure planes.

## HOSTILE-OS scars

1. **QEMU version smoke != machine execution.** `qemu-system-i386 --version` worked while machine creation failed because accelerator modules were absent.
2. **Fixture mismatch != kernel failure.** A modern/quarantined control root produced Linux child `ff00`; period-compatible userspace removed it.
3. **Shell invocation mode mattered.** Old shell `sh SCRIPT` stalled while `. SCRIPT` worked. The bad fixture path was not OS mechanism evidence.
4. **Foreground tool window != durable scientific run.** Long builds/emulation outlived or were killed by tool-call windows. Detached durable launch + owned receipt became mandatory.
5. **Modern compiler failure != donor source defect.** GCC 14 incompatibilities were moved to external build adapters while preserving 88/88 canonical source bytes.
6. **Missing tool != donor failure.** FreeDOS exact-source build was allowed to fail at the first `ia16-elf-gcc` boundary; the missing tool was supplied rather than patching donor code.
7. **P05 invalid simulator.** First scheduler simulator re-arbitrated every tick instead of matching Linux timer/block continuation semantics. Attractive metrics from that run were invalidated and retained as scar evidence.
8. **P01 C002 bad harness.** Clean output from an invalid/over-complete representation harness did not count.
9. **P17 real mechanism failure.** 18/72 cases lost child completion when it happened before wait installation. The fix was a real current completion condition, not evaluator massage.
10. **P19 evaluator failure.** After the mechanism was fixed, a stale evaluator still knew only the old success path. It produced false red. The evaluator was corrected without changing the scenario matrix.
11. **Verifier mutation scar.** Earlier package verification created new logs/receipts inside the specimen and thereby mutated what it was verifying. Final closure verification must be non-mutating; receipts live outside the sealed payload.
12. **Storage layout can become hidden policy.** Linux equal-counter tie choice depended on task-table position. Swapping storage slots swapped the winner.

## Execution discipline that follows

- Name the discriminator before consequential execution.
- Record cwd, interpreter/toolchain, environment, exact donor/source hashes, start/end, stdout/stderr, PID where relevant, exit status, completion marker/receipt, and result hashes.
- Inspect final artifact/state; do not infer it from command success.
- Timeout or ambiguous process state remains UNKNOWN until resolved.
- Keep invalid evidence; label it invalid rather than deleting the scar.
- Keep evaluator independent enough that new lawful success paths do not silently become false failures.
- Preserve source/runtime/tooling boundaries.
- Prefer exact current bytes/logs over narrative continuity.

## Reincarnation package verifier root/nested-manifest collision — 2026-08-29

The first final-package verification falsely reported the exact R3.1 nested `MANIFEST_SHA256.json` as missing. The package manifest contained it correctly; the verifier mistakenly excluded every file whose basename was `MANIFEST_SHA256.json` when building observed membership. Repair: exclude only the reincarnation root manifest by **relative path**, not basename. Lesson: verifier namespace/exclusion rules are themselves testable mechanisms; a red verifier result does not prove specimen corruption until evaluator logic is qualified.

## I001 long-replay IRQ-count evaluator sensitivity — 2026-08-30

A 3304-cycle earned-chain overnight campaign produced 660 I001 evaluator failures and zero failures in A01/RK01/RB02/ARB01/RR01/IRQ01. Retained I001 failures completed both QEMU boots exit33 and passed static closure, but observed `IRQ_EVENT=2` where the historical exact evaluator requires `IRQ_EVENT=1`.

Do not launder this into either conclusion. It is not yet proof the mechanism failed, and it is not lawful to dismiss 660 red evaluations as noise. The live seam is whether exact timer-event count is semantic or incidental. Historical evaluator/source remain unchanged; a new preregistered discriminator is required.

## Per-turn continuity scar — 2026-08-30

Repeated thread loss and stale local-only state demonstrated that “publish at end of substantive pass” leaves windows where a new thread can regress. Continuity is now a per-meaningful-turn Git/GitHub obligation. Failure to publish must be reported as pending/FAILED/UNKNOWN, never silently deferred as though remote continuity were current.

## I001 IRQ-count seam resolution and fixture scars — 2026-08-30

The prior long-replay `IRQ_EVENT=2` seam is resolved at tested count-1/count-2 scope by I001/IRQCOUNT01 PASS. All 660 historical I001 reds were verified to differ from the expected Boot1 trace only at `IRQ_EVENT=1` vs `2`; Boot2 is exact. Their evaluator FAIL status remains historical truth; the new interpretation is exact-evaluator overbinding for this tested consequence.

Two new execution scars remain visible:
1. a pre-build launcher-root mistake failed before mechanism execution and was retained;
2. the first QEMU attempt assumed PIT command `0x30` would generate repeated interrupts, but mode 0 is one-shot. ONE passed, MULTI timed out. Amendment A added guest-side PIT rearm and preserved the timeout as `FAILED_FIXTURE / NO_SCIENCE_CONCLUSION`.

A later semantic PASS was also deliberately marked non-controlling because Amendment A had not been included in its run-local input snapshot. Launcher v2 fixed that provenance defect; only the final rerun is controlling.

## D64/FR01 deterministic recovery scars — 2026-08-30

FR01 CLOSED PASS only after preserving three implementation/transport failures:

1. Launcher v1 built successfully but failed before fixture creation/QEMU because a local boolean shadowed `build_fixtures()`.
2. First 41-QEMU campaign: every trace `S1_8K_OK / IO_FAIL`, exit35. Cause: attempted CHS sectors19/20 on head0 despite 18-sector floppy track geometry. Amendment B corrected LBA18=C0/H1/S1 and LBA19=C0/H1/S2.
3. Second 41-QEMU campaign: same `IO_FAIL` signature after CHS correction. Cause: stage2 trusted incoming DL even though qualified stage1 debug output clobbers DX. Amendment C bound transport to the qualified saved boot-drive byte at physical0x7c4b, independently confirmed by symbol readback.

Neither IO_FAIL campaign reached record validation/selection/reconstruction, so neither was promoted into mechanism evidence. The final campaign is controlling.

Rule reinforced: transport/fixture failure is not mechanism failure, and a qualified loader's handoff contract must be used exactly rather than guessed from register convention.
