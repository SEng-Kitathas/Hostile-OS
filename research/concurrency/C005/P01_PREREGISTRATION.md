# C005/P01 preregistration — local interrupt masking versus second-CPU observation

Status: PREREGISTERED BEFORE IMPLEMENTATION

## Question

Does `cli` around a coupled shared-state mutation prevent a second CPU from observing a mixed state, or is inter-CPU exclusion separately required?

## Two-CPU fixture

- QEMU i386 TCG with `-smp 2`;
- BSP starts AP1 using the local APIC INIT/SIPI path;
- shared coupled bytes begin `A=11, B=22`;
- target final pair is `A=33, B=44`;
- AP repeatedly observes the pair while BSP mutates it.

## Bad/current one-core witness

BSP executes `cli`, writes `A=33`, leaves a deliberate finite instruction window, then writes `B=44`, then `sti`.

AP is not interrupt-masked by BSP's `cli`.

Expected discriminator: AP observes at least one mixed `33/22` state.

## Good witness

Use one byte of shared exclusion acquired with an atomic x86 `xchg` by both BSP mutation and AP observation. BSP may still use `cli` locally, but AP observes the pair only while holding the same inter-CPU exclusion.

Expected discriminator: AP observes no mixed state and eventually observes final `33/44`.

## Required controls

- AP startup/ready must be explicit;
- both CPUs must report participation;
- bad and good phases use the same coupled bytes and target values;
- run exits cleanly only after AP confirms final state in both phases;
- a timeout is UNKNOWN.

## Ceiling

PASS would earn only `LOCAL_INTERRUPT_EXCLUSION != INTER_CPU_EXCLUSION` and show atomic shared exclusion as one working witness on tested QEMU x86 SMP. It would not promote a lock object, scheduler, fairness rule, memory model, or physical-hardware guarantee.
