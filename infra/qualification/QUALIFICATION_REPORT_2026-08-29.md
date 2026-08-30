# Freestanding x86 infrastructure qualification — 2026-08-29

**Class:** infrastructure qualification, not C003 scientific evidence
**Disposition:** QUALIFIED for bounded freestanding i386 build/boot probes

## Compiler/linker path

- clang: `E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin\clang.exe`
- clang version: Android clang 21.0.0, target host `x86_64-w64-windows-gnu`
- clang SHA-256: `f2e1b93d9dd27b847773e7de61b00f1b49ae27eb20ba434297cc020f768a1dfb`
- ld.lld: `E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin\ld.lld.exe`
- ld.lld SHA-256: `1260f9d6e0522bd476d040203998fa03406607971c13a9aa74f3f66f1e6d1c5d`
- llvm-objcopy: same NDK LLVM bin directory; exact executable hash was not captured because the earlier aggregate hash call timed out before printing it.

Build target exercised: `i386-unknown-none-elf`, freestanding assembly, ELF32 link, raw-binary objcopy.

## QEMU path

Standard QEMU was already installed but absent from PATH:

- executable: `C:\Program Files\qemu\qemu-system-i386.exe`
- package: `SoftwareFreedomConservancy.QEMU`
- version: `11.1.0 (v11.1.0-12130-ge470268ff4)`
- SHA-256: `dbbf7242e5b0d295e54336c69034a266ee1cc117d7ac6e3060e38bb61651200b`

The Android SDK emulator QEMU derivative was separately tested and demoted as a launcher donor: even in its `-fuchsia` path it injected emulator defaults and failed on an unsupported default NIC. It is not the qualified scientific launcher.

## Boot witness

Sources:
- `infra/qualification/boot_witness.S`
- `infra/qualification/boot_witness.ld`

Built result:
- raw size: 512 bytes
- boot signature: `55 AA`
- raw SHA-256: `9ba701c9ab6aa7220fab3416c1a32a66af5097b7ba5f970351fe5ae30fb81861`

Standard-QEMU launch used no display, monitor, or serial device. Guest output was captured on debug port `0xE9`; deterministic guest termination used `isa-debug-exit` at `0xF4`.

Observed consequence:
- QEMU exit code: `33`, the expected encoding of guest value `0x10` through `isa-debug-exit`
- debugcon text: `PCMMAD-QEMU-OK\n`
- debugcon SHA-256: `c44ca21e202616d19e3c482bf2c67561262ecc1aa314a02701a0b97b1d556730`

## Qualification boundary

This proves that the current machine can compile, link, materialize, boot, observe, and deterministically terminate a freestanding 16-bit/i386-compatible boot witness under standard QEMU.

It does **not** qualify any C003 mechanism, source translation, evaluator, or scientific consequence by itself.
