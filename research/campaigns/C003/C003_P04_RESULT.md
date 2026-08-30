# C003 / P04 â€” durable bytes across real QEMU restart / runtime binding expiry

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P04 of 20
**Architecture promotion:** NONE
**P05 earned:** YES

## Question

Can a bounded durable record survive termination of one QEMU process and be recovered by a second fresh QEMU process while runtime access-currentness resets to expired volatile state and becomes current only after an explicit fresh rebind?

## Preregistered machine boundary

- standard 1.44 MiB raw floppy image;
- sector 1: freestanding boot image;
- sector 2: bounded durable record;
- two separate QEMU 11.1.0 processes;
- BIOS `int 13h` sector transport used only as the declared block-transport mechanism for this persistence-semantic discriminator;
- volatile `runtime_access_current` exists only in boot-loaded RAM and is not stored in the durable sector.

## Durable run

Run: `20260829T212800Z_p04_restart_persistence_01`

Boot 1 observation:

```text
BOOT1_INIT=PASS
```

Boot 2 observation from a separate fresh QEMU process:

```text
BOOT2_DURABLE=PASS
BOOT2_STALE=EXPIRED
BOOT2_REBIND=PASS
```

Evaluator version: `C003-P04-restart-persistence-v1`

Evaluator result: `passed=true`

Both QEMU launches:
- expected exit: `33`
- observed exit: `33`
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Exact source hashes

- mechanism: `84d7984baddf4b0f379f6b58075db3260da0e1f5698b64bffc6d6e58a265c4ff`
- fixture assembly: `b23e6f53723648d8d3cafa8b1122db46202237fe85cc8b8f88ca8d16f17bfa40`
- fixture JSON: `de11b534b3e3225e1513244561d48744d2b4842c7fdf27c5b6c11d58582eaf89`
- linker: `1d5859b203e664be100f2cb1ecc4a1a28345be28bc6cdb6d527de4f905869381`
- evaluator: `4bcd4f2ad66fa2812f8bb4ddd01354b4fa2ffb2bcbccd894330cbe0f61aec56d`
- launcher: `9c8da0175ff560b373c49a9394ea451e8d13de87e7a7b93aeb050bd3b7328c3b`

## Exact run artifacts

- boot image: 512 bytes
- boot image SHA-256: `a8aa64e2ef64afc720b55c1e3add47342174c97f0f530825b72f921ea5a6a8f6`
- initial disk SHA-256: `e2b1b2045b61b1b66f5a7ded3d96d383103dbba2f9b7fc1b9ef10c83d440ae68`
- disk after Boot 1 SHA-256: `43fd2620dbddc07c0bada42a692a2f7b04971e08013bb74c8283dcba33d76a1c`
- disk after Boot 2 SHA-256: `43fd2620dbddc07c0bada42a692a2f7b04971e08013bb74c8283dcba33d76a1c`
- Boot 1 debug SHA-256: `d34ab35e60129202d357716469c00ea41047d3fe2d33500348a1151fc82da4cc`
- Boot 2 debug SHA-256: `a9659b82194115192e2a9b617701542d8390c9484964146c19c768b778684d61`
- durable sector SHA-256: `2905e5de392fe14550ae6c79d82f521f17e97552f9e280b171c79a0361cbd669`
- evaluation SHA-256: `468160b72fcc48ccec05040320adcc69e1b677ada9f4bca66911de14b3c51672`
- receipt SHA-256: `6b1ca167850dae9b8cbd1e8aa0f862b942216731bd69bc4959e5bfb7c1f2952d`

Independent post-run hash crosscheck matched the receipt for the boot image, final disk, both debug artifacts, durable sector, and evaluator artifact.

Sector 2 began exactly:

```text
48 4f 53 34 52 5a 00 00 00 00 00 00 00 00 00 00
```

The first six bytes are `HOS4RZ`; every byte from offset 6 through 511 was zero.

## Corroborative process-boundary replay

A concurrently created replay, `20260829T212815Z_p04_restart_persistence_pid_02`, was not assumed authoritative by origin. It was audited after creation.

It used the same mechanism, fixture, linker, and evaluator hashes as the primary run and reproduced the same boot image hash, final disk hash, Boot 1/Boot 2 debug hashes, durable-sector hash, and evaluator PASS.

Its Python launcher added explicit process receipts:

- Boot 1 PID: `13408`, exit `33`;
- Boot 1 ended: `2026-08-29T21:28:13.119104+00:00`;
- Boot 2 PID: `28052`, exit `33`;
- Boot 2 started: `2026-08-29T21:28:13.142222+00:00`;
- `boot1_completed_before_boot2_started=true`;
- `numeric_pids_distinct=true`.

Corroborative PID receipt SHA-256: `3a566b5889344ee3886a2eece82a7c25249fa3f2d6c452bb778e8e4e44656c2c`.

This replay strengthens the process-boundary evidence but does not raise the authority ceiling or change the scientific consequence.
## Qualified consequence

For this bounded clean-restart fixture:

- durable identity `R` and payload byte `0x5a` survived complete termination of one QEMU process and launch of another;
- the disk hash changed after Boot 1 wrote the record;
- the disk hash was unchanged by Boot 2, which only observed durable bytes and changed volatile RAM state;
- fresh Boot 2 began with `runtime_access_current == 0` despite durable identity survival;
- runtime access became current only after the explicit in-guest rebind;
- Python file I/O, Python object lifetime, Python serialization, and Python default initialization are not necessary to realize this tested clean-restart distinction in the guest mechanism.

This is an absence-of-necessity result for the tested slice, not a claim about the exact lost C002 implementation.

## What P04 does not earn

P04 does not establish:

- crash consistency;
- interrupted/partial update recovery;
- partial-sector atomicity;
- physical-device flush/timing semantics;
- filesystem semantics;
- general serialization;
- a storage subsystem architecture;
- architecture promotion.

## P05 discriminator earned by P04

P04 proves only clean completed persistence. The next unearned distinction is recovery when a durable update is **started but not committed** before process termination.

P05 SHALL therefore pressure the smallest explicit durable-currentness mechanism that distinguishes:

- a previously committed durable generation that remains recoverable;
- a newer tentative generation whose data bytes exist but whose commit state was never completed;
- a subsequent completed generation that may become current.

The bounded discriminator should compare a naive highest-generation reader against a commit-qualified reader. A simulated interruption must occur at an explicit deterministic boundary after tentative bytes are durable but before the commit marker is written. Recovery must prefer the last committed generation rather than silently treating the newest bytes as current.

This is a persistent-currentness discriminator, not permission to introduce a filesystem, journal manager, transaction subsystem, or general crash-consistency architecture.

P06-P20 remain unwritten.


## P05 seam adjudication addendum

The first concurrent draft of this result proposed interrupted/partial durable-update recovery as P05. That branch is **REJECTED / NOT EARNED** for the current campaign frontier.

Reason: the recovered C002 closeout explicitly states that C002 did **not** earn `crash/partial-write recovery`. C003/P04 also preregistered crash consistency and partial-write recovery as non-claims. Promoting that excluded area directly into the next pass would widen beyond the inherited workload instead of letting P04 earn its next discriminator.

The crash-currentness proposal is preserved as a revisit candidate, not deleted, but it does not control P05.

The next inherited whole-P01 obligations still directly unembodied after P04 include:
- asynchronous/event consequence;
- idle/no-useful-work behavior;
- bounded missing-operation failure.

The highest anti-toy pressure among these is asynchronous event + idle wake because it directly removes host scheduling/timing and interpreter-continuation assumptions from a consequence path.

**Adopted P05 discriminator:** guest-installed real-mode virtual PIT/PIC IRQ0 handler under standard QEMU; guest enters `HLT` with no useful work pending; an actual virtual timer interrupt must create explicit event state and release the waiting activity. The launcher/fixture may not call the wake path. Timeout remains UNKNOWN. This is QEMU virtual-hardware evidence only and does not claim physical device timing or scheduler architecture.

P06-P20 remain unwritten.

## Evidence-authority correction

The earlier wording in this result called `20260829T212800Z_p04_restart_persistence_01` the primary durable run and the PID-receipt replay merely corroborative. That authority ordering is corrected here.

- `20260829T212800Z_p04_restart_persistence_01` originated from an unverified concurrent invoker and did not record PID/start/end process boundaries. It remains **corroborating evidence only**.
- `20260829T212815Z_p04_restart_persistence_pid_02` was launched under the controlled execution path with explicit PIDs, argv, start/end timestamps, terminal exits, strict Boot1-before-Boot2 ordering, independent evaluator readback, and post-inspection. It is the **controlling qualified P04 consequence**.

The observed bytes, boot traces, disk hashes, and evaluator result are identical between the two runs, so this authority correction changes lineage/posture, not the scientific observation.
