# C003 / P06 — bounded missing-operation failure without exception machinery

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P06 of 20
**Architecture promotion:** NONE
**P07 earned:** YES

## Controlling preregistration

P06 is governed by `C003_P06_PREREGISTRATION.md` as committed at:

`463021d9b385f4a97f7bd314dd54ecc08285ea56`

A concurrent uncommitted supersession appeared only after the qualified run had already completed. It was quarantined under `continuity/quarantine/20260829T2135_p06_posthoc_supersession/` and cannot retroactively change P06 criteria.

## Question

Can an unknown operation be rejected in bounded freestanding guest control flow using only an explicit result byte, while leaving protected guest state unchanged, without exception machinery, host dictionaries, string dispatch, or a service/manager primitive?

## Controlling run

Run: `20260829T213505Z_p06_missing_operation_01`

QEMU:
- PID: `26424`
- started: `2026-08-29T21:35:03.635474+00:00`
- ended: `2026-08-29T21:35:03.828154+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Raw observation

```text
KNOWN_STATUS=O
UNKNOWN_STATUS=M
BEFORE_UNKNOWN=B
AFTER_UNKNOWN=B
DONE
```

Evaluator version: `C003-P06-missing-operation-v1`

Evaluator result: `passed=true`

The output is raw status/state data. The guest does not print a self-graded PASS for the discriminator.

## Mechanism

Fixture:
- initial protected state `A`;
- known operation code `0x01`;
- unknown operation code `0x7f`.

Guest operation relation:
- `0x01` increments protected state and returns status `O`;
- any other operation returns `M` and does not mutate protected state.

Observed sequence:
- known operation changed state `A -> B`;
- unknown operation returned `M`;
- state was `B` immediately before the unknown operation;
- state remained `B` after the unknown operation.

## Exact source hashes

- mechanism: `500cba2340932b9f269f057975ca5989518af617cdb7084332b3fa96065c3ec9`
- fixture: `eba074cb31bf397768874d161bcace9fbc0b918f60ff59349d20a22a002a0382`
- linker: `98e780fca52ce79e3de7a0f3363d6a321d32f009f7c056ab0ed9d41f205d9622`
- evaluator: `2985cee5b40d49ee8681bf5cccba61186b59ed9ed0d927eb7bd1e7b26086b43b`
- launcher: `d21bcc5c5da3fbb0594e4a4a91bdffe7dd39b1697cb0bcea06fb8d562e5bb451`

## Exact run artifacts

- boot image: 512 bytes
- boot image SHA-256: `25c1908343fd6c07731d947d4e7285c3d6400f3920910896549de4dc09e28297`
- debugcon SHA-256: `bfca14da3369401755f8633391ae8382086a519b1bb8c16454cbb58f861556de`
- evaluation SHA-256: `705827d2d38cd054875fa26a7f6d70486b5e25aaea4a3e055983e61bd545fbab`
- receipt SHA-256: `c9927c800b9dc09c00f81a3d2504aaddef0ba0b16d61b1795bc64fa893023800`

No standard QEMU process remained after post-inspection.

## Qualified conclusion

For this bounded one-byte operation/result slice:

- missing operation failure can return explicitly and boundedly without Python exception machinery;
- unknown operation handling does not require a host dictionary or string-dispatch runtime;
- the missing path can leave protected state unchanged;
- known success and missing failure can be externally distinguished by raw result bytes;
- no service/manager/error subsystem primitive is required by this slice.

This does not establish a general syscall/API namespace, capability system, dynamic linking, unbounded dispatch, general fault containment, or architecture promotion.

## Post-hoc supersession conflict

The quarantined supersession file was written at `2026-08-29T21:35:04.5433755Z`, after the controlling run ended at `21:35:03.828154Z`, while claiming no P06 execution had occurred. That claim is contradicted by the durable run receipt. It therefore has no retroactive preregistration authority.

Its stronger follow-on idea is nevertheless useful and is preserved as P07 pressure rather than discarded.

## P07 discriminator earned by P06

P06 proves only that a missing operation can fail locally without mutating one protected state. It does **not** yet prove that such a local failure leaves a distinct later progress-capable activity free to continue.

P07 is therefore earned as a failure-locality / later-progress discriminator:

- activity `A` requests a missing operation and receives local status `M`;
- distinct activity `B` subsequently requests a present operation and must still complete, returning `O` and advancing protected progress state;
- a deliberately bad global-failure-latch control receives the same initial missing request but then blocks activity B with status `X` and leaves progress state unchanged;
- fixture supplies identities/opcodes/state only;
- evaluator consumes raw statuses/state, not self-graded PASS labels.

This directly pressures multiple progress-capable activity behavior plus the distinction between local failure and a global poison latch, without promoting Process/Scheduler/ErrorManager primitives.

P08-P20 remain unwritten.
