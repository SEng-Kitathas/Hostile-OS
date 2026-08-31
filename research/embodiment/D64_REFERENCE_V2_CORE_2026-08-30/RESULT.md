# D64 reference v2 core-mode embodiment result — 2026-08-30

Status: ENGINEERING EMBODIMENT CHECK / NOT SCIENCE / NOT CURRENT_RESEARCH_REFERENCE

The first integrated `core` reviewer workload builds and boots from the self-contained `os/research_only/d64_reference_v2/` tree.

Measured:
- named state remains exactly 3467 bytes;
- stage2 raw: 1859 bytes;
- total linked stage2 memory footprint: 5454 bytes;
- qualified 8192-byte envelope headroom: 2738 bytes;
- QEMU completed exit33;
- verifier PASS 8/8.

Reviewer trace demonstrates already-sealed D64 consequences: activity full at64, row full at20, shared live count2, stale binding rejection, fresh binding value, local missing binding, bound-release block, final-detach reclaim, stale direct-resource handle after slot reuse, and fresh reused-resource handle/value.

This is an embodiment/integration check only. It does not create new science authority beyond its mapped parent results.
