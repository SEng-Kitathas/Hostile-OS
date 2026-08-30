# D64 / ARB01 — overlapping preregistration supersession

**Disposition:** ARB01 CONTROLLING BEFORE EXECUTION
**Date:** 2026-08-30

Three preregistrations were created concurrently for the same activity-lifecycle / binding-state composition seam:

- `D64/AR01` at `55578e4f99c440a9767ed749815085b041ec5169`
- `D64/AB01` at `1f8d0b12d02259342e45af92757ff6446b80dead`
- `D64/ARB01` at `c7170dc018e463e6220bb7ce39e9018950e65754`

No AR01 or AB01 run directory exists and no guest execution occurred under either earlier preregistration.

ARB01 is the newest and most discriminating version. It preserves the shared D64 representation and adds two useful closure pressures absent or weaker in the earlier versions:

1. full 1,280-cell binding-generation reset is made observable through seeded tail residue at cell 1279;
2. separate resource namespace history is made observable by requiring resource generation/epoch preservation across activity rekey and stale/fresh direct-resource checks afterward.

Therefore:

- `AR01` is superseded before execution;
- `AB01` is superseded before execution;
- `ARB01` is the sole controlling preregistration for this seam;
- no scientific consequence attaches to the earlier preregistrations;
- their committed preregistration artifacts remain preserved as concurrency history and are not rewritten or deleted.

Any untracked implementation scratch created under AR01/AB01 is non-authoritative and must not be admitted as ARB01 evidence.

`D64_ARB01_CONTROLLING / AR01_SUPERSEDED_PRE_EXECUTION / AB01_SUPERSEDED_PRE_EXECUTION / NO_EARLIER_RUNS`
