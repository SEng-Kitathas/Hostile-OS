# H1-SMP-MIN01 integration specification — AP bring-up fit test

Status: **SEALED SPEC BEFORE CANDIDATE IMPLEMENTATION**
Parent plan: `research/plans/POST_C005_REPRESENTATION_PARETO_CONVERGENCE_2026-08-31.md`
Source body: exact committed `os/research_only/d64_reference_v2/`
Nature: embodiment/integration qualification of already-earned C005 responsibilities; **not a new broad science campaign**.

## Question

Can the current D64-v2 body add a real second-core startup/provenance reviewer mode without exceeding the existing8192-byte linked stage2 envelope or changing existing C/R/F semantics?

## Candidate delta

Only:
- mode `S` dispatch;
- AP trampoline in free low memory at0x6000;
- x86 local-APIC INIT/SIPI startup of APIC ID1;
- BSP/AP local APIC ID readback;
- AP-ready handshake;
- compact S-mode trace.

No relation-table concurrency, user authority, scheduler, mailbox, forced recovery, versioned readers or new durable state are admitted in MIN01.

## Required S-mode trace

```text
S1_8K_OK
TEST=H1_SMP_MIN01
BSP_ID=00
AP_ID=01
AP_READY=1
SMP_DONE
```

## Acceptance

1. Candidate source/build inputs snapshotted exactly before build/run.
2. linked runtime `.text + .rodata + .bss <=8192` bytes.
3. H1 QEMU proxy uses `pc-q35-11.1`, `phenom`,2 vCPU,4096 MiB, TCG, no network and emits exact S-mode trace with exit33.
4. Candidate C mode retains exact current D64-v2 core+IRQ trace under H1 QEMU proxy.
5. Candidate Bochs one-CPU replay retains exact C mode, restart two-boot semantics/invariants and five faulted-media traces/invariants.
6. No claim of physical H1 qualification.

## Decision after result

- PASS: proceed to MIN02 whole-operation-gate prototype inside the same envelope.
- envelope FAIL: measure exact burden before considering compression or larger-loader qualification.
- semantic replay FAIL: stop and localize regression before MIN02.

Passing MIN01 does not replace `d64_reference_v2`.
