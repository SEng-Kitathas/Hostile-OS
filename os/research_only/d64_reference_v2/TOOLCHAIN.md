# Toolchain

The build discovers Clang, LLD, llvm-objcopy, llvm-nm and QEMU through explicit `HOSTILE_*` variables, `HOSTILE_LLVM_BIN`, PATH, and the common Windows QEMU path.

Invocation spelling is preserved separately from resolved binary identity. This matters for LLVM multi-call binaries on POSIX hosts.

Non-network reviewer workloads explicitly use `-nic none`.
