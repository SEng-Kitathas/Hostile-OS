# D64 Stage-2 8 KiB Loader Qualification Result — 2026-08-30

**Disposition:** PASS / QUALIFIED INFRASTRUCTURE
**Scientific claim:** NONE
**Parent plan:** `research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md`
**Qualification spec commit:** `ca21370643b8526ce2d66b4de1f2aec2c78a008d`
**Architecture promotion:** NONE

## Purpose

Qualify a fixed first-track evidence envelope large enough for D64 resource-binding pressure without treating the earlier 4 KiB stage-2 limit as architecture law.

Qualified layout:

- BIOS sector 1: 512-byte stage 1;
- BIOS sectors 2..17: fixed 16-sector / 8,192-byte stage 2;
- stage-2 load range: `0x8000..0x9FFF`;
- BIOS sector 18 remains untouched zero;
- raw floppy image size: 1,474,560 bytes.

This is infrastructure qualification only.

## Attempt 1 engineering scar

Attempt identifier:

`20260830T052700Z_d64_stage2_8k_loader_01`

The launcher created the run directory and empty `inputs/` directory, then failed before input snapshot/manifest, compilation, or QEMU because it calculated the repository root as the parent of `HOSTILE_OS` and ran `git rev-parse HEAD` there.

Observed exception:

`subprocess.CalledProcessError: Command ['git', 'rev-parse', 'HEAD'] returned non-zero exit status 128`

No controlling inputs were snapshotted, no guest binary was built, and no guest ran. Therefore attempt 1 has no scientific or infrastructure consequence.

Repair: change the launcher repo-root calculation from `src.parents[3]` to `src.parents[2]`, pointing at the actual `HOSTILE_OS` Git working tree. Because launcher source changed, a new run ID was required.

## Controlling run

Run:

`20260830T052900Z_d64_stage2_8k_loader_02`

QEMU:

- PID: `17504`
- started: `2026-08-30T05:26:53.782249+00:00`
- ended: `2026-08-30T05:26:54.068389+00:00`
- status: `COMPLETED`
- exit: `33`
- wall time: `286.123 ms` as harness data only

Evaluator exit: `0`.
Static checker exit: `0`.
Independent closure audit: PASS.

## Exact guest trace

```text
S1_8K_OK
S2_8K_OK
```

The stage-2 success path compares the linked tail marker at address `0x9FF0` against byte `0xA5` before printing `S2_8K_OK`.

## Qualified consequence

The controlling run establishes the bounded infrastructure statement:

> BIOS INT 13h AH=02h can load exactly 16 contiguous first-track floppy sectors, BIOS sectors 2..17, into physical `0x8000..0x9FFF`; guest code at the start of stage 2 can observe the required marker at linked address `0x9FF0`, near the end of that extent, and then complete the exact success path.

This is stronger than merely reaching a stage-2 entry point because the success trace depends on the byte loaded at raw stage-2 offset `0x1FF0`.

## Exact size / layout readback

- stage 1 raw bytes: `512`
- stage 1 boot signature: `55aa`
- stage 2 raw bytes: `8177`
- required tail offset: `0x1FF0` / decimal 8176
- byte at tail offset: `0xA5`
- stage 2 padded bytes: `8192`
- disk image bytes: `1474560`
- zero-based sector 17 / BIOS sector 18 after run: all zero

Stage-2 raw size 8,177 bytes means the emitted image extends through and includes the marker at offset 8,176.

## Input-snapshot / provenance closure

The controlling run followed `EXPERIMENT_RUN_INPUT_SNAPSHOT_PROTOCOL.md` from before compilation.

Run-local snapshot inputs include:

- qualification spec;
- D64 resource-binding scale plan;
- stage-1 source/linker;
- stage-2 source/linker;
- launcher;
- evaluator;
- static checker.

Input-manifest SHA-256:

`54524105a9aab6d6bda31249c9f234a93120fb38b4a50070426c430d8114155f`

Receipt SHA-256:

`3c99d87bac903cb9b36ef6644f323c533e70efacbd9f3f47af9573f78a5f8adf`

Independent audit SHA-256:

`3aa032ef0ab79d71f8ecb2aa9f8d1f913b70ac1dce4b72d10aba8216f6a5543d`

Independent audit verified:

- manifest hash equals receipt input-manifest hash;
- every snapshot path, byte count, and SHA-256 matches the manifest;
- every receipt source hash equals the corresponding snapshot hash;
- controlling preregistration lineage is exactly `ca21370643b8526ce2d66b4de1f2aec2c78a008d`;
- snapshot timestamp precedes QEMU execution;
- stage 1 is exactly 512 bytes with `55aa`;
- raw stage 2 is exactly 8,177 bytes and contains `0xA5` at `0x1FF0`;
- padded stage 2 is exactly 8,192 bytes and begins with the exact raw stage 2;
- disk layout contains exact stage 1 and stage 2 at the declared offsets;
- BIOS sector 18 remains zero;
- QEMU/evaluator/static closure all pass;
- all nine static checker fields are literal boolean true;
- attempt 1 produced no manifest or guest trace and therefore has no qualification consequence.

## Static/source closure

All nine preregistered checks passed:

1. stage 1 uses BIOS read AH=02h, AL=0x10, CH=0, CL=2, DH=0 and far-jumps to `0000:8000`;
2. stage-1 linker fixes signature at `0x7DFE`;
3. stage-2 linker places `.tail` at `0x9FF0` and asserts final address <= `0xA000`;
4. stage-2 source defines marker `0xA5` and checks it before success output;
5. raw stage-2 byte at offset `0x1FF0` is `0xA5`;
6. padded stage 2 is exactly 8,192 bytes;
7. BIOS sector 18 remains zero;
8. run-local manifest and receipt source hashes agree;
9. host harness does not synthesize guest success trace or mutate guest memory.

## Key controlling hashes

Sources:

- stage1.S: `6cacc1e2fb397cb09321459b7d930718546288fce1a68a619adf76b795c00276`
- stage1.ld: `e5da57aefb8ff22b1c858e7372bab49c29d8cd45d83650b53664e44c51a6a3fa`
- stage2.S: `fdef8cb5f69d1ef699ae369a31083d42a948d976367ccb83ce8946e8e2c2dfd1`
- stage2.ld: `04a4141c295bf71c4086d147acd55b57ef745ba77e4e318275140f6c2bc1f64d`
- evaluator: `ba6d962a7290780113d5fe9e1c0881b6dd37528d128bb4e6f54b03a19a1d4f4b`
- static checker: `aac6757ba1ea8e66f89210fe1a3b165945625b9074a0fa768daf22c4fbfb8df4`
- launcher: `457229dcf43248836e822d8eada88c0d75ca01fa2fb9b19d0c53f32c7963450e`

Artifacts:

- stage1.bin: `feecbbfdea750fc26f401c0e8eeeabcdd70953036bd60e287368e987ac1ed97d`
- stage2.raw.bin: `7ff9ebe7ac73ea4f88e259690d6a630d9d8333bc6a8089a86e08aee364975680`
- stage2.padded.bin: `492ef24b371cc0a98a0c52fad76b5f2d4260b6878ee20b91c580605005f8b632`
- disk.img: `5641f085bb29bc2d92bf54a4f2425f8235651a68f607879744f630258eb8dd5e`
- debug trace: `9d31529e2364385c629bcdb6ce8938aea1cce9ed5eeaf0d8350d5ab007fc67d4`
- evaluation: `eb9a416f77c5762a1b271f2e423b7fd131ee16a6460078eb85062aa8f0154101`
- static closure: `21bc5c81d96903253dfe07d0facae1215d8447aebefe0676599ed5bc80e2e0a3`

## Authority ceiling / nonclaims

This qualification does not establish:

- D64 resource-binding semantics;
- arbitrary stage-2 size;
- cross-track BIOS reads;
- native post-takeover storage transport;
- final HOSTILE-OS image layout;
- resource lifetime/currentness correctness;
- architecture promotion;
- R3.1/R6 SOP authority change.

The 8 KiB envelope is a qualified experiment infrastructure surface only.

## Next lawful use

The D64 resource-binding scale plan may now use this fixed 16-sector / 8 KiB stage-2 envelope in a separately preregistered discriminator.

## Disposition

`D64_STAGE2_8K_LOADER_QUALIFIED / FIRST_TRACK_SECTORS_2_TO_17 / LOAD_0x8000_TO_0x9FFF / TAIL_0x9FF0_OBSERVED / INPUT_SNAPSHOT_CLOSED / RESOURCE_BINDING_EXPERIMENT_NOW_LAWFUL`
