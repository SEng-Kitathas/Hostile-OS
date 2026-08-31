# Physical H1 splash-wrapper result — TV NO SIGNAL

Date: 2026-08-31
Status: **PHYSICAL OBSERVATION / FAILURE PRESERVED / EXACT INSTRUCTION NOT YET LOCALIZED**

Operator report from first physical boot attempt of the qualified splash-wrapper USB on HP Pavilion p2-1120 H1:

- firmware/boot menu accepted the SanDisk as a boot device;
- immediately after launching that boot device, the attached TV reported **NO SIGNAL**;
- no visible splash or probe text was observed;
- no persistent thumb-drive log exists because the physical wrapper/probe path is read-only and does not write logs to the boot media.

This is direct operator-reported physical-H1 evidence that the qualified emulator presentation path is not sufficient for the real HP->TV display chain.

The failure is not yet localized to one instruction. The leading discriminator is the splash wrapper's explicit transition to legacy VGA mode 13h (`INT 10h AX=0013h`), because the underlying probe itself does not require an explicit graphics-mode transition.

Next discriminator is preregistered separately: a text-only wrapper preserving the firmware-selected video mode, using the same dual EDD/CHS USB transport and the exact same qualified probe stage2.

No architecture demotion follows yet. Physical H1 remains UNQUALIFIED.
