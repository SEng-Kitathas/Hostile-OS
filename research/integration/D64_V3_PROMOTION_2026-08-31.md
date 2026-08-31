# D64 reference v3 promotion — 2026-08-31

Status: **PROMOTED TO CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**

Promotion parents:
- Candidate-B selection: `research/integration/H1_SMP_SUCCESSOR_ADMISSION_REVIEW_2026-08-31.md`;
- isolated admission result: `research/integration/D64_V3_ISOLATED_ADMISSION_RESULT_2026-08-31.md`;
- admitted machine-source package commit: `90f7ee369157597cd7e4ac5fac04ae269e44ea8a`;
- admitted package Git tree: `171b3be2d985560c34a1a1b98ead0cf7cda8b404`;
- isolated evidence commit: `cf67026`.

The successful isolated package proved:
- stage2 raw4494 bytes;
- linked stage28089/8192 bytes,103 bytes headroom;
- named semantic state3467 bytes;
- implementation scratch62/128 bytes;
- H1-QEMU two-core mailbox-owner S trace exact;
- inherited core+IRQ exact;
- restart write/reconstruct exact;
- five faulted-media cases exact/read-only;
- package verifier20/20;
- no build/run dependency on research/continuity/authority/handoff trees.

Promotion changes current-status/index/tool pointers only. The admitted stage1/stage2 machine source is unchanged. `d64_reference_v2/` and `i001_reference/` remain preserved prior lineage.

Current-reference status does **not** mean final architecture, production readiness, general-purpose release, physical H1 qualification, arbitrary-core SMP, owner-failure recovery, or complete C004 authority embodiment.
