# C004/P18 implementation scars

## Pre-QEMU loader packaging failure

First sealed implementation commit `4e6f559` failed at link because stage1 duplicated the linker-owned boot signature. `ld.lld` reported `stage1 exceeds one boot sector` and `.payload`/`.sig` overlap.

Disposition: harness/build defect; no QEMU process started; preserved in the failed run directory and Amendment A. No science consequence.
