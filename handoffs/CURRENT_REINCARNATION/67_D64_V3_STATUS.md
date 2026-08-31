# Status

- body class: research-only
- generation: D64 reference v3
- admission: **CURRENT_RESEARCH_REFERENCE**
- selected topology: BSP single relation owner + explicit AP request/result mailbox
- final architecture: false
- production ready: false
- general-purpose release: false
- physical H1 qualified: false

Candidate basis:
- C005 CLOSED20/20 hard stop;
- H1-SMP-MIN01 second-core transport PASS;
- Candidate A MIN02 PASS at8189/8192 linked bytes;
- selected Candidate B MIN03 PASS at8089/8192 linked bytes;
- named semantic state remains3467 bytes;
- implementation scratch used62 bytes;
- exact Candidate-B S trace `IDS=0001 / OWNER=BSP / MAIL=WW11`;
- H1 QEMU existing core+IRQ exact;
- Bochs one-core core/restart/fault regressions exact in integration qualification.

Isolated `os/`-only admission PASS: build exact; H1-QEMU all-mode replay exact; verifier 20/20. Admission evidence is preserved under `research/reproduction/D64_V3_ISOLATED_ADMISSION/`, but this package does not depend on that tree at build/run time.
