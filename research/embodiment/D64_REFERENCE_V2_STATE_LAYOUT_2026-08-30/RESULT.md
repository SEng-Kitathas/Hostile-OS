# D64 reference v2 state-layout skeleton result — 2026-08-30

Status: ENGINEERING EMBODIMENT CHECK / NOT SCIENCE / NOT CURRENT_RESEARCH_REFERENCE

The representation-first v2 skeleton built and booted successfully after the state-budget plan was sealed.

Measured:
- stage1: 512 bytes, `55 aa`;
- stage2 raw: 84 bytes;
- named v2 state: exactly 3467 bytes;
- total linked stage2 memory footprint: 3680 bytes;
- qualified envelope: 8192 bytes;
- linked headroom: 4512 bytes;
- QEMU: `COMPLETED`, exit33;
- trace: `S1_8K_OK`, `HOSTILE_OS_D64_V2_STATE_LAYOUT_OK`;
- verifier: PASS 7/7.

This proves only that the selected representation fits and the skeleton boots. It does not prove the later reviewer mechanisms have been embodied yet.
