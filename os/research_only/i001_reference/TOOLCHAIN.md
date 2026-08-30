# Toolchain and reproduction envelope

## Historical qualifying environment

The controlling I001 receipt recorded exact executable hashes and paths. The local environment used:

- Android NDK r29 LLVM toolchain
- Clang 21.0.0
- LLD 21.0.0
- QEMU 11.1.0 development build
- Python 3.14.6

A reviewer-friendly machine-readable copy is `toolchain.lock.json`.

The historical receipt remains the authority for exact tool hashes:
`research/integration/I001/runs/20260830T042900Z_i001_integration_03/receipt.json`.

## Outside-review policy

The portable build does not require those exact paths. It discovers tools through environment variables/PATH and records the observed version strings and executable paths in `build/build_manifest.json`.

There are two different claims:

1. **machine-byte reproduction** — stage1/stage2 hashes match the controlling I001 binaries;
2. **scientific rerun** — the rebuilt image boots through the required two-process runtime behavior.

A different modern LLVM version may still produce identical bytes. If it does not, that is a reproduction difference to inspect, not automatic evidence that either toolchain is wrong.
