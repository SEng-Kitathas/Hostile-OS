# C005/P17 preregistration — same bounded version value versus same snapshot epoch

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P16 CLOSED PASS
Cross-domain parent: P11 version-validated snapshots

## Question

If a versioned snapshot uses a bounded version field, can enough completed writes cycle the version back to the reader's original even value and make a stale cross-era snapshot appear stable?

## Bad 8-bit version fixture

State begins version00, A11/B22. AP snapshots pre-version00 and A11, then pauses.

BSP performs exactly128 complete writer cycles, each advancing the 8-bit version by2 (odd during write, even after), so the version wraps back to00. Final pair is A33/B44.

AP resumes, reads B44 and post-version00. A naive P11 equality/even check sees pre00==post00 and accepts cross-era pair A11/B44.

Expected: `BAD_VERSION=00`, `BAD_ACCEPT=1`, `BAD_CROSS_ERA=1`.

## Good epoch+version witness

Reset with `(epoch,version)=(00,00)`. AP snapshots packed0000 and A11. BSP again performs128 complete writes; when the low version wraps00, it advances epoch00->01. Final packed state0100 and pair33/44.

AP's stale packed0000 check rejects (`GOOD_STALE_ACCEPT=0`). A fresh retry at0100 accepts33/44 (`GOOD_FRESH_ACCEPT=1`).

## Ceiling

PASS earns only `SAME_BOUNDED_VERSION_VALUE != SAME_SNAPSHOT_EPOCH` once wrap is reachable. A larger or epoch-extended token is one witness; no universal width, timestamp or version-counter architecture is prescribed.
