# C004/P06 result — cooperative authority checks versus raw same-domain bypass

Status: **CLOSED PASS**
Implementation commit: `6a215bb`
Controlling run: `P06/runs/20260831T023112Z_c004_p06_01`

Exact discriminator:
```text
B_CHECKED_WRITE=U
B_CHECKED_AFTER=7E
B_RAW_AFTER=55
```

The checked API correctly enforced B's READ-only relation. Arbitrary code in the same privilege/address domain then bypassed that API and directly mutated the protected byte.

Earned:

`COOPERATIVE_AUTHORITY_CHECKS != PROTECTION_FROM_UNTRUSTED_CODE`.

This is a mechanism ceiling, not a harness failure. C004 must now test an enforcement boundary that hostile code cannot bypass merely by choosing another instruction path.

Run-local inputs 8/8; stage2 285 bytes, SHA `aa20ed434b24e154840cd9f6d54f8b756c3c88174039b84a996cfa21e1484953`.
