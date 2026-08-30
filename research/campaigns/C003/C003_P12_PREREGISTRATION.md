# C003 / P12 preregistration — finite-width generation wrap versus stale-token alias

**Preregistered:** 2026-08-30
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P12 of 20
**Earned by:** C003/P11 bounded explicit-bounds success
**Architecture promotion:** FORBIDDEN

## Why P12 exists

P11 exposed one host safety subsidy: bounded collection mutation needed an explicit low-level bound once raw memory writes were available.

Another high-value Python-host suspect is **arbitrary-width integer semantics**. C002 could use generation/currentness counters without machine-width wrap unless wrap was explicitly modeled. A freestanding machine field has finite width.

P03 already established the value of currentness guarding, but it did not pressure generation alias after wrap. P12 tests only that narrow seam.

## P12 question

After exactly 256 generation increments from zero, can a stale generation-0 token falsely appear current when the generation is stored in 8 bits, while a wider explicit generation representation under the same increments avoids that alias and rejects the stale token?

## Fixture responsibility

The fixture supplies facts only:
- initial generation: word `0`;
- stale token: word `0`;
- increment count: word `256` (`0x0100`).

The fixture SHALL NOT:
- perform increments;
- choose field width;
- compare token/currentness;
- manufacture a fresh token;
- grade the result.

## Mechanism state

The mechanism maintains:
- `generation8`: one byte;
- `generation16`: one word;
- `fresh_token16`: one word, created only after the increment loop.

Both generations start from the same fixture initial generation.

## Shared increment path

The mechanism SHALL load the fixture increment count into a 16-bit loop counter and perform exactly one `generation8 += 1` and one `generation16 += 1` per iteration until the count reaches zero.

With initial generation zero and count 256:
- `generation8` must wrap modulo 256 to `0`;
- `generation16` must become `0x0100`.

The mechanism then snapshots `generation16` into `fresh_token16`.

## Narrow stale-token control

A naive equality-only 8-bit currentness check compares the low byte of stale token `0` with `generation8`.

Because the 8-bit generation wrapped back to `0`, this stale token is falsely accepted as current.

Report status `A` for accepted.

This path is the negative control. It does not claim that 8-bit generations are always invalid; it shows the alias at their exact modulus under this fixture.

## Wider explicit path

The 16-bit currentness check must be an equality comparison, not a reject-all stub.

It SHALL perform two checks:
1. compare `fresh_token16` with `generation16` and report `A` because they are equal;
2. compare stale token word `0` with `generation16` and report `R` because `0 != 0x0100`.

This proves that the wider path still accepts a genuinely current token while rejecting the stale token under the same 256-increment history.

## Exact raw guest observation contract

```text
COUNT_HI=1
COUNT_LO=0
STALE_TOKEN=0
NARROW_GEN=0
NARROW_STALE=A
WIDE_HI=1
WIDE_LO=0
WIDE_FRESH=A
WIDE_STALE=R
DONE
```

The guest SHALL emit raw facts only and SHALL NOT self-grade PASS.

## Independent evaluator

The evaluator SHALL require exact line equality and separately verify:
- fixture count is observed as high byte 1, low byte 0;
- stale token is 0;
- 8-bit generation after the shared loop is 0;
- narrow equality falsely accepts the stale token (`A`);
- 16-bit generation after the same shared loop is high byte 1, low byte 0;
- fresh 16-bit token is accepted (`A`);
- stale 16-bit token is rejected (`R`).

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- one 512-byte boot image with `55aa` signature/hash;
- exact QEMU argv/PID/start/end/exit;
- bounded launcher timeout;
- debugcon artifact/hash;
- build/QEMU/evaluator stdout+stderr;
- evaluator result/hash;
- durable receipt;
- post-run non-mutating inspection.

Timeout or ambiguous process state = UNKNOWN.

## Success / failure criterion

P12 succeeds only if the exact raw observation matches the preregistered matrix with deterministic QEMU success exit and independent evaluator pass.

A completed alternate matrix is a qualified mechanism failure. Build failure before execution is an engineering scar with no scientific consequence. Timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that, under exactly 256 increments from zero, an 8-bit equality-only generation check aliases stale token 0 while a 16-bit representation avoids that specific alias and still accepts a fresh token.

It would not establish:
- that 16 bits is generally sufficient;
- wrap-free generations at arbitrary lifetime;
- monotonic-clock semantics;
- ABA freedom in general;
- cryptographic uniqueness;
- arbitrary-width integer replacement as a whole;
- allocator, process, scheduler, or manager architecture;
- architecture promotion.

A 16-bit field will itself wrap after 65536 increments unless another rule exists. P12 is about exposing the finite-width design burden, not choosing a universal width.

## Pareto / ontology pressure

The test should pay only for the width distinction needed by the fixture. Do not import a general big-integer library or a generation manager to reproduce Python's unlimited integer behavior.

## Stop rule

Reconcile P12 before deriving P13. P13-P20 remain unwritten until P12 consequence earns the next discriminator.
