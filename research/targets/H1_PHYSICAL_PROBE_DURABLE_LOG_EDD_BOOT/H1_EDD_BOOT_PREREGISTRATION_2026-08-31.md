# H1 durable logger EDD boot-loader repair preregistration — 2026-08-31

Status: **PREREGISTERED / BUILD PENDING**

Physical trace evidence from `H1_PHYSICAL_PROBE_DURABLE_LOG_TRACE_LBA257`:
- LBA257 persisted `H1TRACE_STAGE1_ENTER`;
- `H1TRACE_STAGE1_LOADED` absent;
- `H1TRACE_LOADER_ENTER` absent;
- no normal `H1LG` record.

Earned interpretation: BIOS executed sector 0 and EDD write to LBA257 succeeded, but the existing stage1 CHS AH=02 read of 8 sectors (loader at LBAs1..8) did not complete successfully. The resident logger was never entered.

Selected repair: keep the physically proven journal base at LBA257 and replace only the stage1 loader read with EDD AH=42.

Stage1 SHALL:
1. preserve BIOS boot drive DL;
2. write `H1TRACE_STAGE1_ENTER` to LBA257 using AH=43 as a breadcrumb;
3. verify EDD support via AH=41;
4. issue one AH=42 read of 8 sectors from LBA1 into 0000:6000;
5. on successful read, overwrite LBA257 with `H1TRACE_STAGE1_LOADED` via AH=43;
6. far-jump to 0000:6000;
7. retain a visible/debug failure string on read failure.

The resident loader/probe/logger remains derived from the already-qualified LBA257 logger. Its first instruction breadcrumb `H1TRACE_LOADER_ENTER` may remain for physical localization and shall be overwritten by a normal H1LG record if logging proceeds.

Safety:
- boot-device writes remain bounded to journal/trace LBA257..384;
- no internal disk path;
- no graphics mode switch;
- no D64-v3 mutation.

Qualification:
- stage1 exactly 512 bytes;
- loader <=4096 bytes;
- probe <=8192 bytes;
- QEMU IDE/EDD must produce normal 36-record journal through H1PROBE_END;
- all bytes outside LBAs257..384 unchanged;
- physical image/prefix raw-readback verified before reuse.
