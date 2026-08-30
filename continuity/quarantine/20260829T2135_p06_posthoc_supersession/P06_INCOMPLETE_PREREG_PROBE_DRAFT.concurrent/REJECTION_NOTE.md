# Rejected P06 incomplete probe draft

**Date:** 2026-08-29
**Disposition:** PRESERVED / DO NOT EXECUTE AS C003/P06

This untracked probe draft implemented the first P06 preregistration committed at `463021d9b385f4a97f7bd314dd54ecc08285ea56`.

That preregistration was later found to be weaker than the discriminator explicitly earned by its parent P05 result `ae829292f384f89904f0ca3eef63ba122072ebc0`.

The draft tests a known operation followed by an unknown operation and checks only that the unknown operation leaves state unchanged. It does **not** test the load-bearing parent requirement that:

- the missing operation occurs first;
- a distinct later progress-capable activity still succeeds after local failure;
- an otherwise comparable global-failure-latch control blocks that same later progress.

No scientific P06 execution used this draft before supersession.

Use `C003_P06_PREREGISTRATION_SUPERSESSION_2026-08-29.md` for the active P06 contract.
