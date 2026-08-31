# C004/P17 result — authorization at request time versus effect time

Status: **CLOSED PASS**
Implementation commit: `9b20fe0`
Controlling run: `P17/runs/20260831T031429Z_c004_p17_01`

A ring3 caller queued value55 while WRITE-authorized. The protected mediator then revoked authority before application.

Good application revalidated caller/authority-generation/current rights and returned U, leaving X=7E. Bad control trusted only the cached request-time authorization decision and returned W, changing X=55.

Earned: when revocation can occur between request acceptance and effect application, `REQUEST_AUTHORIZED != EFFECT_CURRENTLY_AUTHORIZED`. Delayed effects need enough provenance/currentness to revalidate at the authority point that matters.

No universal queue/job primitive or async execution model is earned.
