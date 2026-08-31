# H1-SMP-MIN03 result — single-writer owner + explicit mailbox

Status: **CLOSED PASS / INTEGRATION QUALIFICATION**
Spec commit: `71e708b`
Implementation commit: `dbf2291`
Controlling run: `runs/20260831T102244Z_h1_smp_min03_01`

Candidate B preserved the existing single-writer relation internals. In S mode only BSP called the unchanged `binding_attach_first`; AP wrote a six-byte request payload into a separate mailbox, published request only after payload, waited for completion, and never touched the legacy relation-call scratch. BSP copied the mailbox payload into the existing scratch, performed B->RB, stored result W, then published done.

Exact S trace:

```text
S1_8K_OK
TEST=H1_SMP_MIN03
IDS=0001
OWNER=BSP
MAIL=WW11
SMP_DONE
```

All qualification checks passed:
- linked runtime **8089 / 8192 bytes**;
- remaining headroom **103 bytes**;
- raw stage2 **4494 bytes**;
- named semantic state unchanged **3467 bytes**;
- implementation scratch used **62 / 128 bytes**;
- AP has no relation mutation call and no legacy input-scratch writes;
- request payload precedes request publication;
- result store precedes done publication;
- no Candidate-A `smp_gate` / `xchg` machinery;
- H1 QEMU S-mode exact;
- H1 QEMU existing C-mode core+IRQ exact;
- Bochs one-CPU core/restart/five-fault replay exact.

## Measured comparison to Candidate A

| Surface | MIN01 transport | Candidate A MIN02 | Candidate B MIN03 |
|---|---:|---:|---:|
| linked bytes | 7811 | 8189 | 8089 |
| headroom | 381 | 3 | 103 |
| raw stage2 | 4216 | 4594 | 4494 |
| implementation scratch used | 50 | 60 | 62 |
| relation mutators in S mode | none | BSP + AP behind global gate | BSP only |
| new coordination shape | AP-ready only | whole-operation atomic gate | request/result mailbox + single owner |
| progress dependency | AP startup only | current gate holder completes | BSP owner services mailbox |

Candidate B is 100 linked bytes smaller than Candidate A and buys 100 bytes of headroom while using two more scratch bytes. It also preserves single-writer relation internals. Candidate A remains conceptually attractive for direct callers and avoids a central relation owner, so this result alone does not make B universally dominant.

No successor-body promotion is made here. Candidate C / per-CPU scratch + narrow transition gate should be priced only if the A/B tradeoff remains material in the successor review.
