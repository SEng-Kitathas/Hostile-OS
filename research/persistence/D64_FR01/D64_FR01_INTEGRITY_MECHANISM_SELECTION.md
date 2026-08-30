# D64/FR01 integrity mechanism selection — 2026-08-30

Status: MECHANISM SELECTION BEFORE PREREGISTRATION / NO SCIENCE EXECUTION
Parent: D64/PR01 clean-restart persistence
Target: deterministic faulted durable-media recovery

## Candidate record payload

Preserve PR01's durable meaning and add a 32-bit durable sequence. Candidate payload is 24 bytes:

- bytes0..3: magic `H4F1`;
- byte4: durable identity;
- byte5: durable value;
- byte6: last activity epoch;
- byte7: last resource epoch;
- bytes8..15: historical handle/currentness negative-control scalars;
- bytes16..17: marker `0x1234`;
- byte18: record version `1`;
- byte19: reserved `0`;
- bytes20..23: little-endian durable sequence.

The integrity mechanism is additional to those 24 bytes.

## Mechanisms compared

### A. Per-byte complement copy + commit marker

Layout: 24-byte payload + 24-byte complement + 4-byte commit = 52 bytes.

Simple tear and single-byte corruption pressure: all rejected.

Defect: coherent mutation of one payload byte and the corresponding complement byte remains valid. The representation doubles payload storage and still does not independently summarize the record.

Disposition: rejected on Pareto pressure.

### B. Additive 16-bit checksum + commit marker

Layout: 24-byte payload + 2-byte sum + 4-byte commit = 30 bytes.

Simple tear and single-byte corruption pressure: all rejected.

Defect: balanced two-byte corruption is invisible. Example: increment durable identity byte and decrement durable value byte; the sum remains unchanged and the record validates.

Ten such collision examples were found immediately in the pressure search. The corresponding CRC16 record rejected each tested corruption.

Disposition: rejected because it costs the same two integrity bytes as CRC16 while admitting a simple structured corruption family.

### C. CRC-16/CCITT-FALSE + commit marker

Parameters:
- polynomial `0x1021`;
- initial value `0xFFFF`;
- no reflection;
- no final xor.

Layout: 24-byte payload + 2-byte CRC + 4-byte commit = 30 bytes.

Pressure results:
- all byte-boundary zero-tail tears rejected;
- all tested single-byte corruptions rejected;
- payload mutation with stale CRC rejected;
- all exhaustively tested contiguous burst flips of length 1..16 bits over the 24-byte payload rejected;
- tested balanced two-byte mutations that collide under additive sum were rejected.

This is an integrity/error-detection mechanism only. It is not cryptographic authenticity and is not presented as one.

Disposition: selected.

## Selected record

Total logical durable record: **30 bytes**.

| Offset | Meaning |
|---|---|
| 0..23 | durable payload |
| 24..25 | CRC16/CCITT-FALSE over bytes0..23 |
| 26..29 | commit marker ASCII `CMIT` |
| 30..511 | zero |

The commit marker is checked separately from the CRC. A record is valid only if magic/version/declared marker fields, CRC, and commit marker all validate.

## Two-sector rule

Use two independent sectors:
- record A: BIOS sector18 / zero-based LBA17;
- record B: BIOS sector19 / zero-based LBA18.

The current 8 KiB stage2 occupies sectors2..17, so both durable sectors lie outside the loader extent.

## Sequence rule for FR01

FR01 tests only small non-wrapping sequences `1`, `2`, and `3`.

If both records are valid:
- larger sequence wins;
- equal sequence + identical logical record is equivalent and may select A;
- equal sequence + different durable payload is ambiguous and fails closed.

Sequence wrap/order beyond this bounded range is explicitly not earned by FR01.

## Negative controls retained

The experiment must contain at least:
- a naive highest-sequence selector that ignores integrity/commit validity and accepts an invalid higher-sequence B fixture;
- a checksum-collision fixture that would pass the rejected additive-sum design but is rejected by CRC16;
- a stale/missing commit fixture;
- deterministic torn-record fixtures.

## Authority ceiling

This selection only chooses the mechanism to test. It establishes no durable-recovery science by itself and no physical power-fail guarantee.
