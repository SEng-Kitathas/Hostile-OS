# C004/P10 result — delegation attenuation inside protected mediator

Status: **CLOSED PASS**
Implementation commit: `43228bf`
Controlling run: `P10/runs/20260831T023829Z_c004_p10_01`

With privilege enforcement active (`GP_SEEN=1`), trusted-provenance B held READ only. Good protected delegation of requested rights03 produced C rights01; bad protected mediator copied requested rights and produced03.

Earned:
`PROTECTED_AUTHORITY_STATE != NON_AMPLIFYING_AUTHORITY_TRANSFORMATION`.

Run-local inputs 8/8; stage2 689 bytes, SHA `026f6f7a5f23e02b3775a41817e4523581be017e22bba574293f585a4607b198`.
