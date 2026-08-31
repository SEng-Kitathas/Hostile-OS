# C005/P18 preregistration — durable meaning versus transient concurrency ownership across restart

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P17 CLOSED PASS
Cross-domain parent: d64 restart rule `durable meaning -> validate/currentness -> reconstruct fresh relations`

## Question

If a durable resource record is written while runtime concurrency state says `held=1/users=1`, should a fresh boot reconstruct those transient ownership/participation bits as live current state?

## Two-boot fixture

Boot1 writes one durable record containing:
- resource meaning/value7E;
- resource generation05;
- historical runtime concurrency fields held1/users1/concurrency-epoch1.
Boot1 exits cleanly.

Boot2 is a fresh QEMU process on the same disk, with no host write between boots.

## Bad reconstruction

Treat durable held1/users1/epoch1 as live runtime concurrency state. A fresh claimant cannot acquire (`BAD_FRESH_ACQUIRE=0`) and reclaim remains blocked by a user that no longer exists (`BAD_PHANTOM_USER=1`).

## Good reconstruction

Validate durable resource meaning/value7E/generation05, but reconstruct fresh runtime concurrency state held0/users0 and advance concurrency epoch1->2. A fresh claimant acquires successfully (`GOOD_FRESH_ACQUIRE=1`), resource value remains7E, and no phantom user exists.

## Ceiling

PASS earns only `DURABLE_RESOURCE_MEANING != DURABLE_RUNTIME_CONCURRENCY_OWNERSHIP`. Fresh runtime ownership/participation must be reconstructed rather than blindly reloaded when the owning CPUs/executions did not survive restart. It does not prescribe all restart policy or say no concurrency metadata can ever be durable.
