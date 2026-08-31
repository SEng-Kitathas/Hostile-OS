# HOSTILE-OS D64 Reference v3

**RESEARCH PURPOSES ONLY — NOT A RELEASE — NOT FINAL ARCHITECTURE**

This directory is the selected H1 SMP successor candidate descended from D64 reference v2. It adds the bounded two-core H1 participation mechanism selected after C005: BSP retains sole relation-mutation ownership while AP submits an explicitly ordered request/result mailbox.

Current package state: **CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY**.

This exact machine body passed isolated `os/`-only build/run/verify admission after the retained runner-transport scar. Promotion does not make it final architecture, production-ready, or physical-H1-qualified.

The working words `activity`, `binding`, `resource`, `owner`, and `mailbox` are implementation vocabulary, not constitutional primitives.

Build/run/verify from this directory:

```text
python build.py
python run.py --mode all
python verify.py
```

The package is designed for an `os/`-only sparse checkout. Build/run/verify do not read `research/`, `continuity/`, `authority/`, or `handoffs/`.

H1/QEMU is a target proxy. Passing it is not physical HP Pavilion p2-1120 qualification.
