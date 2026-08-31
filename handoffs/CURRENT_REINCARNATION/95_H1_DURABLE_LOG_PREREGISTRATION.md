# H1 durable boot-USB journal preregistration — 2026-08-31

Status: **PREREGISTERED / IMPLEMENTATION NOT YET QUALIFIED**
Trigger: first physical H1 splash-wrapper boot was accepted by firmware, then the attached TV immediately reported `NO SIGNAL`; the existing physical probe path had no persistent log.
Parent display discriminator: `research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER/`
Parent diagnostic probe: `research/targets/H1_PHYSICAL_PROBE/`

## Question

Can the next physical H1 boot preserve an exact-enough execution transcript on the boot USB even when the display path is unusable, while leaving the HP internal disk untouched?

## Selected mechanism

Use a separate text-only wrapper descendant with a resident BIOS disk-journal engine. Keep the firmware-selected video mode; do not request VGA mode 13h.

The logger SHALL write only to a reserved raw-sector journal region on the boot USB itself:

- journal start LBA: **256**;
- journal sector count: **128**;
- journal byte capacity: **65,536 bytes**;
- no filesystem is required;
- no HP internal storage path is opened or written.

Each 512-byte journal sector SHALL contain:

- bytes 0..3: ASCII magic `H1LG`;
- bytes 4..5: format version `1`;
- bytes 6..7: boot-session ID derived from the low 16 bits of BIOS tick count at journal initialization;
- bytes 8..9: monotonically increasing record sequence within the boot;
- bytes 10..11: payload byte count, maximum 500;
- bytes 12..511: ASCII payload.

The logger SHALL restart sequence at zero on each boot. Extraction SHALL accept only contiguous records with the same session ID and expected sequence, preventing stale trailing sectors from an older boot from being silently joined to the new packet.

## Wrapper milestones

After BIOS disk-mode detection succeeds and before probe handoff, durable output SHALL include at minimum:

- `H1LOG_BEGIN`;
- `H1LOG_DISK=EDD` or `H1LOG_DISK=CHS`;
- `H1LOG_PROBE_LOADED`;
- `H1LOG_CHAIN_PROBE`.

These messages SHALL also remain visible through BIOS teletype/debug output where available.

## Probe transcript

The diagnostic probe's existing character-output path SHALL be mirrored through a tiny hook into the resident wrapper logger. The hook SHALL not replace the existing VGA/debug output; it adds persistence.

The journal SHALL therefore capture the same line-oriented probe transcript, including at minimum when reached:

- `H1PROBE_BEGIN`;
- CPU identity/capability records;
- boot/INT13 facts;
- firmware/EBDA/RSDP facts;
- IRQ/APIC facts;
- E820 records;
- PCI records;
- `H1PROBE_END`.

Journal flush policy: flush on newline and whenever the current 500-byte payload fills. A completed line should therefore become durable before later probe work can fail.

## Safety boundary

This descendant intentionally changes the prior read-only boot-media rule **only for the reserved journal region on the boot USB**.

It SHALL NOT:
- write any LBA outside 256..383 through its journal write path;
- write the HP internal disk;
- write PCI configuration space;
- write firmware/flash;
- program PIC/APIC state;
- start AP1;
- modify D64-v3.

BIOS disk writes used by the journal SHALL be limited to:
- INT13h AH=43 for EDD write when EDD is available;
- INT13h AH=03 for one-sector CHS fallback when the boot USB is presented as floppy-like.

The loader/probe read paths retain AH=42/AH=02 and AH=08/AH=41 detection as already qualified.

## Qualification requirements

Before physical use:

1. implementation source is committed;
2. derived probe remains inside the existing 8 KiB stage2 linked envelope;
3. static audit proves the only BIOS write functions in the new transport are AH=43/AH=03 and the journal LBA is bounded to 256..383;
4. QEMU qualification runs both floppy/CHS and IDE/EDD paths against writable run-local image copies;
5. each run reaches `H1PROBE_END` through the existing debug channel;
6. extracted raw journal contains the wrapper milestones and full required probe markers;
7. all bytes outside the reserved LBA 256..383 journal region remain byte-identical before vs after each QEMU run;
8. journal extraction rejects stale/mismatched session or sequence records;
9. physical-use image starts with a zeroed journal region and receives a new SHA-256.

## Physical interpretation

After physical H1 boot, the USB journal is authoritative only for code paths that successfully wrote journal records. Absence of a later record localizes progress no farther than the last durable record; it does not prove the immediately following instruction failed.

If the TV loses sync again but the journal reaches `H1PROBE_END`, display failure is separated from probe execution. If the journal stops earlier, the last valid record becomes the next physical discriminator.

Physical H1 remains UNQUALIFIED until the journal from real hardware is recovered and reconciled.
