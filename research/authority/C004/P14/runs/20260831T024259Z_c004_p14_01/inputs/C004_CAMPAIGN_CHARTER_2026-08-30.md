# C004 — mutually-untrusted authority/protection re-derivation campaign

Date opened: 2026-08-30
Status: OPEN / BROAD HSP CAMPAIGN / EXACTLY 20 SCIENTIFIC PASSES MAXIMUM
Mode: BUILD-PLAN
Architecture posture entering campaign: `INTEGRATED_SHADOW_CANDIDATE`
Trigger: `research/comparison/MATURE_OS_BLIND_COMPARISON_TRANCHE_01_2026-08-30.md`

## Campaign question

When mutually untrusted activities coexist, which additional future-relevant distinctions are actually required beyond currentness/applicability to prevent unauthorized observation or mutation?

This campaign does **not** assume the answer is a capability object, ACL, user/process privilege model, ring architecture, credential bundle, namespace, or any familiar security subsystem.

The comparison supplied only the pressure:

`CURRENT_REFERENCE ?= AUTHORIZED_USE`

The campaign must derive the minimum mechanism from hostile consequences.

## Broad-domain rule

C004 returns to the original exact 20-pass HSP campaign form because authority/protection is a new open responsibility domain, not a localized descendant seam.

- P01 begins below hardware protection to isolate the first missing distinction.
- Each later pass is chosen only after reconciling the previous result.
- P20 hard-stops the campaign whether the domain is complete or not.
- No architecture promotion occurs automatically from any pass or from P20.

## Quarantine from mature systems

During C004:
- Linux credentials/permissions, seL4 capabilities, Plan 9 namespaces/permissions and DOS access modes are question sources only;
- no external implementation is copied;
- no external noun is admitted as a primitive;
- a familiar mechanism may reappear only if HOSTILE-OS pressure independently forces the same distinction.

## Primary hostile dimensions

The campaign may pressure, if earned:
- caller identity versus target identity;
- currentness versus permission;
- operation-specific authority;
- delegation/attenuation;
- revocation independent of resource reuse;
- forgeability/ambient naming;
- software checks versus actual untrusted-code bypass;
- privileged mediation / memory or I/O protection if software-only enforcement proves insufficient;
- failure locality;
- finite authority capacity;
- lifecycle/reuse cleanup;
- restart/persistence boundaries;
- interrupt/device authority;
- whole-workload composition.

This list is a pressure reservoir, not a precommitted pass schedule.

## Scientific stop / interpretation rules

- A software API that rejects a bad request does not establish protection against code that can bypass the API.
- A protected-mode mechanism is not automatically architecture; it is one possible enforcement witness.
- Failure to protect one consequence does not automatically earn a historical security subsystem.
- Every pass must preserve a weakened/bad control where practical.
- Harness/build/evaluator failures remain separate from mechanism failures.
- Run-local controlling inputs must be snapshotted before build/execution.
- Ambiguous process state is `UNKNOWN`.

## Campaign success criterion

By P20, either:
1. a smaller bounded authority/protection grammar survives whole-workload composition with its enforcement assumptions explicit; or
2. the campaign closes with a precisely bounded unresolved blocker.

In both cases, the result must state what is and is not prevented from an actually untrusted participant rather than merely a cooperative caller.
