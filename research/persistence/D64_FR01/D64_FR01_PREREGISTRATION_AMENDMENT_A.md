# D64/FR01 preregistration amendment A — fixture-label isolation

Date: 2026-08-30
Status: VISIBLE FIXTURE AMENDMENT BEFORE GUEST IMPLEMENTATION / BEFORE SCIENCE EXECUTION
Parent preregistration: `D64_FR01_PREREGISTRATION.md`

## Why this amendment exists

The preregistered guest trace requires `CASE=<case-id>` for F01..F11 and every F12 tear boundary. The two durable sectors must not contain host test-oracle metadata because selection/recovery must be driven only by durable-record bytes.

The original text also said remaining disk bytes stay fixture-zero, which leaves no clean place for a per-fixture label without changing stage1/stage2 bytes or contaminating the durable records.

## Amendment

Reserve BIOS sector20 / zero-based LBA19 as a **fixture-label-only sector**.

Layout:
- bytes0..3: ASCII `CASE`;
- bytes4..35: zero-terminated ASCII case id, maximum31 characters;
- bytes36..511: zero.

Examples:
- `F01`;
- `F10`;
- `F12_tear_00`;
- `F12_tear_29`.

All disk bytes after sector20 remain fixture-zero.

## Isolation rule

The guest may read sector20 only into a dedicated label buffer and may use those bytes only to print the `CASE=` line.

The label buffer is forbidden from influencing:
- record validation;
- CRC calculation;
- sequence comparison;
- checked selection;
- naive selection;
- epoch derivation;
- stale-handle validation;
- runtime reconstruction;
- durable/fresh value exposure;
- exit status other than an explicit malformed-label fixture error.

Static closure must verify the label buffer is referenced only by the fixture-label read/validation/print routines.

The host evaluator already knows the fixture id from its own campaign plan. Therefore the printed label is provenance/trace binding, not the source of the expected result.

## Evidence-envelope correction

The qualified disk layout for FR01 is now:
- sector1: stage1;
- sectors2..17: stage2 extent;
- sector18: durable record A;
- sector19: durable record B;
- sector20: fixture-label-only metadata;
- sectors21 onward: zero.

No other preregistered hypothesis, durable format, selection rule, recovery rule, fixture expectation, or authority ceiling changes.
