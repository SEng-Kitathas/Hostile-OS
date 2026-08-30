# POST-C003 / R01 — P03 spanning-reader ABA/currentness revisit result

**Disposition:** PASS CLOSED / BOUNDED REVISIT SUCCESS
**Parent evidence:** C003/P03
**C003 pass count effect:** NONE — C003 remains CLOSED 20/20
**Architecture promotion:** NONE

## Controlling preregistration

`POST_C003_R01_P03_ABA_PREREGISTRATION.md` was sealed at Git commit `4c4142fd2de706c165a63a333932cffe55fb9e65` before any R01 mechanism source existed.

## Engineering scar

Attempt `20260830T031600Z_post_c003_r01_p03_aba_01` failed at link time before QEMU because the probe payload exceeded the one-sector evidence limit by one byte at the signature boundary.

That attempt has no scientific consequence.

The repair did not weaken the preregistered matrix. The four-byte fixed relation record was moved from boot-image data bytes to explicit fixed low-memory scratch addresses `0x0500..0x0503`. The relation remained one fixed record; this removed image bytes only.

## Controlling run

Run: `20260830T031800Z_post_c003_r01_p03_aba_02`

QEMU:
- PID: `14232`
- started: `2026-08-30T03:16:04.934188+00:00`
- ended: `2026-08-30T03:16:05.225736+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds

Evaluator exit: `0`.
Static checker exit: `0`.
QEMU/evaluator/static-check stderr: empty.

Linked probe size from `llvm-size`: text 507 bytes + data 2 bytes = 509 bytes before raw-image padding/signature handling. Raw boot image: exactly 512 bytes with signature `55aa`.

## Exact raw observation

```text
FLAG_PRE=0
FLAG_OWNER=A
FLAG_HISTORY=B
FLAG_POST=0
FLAG_ACCEPT=S
VER_PRE=1
VER_OWNER=A
VER_HISTORY=B
VER_POST=2
VER_ACCEPT=R
STABLE_VER_PRE=2
STABLE_OWNER=B
STABLE_HISTORY=B
STABLE_VER_POST=2
STABLE_ACCEPT=C
DONE
```

Evaluator `POST-C003-R01-P03-ABA-v1`: passed.

## Source hashes

- mechanism: `6810a0e5fe7b427b8b8a1337810b2df6c5e056663f9f207551875c72ca0be7b8`
- fixture: `67701b37c65a0773416eacf0ff7f75148570fbbb57d5f0ffd6a4ac65c9d0a0f1`
- linker: `1a723b1ce73cec7bdac582dcea27533901dcc1782d30428c6655c866bb396902`
- evaluator: `94305fc3ce67ea55c2f01c81847d8423bf740fbfc7609e7a47e7ef86829e51e9`
- static checker: `62c61e2d14bfd1ddbb8a6e6c83443528cb8d6310ecf5981fa496f6b5fdcc451a`
- launcher: `4e7b3d51380def1796ee08db03f0bcf2f2c50d991b6d95ae550f3e44f038270b`

## Run hashes

- boot image: `75fd27d88095980d1f6b3bab642fb23c2690819d82d4740ff7020abb8f3f3b3c`
- debug trace: `552862e9a7893f015ea71010cbba25c4ad9d8b97decdf81327642e1c92260e2f`
- evaluation: `3b5975a38a547d1dd5975d3af8a87d0c9201a8434d7a983432145a6ca0b79e65`
- static closure: `33601a41c32ffa7d70606aa8669617e95f2125a033004f16c2e79c5243288fb8`
- independent source audit: `9101a52b7f49f5aca337921f25df5071ffcfa4c7477f2aa6f06ef6b15f8731b1`
- receipt: `5f6d29d4efb90d215a23f37d76a3cd95ecef882aa022c1a1d1dfb9312d036797`

## Static/source closure

The built-in static checker passed and verified:

- one fixed owner/history/active/version record;
- both trials call the same mutation routine;
- mutation order is active=1 -> owner B -> history B -> version increment -> active=0;
- version increments exactly once per mutation;
- flag-only acceptance does not compare version;
- version-qualified acceptance compares saved pre/post versions before acceptance;
- stable version-qualified path can accept coherent B/B;
- no second relation record exists.

A separate independent source audit also passed and verified:

- fixture supplies only five input bytes: initial A/A/version1 and target B/B;
- fixture does not contain expected result tokens;
- launcher does not write `debugcon` or mutate guest relation state;
- evaluator reads guest debug output and does not mutate guest state;
- the same complete mutation routine is used in both interleavings;
- runtime/evaluator/static results and receipt source hashes agree with the exact files.

## Qualified consequence

For this one-record, one-complete-mutation interleaving:

1. the reader begins with `mutation_active=0` and owner A;
2. a complete A/A -> B/B mutation occurs and clears `mutation_active` back to 0;
3. the reader then reads history B;
4. a flag-only rule sees clear before and clear after and accepts the mixed A/B snapshot;
5. the same interleaving with version snapshot 1 before and 2 after is rejected;
6. the version rule is not reject-all: a later stable B/B read sees version 2 before and after and is accepted coherent.

Therefore:

> clear-before/clear-after mutation flags do not prove that a multi-field read did not span a completed mutation. A changed version around the read detects this bounded ABA-shaped snapshot; an unchanged version can still accept the stable post-mutation snapshot.

This closes the exact P03 revisit seam at bounded scope by showing that the active flag alone is insufficient for spanning readers under this reader model.

## Relationship to P12

R01 does **not** make version equality universally safe.

P12 remains controlling evidence that finite generations can wrap and alias stale values. R01 establishes the need for a version/change detector around this spanning read; P12 keeps the version-width/rollover burden open.

Any future integrated design must therefore define a lifetime/rollover rule, a stronger identity/version composition, or another currentness mechanism appropriate to its actual reuse horizon.

## Authority ceiling / nonclaims

R01 does not establish:

- general linearizability;
- universal ABA freedom;
- arbitrary version lifetime;
- wrap-free generations;
- SMP memory ordering;
- seqlock architecture;
- transaction architecture;
- lock-free correctness;
- general interrupt atomicity;
- scheduler/process/file/manager architecture;
- final OS architecture;
- R3.1 promotion;
- replacement readiness.

## Revisit disposition

`P03_SPANNING_READER_SEAM_RESOLVED_AT_BOUNDED_SCOPE / ACTIVE_FLAG_ALONE_INSUFFICIENT / VERSION_CHANGE_DETECTS_TESTED_SPAN / ROLLOVER_POLICY_STILL_OPEN`
