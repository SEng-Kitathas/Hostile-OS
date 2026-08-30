# Release Verification — R3.1

PASS: exact membership, pinned ancestry, source class+body binding, exact human-section binding, governance boundary, active scars, execution/release recovery, honest coverage blockers, and dormant substrate schema.
ASSURANCE_CEILING=STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY

Hostile mutations: **19/19 rejected as expected**.
Verifier authoring lint: **PASS (AST unused-import check; ruff unavailable)**.

Narrow correction from R3:
- removed unused `sys` import;
- added type contracts to the load-bearing verifier functions;
- replaced global prose-substring acceptance with exact parsed live-section comparison;
- added a mutation where the expected C16 sentence is preserved elsewhere while the live C16 section is corrupted; it is rejected;
- sharpened the shadow-use discriminator to measure both lawful decision equivalence and operator/recovery quality.

Parent R6 SHA-256: `69721b7b6c4b8c04d5377f1b7c0afa044530a6352496c7cb564f4cb4ef2df257`
Churn falsification SHA-256: `c65d7e6fa00ae846d6138fffbf26478caa40006b09859ecc4a7fc31ff75bbb02`

This receipt does **not** claim semantic equivalence to all of R6, replacement readiness, independent verification, or foundation promotion. Fresh real-project shadow use remains the only replacement blocker.
