# C005/P20 preregistration — hard-stop adversarial release-provenance challenge

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P19 CLOSED PASS
Campaign rule: **P20 IS THE C005 HARD STOP**
Target-shaped execution surface: H1 QEMU proxy (`pc-q35-11.1`, `phenom`, 2 vCPU, 4096 MiB, TCG, no network)

## Question

At the end of C005, can an untrusted second CPU release another CPU's current exclusion claim merely by supplying the owner's identity, or is actual CPU provenance independently load-bearing for release?

## Fixture

BSP reads its local APIC ID (expected00), atomically acquires one shared claim, records owner=BSP-ID, and remains inside the protected region.

AP reads its own local APIC ID (expected01) but supplies an untrusted claimed owner ID00.

## Bad control

Release path trusts the AP-supplied claimed owner. Because claim00 matches recorded owner00, it clears the held byte. AP then atomically acquires while BSP still believes it owns the region.

Expected:
- `BAD_CLAIMED_ID=00`;
- `BAD_ACTUAL_ID=01`;
- `BAD_RELEASE=1`;
- `BAD_AP_ACQUIRE=1`;
- `BAD_DOUBLE_OWNER=1`.

## Good witness

Reset with BSP owning again. AP again claims owner00, but release derives actual caller CPU from the local APIC ID register and compares actual01 against owner00.

Expected:
- release denied (`GOOD_RELEASE=0`);
- AP cannot acquire while BSP remains active (`GOOD_AP_ACQUIRE_WHILE=0`);
- no double ownership (`GOOD_DOUBLE_OWNER=0`);
- after BSP explicitly releases, AP can acquire (`GOOD_AP_ACQUIRE_AFTER=1`).

## Campaign stop

Regardless of outcome, C005 stops after this pass. **No C005/P21 may be created or run.**

## Ceiling

PASS earns only `CLAIMED_OWNER_ID != TRUSTED_RELEASE_PROVENANCE` for this tested x86 APIC-backed two-CPU boundary. Local APIC ID is an enforcement witness, not universal architecture. H1 QEMU proxy PASS is not H1 physical-hardware qualification.
