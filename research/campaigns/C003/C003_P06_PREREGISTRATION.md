# C003 / P06 preregistration — bounded missing-operation failure without exception machinery

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P06 of 20
**Earned by:** C003/P05 bounded async IRQ/idle-wake success
**Architecture promotion:** FORBIDDEN

## Why P06 exists

`bounded missing-operation failure` is an inherited whole-P01 obligation that remains directly unembodied after P05.

The corresponding still-UNKNOWN Python-host burden includes exception control flow, dynamic dispatch/container behavior, strings/labels, and host-language failure propagation.

## P06 question

Can an unknown operation be rejected in bounded freestanding guest control flow using only an explicit result byte, while leaving protected guest state unchanged, without exception machinery, host dictionaries, string dispatch, or a service/manager primitive?

## Fixture

The fixture supplies only:
- initial protected state: ASCII `A`;
- known operation code: `0x01`;
- unknown operation code: `0x7f`.

The fixture SHALL NOT supply success/failure status or mutate state.

## Mechanism

One bounded `apply_operation` relation:
- input operation code in a register;
- operation `0x01`: increment protected state `A -> B`, return status byte ASCII `O`;
- any other operation: do not mutate protected state, return status byte ASCII `M`.

No loop over an unbounded namespace is required for this pass.

## Raw guest observation contract

The guest SHALL emit raw status/state values only:

```text
KNOWN_STATUS=O
UNKNOWN_STATUS=M
BEFORE_UNKNOWN=B
AFTER_UNKNOWN=B
DONE
```

The guest SHALL NOT emit a self-graded `PASS` for the discriminator.

The external evaluator decides whether:
- the known operation was accepted;
- the known operation changed state to `B`;
- the unknown operation returned explicit missing status `M`;
- state was exactly `B` before and after the unknown operation.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- 512-byte image/signature/hash;
- exact QEMU argv/PID/start/end/exit;
- bounded launcher timeout;
- debugcon/hash;
- build/QEMU/evaluator stdout+stderr;
- evaluator result/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P06 succeeds for this bounded discriminator only if the exact raw observation is:

```text
KNOWN_STATUS=O
UNKNOWN_STATUS=M
BEFORE_UNKNOWN=B
AFTER_UNKNOWN=B
DONE
```

with deterministic QEMU success exit and independent evaluator pass.

A completed guest that returns another state/status is a qualified mechanism failure. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that this bounded missing-operation path does not require Python exceptions, host-language dispatch containers, or string dispatch. It would not establish a general syscall/API namespace, capability system, service architecture, dynamic linking, or architecture promotion.

## Stop rule

Reconcile P06 before deriving P07. P07-P20 remain unwritten until P06 consequence earns the next discriminator.
