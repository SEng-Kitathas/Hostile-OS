# C003 / P05 — virtual asynchronous IRQ consequence / idle HLT wake

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P05 of 20
**Architecture promotion:** NONE
**P06 earned:** YES

## Question

Can a minimal freestanding real-mode mechanism enter a true idle `HLT` state and resume only because an asynchronously delivered virtual PIT/PIC IRQ0 records explicit event state and releases a waiting activity, without the launcher, fixture, or evaluator performing the wake?

## Preregistered machine boundary

- one 512-byte freestanding boot sector;
- standard QEMU 11.1.0 under TCG;
- real mode;
- guest-installed IRQ0 vector 8 in the IVT;
- guest-programmed PIT channel 0 one-shot/terminal-count source;
- guest PIC mask permitting only master IRQ0;
- fixture supplies only a PIT divisor;
- no host callback, software interrupt injection, or launcher wake path;
- no Process/Scheduler/Service/EventManager primitive.

## Durable run

Run: `20260829T213200Z_p05_async_irq_idle_01`

QEMU process:
- PID: `4468`
- start: `2026-08-29T21:32:44.592347+00:00`
- end: `2026-08-29T21:32:44.791015+00:00`
- status: `COMPLETED`
- expected exit: `33`
- observed exit: `33`
- launcher timeout: `8` seconds

Exact guest observation:

```text
PRE_EVENT=0
IDLE_ENTER=PASS
IRQ_EVENT=PASS
IDLE_WAKE=PASS
DONE
```

Evaluator version: `C003-P05-async-irq-idle-v1`

Evaluator result: `passed=true`, exit `0`.

QEMU stdout/stderr: empty.
Evaluator stderr: empty.

## Exact source hashes

- mechanism: `327c6775c3b283fa07038ba28483597d2132852d051cc3e963117a7906290cac`
- fixture: `99c96c50541529d525fe520dc70586b9c12ca60d3eb85e437ed1a56646d1e74e`
- linker: `2a579f1f9db4d8451eb217453a72ff4397af10ee5981f82fb88e3560703f3af7`
- evaluator: `34acf704f7de11c82caeb3fe57b6f1b8096d359b8e046533a11ca89f715c1bcf`
- launcher: `1842464dbc2cbf415966cd0b216deb9ede2f698d67d526834d8c7d47309fc1f3`

## Exact run artifacts

- boot image: 512 bytes
- boot image SHA-256: `095b347019351a392759778e8ccb47428f9f0b5651b0b49aed0942c2f8b23fe9`
- debugcon SHA-256: `2fa966d8fb3407a4681ed337ec09286593cd030ea12fe6860117585a20992524`
- evaluation SHA-256: `d857149ba40fc752450e85f548f54fd7b0b0005b33fd3543e16b61f98561094a`
- receipt SHA-256: `445cfb5b8d244a96ed1984568ea2e65284828d82339c2e351decebeb4ac1f288`
- QEMU stdout SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- QEMU stderr SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- evaluator stdout SHA-256: `5e0b8e49771210d815a700a553eaef644b67779a3a0c024aa2c739147bb585e4`
- evaluator stderr SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating hash inspection matched the receipt for all checked artifacts.

## Causal boundary check

Static inspection of `mechanism.S` confirms:

- initialization writes `event_generation=0`, `waiting=1`, `woken=0` before idle entry;
- ordinary post-HLT code only reads/checks these fields;
- the IRQ0 handler is the only post-initialization code path that increments `event_generation`, clears `waiting`, or sets `woken`;
- the launcher QEMU argv contains no interrupt-injection mechanism or host callback into the wake path.

The mechanism executes `STI; HLT`, then does not pass the post-idle state check until the virtual IRQ0 handler has changed explicit state and returned with `IRET`.

## Qualified consequence

For this bounded standard-QEMU virtual-hardware fixture:

- the guest reached idle with event generation zero and a waiting relation active;
- an actual QEMU virtual PIT/PIC IRQ0 caused the guest-installed handler to update event/current wait state;
- the waiting state was released and ordinary execution resumed after `HLT`;
- the launcher, fixture, and evaluator did not perform the wake;
- a separate idle identity is not required for the tested no-useful-work → halt-while-wakeable consequence;
- Python host scheduling/timing, Python callbacks, Python exceptions, and interpreter continuation are not required to realize this tested asynchronous wake path in the guest.

This removes fixture-supplied event provenance from the tested slice: provenance is the declared QEMU virtual PIT/PIC path.

## What P05 does not earn

P05 does not establish:

- physical hardware timing;
- general interrupt-controller architecture;
- scheduler architecture;
- multicore interrupt routing;
- interrupt priority/fairness;
- real-time guarantees;
- SMP or memory-ordering correctness;
- architecture promotion.

## P06 discriminator earned by P05

After P05, the inherited whole-P01 obligation still explicitly unembodied with the highest direct anti-toy value is **bounded missing-operation failure**.

C002's surviving claim is narrow: a bounded local failure can preserve coherent later progress without requiring a global error-manager object. The Python ancestor may have hidden this distinction behind exception/control-flow machinery.

P06 SHALL therefore pressure the smallest fixed-capacity operation-dispatch mechanism in which:

1. one activity requests an operation identity that is absent;
2. the missing request produces a bounded local failure result rather than mutating a global failure latch;
3. a distinct later progress-capable activity requests a present operation and still completes coherently;
4. an intentionally global-failure control demonstrates the opposite consequence by blocking that later progress after the same missing request.

The fixture may supply activity identities and requested operation identities only. It may not decide missing/present status, synthesize the local failure, or execute the later successful operation.

This discriminator may pressure finite/multiple-progress activity state and exception/control-flow subsidy at the same time, but it SHALL NOT introduce a Process, Service, exception runtime, global ErrorManager, or scheduler primitive.

P07-P20 remain unwritten.
