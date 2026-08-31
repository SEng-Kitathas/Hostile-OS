# C004/P07 preregistration — first actual privilege enforcement boundary

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P06 CLOSED PASS

## Question

Can a hardware privilege/address boundary prevent untrusted guest code from acquiring direct writable access to kernel-owned state while still allowing an explicit mediated transition back to trusted code?

## Candidate witness

Use x86 protected mode only as an enforcement witness, not as architecture authority:
- ring0 flat kernel code/data segment owns resource X=7E;
- ring3 code/data segment is a separate bounded user region;
- ring3 cannot load the ring0 data selector;
- #GP is caught by a ring0 handler through a TSS/IDT privilege transition;
- handler resumes ring3 after the denied selector load;
- ring3 invokes an explicit DPL3 interrupt gate to trusted code;
- trusted handler reports the result and exits.

## Expected discriminator

One freestanding boot must show:
- user mode entered;
- ring3 attempt to load kernel writable data selector causes exactly the expected #GP path;
- protected resource X remains7E;
- explicit mediated ring3->ring0 gate is reached after the fault;
- guest exits normally through the trusted handler.

## Bad/control relationship

P06 already supplies the same-domain raw-store control where no privilege boundary exists and X becomes55. P07 does not recolor or replace it.

## Ceiling

If observed, P07 earns only that **some non-bypassable enforcement boundary is required and x86 privilege separation is one working witness** for this bounded mutation consequence.

It does not make x86 rings, segmentation, TSS, system-call gates, processes, users, or a microkernel into HOSTILE-OS primitives. It does not yet test read/write rights through the mediated gate; that is a later discriminator if P07 passes.
