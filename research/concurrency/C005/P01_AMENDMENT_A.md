# C005/P01 Amendment A — 32-bit LAPIC MMIO addressing repair

Status: AP-START TRANSPORT AMENDMENT / NO COHERENCE RESULT YET

First controlling attempt `P01/runs/20260831T033403Z_c005_p01_01` booted the BSP and reached `TEST=C005_P01`, but AP did not reach the ready handshake. Evaluator failed only because two-CPU participation/coherence phases never started.

Disassembly showed absolute LAPIC stores in `.code16` were encoded as 16-bit moffs addressing, truncating `0xFEE00310/0xFEE00300` to low addresses. INIT/SIPI was therefore never delivered to the AP.

Correction: load each LAPIC MMIO address into `%edi` and access through `(%edi)`, forcing 32-bit address-size encoding in 16-bit code.

No C005/P01 question, shared-state discriminator, deliberate mixed window, atomic `xchg` good witness, evaluator expectation, or authority ceiling changes.
