# C004/P19 result — protected two-caller whole-workload composition

Status: **CLOSED PASS**
Implementation baseline commit: `8440017`
Amendment A commit: `76303d3`
Controlling run: `P19/runs/20260831T032022Z_c004_p19_01`

Two distinct ring3 code selectors represented A and B. The mediator derived caller provenance from CPU-saved user CS. Both domains independently attempted direct kernel-data access and #GP count reached02.

Observed composition:
- A READ W/7E;
- A delegated attenuated READ-only authority to B (`B_RIGHTS=01`);
- A queued WRITE55, then A WRITE was revoked;
- queued apply revalidated and returned U, leaving7E;
- B READ W/7E;
- B WRITE U, leaving7E;
- B revocation left resource live count02;
- A later READ remained W/7E.

Earned: the current authority grammar composes in one bounded protected two-caller workload without requiring a Process/credential/security-manager primitive. Caller provenance, operation-specific rights, attenuation, currentness/revocation, delayed-effect revalidation, authority/resource lifetime separation and failure locality coexist without contradiction at this tested scope.

No completeness, final architecture, SMP/IOMMU/DMA/NMI security, or production claim is earned.
