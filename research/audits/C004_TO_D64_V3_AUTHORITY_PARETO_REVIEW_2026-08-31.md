# C004 -> D64-v3 authority/protection representation Pareto review — 2026-08-31

Status: **CLOSED REPRESENTATION REVIEW / KEEP V3 UNCHANGED / NO C006 OPENED**
Parents: C004 CLOSED 20/20, C005 CLOSED 20/20, `os/research_only/d64_reference_v3/` CURRENT_RESEARCH_REFERENCE, H1 first-target capability.

## Question

Should the remaining 103 bytes of D64-v3 headroom be spent now to retrofit some or all of the C004 authority/protection grammar into the current H1 research body?

## Verified current-body state

Current D64-v3 build manifest:
- linked image memory: 8,089 / 8,192 bytes;
- remaining headroom: 103 bytes;
- raw stage2: 4,494 bytes;
- named semantic state: 3,467 bytes;
- implementation scratch: 62 / 128 bytes.

Direct source/symbol inspection finds:
- stage2 remains `.code16`;
- no current `CR0`, `LGDT`, `LIDT`, `LTR`, TSS, GDT, ring3/CPL, grant/right/delegation/revocation, or authority-currentness body;
- the only current caller-provenance-like statement is the scoped H1 topology comment: `BSP is sole S-mode caller of relation mutation APIs. AP publishes mailbox only.`

That H1 ownership rule is a trusted-body concurrency rule, not C004's untrusted-authority boundary.

## C004 obligations that remain scientifically adopted

The C004 adoption review requires, when actually untrusted code/effects are admitted:
- trusted caller provenance distinct from untrusted claims;
- authority/applicability distinct from resource currentness;
- operation-specific rights;
- non-amplifying delegation/attenuation;
- independent authority currentness/revocation;
- checked reusable authority identity/currentness;
- explicit finite capacity and initialization;
- authority lifetime separate from resource lifetime;
- effect-time revalidation where revocation may intervene;
- restart authority epoch/currentness where grants reconstruct;
- local unauthorized failure;
- a non-bypassable enforcement boundary;
- privileged mediation for otherwise directly issuable effects such as I/O.

These remain shadow obligations. They are not silently revoked because v3 does not embody them.

## Hard fit pressure from the earned x86 witness

C004/P20's final caller-provenance witness used real ring3 domains and a CPU-enforced ring transition. Its source includes:
- a 104-byte TSS;
- GDT/TSS descriptor state;
- IDT/gate state;
- protected caller provenance handling;
- operation-right checks and mediator code.

The 104-byte TSS alone is larger than D64-v3's entire 103-byte remaining linked-image headroom.

This is **not** proof that every possible cross-target authority representation requires a TSS. It is a hard result for the already-earned current x86 enforcement witness: that witness cannot be honestly added to v3's present envelope without compression/reuse or envelope change, even before accounting for the rest of the boundary.

## Pareto alternatives

### A — spend a few bytes on rights/currentness without an untrusted boundary

Reject.

This would create policy-looking state while all executing code remains trusted and able to bypass it. It would fail C004's non-bypassable-boundary requirement and would falsely imply embodiment.

### B — retrofit the C004/P20 x86 ring witness into v3 now

Reject for current H1 capability.

It does not fit the measured 103-byte headroom as-is, and the first H1 capability does not yet require an untrusted execution domain. Paying the mode-transition/enforcement cost now would add capability not demanded by the current target increment.

### C — compress/restructure v3 solely to make room for authority machinery now

Defer.

Compression is justified only when the capability is admitted. Doing it now risks destabilizing the current D64-v3 body and spending engineering effort on an inactive boundary.

### D — preserve C004 as a capability-triggered obligation and qualify a successor when untrusted execution/effects are admitted

**SELECTED.**

Keep D64-v3 unchanged. Preserve its 103 bytes. When a target/workload first admits actually untrusted execution, an untrusted caller-controlled effect path, or another requirement that makes C004's boundary active, perform a new representation/envelope qualification before claiming the capability.

## Selected rule

`NO_UNTRUSTED_DOMAIN_ADMITTED -> C004 remains shadow obligation, not partial body theater`

`UNTRUSTED_DOMAIN_OR_DIRECT_PRIVILEGED_EFFECT_ADMITTED -> non-bypassable authority embodiment gate becomes mandatory before promotion`

At that gate:
1. derive the minimum target-specific enforcement representation;
2. measure whether reasonable compression/reuse can recover enough space;
3. if not, explicitly qualify a larger successor envelope;
4. preserve caller provenance, operation-specific authority, currentness/revocation, and privileged mediation as load-bearing requirements;
5. do not claim security from cooperative checks alone.

## Campaign consequence

This review does **not** open C006. C004 and C005 remain hard-stopped at P20.

A new broad campaign becomes justified only if a new responsibility domain or physical-H1 contradiction appears that cannot be resolved as a bounded integration/qualification descendant. The mere existence of a known, capability-gated embodiment gap is not enough.

## Architecture consequence

- `d64_reference_v3` remains CURRENT_RESEARCH_REFERENCE — RESEARCH PURPOSES ONLY.
- no D64-v3 source byte changes are authorized by this review;
- the 103-byte headroom remains unspent;
- C004 authority/protection science remains valid and explicitly not fully embodied;
- final architecture / production / release status remain false.
