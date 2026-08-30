# Post-C003 Stage-2 Loader Qualification Result — 2026-08-30

**Disposition:** PASS / INFRASTRUCTURE QUALIFIED
**Scientific campaign effect:** none
**Architecture promotion:** none

## Controlling spec

`QUALIFICATION_SPEC.md` was sealed before implementation at Git commit `e8f3e9f` (`Preregister post-C003 stage2 loader qualification`).

## Controlling run

Run: `20260830T041300Z_stage2_loader_01`

QEMU:
- PID: `26032`
- status: `COMPLETED`
- exit: `33`
- start: `2026-08-30T04:12:37.298453+00:00`
- end: `2026-08-30T04:12:37.992189+00:00`
- timeout ceiling: 5 seconds

Exact trace:

```text
S1_OK
S2_OK
```

QEMU stdout/stderr were empty.

## Qualified layout

Using the already-established 1,474,560-byte raw floppy image:

- sector 1 / zero-based 0: 512-byte stage 1;
- sectors 2–9 / zero-based 1–8: exactly eight stage-2 sectors, 4,096 on-disk bytes;
- stage-2 load address: physical `0x8000`;
- BIOS read: CHS 0/0/2, count 8;
- sector 10 / zero-based 9: reserved durable sector;
- no stage-2 read crosses the first-track boundary.

Static readback of stage 1 confirmed:

- `BX=0x8000`;
- `AH=0x02` BIOS read;
- `AL=0x08` sectors;
- `CL=0x02` first stage-2 sector;
- `INT 13h` transport;
- far jump to `0000:8000` after success.

BIOS INT 13h remains platform/firmware transport evidence only.

## Size and disk checks

- stage 1: exactly 512 bytes;
- stage-1 signature: `55aa`;
- stage-2 linked payload: 34 bytes in this qualification witness;
- stage-2 padded on-disk extent: exactly 4,096 bytes;
- full disk: exactly 1,474,560 bytes;
- durable sector after execution: 512 zero bytes; nonzero byte count 0.

## Source hashes

- stage1.S: `56b655c6fcf5c4910699fc080f268ebaca442cf92299d192cf9d197195d8e9e3`
- stage1.ld: `e5da57aefb8ff22b1c858e7372bab49c29d8cd45d83650b53664e44c51a6a3fa`
- stage2.S: `f529c6f252feee338eee3e594cf914077fa622f8df85f5fb4cd3a88ddc0a5b87`
- stage2.ld: `8612b6e066d9db58d50b5051765887717e03c230bc0a862621ecfe50f6ab96a9`
- launcher: `a753e00e2cf02ddd63afad8cf30f5905390057f0b97cbc286cd26136b81e8b8f`

## Artifact hashes

- stage1.bin: `f31804d49960ba1256f2a073193d38b1b65adea5f70cccc565a3dfad5284bd33`
- stage2.raw.bin: `83970875c85a0b5883d5ff991e4c58c49309de7c8ec45f19211ffd0867133d59`
- stage2.padded.bin: `30eb88d9e9f4916f4ba688f41102af12a13ad317aefe0a6c42e9a9fa6d7bff15`
- disk.img: `4d0e3cfde7b9f1873cc83c98f4fe90b90fbf1f63f4b95937728e88e89ed3d3f5`
- debugcon: `561079a4eb5adf4e956a8035384e44968023dd09f5e03dcd4a6a2ff6613251a8`
- qualification_result.json: `1ae2712826a37b1acd0b5d7ce7f7410fbe62d6d3deb4a7183b4d42a48aa0e94a`

## Qualified consequence

The local LLVM/QEMU path can boot a 512-byte stage 1 from the raw floppy, use BIOS disk transport to load a fixed eight-sector stage 2 into `0x8000`, and transfer control to that stage 2 under the exact first-track layout proposed for post-C003 integration.

This qualifies the **evidence envelope only**. It does not prove any HOSTILE-OS integrated mechanism, persistence behavior, scheduler/process architecture, or final layout outside this experiment.

## Gate effect

The post-C003 integration plan may now fix this layout without treating multi-sector loading as an unverified dependency:

`STAGE1_SECTOR=1 / STAGE2_SECTORS=2..9 / STAGE2_BYTES=4096 / LOAD=0x8000 / DURABLE_SECTOR=10`
