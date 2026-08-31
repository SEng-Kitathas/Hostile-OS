# C004/P02 result — operation-specific authority

Status: **CLOSED PASS**
Implementation commit: `56cdb78`
Controlling run: `P02/runs/20260831T022531Z_c004_p02_01`

Exact result:
```text
A_READ=W / A_READ_VAL=7E
A_WRITE=W / A_AFTER=55
B_READ=W / B_READ_VAL=7E
B_WRITE=U / B_AFTER=7E
B_BINARY_WRITE=W / B_BINARY_AFTER=55
```

P02 therefore earns, at bounded cooperative-API scope:

`AUTHORIZED_READ != AUTHORIZED_MUTATION`.

A single binary allow fact cannot preserve both intended futures for B: if it permits the intended read and is reused for mutation, it over-authorizes the write.

This does not earn a universal rights bitmap or security architecture. Hardware/untrusted-code enforcement remains open.

Run-local inputs: 8/8; stage2 537 bytes, SHA-256 `98a902fa4eb374769d803abadb46bd62fc374effc8dbebb45123fbff4ba39ee3`.
