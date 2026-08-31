# D64 reference v2 IRQ embodiment result — 2026-08-30

Status: ENGINEERING EMBODIMENT CHECK / NOT SCIENCE / NOT CURRENT_RESEARCH_REFERENCE

The versioned v2 body now composes the previously integrated D64 core with a real IRQ0 reviewer path.

Measured:
- named state: 3467 bytes;
- stage2 raw: 2592 bytes;
- total linked memory: 6187 bytes;
- 8192-byte envelope headroom: 2005 bytes;
- QEMU completed exit33;
- verifier PASS 8/8.

IRQ reviewer consequence:
- one real event + current relation -> relation1, wake1, progress02;
- two real events + current relation -> same relation/wake/progress consequence;
- two real events + stale wait generation -> relation0, wake0, progress00.

This embodies sealed IRQCOUNT/I001 semantics without promoting exact event count1 into architecture.
