# C005/P01 result — local interrupt masking versus second-CPU observation

Status: **CLOSED PASS**
Implementation baseline commit: `8a2fea1`
APIC transport Amendment A commit: `26a713c`
Controlling run: `P01/runs/20260831T033500Z_c005_p01_01`

Two QEMU i386 TCG CPUs participated (`CPU_COUNT=02`, `AP_READY=1`, `AP_DONE=1`).

Bad/current one-core witness: BSP used local `cli`, wrote A=33, held a finite deliberate window, then B=44. AP observed the mixed pair (`BAD_MIXED=1`) and later final33/44 (`BAD_FINAL=1`).

Good witness: both BSP mutation and AP observation used the same atomic `xchg` exclusion byte. AP observed no mixed pair (`GOOD_MIXED=0`) and eventually observed final33/44 (`GOOD_FINAL=1`).

Earned: `LOCAL_INTERRUPT_EXCLUSION != INTER_CPU_EXCLUSION` at tested QEMU x86 SMP scope. Atomic shared exclusion is one working witness. No lock object, scheduler, fairness rule, weak-memory model or physical-hardware guarantee is earned.

First attempt's AP-start failure remains a harness scar; it did not reach the coherence discriminator.
