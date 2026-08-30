# C003 / P05 preregistration — virtual asynchronous IRQ consequence / idle HLT wake

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P05 of 20
**Earned by:** C003/P04 bounded clean-restart success after rejection of an unearned crash/partial-write branch
**Architecture promotion:** FORBIDDEN

## Why P05 exists

C003 inherits whole-P01 obligations including:
- asynchronous/event consequence;
- idle/no-useful-work behavior.

P01 exercised completion/wait ordering in a bounded freestanding reconstruction, but the consequence was still produced by sequential guest control flow rather than an actual asynchronous virtual-hardware event. P04 closed bounded clean-restart persistence. The highest remaining anti-toy pressure is therefore a real QEMU virtual timer interrupt that releases a guest from `HLT` without launcher/fixture wake behavior.

The previously generated crash/partial-write P05 branch is preserved under `rejected_branches/` but is not authoritative because recovered C002 explicitly says crash/partial-write recovery was not earned.

## P05 question

Can a minimal freestanding real-mode mechanism enter a true idle `HLT` state and resume only because an asynchronously delivered virtual PIT/PIC IRQ0 records explicit event state and releases a waiting activity, without the launcher, fixture, or evaluator performing the wake?

## Machine boundary

- one 512-byte freestanding boot sector;
- standard QEMU 11.1.0;
- real mode;
- guest-installed IRQ0 vector in the IVT;
- guest-programmed 8253/8254-compatible PIT channel 0;
- guest-programmed 8259-compatible PIC masks;
- no host callback into the guest wake path;
- no Process/Scheduler/Service/EventManager primitive.

This is QEMU virtual-hardware evidence. It is not physical-device timing proof.

## Fixture responsibility

The fixture may supply only timer parameters, such as the PIT divisor.

It SHALL NOT:
- set `event_generation`;
- set `woken`;
- clear `waiting`;
- call the IRQ handler;
- inject a software interrupt to fake the event;
- directly call the guest continuation after `HLT`.

## Mechanism state

Minimal explicit guest state:
- `event_generation` byte, initialized 0;
- `waiting` byte, initialized 1 before idle entry;
- `woken` byte, initialized 0.

## Mechanism sequence

1. disable maskable interrupts;
2. initialize DS/ES/SS/stack;
3. install the guest IRQ0 handler at IVT vector 8;
4. mask all PIC interrupt lines except master IRQ0;
5. program PIT channel 0 as a one-shot/terminal-count source using the fixture divisor;
6. set explicit state `event_generation=0`, `waiting=1`, `woken=0`;
7. emit:

```text
PRE_EVENT=0
IDLE_ENTER=PASS
```

8. execute the `STI; HLT` idle boundary;
9. remain in/re-enter `HLT` until the IRQ handler has incremented `event_generation`;
10. IRQ0 handler SHALL:
    - increment `event_generation`;
    - if `waiting==1`, clear `waiting` and set `woken=1`;
    - send PIC end-of-interrupt;
    - return with `IRET`;
11. after wake, guest verifies `event_generation>0`, `waiting==0`, and `woken==1`;
12. emit exactly:

```text
IRQ_EVENT=PASS
IDLE_WAKE=PASS
DONE
```

13. exit deterministically through `isa-debug-exit`.

## Asynchronous discriminator

The wake path is qualified only if:
- the guest reached the idle boundary with `event_generation==0`;
- the IRQ handler is the only code path that can increment `event_generation` or set `woken`;
- the launcher performs no interrupt injection beyond supplying QEMU itself;
- QEMU delivers the virtual PIT/PIC interrupt after guest interrupt enable;
- the exact post-IRQ state is observed.

A boot banner or a direct call into the handler does not satisfy the discriminator.

## Evidence contract

Mechanism, fixture, linker, launcher, evaluator, environment, and consequence remain separate.

Require:
- stable run directory;
- exact source/tool hashes;
- exact QEMU argv;
- process PID/start/end/exit receipt;
- build stdout/stderr;
- 512-byte boot image/signature/hash;
- debugcon artifact/hash;
- QEMU stdout/stderr;
- evaluator stdout/stderr/result/hash;
- bounded launcher timeout;
- post-run non-mutating inspection.

If QEMU does not complete before the launcher timeout, the scientific consequence is `UNKNOWN_TIMEOUT`, not a mechanism failure, unless separate evidence proves the guest reached a known bounded failure state.

## Success / failure criterion

P05 succeeds for this bounded discriminator only if the exact debug observation is:

```text
PRE_EVENT=0
IDLE_ENTER=PASS
IRQ_EVENT=PASS
IDLE_WAKE=PASS
DONE
```

and the independent evaluator confirms the exact matrix with QEMU completing through the deterministic success exit.

A guest-defined failure exit may identify mechanism failure. A launcher timeout remains UNKNOWN.

## Authority ceiling

Success would establish only that the tested QEMU virtual PIT/PIC interrupt can asynchronously move a bounded explicit guest state from idle/waiting to woken without host-language scheduling or launcher wake behavior.

It would not establish:
- physical hardware timing;
- general interrupt-controller architecture;
- scheduler architecture;
- multicore interrupt routing;
- interrupt priority/fairness;
- real-time guarantees;
- architecture promotion.

## Stop rule

Reconcile P05 before deriving P06. P06-P20 remain unwritten until P05 consequence earns the next discriminator.
