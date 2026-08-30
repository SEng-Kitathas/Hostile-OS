# Opus independent-host I001 reproduction report — raw operator-supplied donor material

Date admitted: 2026-08-30
Source: operator-supplied text attributed to Opus
Authority: external report / controlled evidence; not locally verified raw artifacts because the foreign-host files themselves were not supplied in this thread

---

All four packages verify. Extracting QEMU to complete the scientific rerun.TCG accelerator loads. Running the scientific rerun.Full pass. Both claims independently satisfied.

```text
stage1_hash_matches_i001        TRUE
stage2_hash_matches_i001        TRUE
stage1_size_512                 TRUE
stage1_signature_55aa           TRUE
stage2_within_4096              TRUE
distinct_qemu_pids              TRUE
boot1_exit33                    TRUE
boot2_exit33                    TRUE
no_host_write_between_boots     TRUE
irq_event_positive              TRUE
historical_exact_irq_event_one  TRUE
failures: []
```

**Machine-byte reproduction and scientific rerun, both from an independent host.** Different OS, different clang (18.1.3 vs 21.0.0), different lld, different QEMU (6.2.0 vs 11.1.0), clean clone, no author paths. The rebuilt stage1 and stage2 hash to the controlling I001 bytes, and the two-boot workload runs through to exit 33 across two distinct QEMU processes with no host write between them.

`historical_exact_irq_event_one` came back **true** on my run. One data point, on a different QEMU major version, so it doesn't resolve the 660-red seam — but it's the first outside observation of it and it landed on the historical side.

## Three defects that blocked reproduction

**1. `find_tool` resolves symlinks and destroys multi-call binary identity.** Already reported; unchanged. `/usr/bin/ld.lld` -> `/usr/lib/llvm-18/bin/lld`, argv[0] becomes `lld`, the generic driver refuses. `HOSTILE_LLD` doesn't rescue it because line 41 also calls `.resolve()`. Needed a PATH shim.

**2. The QEMU transplant doesn't set `QEMU_MODULE_DIR`.** `run-qemu-i386.sh` sets `LD_LIBRARY_PATH` and `-L share/qemu` but not the module directory, so `accel-tcg-i386.so` never loads:

```text
ERROR:../../accel/accel-softmmu.c:82:accel_init_ops_interfaces:
assertion failed: (ops != NULL)
```

The module is present in `modules/`. QEMU just can't find it. One `export QEMU_MODULE_DIR="$HERE/modules"` in the launcher fixes it.

**3. `share/qemu` ships one ROM.** Only `qboot.rom`. QEMU tries to load `efi-e1000.rom` for the default NIC and aborts. `-nic none` clears it — and this workload has no business having a NIC at all, so pinning that in `run.py`'s argv would make the run more hermetic rather than less.

None of these are science defects. All three are transplant-portability defects, and they're the same class as the CRLF hashes and the Windows path separators — **the environment is part of the experiment and it hasn't been packaged as rigorously as the bytes have.**

## What I'd suggest

Fold the shim into `run-qemu-i386.sh` — module dir plus `-nic none`. Drop `.resolve()` from `find_tool`, or keep the resolved path for the manifest and invoke by discovered name. Add `* text=auto eol=lf` to `.gitattributes` so historical receipt sources verify on non-Windows clones without manual CRLF conversion.

After that, a stranger with the repo and the smuggle bundle reproduces I001 end to end with no manual intervention.

## Worth noting

`TOOL_PATH != TOOL_IDENTITY` and `TRANSPLANTED_BINARY != TRANSPLANTED_ENVIRONMENT`. Both are the project's own thesis — identity is not location, and a thing carries state its name doesn't — appearing in its own infrastructure on the first outside execution. That's the tightest possible confirmation that the architecture's central insight generalizes.
