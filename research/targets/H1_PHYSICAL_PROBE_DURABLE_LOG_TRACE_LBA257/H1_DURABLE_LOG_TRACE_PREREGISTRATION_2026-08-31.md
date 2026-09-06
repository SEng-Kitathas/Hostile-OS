# H1 durable-log execution-trace descendant preregistration — 2026-08-31

Status: **PREREGISTERED / BUILD PENDING**

Parent: `research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG_LBA257/`

Trigger: physical H1 boot with the verified LBA257 durable-log image left the entire first 1 MiB byte-identical to its prepared state and the relocated journal LBAs257..384 all-zero. Physical discriminators already proved EDD AH=43 persistence to LBA257 and non-persistence to LBA256.

## Question

Where does the full wrapper stop before the normal logger can persist its first `H1LG` record?

## Mechanism

Use the already physically proven writable LBA257 as a single overwrite breadcrumb sector. The trace descendant SHALL preserve the qualified logger/probe body and add only execution breadcrumbs:

1. sector-0 entry attempts EDD write of `H1TRACE_STAGE1_ENTER` to LBA257;
2. after the existing 8-sector CHS loader read succeeds, sector 0 attempts EDD write of `H1TRACE_STAGE1_LOADED` to the same LBA257;
3. first instructions of the resident loader attempt EDD write of `H1TRACE_LOADER_ENTER` to the same LBA257;
4. the normal relocated durable logger then uses LBA257 as record sequence 0 and, if successful, overwrites the trace sector with the normal `H1LG` record.

Only LBA257 is used for breadcrumbs. The normal logger remains bounded to LBAs257..384.

## Interpretation

Post-boot LBA257 state:
- all-zero -> sector-0 breadcrumb did not persist; boot/execution assumption must be challenged;
- `H1TRACE_STAGE1_ENTER` -> sector 0 executed, but existing CHS loader read did not reach successful completion;
- `H1TRACE_STAGE1_LOADED` -> loader bytes were read, but control did not reach the resident loader breadcrumb;
- `H1TRACE_LOADER_ENTER` -> resident loader began, but normal logger did not persist its first record;
- valid `H1LG` record -> normal logger persistence succeeded; decode full journal.

## Safety

No internal-disk path is added. Breadcrumbs target only BIOS boot drive DL and only LBA257. No video-mode change is added. No D64-v3 mutation.

## Qualification

- source derived from qualified LBA257 logger;
- stage1 remains exactly 512 bytes;
- loader remains within 4 KiB;
- probe remains within 8 KiB;
- QEMU IDE/EDD execution shall end with a valid normal `H1LG` journal through `H1PROBE_END`, proving breadcrumbs are overwritten by normal logging when the full path succeeds;
- bytes outside normal journal LBAs257..384 remain unchanged.
