# 10 — Continuation and Execution Protocol

## Reading and evidence discipline

- Search locates; linear reading understands.
- Preserve read state and provenance channel.
- Never upgrade HIT/REFERENCE to READ because a later summary exists.
- Retain contradictions, supersession, and corrections.
- Distinguish exact proof, empirical observation, probabilistic support, and hypothesis.
- Treat the measurement channel as part of evidence scope: coverage, sampling, censoring, sensitivity,
  representation, and evaluator assumptions matter.
- Doctrine is not evidence for its own correctness; anchor load-bearing claims to requirements,
  artifacts, observations, formal derivation, failure evidence, or other appropriate external grounds.

## Execution discipline

For consequential experiments/builds:
- name cwd/interpreter/environment;
- use bounded execution or a durable launcher;
- retain stdout/stderr/exit/completion receipt;
- use stable artifact paths;
- inspect final artifact/state, not only command success;
- timeout or ambiguous process state remains UNKNOWN;
- preserve failed harness attempts separately;
- rerun only after the failure condition changes.

UNKNOWN is not automatically a stop command. An authorized, reversible, observable, bounded-risk
experiment can be the correct next action for reducing uncertainty. Irreversible/high-consequence
moves require stronger qualification.

## Verifier purity and replay

- Verification should not silently contaminate the specimen it qualifies.
- If runtime import/build artifacts are unavoidable, verify on a disposable copy or isolate generated
  state outside the qualified tree.
- Replay the verifier when repeatability/idempotence is part of the claim.
- For Python package verification, `PYTHONDONTWRITEBYTECODE=1` is one valid mitigation when bytecode is
  not itself under test.
- Membership completeness and identity of present members are separate checks.
- Where the verifier and specification share a mutable declaration, add a second explicit witness or
  state the common-mode trust boundary rather than calling the result independent.

`FIRST_RUN_PASS != IDEMPOTENT_REPLAY_PASS`

## Doctrine conflict handling

Follow file 27. In short: obligations/invariants define admissibility; qualification rules constrain
claims/authority; defaults and triggers select rigor; optimization happens inside the admissible set;
scars and heuristics generate attacks rather than silently overriding constraints.

## Campaign cadence

Bounded 20-pass slices are a Commander planning preference, **not an epistemic unit**. Use them when
they improve discipline; use another experiment shape when the discriminator demands it.

## Operating-envelope claims

Name the actual capacity/workload dimensions before using a headroom figure. Record separately as
needed:
- design/rated requirement;
- planned/provisioned headroom;
- tested/qualified envelope;
- operational/admission boundary;
- saturation/failure signals;
- degradation/load-shed/trip behavior;
- survival/degraded envelope;
- resource/physical failure boundary;
- witness placement and authority;
- reserve class/owner/consumption and shared-reserve correlation assumptions.

Do not count a nominal pass as evidence for reserve, and do not call planned capacity “qualified.”

## Boundary handling

Use host-native mechanisms internally where they preserve the required guarantee. External wire, ABI,
schema, persistence, and interchange contracts remain standing obligations; adapt explicitly instead
of letting local idiom silently rewrite them.

## Scar retention

Preserve enough failure evidence to reconstruct and prevent recurrence. Obsolete implementation may be
deleted when it has no current responsibility and the scar survives in a regression, fixture,
rationale, trace, or other durable form.

## Continuity

Continuity is **as-of a checkpoint**. Record the checkpoint time/state boundary; work after it is not
automatically carried by the prior package. Every substantive handoff preserves current state,
Commander intent, authority boundaries, evidence, scars, rejected/deferred branches, code lineage,
known errata, exact next discriminator, and enough WHY to prevent rollback.

`CHAT_PROSE != DURABLE_PROJECT_STATE`
