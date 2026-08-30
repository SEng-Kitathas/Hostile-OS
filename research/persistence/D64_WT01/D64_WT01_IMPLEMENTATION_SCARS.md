# D64/WT01 implementation scars — 2026-08-30

Status: PRE-SCIENCE DEVELOPMENT HISTORY

## Scar 1 — assembly debug strings contained literal newlines

During pre-science compile smoke, the first writer source encoded the debug `.asciz` lines with literal source newlines inside quoted assembly strings instead of escaped `\n` sequences.

Clang emitted four unterminated-string warnings but still produced an object/binary.

Disposition:
- treated as failed smoke despite successful object generation because debug trace bytes are part of the evidence contract;
- no QEMU WT01 science process ran;
- source was corrected to explicit escaped newline bytes;
- warning-free compile/link then passed.

Science consequence: none.

## Scar 2 — static checker searched for the wrong literal guard text

The first WT01 static smoke passed 15/16 checks. The only false check was `force_kill_only_when_stopped`.

The launcher already contained the required safety guard:

```text
assert ctx['stopped'] is True
```

inside `force_terminate(ctx)` immediately before process kill.

The checker incorrectly searched for the unrelated literal text:

```text
assert stopped is True
```

Disposition:
- classified as checker defect, not missing launcher guard;
- checker was corrected to require the actual context guard plus `def force_terminate` and `p.kill()`;
- static smoke then passed 16/16;
- no WT01 QEMU science process had run before correction.

Science consequence: none.

## Pre-science closure after repairs

- Python launcher/evaluator/static/audit syntax: PASS;
- writer compile/link: PASS, no warnings;
- stage1: 512 bytes;
- writer stage2 raw: 197 bytes;
- `writer_int13_site`: `0x8042`;
- `writer_after_int13`: `0x8046`;
- static/source smoke: 16/16 PASS;
- embedded FR01 B record hex: `4834463151720202000102000100010234120100020000006c36434d4954`.

These are implementation qualification facts only. They do not count as WT01 science.
