# H1-SMP-MIN02 result — whole-operation gate

Status: **CLOSED PASS / INTEGRATION QUALIFICATION**
Implementation baseline commit: `5e5db3d`
Reporting Amendment A commit: `1f1ca34`
Controlling run: `runs/20260831T060220Z_h1_smp_min02_01`

The candidate used the existing v2 relation representation and shared global call scratch. Bad phase let BSP prepare A->RA arguments, then AP overwrote the same global inputs with B->RB before BSP called `binding_attach_first`. BSP returned W but the resulting relation was B->RB, not A->RA (`BAD=W01`).

Good phase used one atomic gate across **argument preparation + existing relation call + result capture** for each CPU. BSP attached A->RA and AP attached B->RB correctly (`GOOD=WW11`).

Regression/fit evidence:
- linked runtime: **8189 / 8192 bytes**;
- headroom: **3 bytes**;
- named semantic state unchanged: **3467 bytes**;
- H1 QEMU S-mode exact;
- H1 QEMU existing C-mode core+IRQ exact;
- Bochs one-CPU core/restart/five-fault replay exact.

The first sealed run `20260831T060112Z_h1_smp_min02_01` remains non-controlling because BAD row bits were reported after the good reset. Amendment A changed only report timing; the controlling rerun passed.

Consequence: **whole-operation serialization is a viable lowest-concept-count way to make the existing shared-scratch relation API safe for two trusted callers, but in the current verbose reviewer body it consumes essentially the entire8 KiB envelope.**

MIN02 does not replace `d64_reference_v2`; Candidate B (single-writer relation owner + explicit mailbox) should be priced before a successor-body choice.
