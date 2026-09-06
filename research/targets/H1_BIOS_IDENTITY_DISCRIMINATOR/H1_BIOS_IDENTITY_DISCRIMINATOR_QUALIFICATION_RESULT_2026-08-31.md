# H1 BIOS identity discriminator — QEMU qualification result — 2026-08-31

Status: QUALIFIED FOR ONE PHYSICAL H1 RUN

## Preregistered question

Can a sector-0-only discriminator capture the legacy-boot SMBIOS 2.x identity while using only the already-earned LBA257 evidence write path and performing no BIOS disk read?

## Build

Toolchain:
- clang/lld/llvm-objcopy from Android NDK 29 LLVM at `E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin`

Physical build:
- boot sector: 512 bytes
- boot-sector SHA-256: `cc0c93ed1ba7142c2dc9605d230aaf9938a1ba4c3008a95cbd505fa099e16ae5`
- 1 MiB image SHA-256: `b2de0a8f650a6b31678b3d5874b5d044d3c9e3bd9a93f7b00de59c53d73966c3`
- initial LBA257: all zero

QEMU build:
- boot-sector SHA-256: `eec4b8b0b739d35e4f47118b270598ddfe4987b6517da1af362bb85545aa35f8`
- pristine 1 MiB image SHA-256: `cec889fe92748a89b4bd7cc8b2c5e78178e79b5c801909d6fe73dc921f1f882b`

## Emulator run

Environment:
- QEMU 11.1.0
- `qemu-system-i386`
- `pc` machine, 64 MiB RAM
- raw IDE boot image
- ISA debug-exit at I/O port `0xF4`

Observed process exit: `33`, the expected value from the QEMU-only completion path.

LBA257 result:
- header: `H1SMBIOS1`
- boot DL: `0x80`
- status: `0`
- SMBIOS version: `2.8`
- entry-point length: `31`
- checksum marker: valid
- structure-table length: `413`
- structure count: `9`
- table physical address: `0x000F5320`
- result-sector SHA-256: `dc1f3f7c5809dc74c86474710ed91f6c5d79fd6482794c9cf8eaafce21a0c87c`

Parser decoded, among other records:
- Type 0 BIOS vendor: `SeaBIOS`
- Type 0 BIOS version: `rel-1.17.0-0-gb52ca86e094d-prebuilt.qemu.org`
- Type 1 system manufacturer: `QEMU`
- Type 1 product: `Standard PC (i440FX + PIIX, 1996)`
- Type 1 version: `pc-i440fx-11.1`

The complete advertised 413-byte SMBIOS table fit in the 448-byte capture window and parsed through Type 127 without truncation.

## Mutation check

Bytewise sector comparison of the pristine QEMU image against the post-run image found:
- changed sector count: `1`
- changed LBA: `257`
- changed bytes within LBA257: `306`
- all other sectors unchanged

## Qualification result

PASS for one physical H1 identity run.

The qualified physical image performs no BIOS disk read, does not modify firmware variables or internal storage, and writes runtime evidence only to boot-USB LBA257. Physical results remain unknown until raw readback after the H1 boot.
