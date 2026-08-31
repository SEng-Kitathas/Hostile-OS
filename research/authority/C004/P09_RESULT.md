# C004/P09 result — caller identity must not be an untrusted claim

Status: **CLOSED PASS**
Implementation commit: `3bbcfb2`
Controlling run: `P09/runs/20260831T023715Z_c004_p09_01`

With the privilege boundary active (`GP_SEEN=1`), the trusted gate treated the only ring3 context as B and denied WRITE (`U`, X7E). A bad gate indexed the same rights table using B's untrusted `claimed_caller=A` request field and accepted WRITE, changing X to55.

Earned:

`AUTHORITY_CALLER_IDENTITY_REQUIRES_TRUSTED_PROVENANCE` at this bounded enforcement scope.

No general authentication/credential/process representation is earned.

Run-local inputs 8/8; stage2 816 bytes, SHA `48a6f911bebaac51c6defd03112be5a4b85c4f1a143b9533978352966d4a9d26`.
