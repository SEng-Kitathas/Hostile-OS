# C005/P01 implementation scars

## First controlling attempt — AP startup transport failure

Run: `P01/runs/20260831T033403Z_c005_p01_01`

Trace:
```text
S1_8K_OK
TEST=C005_P01
AP_START_FAIL
C005_P01_FAIL
```

Cause: 16-bit absolute moffs encoding truncated local-APIC MMIO addresses, so INIT/SIPI did not reach AP1.

Disposition: harness/transport failure before coherence discriminator; preserved and repaired by Amendment A. It is not a coherence mechanism FAIL.
