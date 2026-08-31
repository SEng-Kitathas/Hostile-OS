# C005/P09 result — cross-CPU revocation versus delayed effect

Status: **CLOSED PASS / C004 REINFORCED UNDER SMP**
Implementation commit: `45c25b6`
Controlling run: `P09/runs/20260831T045734Z_c005_p09_01`

AP accepted WRITE at authority generation1. BSP revoked WRITE and advanced generation2 before application. Bad AP trusted its cached request-time decision and wrote55 (`BAD_APPLY=W`). Good AP revalidated current generation+rights after the cross-CPU revoke and rejected (`GOOD_APPLY=U`, value7E).

Result: C004/P17's `REQUEST_AUTHORIZED != EFFECT_CURRENTLY_AUTHORIZED` survives tested two-CPU QEMU x86 pressure. No new authority primitive was needed; this is cross-domain reinforcement.
