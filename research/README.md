# HOSTILE-OS research archive

This tree is the timestamped scientific record behind HOSTILE-OS.

It contains preregistrations, probes, fixtures, run-local input snapshots, receipts, traces, static closures, independent audits, adoption reviews, plans, and bounded conclusions.

Research artifacts are preserved because they explain what was tested, what failed, what was earned, and what remains provisional. They are not automatically OS architecture merely because they are present here.

## Installation independence

Nothing under `research/` is allowed to become a hidden build or installation dependency for a released HOSTILE-OS.

The future installable tree is `../os/`. Users who only want the OS may use the sparse/partial-clone path documented in `../INSTALL_FROM_GIT.md` and avoid downloading this research tree.

## Full-history purpose

A normal GitHub clone intentionally includes this directory so the repository also functions as a dated project-wide research ledger.
