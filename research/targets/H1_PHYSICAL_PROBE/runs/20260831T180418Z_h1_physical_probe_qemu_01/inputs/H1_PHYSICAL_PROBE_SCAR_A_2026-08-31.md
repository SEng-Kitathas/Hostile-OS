# H1 physical probe qualification Scar A — CPUID availability precheck

Date: 2026-08-31
Status: **PRESERVED NON-CONTROLLING INFRASTRUCTURE FAILURE**

The first H1-probe QEMU qualification boot completed the probe and emitted `H1PROBE_END`, but the CPUID family reported `CPU_CPUID=UNAVAILABLE` under the qualified QEMU `phenom` target proxy.

The failing implementation first tried to prove CPUID availability by toggling EFLAGS.ID in real mode. That precheck did not behave as assumed in this proxy path and therefore suppressed a CPUID instruction that the target model does support.

Other first-run observations were present: boot-drive/INT13 facts, PIC masks, a complete E820 walk, PCI enumeration, and normal end framing. QEMU exited through the emulator-only debug-exit path with code 67.

This run does **not** qualify the probe because the preregistered CPU observation family was missing.

Repair rule:
- remove the EFLAGS.ID availability precheck;
- execute CPUID directly on this target-specific probe;
- keep the physical target scope explicit: AMD E2-1800 is known to implement CPUID, and the qualified H1 QEMU proxy implements CPUID;
- preserve the same preregistered output contract and all other probe behavior.

No physical-H1 claim follows from this scar or its repair.
