# H1 v3 current-reference cross-emulator replay adjudication — 2026-08-31

Status: **CURRENT V3 MATRIX PASS / ONE PRE-PROMOTION RUN NON-CONTROLLING**

Two v3-based matrix runs were produced during promotion closure.

## Pre-promotion validation — non-controlling

`runs/20260831T103138Z_h1_emulator_matrix_01`

- matrix PASS;
- QEMU H1 proxy PASS;
- Bochs core/restart/five-fault PASS;
- receipt records source Git HEAD `cf67026b72034d8a8acc4d2898a542a15e0e72e9`.

The runner/current-body pointer modifications used for this execution were still uncommitted, so the recorded source HEAD does not bind the exact runner bytes. Preserve this run as useful pre-promotion validation only; do not use it as controlling current-reference evidence.

## Post-promotion replay — controlling current-reference matrix

`runs/20260831T103212Z_h1_emulator_matrix_01`

- source Git HEAD `af8a11eb055b486c38cefb3676066b3e6d808f32` (`Promote D64 reference v3 and retarget current H1 tools`);
- base image SHA-256 `0bf0dd01902e548a47f186bf49aa117d534ddd0f8fd8e75cb04885cf83432099`;
- QEMU H1 current-body replay PASS;
- Bochs independent core replay PASS;
- Bochs restart exact/invariants PASS;
- Bochs five faulted-media cases exact/read-only PASS.

This is the controlling post-promotion cross-emulator matrix for the current v3 body at this checkpoint.

Authority ceiling remains unchanged: QEMU/Bochs agreement is cross-emulator reproduction evidence and target-shaping pressure, not physical HP Pavilion p2-1120 qualification.
