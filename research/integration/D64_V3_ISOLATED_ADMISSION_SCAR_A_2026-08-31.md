# D64 v3 isolated admission scar A — H1 target disk read-only transport

Status: **RUNNER FAILURE / NO GUEST SCIENCE RESULT**
Candidate package commit: `47362f4`

The first `os/research_only/d64_reference_v3/run.py --mode all` attempt completed the host process quickly but every QEMU invocation exited1 before guest boot, with empty debug traces and stderr `Block node is read-only`.

Cause: the new standalone runner attached the H1 500 GiB QCOW target as `if=ide,...,readonly=on`. The already-qualified H1 integration runner attached this target disk writable. On the tested Q35 path the standalone read-only attachment was rejected before guest execution.

Amendment A removes `readonly=on` from **only the auxiliary H1 target QCOW attachment**. The boot/restart/fault floppy read-only semantics remain unchanged, candidate stage1/stage2 bytes are unchanged, target machine/cpu/smp/memory profile is unchanged, and no expected guest trace or admission criterion changes.

The failed host-side attempt is not a body FAIL/PASS and must not be promoted as guest evidence.
