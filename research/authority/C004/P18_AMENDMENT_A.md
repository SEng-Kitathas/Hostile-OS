# C004/P18 Amendment A — boot-sector signature duplication repair

Status: PRE-SCIENCE HARNESS AMENDMENT

The first post-seal launch attempt failed during stage1 link, before any QEMU process started.

Cause: P18 `stage1.S` embedded `.org 510` / `.word 0xaa55` even though the inherited `stage1.ld` already reserves address `0x7dfe` and inserts `SHORT(0xaa55)`. The duplicate source-side signature expanded `.payload` past the one-sector limit and overlapped `.sig`.

Correction: remove only the duplicate source-side `.org` and signature bytes. The linker remains the sole boot-signature authority.

This amendment changes no P18 question, expected trace, durable record, authority mechanism, bad control, or evaluator. No P18 scientific QEMU process had started before the amendment.
