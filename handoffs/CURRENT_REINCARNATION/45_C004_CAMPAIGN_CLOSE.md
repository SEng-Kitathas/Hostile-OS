# C004 campaign close — mutually-untrusted authority/protection re-derivation

Date closed: 2026-08-31 UTC
Status: **CLOSED 20/20 / HARD STOP OBEYED**
Architecture posture: remains `INTEGRATED_SHADOW_CANDIDATE`
Architecture promotion: **NONE AUTOMATIC**
P21: **FORBIDDEN / NOT CREATED**

## Campaign question

When mutually untrusted activities coexist, which additional future-relevant distinctions are required beyond currentness/applicability to prevent unauthorized observation or mutation?

## 20-pass result

C004 closed all twenty scientific passes. The campaign moved from cooperative checked access through an actual ring3/ring0 enforcement boundary and ended with a two-caller protected composition plus a forged-caller adversarial challenge.

### Earned grammar

At the tested bounded scopes, the following distinctions remain independently load-bearing:

1. **current reference != authorized use** — P01;
2. **authorized read != authorized mutation** — P02/P08;
3. **delegation must not amplify beyond current delegator authority** — P03/P10;
4. **authority currentness != resource currentness** — P04/P11;
5. **authority slot location != authority identity/currentness** — P05;
6. **cooperative software checks != protection from arbitrary untrusted code** — P06;
7. **untrusted mutation requires a non-bypassable enforcement boundary** — P07;
8. **trusted caller provenance is required; caller identity cannot be an untrusted claim** — P09/P20;
9. **direct untrusted I/O effects require enforcement distinct from rights checks** — P12;
10. **unauthorized failure can remain local rather than poisoning unrelated valid futures** — P13;
11. **finite authority storage requires explicit exhaustion behavior** — P14;
12. **authority currentness does not replace explicit state initialization on reuse** — P15;
13. **authority lifetime != resource lifetime** — P16;
14. **request-time authorization != effect-time authorization when revocation may intervene** — P17;
15. **reusable authority handles require restart currentness/epoch when namespace reuse can recur across boots** — P18;
16. **the grammar composes under two distinct protected ring3 callers** — P19.

### Working compression

The smallest useful current compression is not a historical credential/process/security-manager bundle. It is closer to:

`protected caller provenance + checked authority relation + operation + currentness -> mediated effect`

where the authority relation may be delegated/attenuated/revoked, has finite reusable storage, has a lifetime separate from the resource, and may need revalidation at effect time and after restart.

This is a working compression, not a declaration of constitutional primitives. Any term may still be split, merged or replaced if later pressure exposes a cheaper grammar.

## What C004 disproved at tested scope

- currentness alone is sufficient authority — false;
- one binary allow bit is sufficient for all operations — false;
- delegation may copy requested rights without attenuation — false;
- resource generation can stand in for authority revocation/currentness — false;
- slot/index location can identify reusable authority — false;
- a cooperative checked API protects against arbitrary same-domain machine code — false;
- caller identity may be trusted because the request says who called — false;
- successful authorization at queue/request time remains sufficient after later revocation — false;
- revoking one caller implies reclaiming the shared resource — false;
- generation alone is sufficient across fresh-runtime namespace reuse — false at the tested restart fixture;
- global failure poisoning is required — false;
- full authority storage may silently overwrite an existing record — false.

## Enforcement witness versus architecture

x86 ring privilege/segmentation, interrupt gates, #GP, IOPL and a TSS were effective **enforcement witnesses**. C004 does not promote those particular mechanisms into universal HOSTILE-OS architecture.

The campaign earns the consequence that an actually untrusted participant needs a non-bypassable enforcement boundary. Which hardware/software mechanism supplies that boundary on later targets remains open.

## Process scars retained

- P17 preregistration existed before runtime and is byte-identical to the run snapshot, but was accidentally not Git-sealed before its implementation commit. P17 therefore has `PREREGISTERED_BEFORE_RUNTIME` evidence, not `GIT_SEALED_BEFORE_IMPLEMENTATION` evidence.
- P18 first sealed implementation failed before QEMU due duplicate boot-signature packaging; Amendment A fixed loader packaging only.
- P19 first controlling attempt timed out and remains `UNKNOWN`; partial trace localized a saved-stack caller-CS offset error. Amendment A repaired only the frame offset; the later controlling run passed.

No red/UNKNOWN evidence was recolored or deleted.

## What is not earned

C004 does not establish:
- complete memory isolation between arbitrary address spaces;
- SMP/weak-memory enforcement;
- DMA/IOMMU/device-bus isolation;
- NMI/SMI/firmware/adversarial-hypervisor protection;
- cryptographic authentication or secrecy;
- side-channel resistance;
- filesystem/user/credential ABI;
- multi-user policy language;
- network/distributed authority;
- real hardware qualification;
- final architecture or production security.

## Campaign disposition

`C004 = CLOSED 20/20`.

The authority/protection domain is no longer an unstructured missing-capability pressure. It now has a bounded earned grammar and explicit enforcement assumptions.

No architecture promotion follows automatically. Any embodiment change must undergo a separate integration/Pareto review, especially because the current v2 research body has only752 bytes of qualified stage2 headroom.
