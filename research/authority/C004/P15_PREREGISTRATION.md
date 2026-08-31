# C004/P15 preregistration — explicit authority-record initialization on reuse

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P14 CLOSED PASS

## Question

When a protected authority record is released and reused for a different caller, can the new caller inherit operation rights left in the old record if reuse does not explicitly initialize all authority-bearing fields?

## Fixture
One reusable authority record initially belongs to B with WRITE-only rights2, generation1. X begins7E.

## Good reuse
Trusted fixture releases B, clears owner+rights, advances generation to2, and allocates the record to C with intended READ-only rights1. Trusted execution context then becomes C.
- record rights ->01/gen02;
- C WRITE55 -> U; X remains7E.

## Bad reuse control
Reset fixture. Release clears owner but leaves old rights2, generation advances, then allocation changes only owner to C. Trusted context becomes C.
- record rights remains02/gen02;
- C WRITE55 -> W; X becomes55.

## Ceiling
If observed, P15 earns explicit initialization of authority-bearing state on record reuse. It does not prescribe a struct/object or zero-fill strategy generally.
