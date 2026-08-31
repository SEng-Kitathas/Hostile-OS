# D64 reference v3 isolated admission result — 2026-08-31

Status: **PASS / ELIGIBLE FOR CURRENT_RESEARCH_REFERENCE PROMOTION**
Source package commit: `90f7ee369157597cd7e4ac5fac04ae269e44ea8a`
Source package tree: `171b3be2d985560c34a1a1b98ead0cf7cda8b404`
Admission packet: `research/reproduction/D64_V3_ISOLATED_ADMISSION/20260831T102825Z_d64_v3_isolated_admission_01`

## Exact body

- stage1:512 bytes,55aa present, SHA-256 `feecbbfdea750fc26f401c0e8eeeabcdd70953036bd60e287368e987ac1ed97d`;
- stage2 raw:4494 bytes, SHA-256 `db79b1d511e32b083fa6ae511e37ea375ea97b0fc3ad1817531f537ea84733b8`;
- linked stage2 memory:8089 /8192 bytes;
- headroom:103 bytes;
- named semantic state:3467 bytes;
- implementation scratch used:62 /128 bytes;
- base disk SHA-256 `0bf0dd01902e548a47f186bf49aa117d534ddd0f8fd8e75cb04885cf83432099`.

## Isolated run

After host-side runner Amendment A, `python run.py --mode all` from the v3 directory completed eight H1-QEMU boots with exit33:
- SMP exact: `IDS=0001`, `OWNER=BSP`, `MAIL=WW11`;
- inherited core+IRQ exact;
- restart boot1 write + boot2 read-only reconstruction exact;
- five faulted-media cases exact and read-only.

The package verifier passed20/20 including the os-only no-parent-runtime-dependency check.

## Scar retained

The first standalone runner attempt did not reach guest execution because the auxiliary H1 target QCOW was attached read-only on the tested Q35 IDE path. `D64_V3_ISOLATED_ADMISSION_SCAR_A_2026-08-31.md` preserves that host-side transport failure. Amendment A changed only the auxiliary target-disk attachment and left candidate stage1/stage2 bytes and guest criteria unchanged.

## Admission judgment

All gates in `H1_SMP_SUCCESSOR_ADMISSION_REVIEW_2026-08-31.md` are satisfied. D64 reference v3 is eligible to become the current research reference. This promotion remains research-only and does not qualify physical H1 hardware, production security, general multicore policy, or final architecture.
