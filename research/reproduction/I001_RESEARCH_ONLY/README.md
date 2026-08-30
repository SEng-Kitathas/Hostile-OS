# I001 research-only reproduction records

These packets reproduce the embodied `os/research_only/i001_reference/` tree. They do not rewrite the sealed historical I001 science result.

## Packet 01 — first captured reproduction
`20260830T195250Z_i001_reference_reproduction_01/`

- exact historical stage1/stage2/initial-disk machine bytes reproduced;
- exact historical Clang/LLD/objcopy/QEMU/Python executable hashes matched;
- two distinct QEMU boots exit33;
- semantic reproduction verifier PASS;
- RB02 12-source historical line-ending adjudication PASS.

## Packet 02 — clean fresh-output reproduction / preferred reviewer record
`20260830T195901Z_i001_reference_reproduction_02/`

This is the stronger reviewer-facing record because it starts in a fresh output directory and explicitly pressures tool discovery:

- ambient no-PATH build attempt fails closed with the expected missing-tool diagnostic;
- supported `HOSTILE_LLVM_BIN` interface then builds source unchanged;
- exact historical stage1/stage2/initial-disk bytes reproduced;
- Boot1 PID 3596 exit33; Boot2 PID 13712 exit33;
- distinct QEMU processes and no host disk write between boots;
- semantic verifier PASS;
- RB02 historical line-ending adjudication PASS;
- packet manifest PASS.

Packet 02 is preferred for outside reviewers. Packet 01 is retained because it is the first actual reproduction capture and carries its own exact receipt/history.
