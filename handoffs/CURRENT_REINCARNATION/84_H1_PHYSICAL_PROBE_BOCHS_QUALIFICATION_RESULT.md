# H1 physical qualification probe — Bochs independent-proxy result

Date: 2026-08-31
Status: **PASS / INSTRUMENT QUALIFICATION STRENGTHENED / PHYSICAL H1 STILL UNQUALIFIED / NO C006**
Preregistration seal: `77b91de3878eb6b1164e3805259c34cce2adbf34`
Harness seal: `d8cc509cdffa3f85503d632e6b597e6e2db307b9`
Controlling run: `research/targets/H1_PHYSICAL_PROBE/runs/20260831T182218Z_h1_physical_probe_bochs_01`

## Qualified consequence

The exact unchanged physical removable-media probe image completed every preregistered observation family under a second independent x86 emulator/firmware stack, Bochs 3.1, without using the QEMU-only debug-exit image and without judging success by equality with QEMU values.

The run reached `H1PROBE_END`. The harness then terminated Bochs because the physical image deliberately halts forever after reporting. Status is therefore correctly recorded as:

`COLLECTION_COMPLETE / EMULATOR_TERMINATED_BY_HARNESS`

and not as a guest process exit.

## Integrity / process evidence

- source Git HEAD: `d8cc509cdffa3f85503d632e6b597e6e2db307b9`;
- Bochs PID: `26904`;
- start: `2026-08-31T18:22:18.943793+00:00`;
- end: `2026-08-31T18:22:20.391529+00:00`;
- exact physical image SHA-256 before run: `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`;
- exact run-copy image SHA-256 after run: `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`;
- preregistration snapshot SHA-256: `19b89a04c49583f8fe465f2d98885a7fc75de6837489a4d294e290282627909b`;
- Bochs executable SHA-256: `a59871b4cae1f8f7729eeb1419ec25e15543641b348bc32f712946d8fb04b1bb`;
- stdout SHA-256: `9f7d23ebbabe941f7c5c61a78ee1aa689b32f481aaa435328864cdaa9a1dcf67`;
- stderr SHA-256: `f7101a9f15cdb7e147f33018dfba8b45b114c13d87cae58e311cfd9865c6879f`;
- Bochs log SHA-256: `80181b1256e68c33ccdeb092cdcf7c87bfdd8ed33d757406eb5f3dbeb4f6c98a`.

All eight run-receipt checks passed, including source/run image hash, read-only image preservation, required marker ordering, CPU/boot/firmware families, and collection-end capture.

## Independent-proxy observations

The Bochs proxy produced:

- CPU vendor `AuthenticAMD`, family `10`, model `02`, stepping `03`, logical count `01`, APIC/MSR present;
- BIOS floppy boot drive `00`, geometry available, INT13 extensions absent;
- EBDA `9FC0`, ACPI RSDP at `000FA3F0`;
- PIC masks `B8/8F`, APIC/MSR capability present, APIC base `FEE00900`;
- a complete E820 map;
- a complete bounded PCI scan;
- full `H1PROBE_BEGIN` → `H1PROBE_END` framing.

## Proxy diversity versus QEMU

The second proxy deliberately did not reproduce QEMU's values exactly. Examples include:

- logical CPU count: QEMU proxy `02`, Bochs proxy `01`;
- CPUID feature/EBX values differ;
- ACPI RSDP/RSDT locations differ;
- PIC mask low bits differ;
- E820 layout differs materially;
- PCI topology and device IDs differ materially.

This is useful evidence. It shows the collection instrument is not passing because it is hard-coded to the first emulator's observed values. The same immutable image discovers and reports a different machine description.

None of these proxy differences is a HOSTILE-OS mechanism contradiction. They are expected environment diversity and remain non-authoritative for physical H1.

## Scientific / architecture ceiling

This closes only a bounded **instrument qualification** question.

It does not:

- qualify HP Pavilion p2-1120 H1;
- make either emulator's values physical truth;
- open C006;
- change C004/C005 pass counts;
- change D64-v3;
- promote architecture, release, production, arbitrary hardware, or broad portability claims.

## Frontier consequence

The physical observation instrument now has successful collection evidence under two independent emulator/firmware stacks using the same physical image:

1. QEMU H1 proxy — qualified earlier;
2. Bochs 3.1 — this result.

The next load-bearing evidence boundary remains the real H1 boot/probe packet. A new broad campaign is still not earned until physical H1 or another verified input exposes a new responsibility domain or mechanism contradiction that cannot be handled as bounded qualification/integration work.
