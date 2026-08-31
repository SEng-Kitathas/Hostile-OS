# H1 physical probe — operator use instructions

Status: **READY FOR PHYSICAL-H1 BOOT WHEN COMMANDER CHOOSES**

Exact image:
`research/targets/H1_PHYSICAL_PROBE/package/h1_probe_physical.img`

Required SHA-256:
`809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`

## Safety boundary

Use a disposable/removable USB device. Writing the image will overwrite that removable device. It is not an installer and does not write the HP internal disk.

Before boot:
1. verify the image SHA-256 exactly;
2. write it only to the intended removable device;
3. leave the HP internal drive connected unless the commander prefers an extra physical safety measure; the probe has no target-disk write path;
4. start continuous phone video before power-on so lines that scroll off the VGA screen are retained;
5. select the removable device through the HP legacy boot menu/BIOS path.

Expected framing:
- first stage eventually reaches `H1PROBE_BEGIN`;
- output includes CPU, BOOT, FW, IRQ, E820 and PCI records;
- final line is `H1PROBE_END`;
- the physical build then halts.

Do not interpret a partial boot as a pass. Preserve the video and visible failure point. Missing observations remain UNKNOWN.

## After the boot

Create a text capture matching the video as exactly as practical and keep the raw video as the primary physical evidence. Do not substitute QEMU values for unreadable/missing physical fields.

The first reconciliation should compare:
- CPU identity/features;
- EBDA/ACPI root;
- E820 map;
- PCI devices/classes/BARs, especially AMD A45 storage/USB/display/network/audio functions;
- APIC capability/base and initial PIC masks;
- boot-drive behavior.

Any physical contradiction with the H1 proxy or D64-v3 assumptions becomes a candidate earned discriminator. It does not automatically demote the architecture until the contradiction is localized and verified.
