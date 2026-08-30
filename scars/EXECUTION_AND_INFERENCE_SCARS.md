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
