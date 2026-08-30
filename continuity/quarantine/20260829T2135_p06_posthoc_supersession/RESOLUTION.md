# P06 post-hoc supersession conflict — resolution

**Detected:** 2026-08-29
**Disposition:** quarantined; does not alter P06 preregistration or result criteria

## Temporal evidence

Authoritative P06 preregistration was committed at Git commit `463021d9b385f4a97f7bd314dd54ecc08285ea56` before execution.

Controlling P06 run `20260829T213505Z_p06_missing_operation_01`:
- QEMU started `2026-08-29T21:35:03.635474+00:00`;
- QEMU ended `2026-08-29T21:35:03.828154+00:00`;
- exit `33`;
- evaluator exit `0`.

The concurrent supersession file was written later at `2026-08-29T21:35:04.5433755Z` while asserting that no P06 scientific execution had occurred. That assertion conflicts with the durable run receipt.

A post-result uncommitted artifact cannot retroactively change a committed preregistration. The supersession and its copied/rejected draft tree are therefore preserved here as controlled evidence but have no authority over P06.

## Useful surviving idea

The supersession proposed a stronger follow-on discriminator: local missing-operation failure for activity A should not prevent a distinct later activity B from performing a present operation, with a deliberately bad global-failure-latch control showing the opposite consequence.

That pressure is methodologically useful and may be earned by P06 as P07. It is not allowed to rewrite P06 after execution.
