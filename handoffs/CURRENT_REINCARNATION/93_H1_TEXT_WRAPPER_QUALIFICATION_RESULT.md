# H1 text-only wrapper qualification result — 2026-08-31

Status: **QUALIFIED EMULATOR DISCRIMINATOR / PHYSICAL H1 RETEST PENDING**

Source HEAD: `9d3c70a47467252161a6763fac526342a10c6696`
Controlling run: `research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER/runs/20260831T194842Z_h1_text_wrapper_qemu_01`

Physical trigger: first physical splash-wrapper boot caused the attached TV to report `NO SIGNAL` immediately after boot-device handoff. Exact failing instruction remains unlocalized; legacy VGA mode 13h transition is the leading discriminator.

## Result

The text-only wrapper is qualified under both emulator BIOS presentations while preserving the firmware-selected video mode.

Static gate: PASS 15/15.

Floppy/CHS:
- PID 24100;
- exit 67;
- `H1TEXT_DISK=CHS` present;
- `H1TEXT_WRAPPER_OK` present;
- full chain through `H1PROBE_END`;
- backing image unchanged.

IDE/EDD:
- PID 16040;
- exit 67;
- `H1TEXT_DISK=EDD` present;
- `H1TEXT_WRAPPER_OK` present;
- full chain through `H1PROBE_END`;
- backing image unchanged.

## Display isolation

Wrapper source contains:
- no explicit `INT 10h AX=0013h` graphics-mode request;
- no explicit `INT 10h AX=0003h` reset;
- no VGA DAC programming;
- no direct A000 framebuffer write;
- BIOS teletype output only, using the firmware's existing video mode.

## Exact qualified body

Text loader: 456 bytes / 4096-byte envelope, 3640 bytes headroom.

Parent probe stage2 remains byte-exact:
- physical stage2 SHA-256 `c12ea44714fd2c4d7dd3590c259e0f196cd38b8a979af8618ddaf79ac31f677d`;
- QEMU stage2 SHA-256 `2b7c0c2b47f751b716d4340aa7e0764d16a07eb49b8d036311d7d9f8e13234e2`.

Physical text-wrapper image:
- bytes: 1,474,560;
- SHA-256: `5f90b22ad6264d2e2afb7c0155454b635a7bd4aa4ed22da6be879d14d3c26b42`.

## Physical interpretation

If physical H1 now keeps the TV synchronized and prints `H1TEXT_WRAPPER_OK`, the splash graphics transition is strongly implicated.

If the TV still reports NO SIGNAL before that marker, the fault lies earlier/deeper than the explicit graphics-mode transition and must be localized separately.

No architecture promotion or demotion follows from emulator qualification alone. Physical H1 remains UNQUALIFIED until retest.
