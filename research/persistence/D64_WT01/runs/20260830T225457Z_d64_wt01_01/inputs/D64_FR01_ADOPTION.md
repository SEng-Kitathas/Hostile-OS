# D64/FR01 adoption — deterministic faulted durable-record recovery

Date: 2026-08-30
Status: ADOPTED AT TESTED SHADOW SCOPE
Science result: `D64_FR01_RESULT_2026-08-30.md`
Science close commit: `78efb0e29f94b374c129f0e0ed936e4b84e6ed84`

## Adopted shadow rule

For faulted durable-state recovery at the tested deterministic media-fixture scope:

1. durable meaning is represented as two independent sector candidates;
2. each candidate is valid only after structural fields, CRC16, and explicit commit marker validate;
3. validity is checked **before** sequence ordering;
4. newest unambiguous valid sequence wins;
5. invalid newer data cannot outrank older valid data;
6. equal-sequence conflicting valid payloads fail closed;
7. no-valid and epoch-exhausted states fail closed;
8. successful recovery rebuilds fresh runtime topology under new epochs and rejects historical handles.

## Selected integrity mechanism

CRC-16/CCITT-FALSE + `CMIT` is adopted for this shadow record lineage because it beat the tested same-size additive checksum and larger complement-copy candidate under preregistered pressure.

This is error/integrity detection, not cryptographic authenticity.

## No architecture overpromotion

The two-sector record format is an incumbent research/shadow mechanism, not yet a constitutional storage API, filesystem format, or production journal.

It may be replaced if later real interruption/hardware pressure exposes missing ordering/atomicity requirements.

## Next reopening triggers

Revisit on:
- real guest-write interruption;
- physical hardware;
- controller/BIOS caching effects;
- sector-write tearing behavior different from deterministic fixtures;
- sequence wrap;
- more than two durable candidates;
- durable object graphs beyond the tested scalar meaning/currentness record;
- stronger integrity/authenticity requirements.
