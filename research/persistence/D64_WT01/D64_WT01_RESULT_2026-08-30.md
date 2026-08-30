# D64/WT01 result — controlled guest-write termination boundary + sealed FR01 recovery

Date: 2026-08-30
Status: **CLOSED PASS**
Architecture posture entering/leaving experiment: `INTEGRATED_SHADOW_CANDIDATE`
Preregistration commit: `10b05576e68c136c9d4f6c098fba41933312bcac`
Implementation seal commit: `93d2c1b6d5d204d224ad8a1f0edb1871a075326a`
Controlling run: `runs/20260830T225457Z_d64_wt01_01`

## Question

When a real guest BIOS INT13 one-sector durable write is interrupted by force-terminating QEMU while the guest is stopped immediately before versus immediately after the first observable backing-sector transition, do the persisted bytes remain the corresponding whole-old/whole-new state, and does the **unchanged sealed FR01 reader** recover the durable meaning represented by those bytes?

WT01 does not attempt to stop inside QEMU's host-side device-emulation action and does not claim a torn actual write.

## Pre-science implementation history

Two implementation defects were found before any WT01 QEMU science execution and are retained in `D64_WT01_IMPLEMENTATION_SCARS.md`:

1. assembly debug strings contained literal source newlines; compile emitted warnings; repaired before any QEMU science run;
2. static checker searched for the wrong literal stopped-guard text even though the launcher already asserted `ctx['stopped'] is True`; checker repaired before science.

After repair:
- Python syntax: PASS;
- writer compile/link: warning-free;
- stage1: 512 bytes;
- writer stage2 raw: 197 bytes;
- pre-science static smoke: 16/16 PASS.

## Controlling provenance

The controlling run recorded Git HEAD:

`93d2c1b6d5d204d224ad8a1f0edb1871a075326a`

All **15** run-local controlling inputs were snapshotted before build/execution and hash-verified:

- stage1 source/linker;
- writer source/linker;
- launcher;
- evaluator;
- static checker;
- independent audit;
- WT01 preregistration;
- interrupted-write plan;
- IW00 feasibility result;
- FR01 result/adoption;
- sealed FR01 controlling stage1;
- sealed FR01 controlling padded stage2.

No controlling input hash mismatch was found.

## Writer

The writer is a minimal freestanding guest using the qualified 8 KiB loader envelope.

It:
- obtains boot drive from qualified stage1 saved byte at physical `0x7c4b`;
- zeroes a full 512-byte guest buffer;
- copies exactly one 30-byte FR01 sequence-2/value-72 record into it;
- writes only B at LBA18 / CHS C0/H1/S1 using BIOS INT13 AH=03;
- exposes `writer_int13_site` on the exact `CD 13` instruction;
- emits `WRITE_READY` before the call and `WRITE_RETURN` only after a successful return.

Controlling writer symbol:
- `writer_int13_site = 0x8042`;
- raw stage2 offset = 66;
- bytes at site = `cd13`.

Writer stage2 raw size: **197 bytes**.

## Campaign population

Total controlling QEMU processes: **45**.

- 5 calibration writer processes;
- 5 K0 writers + 5 sealed-FR01 recovery boots;
- 5 KPRE writers + 5 recovery boots;
- 5 KPOST writers + 5 recovery boots;
- 5 CLEAN writers + 5 recovery boots.

Calibration and forced-termination writers were terminated only while GDB had the guest stopped. Terminal process state was verified before disk inspection.

## Calibration result

Five fresh writer processes independently measured the first guest-instruction stop at which B differed from its initial all-zero sector.

All five observed:

- transition step `T = 547`;
- all inspected B states before T = exact ZERO;
- first changed B state at T = exact FULL seq2/value72 record;
- first changed B SHA-256 = `34daecb79d1fdff1b95748032898e999ed8d54e854ec8eb06451ad0343668e28`.

The zero-sector SHA-256 was:

`076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560`

`T=547` is a measured witness for this exact QEMU/BIOS/directsync campaign. It is **not** an architecture constant.

## Controlled termination results

### K0 — terminate before executing BIOS write

Population: 5/5.

Every writer terminal disk had:
- A unchanged;
- B exact ZERO.

Every sealed FR01 recovery boot:
- `COMPLETED` exit33;
- selected A;
- exposed durable value `71`;
- rejected historical handles;
- accepted fresh binding/resource handles with value71.

### KPRE — terminate at T-1

Population: 5/5.

After exactly 546 guest single-steps from the writer INT13 site:
- B remained exact ZERO;
- QEMU was force-terminated while guest stopped.

Every recovery boot selected A/value71 with the same stale/fresh handle consequence as K0.

### KPOST — terminate at T

Population: 5/5.

After exactly 547 guest single-steps:
- B was exact complete FULL seq2/value72;
- QEMU was force-terminated while guest stopped.

Every recovery boot:
- `COMPLETED` exit33;
- selected B;
- exposed durable value `72`;
- rejected historical handles;
- accepted fresh binding/resource handles with value72.

### CLEAN — normal writer return

Population: 5/5.

Every writer:
- `COMPLETED` exit33;
- trace exactly `S1_8K_OK`, `WRITE_READY`, `WRITE_RETURN`, `DONE`;
- B exact FULL seq2/value72.

Every recovery boot selected B/value72.

## Media-state result

Across all 20 controlled writer cases:

- A remained byte-identical to its initial valid seq1/value71 record;
- B was always one of exactly two states: `ZERO` or `FULL`;
- no controlling case produced `OTHER`;
- K0/KPRE -> ZERO;
- KPOST/CLEAN -> FULL.

Every recovery overlay copied the writer terminal disk and replaced only:
- LBA0 with sealed FR01 stage1;
- LBA1..16 with sealed FR01 padded stage2;
- LBA19 with fixture-label metadata.

A/B hashes were identical before and after every overlay.

The recovery mechanism therefore followed the **persisted bytes**, not the host's intended case class.

## Closure

Evaluator: **PASS / 12 checks**.

Static/source closure: **PASS / 16 checks**.

Independent audit: **PASS / 13 checks**.

All result booleans under checker `checks` are literal JSON booleans.

## Closure hashes

- campaign receipt: `6224fe28510313804a3e9332c5e83824579a9dbbab62d272fc3ff30a5f42d406`
- evaluation: `33fb48c728c2664061a84755556fc8cf09a9db0e38a5b6b420d2784934b104d0`
- static closure: `6086671ae33f1a43061f0612078af56a067ff7a855bb04a8af4371e231c77775`
- independent audit: `252eefcc3fb84d46496130f152d36779f6ee86d7f2874460716582483a5d5571`
- input manifest: `ba52cb21e2114a37067874fdc27a83f294156c8549b032ded5dc6304cc80a1b6`
- writer stage1: `feecbbfdea750fc26f401c0e8eeeabcdd70953036bd60e287368e987ac1ed97d`
- writer stage2 raw: `9a7fc87a3dd9d0484f1fd18fee9678dc1ff7013bcedc6dc699f426817dcf41b6`

## Earned consequence

At the tested QEMU i386 TCG + BIOS floppy + raw `cache=directsync` envelope:

> the actual guest durable-sector write has a repeatable guest-instruction observation boundary between whole-old and whole-complete-new backing states; force-terminating QEMU while the guest is stopped immediately before versus immediately after that observed transition preserves the corresponding whole state, and the unchanged sealed FR01 reader recovers the durable meaning represented by the bytes actually persisted.

WT01 therefore extends the durability chain from:

`host-constructed media-state recovery`

to:

`actual guest write -> controlled process termination at observed boundary -> persisted bytes -> unchanged recovery reader`.

## What WT01 does not earn

WT01 does **not** establish:
- interruption inside QEMU's host-side device action;
- an actual torn sector;
- physical power-loss semantics;
- physical disk or controller sector atomicity;
- cache behavior outside raw `cache=directsync`;
- multiple-sector ordering/commit protocol;
- write barriers/flush semantics;
- filesystem or general journal semantics;
- cryptographic authenticity;
- physical hardware qualification;
- final/canonical architecture.

The absence of `OTHER` in this campaign must not be promoted into a universal atomic-write claim.

## Next pressure implied by the result

The reader/selector and one-sector writer boundary are now separated cleanly enough that the next durability pressure should not manufacture a torn result.

Useful next choices include:
- observational wall-clock kill stress to discover whether QEMU can expose states not visible at guest-instruction boundaries;
- multi-sector ordering/commit pressure, where actual ordering between independent durable records becomes meaningful;
- physical-hardware write-interruption qualification at a later assurance gate.

Any wall-clock kill sweep must remain reliability/transport discovery unless separately preregistered as science.
