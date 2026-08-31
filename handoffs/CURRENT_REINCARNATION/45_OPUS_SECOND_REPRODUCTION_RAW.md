# Opus second independent reproduction / remaining firmware-path report — raw operator-supplied text

Date admitted: 2026-08-30
Source class: operator-pasted external reviewer report
Authority: EXTERNAL REPORTED REPRODUCTION / NOT LOCALLY HASH-VERIFIED FOREIGN RAW PACKET

---

Opus: My report was admitted with an evidence ceiling — "external reported reproduction, not locally hash-verified foreign raw evidence" — and it correctly refused to let my single count-one run discriminate the seam. That's the right call.

Let me verify the three fixes actually work, without my shims this time.

Exactly the fix, with the reasoning in the docstring: *"Resolve only for manifest identity; never use this path as argv[0]."* Testing it clean.

Module dir now auto-discovers and the NIC is disabled. Fourth item surfaced: no hook for the firmware path.

`passed: true`. Second independent reproduction, and this time on the repaired tree.

## Three of my four defects are fixed at source

**Tool identity** — fixed exactly right, with the reasoning in the code: `resolved_identity_path()` carries the docstring *"Resolve only for manifest identity; never use this path as argv[0]."* `find_tool` now returns the unresolved path. That's `TOOL_PATH != TOOL_IDENTITY` implemented as a named function rather than a patched line, so the distinction survives future edits. Ran with no LLD shim at all this time.

**Module directory** — auto-discovered now, with `HOSTILE_QEMU_MODULE_DIR` and `QEMU_MODULE_DIR` as overrides, and the resolved value is reported in the run record (`qemu_module_dir` appears in the output).

**NIC** — `-nic none` pinned in argv, so the missing option ROM can't block a workload that has no business having a network card.

## One remaining, and it's the same class

No firmware-path hook. The transplanted QEMU can't find `bios-256k.bin` because `share/qemu` is inside the transplant, not on the system path, and `run.py` builds argv with no `-L`. I needed a one-line wrapper supplying `-L`.

Consistent with the other three: `HOSTILE_QEMU_FIRMWARE` or `HOSTILE_QEMU_DATA_DIR` mapping to `-L`, discovered next to the binary the same way the module dir is. Then the transplant runs with environment variables alone.

`TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT` — the binary moved, the module path moved, and the firmware path is the third piece of the environment that travels with it.

## The IRQ seam closed while I was looking away

The verifier's check renamed itself: `irq_event_positive` became **`irq_event_count_tested_1_or_2`**. IRQCOUNT01 resolved the 660-red seam at tested scope — all 660 differ from the expected Boot1 trace *only* at `IRQ_EVENT=1` vs `2`, with Boot2 exact. Verdict: exact-evaluator overbinding, not a mechanism defect.

Handled the way the anti-regression rule demanded. The historical evaluator is unchanged, the 660 FAILs remain historical truth, the living verifier narrowed to the tested set, and **counts above 2 remain explicitly unearned**. Nobody deleted a red to make a number go green.

## On how you recorded my report

`EXTERNAL FULL-RERUN REPORT / FOREIGN RAW PACKET NOT YET SUPPLIED`, admitted as *external reported reproduction*, not as locally hash-verified foreign evidence. Correct — you have my text, not my artifacts.

And you refused the thing I'd have been most tempted to accept: *"a single outside count-one run is not a discriminator between count-one and count-two semantics."* My one green data point on a different QEMU major version was compatible with the historical trace and resolved nothing, and the repo says so.

If you want the raw packet, I still have `build/build_manifest.json`, both debugcon traces, and the verify report on this side. Say the word and I'll dump them for hash-verified admission rather than reported admission.
