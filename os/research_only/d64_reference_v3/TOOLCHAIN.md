# Toolchain and transplanted QEMU runtime

The build discovers Clang, LLD, llvm-objcopy and llvm-nm through explicit `HOSTILE_*` variables, `HOSTILE_LLVM_BIN`, and PATH. QEMU is discovered through `HOSTILE_QEMU`, PATH, or the common Windows install path.

Invocation spelling is preserved separately from resolved binary identity. This matters for LLVM multi-call binaries on POSIX hosts:

`TOOL_PATH != TOOL_IDENTITY`

## QEMU runtime environment

A relocated QEMU executable may also depend on runtime material that moved with it. The current runner therefore treats these as distinct:

- executable path;
- module directory;
- firmware/data directory.

Module directory precedence:
1. `HOSTILE_QEMU_MODULE_DIR`;
2. `QEMU_MODULE_DIR`;
3. adjacent `modules/` discovery near the selected QEMU binary.

Firmware/data directory precedence:
1. `HOSTILE_QEMU_DATA_DIR`;
2. `HOSTILE_QEMU_FIRMWARE` (compatibility alias);
3. adjacent `share/qemu/` or `share/` discovery near the selected QEMU binary, requiring `bios-256k.bin` for automatic selection.

When a data directory is selected, `run.py` passes it to QEMU as:

```text
-L <data-directory>
```

The selected path is recorded as `qemu_data_dir` in the run receipt. The selected module path is recorded as `qemu_module_dir`.

This is infrastructure/reproducibility behavior, not OS architecture state.

Non-network reviewer workloads explicitly use `-nic none` so unrelated NIC option-ROM dependencies cannot block the guest.
