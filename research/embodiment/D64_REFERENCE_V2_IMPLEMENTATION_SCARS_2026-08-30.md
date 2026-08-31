# D64 reference v2 implementation / packaging scars — 2026-08-30

Status: ENGINEERING HISTORY / NOT SCIENCE

## Generated linker-map trailing whitespace

During state-layout skeleton staging, `git diff --cached --check` flagged one trailing-space line in the generated linker map. The map was classified as reproducible build noise with no unique meaning beyond the admitted symbol/readback packet, removed from the compact evidence packet, and not rewritten as if it were source.

Science consequence: none.

## Integrated verifier source quoting bug

After the eight integrated reviewer boots had completed successfully, generated `verify.py` failed Python parsing because its output-newline literal had been emitted as a literal source newline, producing an unterminated string.

Disposition:
- all eight QEMU boot receipts already existed and were unaffected;
- build/stage2/run sources did not change;
- only verifier source was repaired;
- `python -m py_compile verify.py` then passed;
- repaired verifier evaluated the existing eight-boot receipt PASS 17/17;
- QEMU rerun was not required because the executable/run inputs were unchanged.

Science consequence: none. Embodiment verification-tool defect retained explicitly.
