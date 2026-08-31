# H1 physical qualification probe — instrument qualification result

Date: 2026-08-31
Status: **QUALIFIED INSTRUMENT / PHYSICAL H1 STILL UNQUALIFIED**
Preregistration seal: `2828ee9b73b53c53c1c878d9ebf021957ec2f2c6`
Amendment A seal: `a32da98938e96f62e698fc4418632fb231343019`
Implementation seal: `51fafe6a61db701a592b6a0564b9b374d748d8b2`
Controlling run: `research/targets/H1_PHYSICAL_PROBE/runs/20260831T180418Z_h1_physical_probe_qemu_01`

## Qualification result

The non-destructive H1 observation instrument is qualified for physical-use preparation under the sealed preregistration + Amendment A.

Controlling H1-proxy run:
- source HEAD: `51fafe6a61db701a592b6a0564b9b374d748d8b2`;
- source tree: `860e8764bab1b043a7f25737328171c7213e725c`;
- QEMU PID: `7940`;
- process exit: `67` through the QEMU-only `isa-debug-exit` path;
- start: `2026-08-31T18:04:18.479761+00:00`;
- end: `2026-08-31T18:04:19.255774+00:00`;
- debug output SHA-256: `d7050841354fb408977d7a03f01cbf0a15290e57a805cf774f6178e191b5c655`;
- all required output markers: PASS.

Static safety/closure gate: PASS 13/13 after preserving checker Scar B.

## Built physical instrument

- stage1: 512 bytes, SHA-256 `ae5d9561a5a4ee4f870d6b1d6a57d4b5de4da3616c0868beefd8e8bf73580dda`;
- physical stage2: 2,460 bytes, SHA-256 `c12ea44714fd2c4d7dd3590c259e0f196cd38b8a979af8618ddaf79ac31f677d`;
- physical stage2 envelope headroom: 5,732 / 8,192 bytes;
- physical removable-media image: 1,474,560 bytes, SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`;
- QEMU-only image SHA-256: `319274733fb44dd5f7f93649e67c4c49d0370f861e8fed636e563f5bf5241944`.

The physical image contains no QEMU debug-exit sequence. The QEMU-only image does.

## Controlling proxy observations

The proxy run produced all required families:
- CPU: `AuthenticAMD`, leaf1 present, decoded family `10`, model `02`, stepping `03`, logical `02`, APIC `01`, MSR `01`;
- boot: BIOS boot drive and geometry reported, INT13 extensions absent for the floppy transport;
- firmware: EBDA `9FC0`; ACPI RSDP found at physical `000F52C0`, revision `00`, RSDT pointer present;
- interrupt/APIC: PIC masks reported; APIC base `00000000FEE00900`;
- memory: E820 walk completed normally;
- PCI: complete bounded BDF scan completed and reported all present proxy functions plus raw BAR values;
- framing: `H1PROBE_BEGIN` through `H1PROBE_END`.

These are **proxy values only**. None may be copied into the future physical-H1 packet as physical truth.

## Preserved scars

### Scar A — CPUID availability precheck

The first implementation used an EFLAGS.ID toggle test that suppressed CPUID under the proxy. The run was non-controlling. The target-specific probe now calls CPUID directly because both the declared AMD E2-1800 target and qualified H1 proxy implement it.

### Scar B — static verifier over-ban

The first static checker incorrectly banned all stage2 INT13 calls, including preregistered read-only AH=08/AH=41 queries. The checker was repaired to admit only those two stage2 BIOS disk functions and still ban write functions.

## Safety statement

The physical build:
- uses BIOS AH=02 only to read its own probe sectors in stage1;
- uses only read-only INT13 AH=08/AH=41 after stage2 starts;
- does not issue PCI configuration-data writes;
- does not program PIC/APIC state;
- does not write the target disk;
- does not start AP1;
- halts after reporting.

## Scientific / architecture ceiling

This result qualifies the **collection instrument under the emulator proxy**. It does not qualify HP Pavilion p2-1120 H1, does not open C006, does not modify C004/C005 pass counts, and does not promote architecture or release status.

Physical H1 remains `UNQUALIFIED` until the exact physical packet is captured and reconciled.
