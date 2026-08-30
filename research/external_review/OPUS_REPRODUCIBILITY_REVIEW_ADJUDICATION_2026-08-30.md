# Opus donor review — reproducibility adjudication

Date: 2026-08-30
Source class: operator-supplied external model/donor review
Authority: controlled evidence, not doctrine by source identity

## Donor claims received

The donor review characterized HOSTILE-OS as real bare-metal x86 work, verified a D64/RB02 controlling run, highlighted the retained failed independent audit and append-only provenance correction, described ARB01's unsafe identity-only release discriminator, and identified two reproducibility gaps:

1. build/run commands were recorded but not independently portable as a clone-and-run package;
2. absent `.gitattributes` allowed line-ending normalization to make historical source hashes appear mismatched on another checkout.

The donor also offered evaluative opinions such as “most physically grounded project” and comparative portfolio judgments. Those opinions are not adopted as project facts.

## Verified findings

### Bare-metal / freestanding characterization — supported
The project contains a real x86 boot chain, hand-written assembly, linker scripts, raw boot images, QEMU execution, debugcon traces, and `isa-debug-exit` terminal status. This is not merely a host-language simulation.

### RB02 controlling run facts — supported
Controlling run:
`research/resource_binding/D64_RB02/runs/20260830T054900Z_d64_rb02_resource_binding_03`

Receipt records:
- QEMU scientific status `COMPLETED`
- exit 33
- 6432-byte stage2 inside 8192-byte envelope
- 3658-byte runtime state
- 1280 maximum observed shared live count

### Failed audit scar — supported
`12_independent_audit.json` is retained with `passed=false`; only `max_live_count` failed because the audit referenced the wrong receipt field name.

`13_independent_audit.json` is retained with `passed=true`, explicitly supersedes audit 12, and states the corrected key: `max_observed_resource_live_count`.

`D64_RB02_PROVENANCE_CORRECTION_2026-08-30.md` separately corrects the sealed result's unresolved audit SHA pointer while leaving the science consequence unchanged.

### Twelve source-hash line-ending mismatch — exactly reproduced
The RB02 input manifest records 12 source hashes from a Windows CRLF snapshot. For all twelve inputs:
- current Windows working/snapshot CRLF bytes match the receipt hash;
- canonical Git blob LF bytes do not match the historical receipt hash;
- converting the canonical Git blob LF bytes to CRLF reproduces the historical receipt hash exactly.

Therefore the donor correctly identified line-ending normalization as the cause. This is a portability/provenance defect in the repository interface, not evidence corruption.

## Build-script claim — qualified
The statement “a run receipt is not a build script” is fair as a reproducibility criticism, but “there is no runnable build” is literally too strong.

The research tree contains executable launchers such as `research/integration/I001/probe/launch_i001.py`. However, the historical launcher hard-codes original-host paths for LLVM, QEMU, and Python. An outside reviewer cannot clone and execute it unchanged unless their machine reproduces those paths. The donor's substantive conclusion — independent reproduction was one rung below artifact consistency — is therefore accepted.

## Repairs adopted from the donor pressure

1. root `.gitattributes` now defines canonical LF text and binary `-text` classes;
2. `tools/verify_historical_receipt_sources.py` explains/verifies historical CRLF receipt hashes without rewriting sealed evidence;
3. `os/research_only/i001_reference/` provides repo-relative source, portable tool discovery, build, run, and verify surfaces;
4. machine-byte rebuild is checked against the controlling I001 stage1/stage2 hashes;
5. contributor/reviewer reproduction is explicitly separated from historical science closure;
6. the I001 exact `IRQ_EVENT=1` historical evaluator is not rewritten — research-only verification reports exact-one as informational and requires only a positive IRQ event plus the stable semantic markers.

## Disposition

`DONOR_REVIEW_PARTIALLY_ADOPTED_AS_REPRODUCIBILITY_PRESSURE / VERIFIED_LINE_ENDING_SCAR / PORTABLE_RESEARCH_OS_EMBODIMENT_ADDED / HISTORICAL_SCIENCE_UNCHANGED`## Reproduction closure after donor pressure

The repair was then pressure-tested twice. Packet 02 is the preferred reviewer record because it used a fresh output directory and intentionally removed tool discovery first: the build failed closed with `missing tool for HOSTILE_CLANG...`, then succeeded unchanged after setting the documented `HOSTILE_LLVM_BIN` interface. It reproduced the exact historical stage1, stage2, and initial-disk hashes and completed two distinct QEMU boots exit33 with semantic verification PASS.

Therefore the donor's substantive “artifact consistency but not clone-and-run reproduction” gap is now **closed on the current qualifying host**. Cross-platform reproduction on a foreign machine remains unverified until an outside environment actually performs it.
