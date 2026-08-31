# H1 durable boot-USB journal qualification result — 2026-08-31

Status: **QUALIFIED EMULATOR INSTRUMENT / PHYSICAL H1 RETEST PENDING**
Preregistration: `30d2b18fbeb2018f8dd7b6e3d4269ab4f8cfb77e`
Implementation: `3d6a0421f278c2033652df1f78019b5456f3f8ac`
Controlling run: `research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG/runs/20260831T195424Z_h1_durable_log_qemu_01`

## Trigger

The first physical splash-wrapper boot was accepted by H1 firmware but the attached TV immediately reported `NO SIGNAL`. The prior physical path was read-only and therefore left no durable execution packet.

## Result

A text-mode-preserving descendant now mirrors wrapper/probe output into a raw append-style boot-USB journal at LBAs 256..383 while preserving BIOS/video output.

Static gate: **PASS 22/22**.

Floppy/CHS controlling run:
- PID 17508;
- exit 67;
- journal records: 36;
- session: 59569;
- debug markers: PASS;
- independently extracted journal markers: PASS through `H1PROBE_END`;
- every byte outside journal LBAs 256..383 unchanged.

IDE/EDD controlling run:
- PID 16376;
- exit 67;
- journal records: 36;
- session: 59587;
- debug markers: PASS;
- independently extracted journal markers: PASS through `H1PROBE_END`;
- every byte outside journal LBAs 256..383 unchanged.

The extracted durable journal in both modes contains wrapper transport milestones plus the complete CPU / boot / firmware / IRQ / E820 / PCI transcript and `H1PROBE_END`.

## Exact body

- wrapper stage1: 512 bytes;
- resident logger loader: 1,376 / 4,096 bytes, 2,720 bytes headroom;
- physical hooked probe: 2,464 / 8,192 bytes, 5,728 bytes headroom;
- QEMU hooked probe: 2,468 / 8,192 bytes, 5,724 bytes headroom.

The hooked probe is derived from the already-qualified probe by one added indirect call in `putc`: `call *0x0500`. The logger engine/buffer remain resident in the wrapper below the probe body. D64-v3 is unchanged.

## Journal format / safety

- journal LBAs: 256..383 only;
- capacity: 65,536 bytes;
- each sector uses `H1LG` + version + session + sequence + payload length + up to 500 ASCII payload bytes;
- session derives from BIOS ticks and extraction accepts only contiguous matching-session/matching-sequence records;
- extractor stale-session/sequence self-test: PASS;
- BIOS write functions are limited to AH=43 EDD and AH=03 CHS fallback in the resident journal writer;
- no HP internal-disk path is opened or written;
- no graphics mode 13h request exists in this descendant;
- no PCI config writes, firmware writes, PIC/APIC programming, or AP startup are added.

## Physical image

`research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG/package/h1_probe_durable_log_physical.img`

- bytes: 1,474,560;
- SHA-256: `ddf9ceec0b97ed8014874e11e804716867ad0956eaa980085373bb803e9a6cca`;
- initial journal region: all zero.

After physical boot the whole-image SHA is expected to change because the journal region is intentionally mutable. This is no longer a read-only boot-medium instrument.

## Physical evidence ceiling

This qualifies the journal instrument under both emulator BIOS presentations. It does not qualify physical H1. The next physical boot should be followed by raw journal extraction from the same SanDisk before the image is rewritten.
