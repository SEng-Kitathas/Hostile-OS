# D64 interrupted durable-write plan — 2026-08-30

Status: BUILD-PLAN CANDIDATE / NOT PREREGISTRATION
Parent: D64/FR01 deterministic faulted-media recovery CLOSED PASS

## Next question

When the guest actually writes a new durable candidate and the QEMU process is deliberately terminated at controlled points around that write, what disk states are observable, and does the already-qualified FR01 reader either select a complete new record, fall back to the old valid record, or fail closed?

## Why this comes next

FR01 qualified the recovery format against explicit preconstructed media states. It did not establish that real BIOS/QEMU writes produce those states under interruption.

The next experiment should pressure the **writer/transport path**, not redesign the reader first.

## Proposed campaign shape

- Begin with sector A valid old sequence1/value71 and sector B empty.
- Guest constructs complete sequence2/value72 record in RAM.
- Writer exposes explicit debug markers immediately before and after the BIOS sector write to B.
- Host runs fresh QEMU processes and terminates them under preregistered timing/marker strategies around the write.
- After each termination, host hashes/extracts sectors A/B without modifying them.
- A separate fresh recovery boot uses the already-qualified FR01 validation/selection logic against that resulting disk.

## Required distinctions

Keep separate:
- host requested termination time;
- actual QEMU process terminal time/state;
- guest last observed debug marker;
- disk bytes observed after process termination;
- recovery boot consequence.

Timeout/uncertain kill state is `UNKNOWN`.

## Candidate pressure classes

1. kill before guest issues write;
2. kill immediately after pre-write marker but before confirmed post-write marker;
3. kill after post-write marker;
4. repeated timing sweep around the write window;
5. clean-write control;
6. host-created torn fixture remains a calibration control, not the interrupted-write result itself.

## Authority ceiling even if successful

This would remain QEMU/BIOS interruption evidence. It would not prove physical-device power-loss guarantees, cache flush behavior, or sector atomicity on real hardware.

Before preregistration, inspect whether QEMU/floppy/BIOS writes complete synchronously enough that process-kill timing can produce meaningful intermediate states; if the transport only exposes old-or-new whole sectors, report that rather than manufacturing a tear.
