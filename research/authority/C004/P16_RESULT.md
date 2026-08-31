# C004/P16 result — authority lifetime versus resource lifetime

Status: **CLOSED PASS**
Implementation commit: `eab3b56`
Controlling run: `P16/runs/20260831T031253Z_c004_p16_01`

Good protected composition revoked B authority only: resource live count remained02 and A READ remained W/7E. Bad control coupled authority revocation to resource reclamation: live count became00 and A READ returned R/00.

Earned: `AUTHORITY_LIFETIME != RESOURCE_LIFETIME` at this bounded protected composition. Revoking one caller's authority does not by itself authorize reclaiming the resource while another live relationship still needs it.

This does not decide a universal binding/authority ownership model.
