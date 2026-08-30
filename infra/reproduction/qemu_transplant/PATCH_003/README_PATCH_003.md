# HOSTILE_OS_SMUGGLE_PATCH_003

Purpose: portability patch for the previously admitted Linux QEMU transplant.

This patch does not replace or rewrite `HOSTILE_OS_SMUGGLE_001.zip` or `HOSTILE_OS_SMUGGLE_PATCH_002.zip`.

Overlay this archive after the earlier smuggle packages.

Changes:
1. `runtime/qemu/run-qemu-i386.sh` exports `QEMU_MODULE_DIR=$HERE/modules` unless the caller already set it.
2. The wrapper adds `-nic none` unless the caller explicitly supplied `-nic`, `-net`, or `-netdev`.

Reason:
- PATCH_002 contains `runtime/qemu/modules/accel-tcg-i386.so`; QEMU 6.2.0 requires module discovery in the transplanted environment.
- The I001 workload has no networking responsibility; an implicit default NIC pulls unrelated option-ROM dependencies such as `efi-e1000.rom`.

Source pressure: operator-supplied Opus independent-host reproduction report, adjudicated at `research/external_review/OPUS_INDEPENDENT_HOST_I001_REPRODUCTION_ADJUDICATION_2026-08-30.md`.
