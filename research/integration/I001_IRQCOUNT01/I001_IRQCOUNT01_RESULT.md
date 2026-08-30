# I001/IRQCOUNT01 result — real IRQ0 event-count semantic discriminator

Date: 2026-08-30
Status: CLOSED PASS
Architecture posture entering/leaving experiment: `INTEGRATED_SHADOW_CANDIDATE`

## Lineage

- Original preregistration commit: `564f454` — `Preregister I001 IRQ event-count semantic discriminator`
- Initial implementation commit: `c5e5f9c`
- Pre-execution print/provenance helper correction: `c1e0eaa`
- Retained pre-build launcher-root scar + correction: `9acf271`
- Amendment A + retained one-shot-PIT timeout: `4c4d6eb`
- Retained non-controlling PASS + amendment-snapshot launcher fix: `d637a79`
- Controlling run source HEAD: `d637a79f22e2551b3993de6c64c74213a9623c9a`

Historical I001 source/evaluator/result were not modified.

## Attempt history

### Attempt 0 — pre-build launcher provenance failure
`runs/20260830T202937Z_i001_irqcount01_01`

The launcher used the wrong Git-root parent. It failed before build and before QEMU. Retained as a launcher/provenance scar. No science consequence.

### Attempt 1 — one-shot PIT fixture failure
`runs/20260830T203047Z_i001_irqcount01_01`

ONE completed exactly as preregistered. MULTI timed out after the first event because PIT command `0x30` selects mode 0 one-shot; the fixture had incorrectly assumed a second event would occur without rearming. QEMU status was `UNKNOWN_TIMEOUT`; evaluator/audit failed because the trace stopped after ONE. Static closure passed. The attempt is retained and explicitly adjudicated `FAILED_FIXTURE / NO_SCIENCE_CONCLUSION`.

Amendment A was then sealed before rerun. It requires guest-side rearming of the same real PIT one-shot after a sub-threshold event count.

### Attempt 2 — semantic PASS, provenance non-controlling
`runs/20260830T203223Z_i001_irqcount01_01`

The amended fixture produced the exact preregistered one/two/bad-relation trace and passed evaluator/static/audit, but the run-local input set had snapshotted the original preregistration without Amendment A. It is retained as `NON_CONTROLLING_PASS`.

### Attempt 3 — controlling PASS
`runs/20260830T203401Z_i001_irqcount01_01`

This run snapshotted all build/evaluator/static/audit inputs plus the original preregistration and Amendment A before build/execution.

## Controlling execution

- QEMU PID: `28520`
- scientific status: `COMPLETED`
- exit code: `33`
- wall time: `227.2124 ms`
- stage1: `512` bytes, valid `55 aa`
- stage2 raw: `902` bytes inside fixed `4096`-byte extent
- evaluator exit: `0`
- static checker exit: `0`
- independent audit exit: `0`
- `all_pass`: `true`
- originals unchanged through closure: `true`

## Controlling trace

```text
S1_OK
TEST=I001_IRQCOUNT01_1
ONE_EVENT=1
ONE_REL=1
ONE_SEM=W
ONE_WAKE=1
ONE_PREPROG=0
ONE_PROG=2
ONE_EXACT=W
MULTI_EVENT=2
MULTI_REL=1
MULTI_SEM=W
MULTI_WAKE=1
MULTI_PREPROG=0
MULTI_PROG=2
MULTI_EXACT=R
BADREL_EVENT=2
BADREL_REL=0
BADREL_SEM=R
BADREL_WAKE=0
BADREL_PROG=0
DONE
```

## Evaluator closure

All 5 checks are literal JSON booleans `true`:
- exact trace;
- ONE semantic accept;
- MULTI same semantic consequence;
- exact-count control discriminates;
- BADREL rejects.

## Static/source closure

All 15 checks are literal JSON booleans `true`, including:
- real IRQ0 vector installation;
- PIT programming;
- handler-owned event increment;
- relation recomputation in the handler;
- threshold masking;
- PIC EOI;
- HLT-based wait;
- guest-side real-PIT rearm after sub-threshold count;
- semantic gate requires nonzero event + valid relation;
- semantic gate does not require exact count one;
- exact-one control separately requires one;
- BADREL is a generation mismatch;
- wake and progress application remain separate;
- stage1 loads the fixed eight-sector extent.

## Independent audit closure

All 11 checks are literal JSON booleans `true`, including run-input manifest integrity, binary envelope, one/multi real-event traces, BADREL negative control, same one/multi progress result, and exact-count-control rejection of MULTI.

## Input-snapshot closure

Input manifest format: `I001_IRQCOUNT01_INPUTS_V2`.

All nine controlling inputs were snapshotted and hash-verified before build:
- stage1 source/linker;
- stage2 source/linker;
- evaluator;
- static checker;
- independent audit;
- original preregistration;
- Amendment A.

## Evidence hashes

- receipt: `719dbeac81fd9010e5ecc0ad64cae5f08535eee5a66faab7f7f52cad705280f4`
- evaluation: `fa993d86277e52479db495d5597f04148e0269e6a89b94bb2627d6e2bfe0d9ba`
- static closure: `cf922602cdc7400f3d2dd30a9fc2c656c578610e34a7e3b586a9db0ce4044e15`
- independent audit: `c7b5f10b33caa6a240e0c83f108b273d93b0296c903d03f3b41f2d93b123bb81`
- debug trace: `3db85cd663de244311694167ad158ccd95efc37a337fae91525805bb8992cefc`
- stage2 raw: `97923b4eef00848f127c992420748d9047f724b4359ef269804b62b6396ae37a`
- input manifest: `c8d5863d00e3f5a2112bc1e4a487edc0404e5cb4296d76252eaf22d95718eec2`
- boot image: `6f960326e3a6f402048506133f0dd4a5bbb2a09248020fd5c53fcb32e05f8098`

## Earned consequence

At the tested one-core real-IRQ0 scope, **exact event cardinality `1` is not load-bearing for the tested wake/progress consequence**.

With the same valid wait relation:
- one real IRQ0 produced semantic accept, wake 1, explicit progress 2;
- two real IRQ0 handler entries produced the same semantic accept, wake 1, explicit progress 2;
- the deliberately exact-one gate accepted the first and rejected the second.

With two real IRQ0 events but a deliberately stale generation relation:
- relation-valid remained 0;
- semantic gate rejected;
- wake remained 0;
- progress remained 0.

Therefore event presence alone is insufficient; current/coherent relation state remains load-bearing. The tested semantic gate is **nonzero event + valid relation**, exercised at event counts 1 and 2.

## Historical I001 implication

A separate reconciliation of all retained long-replay I001 red runs found all 660 share exactly one Boot-1 difference from the historical expected trace: line index 13 changed from `IRQ_EVENT=1` to `IRQ_EVENT=2`. Boot 2 is exact in all 660.

Given IRQCOUNT01, those 660 runs are now classified as **historical exact-evaluator overbinding for this tested consequence**, not mechanism regressions. Their original evaluator status remains FAIL and is not rewritten.

## Authority ceiling

This PASS does not earn:
- arbitrary event counts greater than 2;
- interrupt coalescing/loss semantics;
- SMP/NMI/DMA or weak-memory behavior;
- production interrupt policy;
- physical-hardware proof;
- final architecture promotion.

The experiment closes only the exact-one-versus-tested-positive-event/current-relation seam for real IRQ0 counts 1 and 2.
