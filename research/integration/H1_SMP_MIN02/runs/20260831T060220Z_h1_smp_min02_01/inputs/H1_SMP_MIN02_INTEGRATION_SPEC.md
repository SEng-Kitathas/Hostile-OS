# H1-SMP-MIN02 integration specification — whole-operation gate

Status: **SEALED SPEC BEFORE CANDIDATE IMPLEMENTATION**
Parent: H1-SMP-MIN01 CLOSED PASS
Candidate: post-C005 Candidate A — whole-operation gate
Nature: integration qualification of already-earned C005 rules; not a new science campaign.

## Question

Can the existing shared global relation-call scratch be made safe for two trusted CPU callers by serializing the **entire relation operation** — argument preparation, existing call, and result capture — with one atomic gate, while remaining inside the8192-byte envelope?

## Common setup

Create two current activities A/B and two current resources RA/RB using the existing v2 relation representation/API.

## Bad deterministic scratch-race control

1. BSP writes global input scratch for A->RA.
2. AP waits until that preparation is complete, then overwrites the same global input scratch with B->RB.
3. BSP calls existing `binding_attach_first` without any outer gate.

Required consequence: BSP returns W but A remains unbound while B becomes bound, proving a legal relation operation executed against the wrong caller arguments.

## Good whole-operation gate

Reset/recreate the same two activities/resources. BSP and AP each acquire one atomic shared gate **before** writing global input scratch, keep it through `binding_attach_first` and result capture, then release.

Required consequence: both calls return W; A is bound to RA and B is bound to RB; each resource live count is1.

## Compact S-mode trace

```text
S1_8K_OK
TEST=H1_SMP_MIN02
IDS=0001
BAD=W01
GOOD=WW11
SMP_DONE
```

`BAD=W01` means BSP call statusW, A-bound0, B-bound1.
`GOOD=WW11` means BSP/AP statusesW/W, A-bound1, B-bound1.

## Acceptance

- run-local exact input snapshots;
- linked runtime footprint <=8192;
- named semantic state remains3467 bytes; gate/barrier/result instrumentation must fit existing implementation-scratch allowance;
- exact H1 QEMU proxy S trace above, exit33;
- H1 QEMU C-mode exact regression;
- Bochs one-CPU core/restart/fault replay exact;
- no physical-H1 or arbitrary-SMP claim.

## Decision

PASS means whole-operation serialization is a viable lowest-burden H1 two-core embodiment candidate. It still does not guarantee fairness, stalled-holder recovery, direct untrusted release, or useful relation-level parallelism.

If it cannot fit after reasonable local compression, measure the exact overage before considering Candidate B/C or a larger loader.
