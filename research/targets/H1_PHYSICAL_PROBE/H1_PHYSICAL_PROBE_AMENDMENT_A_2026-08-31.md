# H1 physical qualification probe — Amendment A

Date: 2026-08-31
Status: **SEALED REQUIREMENT AMENDMENT BEFORE CONTROLLING QUALIFICATION**
Parent preregistration: `H1_PHYSICAL_PROBE_PREREGISTRATION_2026-08-31.md`

## Why this amendment exists

The target profile requires physical firmware/ACPI observations. The first probe implementation precheck exercised CPU, INT13, IRQ/APIC capability, E820 and PCI successfully after its CPUID-precheck repair, but the original required-output list did not make an ACPI root observation explicit enough.

That omission is corrected before the controlling qualification run.

## Added required observations

The controlling probe qualification SHALL also emit:

- `FW_EBDA=` with the BIOS Data Area EBDA segment value at physical `0x40E`;
- `FW_RSDP=` with either:
  - the physical address of a valid `RSD PTR ` signature found by the standard bounded scan order (first KiB of EBDA, then physical `0xE0000..0xFFFFF` on 16-byte boundaries), plus revision and RSDT/XSDT pointer fields available from that structure; or
  - explicit `NOT_FOUND` if no signature is found in those regions.

The scan is read-only. This amendment does not require parsing every ACPI table before physical H1 use; it establishes the physical root pointer needed for a later exact table-acquisition path if ACPI becomes load-bearing.

## Qualification status of earlier emulator boots

The emulator boots performed before this amendment are infrastructure prechecks only. They do not control readiness under the amended contract.
