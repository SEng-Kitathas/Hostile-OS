# C005 post-close multicore donor pressure — 2026-08-31

Status: **EXPLORATORY DONOR PRESSURE / NON-AUTHORITATIVE**
Local seam first: current `d64_reference_v2` relation calls use shared global input/output scratch. A narrow internal lock alone cannot make those call interfaces safely concurrent because two CPUs could race while preparing arguments/results before/after the protected transition.

## Donor A — seL4 SMP big-lock approach

Current seL4 multicore documentation describes an SMP kernel using a big-lock approach for tightly coupled cores, while separately noting multikernel designs for higher core counts. Historical seL4 research material also discusses the big kernel lock as a deliberate low-core-count tradeoff whose costs include serialization/WCET/timing effects.

Donor consequence only: **whole-operation serialization is a legitimate low-complexity candidate at small core count when critical operations are short.**

It does not prove HOSTILE-OS should have a Big Kernel Lock, Thread, Scheduler or syscall architecture.

Sources consulted:
- seL4 FAQ, “Does seL4 support multicore?” — seL4 project documentation.
- Gernot Heiser, seL4 Research Update / “Getting Rid of the Big Kernel Lock?”, 2022.

## Donor B — Barrelfish multikernel

Barrelfish's multikernel model makes inter-core communication explicit and treats operating-system state as replicated rather than assuming one shared kernel-state image. Cores communicate via messages.

Donor consequence only: **single-writer/per-core state plus explicit communication is a real alternative to shared-memory locking**, particularly when shared scratch and cache-line movement become dominant.

It does not prove HOSTILE-OS should become a multikernel or import replicated-kernel/process/message ontology.

Sources consulted:
- Baumann et al., “The Multikernel: A new OS architecture for scalable multicore systems,” SOSP 2009.
- Microsoft Research Barrelfish project material describing explicit inter-core communication and replicated state.

## Donor C — K42 scalability work

K42 is additional evidence that multiprocessor operating systems can specialize resource-management representation and implementation instead of imposing one universal synchronization strategy. It is weaker pressure for the immediate H1 seam than the deliberately opposite seL4/Barrelfish pair.

Source consulted:
- IBM Research, “K42: An Infrastructure for Operating System Research.”

## HOSTILE-OS adjudication

Donors do not choose the architecture. The local candidates remain:

1. **whole-operation global gate** — serialize caller scratch preparation + relation operation + result capture;
2. **single-writer relation owner + explicit mailbox** — keep relation tables single-writer and send operations across cores;
3. **per-CPU scratch + narrow transition gate** — make call arguments/results non-shared, then protect only coupled relation mutations.

For H1's two-core target, candidate1 is the lowest immediate representation/code burden and should be prototyped first. Candidate2 remains a high-value alternate if whole-operation serialization creates unacceptable progress/latency burden. Candidate3 remains an alternate if direct multi-CPU relation operations become a required capability.

No donor noun is adopted as primitive architecture by this review.
