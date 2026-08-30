# C003 / P04 preregistration — durable bytes across real QEMU restart / runtime binding expiry

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P04 of 20
**Earned by:** C003/P03 bounded success
**Architecture promotion:** FORBIDDEN

## Why P04 exists

P01-P03 pressured volatile currentness, identity-bound membership history, and coherent mutation boundaries. The largest untouched whole-P01 obligation is persistent bytes across restart.

C002's surviving result distinguishes:
- durable resource identity/bytes that may survive restart;
- runtime access currentness that must expire;
- fresh qualified rebind after clean restart;
- stale runtime bindings that must not be hydrated as current merely because durable identity survives.

## P04 question

Can a bounded durable record survive termination of one QEMU process and be recovered by a second fresh QEMU process while runtime access-currentness resets to expired volatile state and becomes current only after an explicit fresh rebind?

## Machine boundary

This pass uses a standard 1.44 MiB raw floppy image and two separate invocations of standard QEMU 11.1.0.

The guest uses BIOS `int 13h` sector read/write solely as the explicitly declared block-transport mechanism for this persistence-semantic discriminator. This pass does **not** claim to embody a final storage driver or prove a BIOS-based target architecture. Device-driver replacement remains outside P04.

## Durable record

Sector 2 of the raw image is the bounded durable record.

Expected first bytes after initialization:

- bytes 0..3: ASCII `HOS4` magic;
- byte 4: durable resource identity `R`;
- byte 5: payload `0x5a`;
- remaining bytes: zero for this bounded fixture.

The boot sector itself is sector 1.

## Volatile state

`runtime_access_current` exists only in boot-sector-loaded RAM and is initialized to zero in the image.

It SHALL NOT be stored in the durable sector.

## Boot 1

On an initially zero durable sector:

1. guest reads sector 2;
2. if no `HOS4` record exists, guest zeroes the sector buffer;
3. guest writes `HOS4`, identity `R`, payload `0x5a`;
4. guest writes sector 2;
5. guest emits exactly:

```text
BOOT1_INIT=PASS
```

6. guest exits through deterministic `isa-debug-exit`.

The first QEMU process must terminate before Boot 2 is launched.

## Boot 2

A second fresh QEMU process boots from the same raw image.

It SHALL:

1. read sector 2;
2. verify `HOS4`, identity `R`, payload `0x5a`;
3. emit `BOOT2_DURABLE=PASS` only if durable bytes survived;
4. verify `runtime_access_current == 0` from fresh volatile boot state;
5. emit `BOOT2_STALE=EXPIRED` only if runtime access did not survive as current;
6. set `runtime_access_current = 1` as the explicit fresh rebind;
7. emit `BOOT2_REBIND=PASS` only after that state change;
8. exit deterministically.

## Independent evaluator

The evaluator SHALL inspect:

- Boot 1 debug artifact;
- Boot 2 debug artifact;
- final raw disk image bytes at sector 2;
- exact disk/image hashes recorded by the launcher.

Expected observations:

Boot 1:
```text
BOOT1_INIT=PASS
```

Boot 2:
```text
BOOT2_DURABLE=PASS
BOOT2_STALE=EXPIRED
BOOT2_REBIND=PASS
```

Sector 2 first six bytes: `48 4f 53 34 52 5a` (`HOS4RZ` where `Z` is byte `0x5a`).

## Evidence contract

Mechanism, fixture/image initialization, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- 512-byte boot image/signature/hash;
- initial disk hash;
- first-QEMU exact exit and debug hash;
- disk hash after first process exit;
- second-QEMU distinct launch/exit and debug hash;
- disk hash after second process exit;
- evaluator artifact/hash;
- durable sector extract/hash;
- stdout/stderr captures for both QEMU runs and evaluator;
- durable receipt;
- post-run non-mutating inspection.

Timeout/ambiguous process state = UNKNOWN.

## Success / failure criterion

P04 succeeds only if both separate QEMU processes complete, both exact debug contracts match, the final durable sector bytes match independently, and runtime access is observed expired before the explicit second-boot rebind.

A failure may expose a missing persistence distinction, transport assumption, flush/completion issue, or representation cost.

## Authority ceiling

Success would establish only bounded clean-restart persistence semantics under QEMU/raw-floppy/BIOS transport. It would not establish crash consistency, partial-write recovery, filesystem semantics, physical-device timing, general serialization, a storage subsystem architecture, or architecture promotion.

## Stop rule

Reconcile P04 before deriving P05. P05-P20 remain unwritten until P04 consequence earns the next discriminator.
