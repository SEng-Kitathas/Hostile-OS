# C005/P05 preregistration — same free value versus same acquisition opportunity

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P04 CLOSED PASS

## Question

If a reusable exclusion state is observed free, another CPU acquires and releases it, and the byte becomes free again, may a delayed claimant treat that as the same acquisition opportunity?

## Fixture

Represent one reusable claim as `(epoch, held)` packed into a16-bit word for the good witness. Initial state epoch0/held0.

BSP snapshots the initial opportunity before AP's intervening ownership cycle.

AP then acquires and releases once, advancing epoch on release. Final visible `held` is again0.

## Bad control

BSP validates only `held==0` after AP's complete acquire/release cycle and atomically sets held1. Because the held byte returned to0, the stale pre-cycle opportunity is accepted (`BAD_STALE_ACCEPT=1`).

## Good witness

BSP retains expected packed word epoch0/held0. AP's cycle ends at epoch1/held0. BSP performs atomic compare/exchange against its stale expected packed word.

Expected: comparison fails and stale claim is rejected (`GOOD_STALE_ACCEPT=0`, `GOOD_EPOCH=01`). A fresh claimant using epoch1/held0 then succeeds.

## Ceiling

PASS earns only `SAME_VISIBLE_FREE_VALUE != SAME_CURRENT_ACQUISITION_OPPORTUNITY` when reusable ownership can cycle between observation and claim. A version/epoch packed into the atomic comparison is one witness; no universal lock/version type is prescribed.
