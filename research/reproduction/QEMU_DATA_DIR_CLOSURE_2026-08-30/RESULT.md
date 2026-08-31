# QEMU firmware/data-directory transplant closure — 2026-08-30

Status: **CLOSED AT CURRENT PROJECT TRANSPORT SCOPE**
Source commit: `5f57ad17d3daddd2ef26bc4eda4f98ebbaf91af5`
Current v2 tree: `03af56020afe6d117836133c0e33092d098fc13e`
Historical I001 tree: `bd641bcd658fbf558f15a9226f96058351d5794c`

## Finding

Opus's remaining assertion was technically correct for direct Python launch: the runners understood QEMU modules and disabled the default NIC, but the current Python runner did not discover/pass the transplanted firmware/data directory using `-L`.

Important nuance: PATCH_003 already supplied `-L "$HERE/share/qemu"`, so the project had wrapper-level coverage. The gap was **known in wrapper / missing in direct Python runner**, not total absence.

## Current-reference repair

`os/research_only/d64_reference_v2/run.py` now supports:
- `HOSTILE_QEMU_DATA_DIR`;
- `HOSTILE_QEMU_FIRMWARE` alias;
- adjacent `share/qemu` and `share` auto-discovery near the selected binary;
- `bios-256k.bin` presence for automatic data-dir selection;
- `-L <selected-data-dir>` in every QEMU argv;
- `qemu_data_dir` in the run receipt.

Synthetic transplant discovery PASSed for `runtime/qemu/bin`, adjacent `modules/`, and adjacent `share/qemu/bios-256k.bin`.

## Exact committed os-only readback

An exact `git archive HEAD os` export from `5f57ad17d3daddd2ef26bc4eda4f98ebbaf91af5` contained none of `research/`, `continuity/`, `authority/`, or `handoffs/`.

From that isolated export:
- build PASS;
- 8 reviewer QEMU boots PASS;
- verifier PASS 17/17;
- `qemu_data_dir = C:\Program Files\qemu\share`;
- every one of the 8 QEMU argv arrays contained `-L` plus that selected data directory: **true**;
- stage2 raw hash unchanged: `5d78b672812674810d6363594a1e5c0b76b90a9a2b272229a9146bfa453127ac`.

Historical I001 source/body was not rewritten. PATCH_003 remains its supported transplanted-QEMU wrapper route and already supplies `-L`, module binding, and `-nic none`.

## Gates

- I001 historical portability gate V2: **true** (8/8);
- current QEMU transplant portability gate V1: **true** (9/9);
- integrated v2 verifier: **true** (17/17).

## Science consequence

None. This is reproducibility/transplant infrastructure closure.

It strengthens the infrastructure statement:

`TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT`

without promoting that analogy into OS architecture evidence.
