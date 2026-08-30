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

Before preregistration, inspect whether QEMU/floppy/BIOS writes complete synchronously enough that process-kill timing can produce meaningful intermediate states; if the transport only exposes old-or-new whole sectors, report that rather than manufacturing a tear.## Feasibility readback — 2026-08-30

Non-scientific feasibility is now recorded at:
`research/persistence/D64_IW00_FEASIBILITY_2026-08-30/`.

Using the sealed PR01 writer, QEMU TCG/GDB remote control, `cache=directsync`, and a breakpoint immediately before the real BIOS `int 13h` write instruction (`0x837d`):

- the durable sector stayed whole-old through BIOS single-step 546;
- at single-step 547 it changed directly to the complete new PR01 sector hash;
- no intermediate/torn bytes were visible at guest-instruction stop points;
- five fresh QEMU repetitions produced the same first-change step 547 and same complete post-write hash.

This means a host wall-clock kill race is **not** appropriate as the sole controlling discriminator. The emulated block action appears indivisible at guest-instruction observation granularity in this envelope.

## Refined next experiment

The next controlling experiment should test **process termination at actual guest-write boundaries**, not claim a mid-sector tear:

1. use a new FR01-format writer that starts from valid A seq1/value71 and writes valid B seq2/value72 through BIOS INT13;
2. identify the real writer `int 13h` instruction address from the sealed writer ELF;
3. in several fresh calibration processes, breakpoint immediately before the call and single-step BIOS until the B sector first changes;
4. require the first-change step to be repeatable and require every observed instruction-boundary B state to be either exact empty/old or exact complete-new;
5. terminate fresh QEMU writer processes while stopped at:
   - immediately before `int 13h`;
   - one guest instruction before the calibrated first media transition;
   - immediately after the calibrated first media transition;
   - clean-write control;
6. after termination, hash/extract A/B sectors;
7. create a recovery copy by replacing **only** boot/stage2/fixture-label sectors with the already-sealed FR01 reader; prove A/B hashes are unchanged by this overlay;
8. boot the unchanged FR01 reader and verify it selects A for old/empty B and B for complete valid new B.

This earns process-termination persistence/recovery at controlled guest instruction boundaries. It still does not earn mid-device-action interruption or physical power-loss semantics.

## Optional stress plane

Only after the controlled boundary experiment closes, an observational stress sweep may release QEMU from the pre-write breakpoint and issue host process termination at varied wall-clock delays. Any observed B state is classified exactly:
- old/empty;
- complete new;
- other/torn/unknown.

That sweep is reliability/transport discovery, not the controlling science discriminator. If it reveals a new media state, the FR01 reader must be run against that exact state before any interpretation.
