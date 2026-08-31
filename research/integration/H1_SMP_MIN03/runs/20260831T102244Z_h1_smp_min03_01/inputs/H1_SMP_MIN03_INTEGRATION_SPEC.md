# H1-SMP-MIN03 integration specification — single-writer owner + explicit mailbox

Status: **SEALED SPEC BEFORE CANDIDATE IMPLEMENTATION**
Parent: H1-SMP-MIN02 CLOSED PASS
Parent plan: `research/plans/POST_C005_REPRESENTATION_PARETO_CONVERGENCE_2026-08-31.md`
Candidate: post-C005 Candidate B — single-writer relation owner + explicit mailbox
Source body: exact H1-SMP-MIN01 candidate lineage, so Candidate B does not inherit Candidate A's whole-operation gate machinery.
Nature: embodiment/Pareto qualification of already-earned C005 responsibilities; **not a new broad science campaign**.

## Question

Can the H1 two-core increment preserve the existing single-writer relation internals by giving BSP sole relation-mutation ownership and letting AP submit one explicit request/result mailbox, while staying inside the existing8192-byte linked stage2 envelope and preserving all existing reviewer behavior?

## Required mechanism

- BSP is the only CPU permitted to call `binding_attach_first` in S mode.
- AP never writes the existing global relation-call scratch.
- AP writes its mailbox request payload first, then publishes `request=1`.
- BSP waits for `request=1`, copies the mailbox payload into the existing global scratch, calls the unchanged relation operation, writes the result byte, then publishes `done=1`.
- No whole-operation atomic gate is used in Candidate B.
- Central-owner progress dependency is explicit and accepted for this candidate; no fairness/stalled-owner recovery is claimed.

## Test workload

Fresh setup creates activities A/B and resources RA/RB using the unchanged generic body.

1. BSP directly attaches A->RA as owner.
2. AP publishes one mailbox request for B->RB and waits.
3. BSP services that request and publishes completion.
4. AP records completion and halts.

## Required S-mode trace

```text
S1_8K_OK
TEST=H1_SMP_MIN03
IDS=0001
OWNER=BSP
MAIL=WW11
SMP_DONE
```

Interpretation:
- first W = BSP's direct A->RA status;
- second W = AP mailbox request result;
- first `1` = row0 bound to RA;
- second `1` = row1 bound to RB.

## Static/representation requirements

1. S-mode AP worker source contains no `call binding_attach_first`.
2. S-mode AP request payload stores precede publication of mailbox request flag.
3. BSP result store precedes publication of mailbox done flag.
4. S-mode Candidate B contains no Candidate-A `smp_gate` state or `xchg` gate acquisition.
5. Named semantic state `v2_state_begin..v2_state_end` remains exactly3467 bytes.
6. Report exact linked image bytes, raw stage2 bytes, implementation-scratch usage and remaining headroom.

## Regression/target requirements

1. Exact candidate inputs snapshotted before build/run.
2. linked runtime <=8192 bytes.
3. H1 QEMU proxy: `pc-q35-11.1`, `phenom`,2 vCPU,4096 MiB, TCG; exact S trace and exit33.
4. Existing QEMU C-mode core+IRQ trace exact.
5. Bochs one-CPU replay retains exact C mode, restart semantics/invariants and five faulted-media traces/invariants.
6. No claim of physical H1 qualification.

## Pareto decision fields

Compare Candidate B against MIN02 Candidate A on:
- linked bytes / headroom;
- raw bytes;
- added scratch/persistent bytes;
- number of new mechanism ideas;
- serialization scope;
- progress dependency;
- future extension pressure.

PASS does **not** promote Candidate B. After PASS, perform an explicit Candidate A vs B convergence/admission review before changing `d64_reference_v2`.
