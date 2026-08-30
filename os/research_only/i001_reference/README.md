# HOSTILE-OS research-only embodied reference — I001 seed

> **RESEARCH PURPOSES ONLY — NOT A RELEASE — NOT A FINAL ARCHITECTURE**

This directory exists so reviewers and contributors can build and boot a real HOSTILE-OS research embodiment without reconstructing command lines from experiment logs or depending on the original author's Windows paths.

It is seeded from the controlling I001 whole-workload integration witness because I001 is the first experiment that composed the main pre-D64 mechanism families into one freestanding two-boot descendant. Later D64/RK01/RB02/ARB01/RR01/IRQ01/PR01 results refine and extend that research; they are **not silently backported into this I001 embodiment**. This tree is therefore a reproducible inspection target, not a claim that I001 is the final OS.

## What this builds

A 1.44 MiB raw floppy image containing:

- 512-byte stage 1 boot sector;
- 4096-byte reserved stage-2 extent beginning at sector 2;
- durable sector at sector 10;
- the I001 freestanding two-boot integrated workload.

The controlling historical I001 run produced:

- stage 1: 512 bytes, SHA-256 `bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8`
- stage 2: 2478 bytes, SHA-256 `2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be`

`verify.py` checks whether an outside rebuild produces those same machine bytes.

## Prerequisites

- Python 3.10+
- Clang/LLVM tools: `clang`, `ld.lld`, `llvm-objcopy`
- QEMU `qemu-system-i386` for booting

Tool discovery is portable:

1. explicit environment variables (`HOSTILE_CLANG`, `HOSTILE_LLD`, `HOSTILE_OBJCOPY`, `HOSTILE_QEMU`),
2. `HOSTILE_LLVM_BIN` directory,
3. executable search through `PATH`,
4. common Windows QEMU location for QEMU only.

The original qualifying environment used Android NDK r29 LLVM/Clang 21.0.0 and QEMU 11.1.0. Exact historical tool hashes remain in the I001 receipt. They are also copied into `toolchain.lock.json` for machine-readable reviewer use. Exact historical tool binaries are **not** required merely to try a rebuild; any binary mismatch is reported rather than hidden.

## Build

Portable source of truth:

```text
python build.py
```

Wrappers:

```text
./build.sh
```

or PowerShell:

```text
./build.ps1
```

or, where GNU Make is available:

```text
make build
```

Outputs go under `build/` and are intentionally not committed as the mutable working build directory. Reproduction evidence that matters is written separately into the durable research tree when qualified.

## Verify machine-byte reproduction

```text
python verify.py --build-only
```

This checks the new build against the historical controlling stage-1/stage-2 binary hashes. It does **not** claim the historical scientific run was reproduced unless the boot path is also run.

## Boot twice in QEMU

```text
python run.py
```

Boot 1 writes durable state. Boot 2 starts as a distinct QEMU process against the same copied disk image and exercises restart/rebind behavior.

Then:

```text
python verify.py
```

The research-only verifier checks stable semantic markers and permits the now-tested `IRQ_EVENT` counts 1 or 2. Counts greater than 2 remain unearned and fail the research-only verifier. That rule is **not** a retroactive change to the historical I001 evaluator. The historical exact evaluator remains sealed and its long-replay `IRQ_EVENT=2` seam remains open research.

## Contributor rule

Do not edit this tree and then imply the historical I001 result changed. Changes here create a new research-only embodiment revision. If a change is intended to earn architecture authority, it needs its own preregistered research/verification path and explicit adoption decision.## Portability notes after independent-host reproduction

An outside-host report reproduced the I001 machine bytes and two-boot run using different Clang/LLD/QEMU versions, but exposed three transplant defects that are now repaired:

- tool invocation path is preserved; resolved binary identity is recorded separately in manifests;
- QEMU module discovery can use `HOSTILE_QEMU_MODULE_DIR` / existing `QEMU_MODULE_DIR` or infer a sibling transplanted `modules/` directory;
- the I001 runner passes `-nic none` because networking is outside this workload and must not introduce unrelated option-ROM dependencies.

The durable Linux QEMU transplant wrapper is superseded by `payload_history/lab_tooling/HOSTILE_OS_SMUGGLE_PATCH_003.zip`, which exports the module directory and defaults networking off.

Run `python tools/check_i001_reproduction_portability.py` from the repository root to verify these repository-side portability contracts.
