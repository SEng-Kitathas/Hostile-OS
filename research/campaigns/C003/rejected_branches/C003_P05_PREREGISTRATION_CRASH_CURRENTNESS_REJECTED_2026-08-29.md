# C003 / P05 preregistration — tentative versus committed durable generation

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P05 of 20
**Earned by:** C003/P04 bounded clean-restart success
**Architecture promotion:** FORBIDDEN

## Why P05 exists

P04 established only clean completed persistence: durable identity/payload survived complete QEMU process restart while volatile runtime access-currentness expired and required explicit rebind.

P04 did not test an update whose data bytes become durable but whose commit/currentness boundary is not completed before process termination.

The next earned question is therefore persistent currentness, not a filesystem or journal subsystem.

## P05 question

Can a minimal explicit commit-qualified generation distinguish the last committed durable state from a newer tentative generation after a deterministic interrupted-update boundary, while a naive highest-generation reader accepts the tentative state?

## Machine boundary

- standard 1.44 MiB raw floppy image;
- sector 1: one-sector freestanding boot image;
- sector 2: fixed durable slot A;
- sector 3: fixed durable slot B;
- four separate QEMU 11.1.0 process launches on the same raw image;
- BIOS `int 13h` sector transport is declared transport only;
- one-byte generation, one-byte payload, one-byte commit marker;
- no heap/dynamic allocation;
- no filesystem, journal manager, transaction subsystem, process, scheduler, or service primitive.

## Record format

Each slot is one 512-byte sector.

Bytes:
- 0..3: ASCII `HOS5`;
- 4: generation byte;
- 5: payload byte;
- 6: commit marker;
- 7..511: zero in this bounded fixture.

Committed marker: `0xc3`.
Tentative marker: `0x00`.

Slot A baseline:
- generation `1`;
- payload `A`;
- committed `0xc3`.

Slot B update:
- generation `2`;
- payload `B`;
- initially tentative `0x00`.

## Boot sequence

### Boot 1 — establish baseline

If slot A is absent, write committed generation 1 / payload A to sector 2 and emit exactly:

```text
BOOT1_BASE=A
```

Then exit deterministically.

### Boot 2 — deterministic interrupted-update boundary

With committed A present and slot B absent:

1. write generation 2 / payload B to sector 3 with commit marker `0x00`;
2. wait for the BIOS sector-write call to return;
3. emit exactly:

```text
BOOT2_TENTATIVE=B
```

4. terminate the QEMU process **without writing the commit marker**.

This is a deterministic semantic interruption after tentative bytes are durable according to the declared BIOS-write boundary. It is not a claim of sudden-power-loss timing, device-cache flush behavior, or partial-sector atomicity.

### Boot 3 — recover then complete

With committed A and tentative B present:

1. naive highest-generation reader ignores commit state and therefore selects B;
2. commit-qualified reader selects the highest generation whose commit marker is `0xc3`, therefore A;
3. emit exactly:

```text
BOOT3_NAIVE=B
BOOT3_QUALIFIED=A
```

4. set slot B commit marker to `0xc3` and rewrite sector 3;
5. emit exactly:

```text
BOOT3_COMMIT_B=PASS
```

6. exit deterministically.

### Boot 4 — recover completed update

With both slots committed, commit-qualified reader must choose generation 2 / payload B and emit exactly:

```text
BOOT4_QUALIFIED=B
```

Then exit deterministically.

## Independent evaluator

The evaluator SHALL consume all four debug artifacts plus independently extracted slot sectors after the relevant boots.

Required exact debug observations:

Boot 1:
```text
BOOT1_BASE=A
```

Boot 2:
```text
BOOT2_TENTATIVE=B
```

Boot 3:
```text
BOOT3_NAIVE=B
BOOT3_QUALIFIED=A
BOOT3_COMMIT_B=PASS
```

Boot 4:
```text
BOOT4_QUALIFIED=B
```

Required durable observations:

After Boot 2:
- slot A prefix = `48 4f 53 35 01 41 c3`;
- slot B prefix = `48 4f 53 35 02 42 00`.

After Boot 3 and Boot 4:
- slot A remains `48 4f 53 35 01 41 c3`;
- slot B prefix = `48 4f 53 35 02 42 c3`.

The evaluator SHALL verify the remainder of each bounded slot is zero.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- 512-byte boot image/signature/hash;
- initial disk hash;
- separate QEMU PID/start/end/exit receipt for all four boots;
- disk hash after each boot;
- debug artifact/hash for each boot;
- slot extracts/hashes after Boot 2 and after Boot 3/4;
- evaluator artifact/hash;
- stdout/stderr for builds, every QEMU process, and evaluator;
- post-run non-mutating verification.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P05 succeeds for this bounded discriminator only if:

- all four QEMU processes terminate with the preregistered deterministic exit;
- Boot 2 leaves generation 2 physically present but tentative;
- Boot 3 naive reader selects B while commit-qualified reader selects A;
- Boot 3 then commits B;
- Boot 4 commit-qualified reader selects B;
- independent sector inspection and evaluator exactly match the preregistered matrix.

A failure is useful if it exposes additional durable state, ordering, completion, or recovery distinctions.

## Authority ceiling

Success would establish only that a tiny explicit commit-qualified generation mechanism is sufficient for this deterministic interrupted-update fixture under QEMU/raw-floppy/BIOS transport.

It would **not** establish:
- real sudden-power-loss crash consistency;
- partial-sector atomicity;
- device-cache flush ordering;
- torn-write recovery;
- filesystem/journal correctness;
- transaction architecture;
- physical storage behavior;
- architecture promotion.

## Stop rule

Reconcile P05 before deriving P06. P06-P20 remain unwritten until P05 consequence earns the next discriminator.
