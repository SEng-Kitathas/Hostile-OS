# Post-C003 Stage-2 Loader Qualification Spec — 2026-08-30

**Class:** infrastructure qualification, not HOSTILE-OS scientific campaign evidence
**Purpose:** qualify the fixed multi-sector evidence envelope proposed by the post-C003 integration plan
**Architecture promotion:** none

## Fixed disk geometry and layout

Use a 1,474,560-byte raw floppy image, matching the already-qualified P04 raw-floppy size.

At 512 bytes/sector this is 2,880 sectors. The qualification uses only the first track and does not cross a CHS track boundary.

- BIOS sector 1 / zero-based sector 0: 512-byte stage-1 boot loader
- BIOS sectors 2–9 / zero-based sectors 1–8: fixed eight-sector stage 2, exactly 4,096 bytes on disk
- BIOS sector 10 / zero-based sector 9: reserved durable sector, untouched by this qualification
- remaining image bytes: zero

## Stage 1 contract

Stage 1 must:

1. run at real-mode boot address 0x7c00;
2. preserve BIOS boot drive from DL;
3. load exactly 8 contiguous sectors starting at CHS 0/0/2 into physical 0x8000 using BIOS INT 13h AH=02h;
4. not load across a track boundary;
5. print exactly `S1_OK` after successful read;
6. transfer control to 0000:8000;
7. print `S1_FAIL` and take the failure debug-exit path if BIOS reports carry/failure;
8. remain exactly 512 bytes with boot signature 55aa.

BIOS INT 13h is platform/firmware transport evidence only. It is not HOSTILE-OS storage architecture.

## Stage 2 contract

Stage 2 must:

1. link for address 0x8000;
2. fit within 4,096 bytes;
3. print exactly `S2_OK`;
4. exit QEMU through the existing isa-debug-exit success value producing host exit code 33;
5. require no host-side state mutation after boot.

## Harness contract

The host may build, pad stage 2 to exactly 4,096 on-disk bytes, construct the raw floppy image, launch QEMU, collect debug output, and hash artifacts.

The host must not synthesize `S1_OK` or `S2_OK`, alter guest memory after boot, or choose the stage-2 entry point after execution starts.

## Exact success observation

```text
S1_OK
S2_OK
```

Success additionally requires:

- QEMU status completed;
- QEMU exit code 33;
- stage-1 size 512 and signature 55aa;
- stage-2 linked binary payload <= 4,096 bytes and padded disk extent exactly 4,096 bytes;
- durable sector remains all zero;
- source/run hashes captured.

A build/link/launcher defect is an infrastructure scar, not HOSTILE-OS science.
