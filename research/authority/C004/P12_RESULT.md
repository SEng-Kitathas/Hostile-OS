# C004/P12 result — direct I/O versus mediated I/O authority

Status: **CLOSED PASS**
Implementation commit: `33a5344`
Controlling run: `P12/runs/20260831T024038Z_c004_p12_01`

Ring3 direct OUT under CPL3/IOPL0 caused the intended #GP (`IO_GP=1`), emitted no raw user marker, and ring0 still executed the mediated I/O/logging path (`MEDIATED_IO=1`).

Earned: untrusted device/I/O effects require an enforcement boundary distinct from software rights checks; privileged mediation is one witness.

No driver/device-manager architecture is earned.

Run-local inputs 8/8; stage2 574 bytes, SHA `72c8d32b629f3a2ab3657dfaf9ac8095664ef329a5d2f84adeaec526dcfac536`.
