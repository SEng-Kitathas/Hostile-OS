# C005/P10 result — real IRQ observation versus concurrent second-CPU mutation

Status: **CLOSED PASS**
Implementation commit: `eb2aec0`
Controlling run: `P10/runs/20260831T050054Z_c005_p10_01`

A real PIT IRQ0 was delivered to BSP while AP mutated coupled bytes. Bad handler read without the inter-CPU exclusion and observed mixed33/22 (`BAD_MIXED=1`), after which AP completed33/44.

Good phase: AP held the shared atomic exclusion across the mutation. IRQ entered while AP reported holding (`GOOD_IRQ_SAW_HOLDING=1`), then the handler acquired the same exclusion before reading. It observed no mixed pair and did observe final33/44 (`GOOD_MIXED=0`, `GOOD_FINAL=1`).

Earned: one-core IRQ coherence and inter-CPU coherence do not compose automatically. An IRQ observer and concurrent CPU mutator touching the same coupled relation must participate in one coherence protocol. x86 xchg/PIC/PIT are witnesses only.
