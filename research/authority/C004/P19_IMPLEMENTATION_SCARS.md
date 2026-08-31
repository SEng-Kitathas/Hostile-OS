# C004/P19 implementation scars

## First controlling attempt — UNKNOWN timeout

Run `P19/runs/20260831T031932Z_c004_p19_01` hit the launcher timeout before clean exit. Partial trace:

```text
S1_8K_OK
TEST=C004_P19
A_READ=U
A_VAL=7E
QUEUE=Q
APPLY=U
AFTER_APPLY=7E
```

The caller-provenance helper read the wrong protected return-frame offset because its own subroutine call shifted the frame. This is an implementation/control-flow defect, not an authority-mechanism result. The attempt remains UNKNOWN and is preserved.
