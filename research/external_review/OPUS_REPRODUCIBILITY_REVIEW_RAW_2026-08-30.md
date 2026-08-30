# Opus donor material — raw review supplied by operator

Date admitted: 2026-08-30
Source: operator-supplied donor material from Opus
Authority: raw controlled evidence; not adopted doctrine by source identity

---

This is real bare-metal work. Let me verify rather than read.

Twelve of twelve source hashes mismatch. Before I report that, let me check the obvious cause.

All twelve mismatches are line-ending normalization. Convert LF to CRLF and every source hash verifies. Not a defect — my clone normalized on checkout.

# HOSTILE-OS — deep evaluation

## What it is

Bare-metal x86 OS research on real hardware emulation. Two-stage boot, hand-written `.S` assembly, custom linker scripts, clang toolchain, QEMU with `isa-debug-exit` and a debugcon serial channel. Not a simulation of an OS — an actual boot chain that either reaches its exit code or doesn't.

`os/` contains a README and nothing else, deliberately: *"Research witnesses under research/ are not silently promoted into this tree. A mechanism enters os/ only after the project has earned and adopted it at the appropriate architecture/release gate."* Twelve megabytes of research, one file in the install surface. That's the promotion discipline expressed as directory layout.

## What I verified

Run `20260830T054900Z_d64_rb02_resource_binding_03`:

```
debugcon hash matches evaluation.json      TRUE
41 of 41 expected lines present            TRUE
12 of 12 source hashes verify (CRLF-normalized)
QEMU status COMPLETED, exit 33, 206ms wall
stage2 raw 6,432 bytes inside 8,192 envelope
runtime state 3,658 bytes
```

Twelve build steps captured with separate stdout and stderr — clang, link, objcopy, twice, then QEMU, evaluator, size, nm, static check, two audits. The full toolchain trace, not a summary of it.

## The finding that makes this credible

`12_independent_audit.json` **fails**. `passed: false`, one check false: `max_live_count`. Cause: the audit script referenced a nonexistent receipt key instead of `max_observed_resource_live_count`.

The failing audit is retained in the run directory as a scar. `13_independent_audit.json` supersedes it and states the correction inline. And `D64_RB02_PROVENANCE_CORRECTION_2026-08-30.md` exists because the sealed result recorded a SHA-256 that matches no tracked artifact — an append-only correction documenting that the audit script had a defect, with both audit file hashes and the disposition of each.

A failing audit preserved next to the passing one that replaced it, plus a public correction for a hash that didn't resolve. That's not decoration. That's the thing almost nobody does.

## The science itself is real

ARB01's result: clearing activity identity while its 20-cell binding row is still live is unsafe. They proved it by *doing the unsafe thing* — identity-only release left binding and resource state intact, a new activity reused the slot, and the ordinary good binding-read routine returned the prior occupant's value `0x7E`.

That's a use-after-free demonstrated at the byte level in a live boot, then a checked release that rejects while any cell in the row is nonempty. Rekey advanced activity epoch 1→2, reset eleven 64-entry arrays and both 1,280-entry binding arrays, cleared seeded tail residue at cell 1279, preserved resource epoch 1 and slot-0 generation history.

Generation counters, epoch invalidation, currentness-after-composition — the exact same primitives as Microseed's authority model, expressed in x86 assembly under an 8KB stage-2 budget.

## The real gap

**A run receipt is not a build script.** I can verify the artifacts are internally consistent and that the sources hash correctly. I cannot rebuild `stage2.raw.bin` from `stage2.S` and confirm it produces the same bytes, because the toolchain invocations are recorded as captured output rather than as a runnable script in the repo.

The receipt records `qemu-system-i386.exe` at a Windows path, a `.venv` launcher on `E:\`, and clang flags in stdout logs. Reconstructible by hand, not executable. So the verification ceiling here is **artifact-consistency**, not **independent reproduction** — one rung below what the F020/R1.1 packages achieved with `VERIFY_PACKAGE.py`.

That matters because HOSTILE-OS is the project where reproduction is most valuable: a boot either happens or it doesn't, and a `make && qemu` that a stranger can run would be the strongest evidence in the entire portfolio.

**Second gap:** the `.gitattributes` has LFS rules but no `* text=auto eol=lf` or `-text` for the run inputs. Every source hash in every receipt is CRLF-recorded, so any Linux clone fails source verification by default. I nearly reported twelve mismatches as a defect. Anyone auditing this from a non-Windows host will hit the same wall, and unlike me they may not check.

That's the third instance of the platform-portability class today — the encoding fix, the path-separator scar in the R3.1 verifier, and now this.

## Verdict

The most physically grounded project you have. QEMU exit codes and debugcon bytes can't be argued with, and a use-after-free reproduced at `0x7E` is about as unfakeable as evidence gets. The evidence discipline is the strongest of the three repos — a preserved failing audit and a public hash-provenance correction are things I have not seen elsewhere.

What it's missing is the one thing it's best positioned to have: a runnable build. Add a `build.sh`, pin the toolchain, add `eol=lf` to `.gitattributes`, and this becomes the only project in the portfolio where an outside party can independently reproduce a scientific result end to end.
