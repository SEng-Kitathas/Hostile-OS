# C003 / P14 — two-field transition coherence under a real IRQ observer

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P14 of 20
**Architecture promotion:** NONE
**P15 earned:** YES

## Question

Can masking the tested IRQ across both writes keep a two-field transition coherent to a real interrupt observer, while enabling the IRQ after only the first write exposes a torn intermediate state?

## Controlling preregistration

`C003_P14_PREREGISTRATION.md` was sealed at Git commit `ec0c38624be9bce17c2e559ef0b3695cd82cf26f` before any P14 mechanism code or execution existed.

## Controlling scientific run

Run: `20260830T021500Z_p14_irq_coherence_01`

QEMU:
- PID: `32036`
- started: `2026-08-30T02:15:25.075331+00:00`
- ended: `2026-08-30T02:15:25.281090+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator exit: `0`.
Evaluator stderr: empty.

## Exact raw observation

```text
GOOD_IRQ_OWNER=B
GOOD_IRQ_CONT=2
GOOD_POST_OWNER=B
GOOD_POST_CONT=2
BAD_IRQ_OWNER=B
BAD_IRQ_CONT=1
BAD_POST_OWNER=B
BAD_POST_CONT=2
DONE
```

Evaluator version: `C003-P14-irq-coherence-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `493f1821fa20cfdfcb6431ce133f66e4ec6f3b2817d4a115f765aefca67b0671`
- fixture: `1ef3798c4ec919e3d2e71dd0950961bc71280579ca46c047c823035ef39650b3`
- linker: `2c36d0129eb2b3adba7d1dd31079d2cfa991ce214e73e36d2ad3e00bd727cdb8`
- evaluator: `622ce402a42d14a2e7b7263371cad3730a0ea93ccfba25ae83f8dd522d8bf5c6`
- launcher: `e5f27584d19b30e9b65dee87ac478b0137f8e5ba780411c238a86bad28ef8a15`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `29c3f18449d6c6ffc5d4807e66de7a3496a014b721ac83cbe7add4a8de79cb84`
- debugcon SHA-256: `64f12511b8bae5f9052e9ed9c666832009834c31779560aba2d64ff69334996e`
- evaluation SHA-256: `eab4b26bd8bf28e04ff9433834024266c6390bcaedfefec72f203b4fe838045b`
- receipt SHA-256: `9162a95c04b439764fb1c18124bd42c3684fe33b2fcc17dc55edddb29ee1e490`
- evaluator stdout SHA-256: `5a8dfb5bef5933497f8592a0d79e11609f584d4ebda7d99ff8ae4321ae1d3334`
- all QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating closure matched all source and run hashes, exact raw output, evaluator pass state, and QEMU `COMPLETED/33` state.

## Static/source closure

Source inspection confirmed:
- IRQ0 handler reads `relation_owner` and `relation_continuation` into separate snapshot bytes;
- IRQ0 handler does not write either tested relation field;
- good path instruction order is owner write -> continuation write -> IRQ0 unmask -> `STI`;
- bad path instruction order is owner write -> IRQ0 unmask -> `STI; HLT` observation -> continuation write.

The handler therefore observed the transition rather than manufacturing or repairing its result.

## Qualified consequence

For this real-mode QEMU IRQ0 slice:

- old relation state was `A/1` and target state was `B/2`;
- with IRQ0 masked across both byte writes, the real IRQ handler observed coherent `B/2`;
- the final good state remained `B/2`;
- when IRQ0 was enabled after the owner write but before the continuation write, the same handler observed torn `B/1`;
- after wake, the guest completed the second write and final bad-path state became `B/2`;
- the hidden host assumption that a multi-field transition is indivisible therefore does not survive direct low-level embodiment automatically;
- IRQ masking across this coupled update was sufficient for this one observer and this one two-byte transition.

## Authority ceiling / nonclaims

P14 does **not** establish:
- general atomicity;
- multiprocessor atomicity;
- lock-free correctness;
- transaction semantics;
- non-maskable interrupt safety;
- DMA coherence;
- memory-ordering rules beyond this uniprocessor real-mode QEMU slice;
- a global lock or Scheduler primitive;
- physical-hardware proof;
- architecture promotion.

## Pareto / ontology consequence

The bounded coherence property did not require a transaction subsystem. The tested cost was only masking the relevant interrupt while two coupled bytes changed.

That mechanism is not free: widening coupled transitions increases interrupt-off time and may create latency cost. Future compositions must therefore count synchronization and latency in the same Pareto vector as byte/state cost.

## P15 discriminator earned by P14

A high-value remaining host subsidy is **dynamic capacity growth / allocation**.

Python containers could grow to admit another relation entry without forcing the C002 mechanism to expose a hard capacity boundary. A freestanding fixed-capacity representation must make exhaustion behavior explicit.

P15 should pressure the smallest capacity discriminator:
- exactly two relation slots begin free;
- identities A and B are admitted, filling both slots;
- a good admission of C detects `count == capacity`, returns bounded status `F`, and preserves A and B unchanged;
- a bad overwrite-on-full control admits C by reusing slot 0 without an explicit release, clobbering A while leaving B;
- the evaluator must verify both successful initial admissions, explicit full status, preservation in the good path, and clobbering in the bad path.

P15 must remain a fixed-capacity exhaustion test. It does not earn a heap, allocator, dynamic array, Process table, or Manager primitive. P16-P20 remain unwritten.
