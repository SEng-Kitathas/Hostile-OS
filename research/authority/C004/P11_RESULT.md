# C004/P11 result — protected authority revocation/currentness

Status: **CLOSED PASS**
Implementation commit: `fff216a`
Controlling run: `P11/runs/20260831T023933Z_c004_p11_01`

With `GP_SEEN=1`, B read W/7E before trusted revocation. Resource currentness remained gen01/epoch01. Old B authority generation then returned U/00; the bad resource-only mediator still returned W/7E.

Earned: `AUTHORITY_CURRENTNESS` remains independently load-bearing under non-bypassable mediation.

Run-local inputs 8/8; stage2 988 bytes, SHA `8bc1ad3b645692f9b2fb96c886cc3fa03b43defcf49ea3d88388a75523df8445`.
