# D64 reference v2 integrated reviewer result — 2026-08-30

Status: ENGINEERING EMBODIMENT CHECK / NOT SCIENCE / NOT YET CURRENT_RESEARCH_REFERENCE

The v2 body now composes three reviewer layers inside the qualified 8 KiB stage2 memory envelope:

1. core finite-capacity/currentness/shared-lifetime workload;
2. real IRQ0 count1/count2/stale-relation workload;
3. restart + bounded FR01-compatible faulted-media recovery.

Measured:
- stage1: 512 bytes, valid `55 aa`;
- named v2 state: exactly 3467 bytes;
- stage2 raw: 3845 bytes;
- total linked stage2 memory: 7440 bytes;
- qualified-envelope headroom: 752 bytes;
- reviewer QEMU boots in one `run.py --mode all`: 8;
- verifier: PASS 17/17.

Restart reviewer mode:
- Boot1 constructs a live relation and writes exact FR01-compatible candidate A;
- B remains zero;
- no host write occurs between Boot1 and Boot2;
- Boot2 uses the same disk read-only, selects A/value71, rejects historical binding/resource handles, reconstructs a fresh relation, and leaves the disk unchanged.

Faulted-media reviewer cases:
- valid old / empty new -> A/value71;
- valid old / valid newer -> B/value72;
- valid old / corrupt newer -> A/value71;
- equal-sequence conflicting valid records -> X fail closed/no value exposure;
- both invalid -> N fail closed/no value exposure.

This packet demonstrates embodiment of already-sealed parent results. It creates no stronger science authority.

Admission as `CURRENT_RESEARCH_REFERENCE` is still blocked on isolated `os/`-only build/run/verify and no-R&D-dependency audit.
