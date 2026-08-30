# Opus independent-host I001 reproduction — adjudication

Date: 2026-08-30
Source class: operator-supplied external-host report
Authority: external reproduction evidence, with local verification of repository defects; foreign-host raw build/run artifacts were not supplied in this thread

## External claim accepted as reported, not locally re-executed

Opus reports a clean-clone reproduction on a different host/OS using Clang 18.1.3, different LLD, and QEMU 6.2.0. The report states:
- stage1/stage2 rebuilt to the controlling I001 hashes;
- 512-byte stage1 and `55 aa` signature verified;
- stage2 remained within 4096 bytes;
- two distinct QEMU processes completed exit33;
- no host write occurred between boots;
- `historical_exact_irq_event_one=true` in that one outside run.

Because the foreign-host files/receipts were not attached here, PCMMAD does **not** promote this into locally hash-verified raw reproduction evidence. It is preserved as an external report. If the foreign packet is later supplied, it should be admitted under `research/reproduction/external/` with its own manifest.

## Defect 1 — symlink / multi-call tool identity: VERIFIED

Current `os/research_only/i001_reference/build.py` returned `.resolve()` for explicit environment tools, `HOSTILE_LLVM_BIN` candidates, and PATH discoveries. On POSIX, a name such as `/usr/bin/ld.lld` may be a symlink into a multi-call executable. Resolving the symlink changes argv[0] from `ld.lld` to the generic target name (for example `lld`), which can change driver behavior.

Disposition: real transplant-portability defect. Invocation identity and resolved binary identity must be recorded separately.

## Defect 2 — QEMU module directory: VERIFIED AGAINST DURABLE SMUGGLE ARCHIVES

`payload_history/lab_tooling/HOSTILE_OS_SMUGGLE_001.zip` contains `runtime/qemu/run-qemu-i386.sh` which exports only `LD_LIBRARY_PATH` and passes `-L "$HERE/share/qemu"`; it does not set `QEMU_MODULE_DIR`.

`HOSTILE_OS_SMUGGLE_PATCH_002.zip` contains `runtime/qemu/modules/accel-tcg-i386.so` (and other modules). Therefore the module exists in the transplant but the historical wrapper does not tell QEMU where to find it.

Disposition: verified transplant-environment defect. Historical ZIPs remain immutable; a new PATCH_003 supersedes the wrapper behavior.

## Defect 3 — default NIC pulls unrelated ROM dependency: VERIFIED AS HERMETICITY DEFECT

Current `os/research_only/i001_reference/run.py` does not request any NIC behavior but also does not disable QEMU's default NIC. The I001 workload has no networking responsibility. Allowing an implicit NIC therefore adds an unrelated firmware/ROM dependency and can cause a transplanted QEMU to fail before the relevant guest executes.

Disposition: verified hermeticity defect. `run.py` now passes `-nic none`; PATCH_003 wrapper also defaults to `-nic none` unless the caller explicitly supplies a NIC/network argument.

## Line-ending recommendation: ALREADY CLOSED BEFORE THIS REPORT

Root `.gitattributes` already contains `* text=auto eol=lf` plus exact-evidence exceptions for scientific run directories. Historical CRLF receipts are handled by `tools/verify_historical_receipt_sources.py` and are not rewritten.

## Architectural analogy

The donor's observation `TOOL_PATH != TOOL_IDENTITY` is technically supported by the symlink defect: the invocation name can carry dispatch meaning that the resolved filesystem target does not. Likewise `TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT` is supported by the QEMU module/ROM failures: copying the executable bytes alone did not recreate the runtime environment required to use them.

These are useful infrastructure analogies to HOSTILE-OS identity/currentness research. They are not themselves new OS architecture proof.

## Disposition

`EXTERNAL_REPRODUCTION_REPORTED / THREE PORTABILITY FINDINGS ADJUDICATED / TWO DIRECT CODE DEFECTS VERIFIED / LINE_ENDING FIX ALREADY PRESENT / SCIENCE RESULT UNCHANGED`## Repository-side repair verification

After repair, the local authoring host was rerun end-to-end:
- controlling I001 stage1 hash remained exact;
- controlling I001 stage2 hash remained exact;
- two distinct QEMU boots completed exit33;
- no host disk write between boots;
- living verifier PASS.

`tools/check_i001_reproduction_portability.py` also passes all repository-side portability checks:
- invocation spelling preserved;
- resolved binary identity recorded separately;
- transplanted QEMU module directory inferred;
- `run.py` disables the default NIC;
- PATCH_003 contains the corrected wrapper;
- PATCH_003 exports `QEMU_MODULE_DIR`;
- PATCH_003 defaults networking off.

Windows did not permit local creation of a real symlink without elevation (`WinError 1314`), so the exact POSIX symlink execution failure remains externally observed rather than locally repeated. A path-spelling surrogate verified the corrected code does not resolve invocation spelling before execution.

## Smuggle PATCH_003

Expanded inspectable source:
`infra/reproduction/qemu_transplant/PATCH_003/`

Deterministic builder:
`tools/build_smuggle_patch_003.py`

Published bundle candidate:
`payload_history/lab_tooling/HOSTILE_OS_SMUGGLE_PATCH_003.zip`

The builder was run twice and produced the same bytes both times:
- bytes: `1455`
- SHA-256: `c8e29d61b299a4a515b5b381682c0e8fd9be92cbcd815c6dd300706b687fa615`

Historical smuggle packages remain unchanged.
