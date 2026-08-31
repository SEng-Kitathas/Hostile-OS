# Status

- body class: research-only
- generation: D64 reference v2
- admission: **CURRENT_RESEARCH_REFERENCE**
- final architecture: false
- production ready: false
- general-purpose release: false

Admission basis:
- representation-first state budget closed;
- core reviewer mode integrated;
- real IRQ0 reviewer mode integrated;
- two-boot restart + FR01-compatible reconstruction integrated;
- five bounded faulted-media reviewer cases integrated;
- isolated `os/`-only build/run/verify audit PASS;
- no `research/`, `continuity/`, `authority/`, or `handoffs/` build/run dependency found;
- historical `i001_reference` tree unchanged.

Measured current body:
- stage1: 512 bytes with `55 aa`;
- named v2 state: 3467 bytes;
- stage2 raw: 3845 bytes;
- total linked stage2 memory: 7440 / 8192 bytes;
- remaining qualified-envelope headroom: 752 bytes;
- reviewer run: 8 QEMU boots;
- verifier: 17/17 PASS.

`CURRENT_RESEARCH_REFERENCE` means only: this is the most current integrated reviewer embodiment of the adopted shadow mechanisms.

It does **not** mean:
- final architecture;
- production-ready OS;
- general-purpose release;
- physical hardware qualification;
- universal sector atomicity;
- filesystem/user ABI completion.
