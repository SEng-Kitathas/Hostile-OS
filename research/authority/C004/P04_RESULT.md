# C004/P04 result — authority revocation separate from resource currentness

Status: **CLOSED PASS**
Implementation commit: `47d8904`
Controlling run: `P04/runs/20260831T022855Z_c004_p04_01`

B read W/7E before revoke. Revocation changed only B's authority relation; resource generation and epoch remained01/01, A still read W/7E, B's old authority generation returned U/00, while the resource-currentness-only bad control still read W/7E.

Earned at bounded mediated scope:

`AUTHORITY_CURRENTNESS != RESOURCE_CURRENTNESS`.

Run-local inputs 8/8; stage2 568 bytes, SHA `b3313f77aecba68b24ef75bb680bf25edc47c0a55f456429610b10db3ba1f21b`.
