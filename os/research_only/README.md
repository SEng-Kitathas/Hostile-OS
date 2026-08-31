# HOSTILE-OS research-only embodiments

Everything here is **RESEARCH PURPOSES ONLY**. These are bootable/rebuildable embodiments for inspection, review, contribution, and reproduction. They are not releases and do not bypass architecture/science promotion gates.

## Current research reference

- `d64_reference_v3/` — current integrated research body. It preserves the D64-v2 core/IRQ/restart/fault semantics and adds the selected H1 two-core participation topology: BSP is the sole relation mutator; AP submits an explicitly ordered request/result mailbox. Isolated os-only admission passed20/20. H1-QEMU is still a target proxy, not physical hardware qualification.

## Preserved prior lineage

- `d64_reference_v2/` — prior D64 integrated reference before post-C005 H1 SMP convergence. Preserved unchanged as historical machine/body lineage.
- `i001_reference/` — historical whole-workload I001 seed, rebuilt byte-for-byte from repo-contained source and bootable under QEMU.

`CURRENT_RESEARCH_REFERENCE` means only the most current integrated reviewer embodiment admitted by the project gates. It does not mean final architecture, production readiness, a general-purpose release, or physical H1 qualification.
