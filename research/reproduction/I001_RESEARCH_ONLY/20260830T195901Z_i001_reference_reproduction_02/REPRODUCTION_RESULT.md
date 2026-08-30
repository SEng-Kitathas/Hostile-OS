# I001 research-only clean reproduction 02

Status: **PASS**

This run was executed from the checked-in `os/research_only/i001_reference/` source into a fresh scratch output directory. Existing mutable `build/` products were not used.

## Tool-discovery pressure
The first build attempt intentionally used the ambient process environment and failed closed because Clang was not on `PATH`. The supported `HOSTILE_LLVM_BIN` interface was then set to the qualified local Android NDK LLVM directory and the source built unchanged. The exact failure diagnostic is preserved.

## Machine-byte reproduction
- stage1: 512 bytes; SHA-256 `bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8`; historical I001 match `true`
- stage2: 2478 bytes; SHA-256 `2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be`; historical I001 match `true`
- initial disk SHA-256 `b9c79c821d0be352132e940201f23d1e2bcd0456d994a1a142fd01a183bc4218`; historical initial-image match `true`

## Runtime reproduction
- Boot1 PID `3596`, status `COMPLETED`, exit `33`
- Boot2 PID `13712`, status `COMPLETED`, exit `33`
- distinct QEMU PIDs: `true`
- no host disk write between boots: `true`
- semantic verifier passed: `true`
- observed historical exact IRQ_EVENT=1 on this run: `true` (informational only; the long-replay IRQ-count seam remains open)

## Historical EOL adjudication
RB02 historical source check passed: `true`. All 12 historical inputs remain explainable through the sealed snapshot plus Git LF -> CRLF normalization classification; sealed historical hashes were not rewritten.

## Authority ceiling
This is independent repository reproduction evidence for the research-only embodied I001 witness. It does not convert I001 into final architecture, does not backport later D64 mechanisms, and does not erase the historical I001 evaluator seam.
