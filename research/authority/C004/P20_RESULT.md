# C004/P20 result — hard-stop adversarial caller-provenance challenge

Status: **CLOSED PASS / CAMPAIGN HARD STOP REACHED**
Implementation commit: `7f14f16`
Controlling run: `P20/runs/20260831T032156Z_c004_p20_01`

Two distinct ring3 caller domains each hit the kernel-data protection boundary (`GP_COUNT=02`). B supplied forged claim `caller=A` (`01`) while the CPU-saved protected caller provenance identified actual caller B (`02`).

Good mediator ignored the untrusted claim, selected authority by protected provenance, returned `GOOD_FORGED_WRITE=U`, and preserved X=7E. A's later valid READ remained W/7E.

Bad control selected authority from B's untrusted claimed caller ID, returned `BAD_FORGED_WRITE=W`, and changed X to55.

Earned: `TRUSTED_CALLER_PROVENANCE` remains independently load-bearing at the end of the bounded C004 composition. An untrusted identity claim cannot replace the provenance supplied by the enforcement transition.

P20 is the mandatory C004 hard stop. **No C004/P21 may be created or run.**

No complete-system security or final architecture claim is earned.
