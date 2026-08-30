# Engineering Decision Ledger

This records not just **what** was chosen but **why**.

## D-001 — Defer broad machinery convergence

**Decision:** Do not immediately run the proposed cross-machinery
`What unique behavior disappears if I remove you?` convergence campaign.

**Reason:** The Commander identified written-stage code quality and coding
practice as a more immediate leverage point.

**Effect:** Machinery status is preserved; no claim that all machinery is
finished.

**Reopen:** After coding/assembly doctrine reaches a dogfood-ready candidate or
when a machinery defect blocks the coding campaign.

---

## D-002 — Treat `doctrine` as a mandatory search term

**Decision:** Any historical use of the word `doctrine` is a quarry entrance.

**Reason:** Important coding rules were historically filed under doctrine,
Law Ω/Omega, Codex, unified standards, CILNX, and adjacent names rather than
under literal `code quality`.

**Constraint:** A keyword hit is not evidence that the whole document was read.

`SEARCH_HIT != HUMAN_INTAKE`

---

## D-003 — Human-linear intake before synthesis

**Decision:** Read surrounding sections or full documents linearly.

**Reason:** Isolated snippets erase:
- why a rule existed;
- whether it was conditional;
- whether it was later corrected;
- whether the speaker was the Commander or a model;
- whether a memorable sentence was rhetoric or an actual mechanism.

**Tradeoff:** Slower than embedding-only synthesis, but lower risk of doctrine
laundering.

---

## D-004 — Separate Commander-origin intent from model elaboration

**Decision:** Track attribution.

**Reason:** The Rahl corpus contains substantial AI-generated doctrine written
in response to the Commander's prompts. Those documents can contain strong
mechanisms but must not be retroactively attributed to the Commander word-for-word.

**Classes:**
- USER_ORIGIN
- CURRENT_BASELINE
- RESEARCH_DESCENDANT
- HISTORICAL_MODEL_SYNTHESIS
- EXTERNAL_DONOR
- MIXED
- UNKNOWN

---

## D-005 — Do not resurrect Omega-era absolutes wholesale

**Decision:** Old Law Ω / Omega / theoretical-maximum material is quarry.

**Reason:** Later forensic engineering repeatedly showed that formal names,
equations, metrics, and “sealed/theoretical maximum” language can exceed the
evidence.

**Retain:** invariants, ownership, enforcement, verification ladders, negative
space, host/substrate pressure.

**Reject/narrow:** universal thresholds, physics metaphors treated as literal
quality metrics, proof-by-label.

---

## D-006 — Keep WHY / HOW / WHAT

**Decision:** Preserve the three-axis craft review.

**WHY:** right problem/contract/mechanism/scope.

**HOW:** structure, state, ownership, authority, failure locality, dependency,
abstraction earning.

**WHAT:** actual code clarity, target validity, tests, resource behavior,
explicit failure, naming.

**Boundary:** This is a craft-quality lens, not promotion authority.

---

## D-007 — Keep negative-space review

**Decision:** Every substantial review asks what can disappear.

**Reason:** Rahl Engineering repeatedly accumulates mechanisms because names and
abstractions suggest themselves.

**Questions:**
- what can be deleted with no loss?
- which dependency is incidental?
- which state owner is duplicated?
- which branch is untested?
- which verifier omits the dangerous failure?
- what is only ceremony?

---

## D-008 — Use smallest coherent real machine, not smallest diff

**Decision:**
`SMALL REVIEWABLE CHANGE INSIDE THE SMALLEST COHERENT REAL MACHINE`

**Reason:** Tiny toy edits can destroy the coupling needed to observe the real
failure; global rewrites destroy attribution.

---

## D-009 — Risk-scale semantic contracts

**Decision:** Preserve Practical Coding 2's A/B/C pressure as research guidance.

- Level A: ordinary idiomatic local code + direct tests.
- Level B: bounded semantic contract for nontrivial state/effects/integration.
- Level C: full semantic compile contract for authority, durability,
  concurrency, retry, protocol, destructive/irreversible effect, high
  consequence, or evidence machinery.

**Reason:** Full semantic ceremony failed the universality test for trivial code.

---

## D-010 — Host-native lowering instead of polyglot cosplay

**Decision:** Import guarantees, not syntax.

**Reason:** A Rust-like annotation in Python does not gain borrow-checker
enforcement. An actor-shaped class does not gain actor isolation. A “contract”
comment does not gain SPARK/Dafny proof.

---

## D-011 — Quality is vector-valued

**Decision:** Do not collapse quality into one score.

Potential axes include:
- functional correctness;
- reliability;
- maintainability;
- performance/resource behavior;
- portability;
- observability;
- recoverability;
- concurrency correctness;
- reproducibility;
- semantic recoverability;
- security/safety where actually relevant.

**Reason:** An artifact can improve one axis while regressing another.

---

## D-012 — Code assembly is a distinct research surface

**Decision:** Study not only final style but how code is assembled.

**Reason:** Many defects arise before formatting:
- wrong semantic owner selected;
- state divided across modules;
- side effects introduced too early;
- retry identity chosen after generated data;
- dependency direction reversed;
- test built around the intended answer;
- implementation fragments written before the real contract is understood.

The assembly path itself deserves explicit practice.

---

## D-013 — Coherent authorship is a requirement, not stylistic vanity

**Decision:** Existing project code should not become a collage of model styles.

**Reason:** Style fragmentation often signals deeper ownership fragmentation and
raises integration width for both humans and AI.

**Boundary:** Coherence does not protect ancestral mistakes from correction.

---

## D-014 — Do not finalize doctrine before corpus saturation

**Decision:** Current forensic intake remains nonfinal.

**Reason:** Historical gaps still exist, but corpus closure must be judged by explicit coverage and
mechanism saturation rather than by an impossible requirement to recover every named file.

**Consequence:** A final constitution requires an explicit quarry-closure argument, known gaps, and
evidence that remaining gaps are unlikely to change the mechanism set. Unavailable sources stay
UNKNOWN rather than blocking forever.

`CORPUS_SATURATION != EVERY_SOURCE_RECOVERED`

---

## D-015 — Authorship Engineering is a first-class engineering surface

**Decision:** Evaluate source authorship separately from executable correctness and generic
style hygiene.

**Reason:** The same semantics can be represented in ways that materially change semantic
recovery, owner discovery, modification locality, repair convergence, false confidence, and
future AI-generated descendants.

**Boundary:** Professional appearance is not semantic honesty. Ordinary senior craft remains a
strong baseline and must not be relabeled as Rahl-specific novelty.

---

## D-016 — Authority topology must be explicit

**Decision:** Prefer singular logical operational authority where one owner suffices. Do not elevate
that default into a universal topology rule.

**Reason:** AE-002 exposed accidental duplicate decision procedures, but legitimate systems may use
replication, consensus, partitioned ownership, CRDTs, leases, or temporary dual-write migration.

**Boundary:** When authority is intentionally plural, define reconciliation, conflict, quorum/cutover,
currentness, and failure semantics explicitly.

`SINGULAR_AUTHORITY != UNIVERSAL_AUTHORITY_TOPOLOGY`

---

## D-017 — Use the narrowest discriminative witness that satisfies the assurance need

**Decision:** For consequential guarantees, prefer a witness that can falsify the relevant bad state
without unnecessarily rebuilding the whole decision procedure.

**Reason:** Full recomputation can become shadow authority and can add stronger semantics than the
contract. But “weakest” is dangerous wording: a narrow witness still must have enough sensitivity,
coverage, and independence to answer the assurance question.

**Boundary:** Separate code is not automatically orthogonal. Name the common-mode story, false
positive/negative costs, placement, and authority.

`WITNESS_NARROWNESS != WITNESS_WEAKNESS`

`DIFFERENT_CODE != ORTHOGONAL_EVIDENCE`

---

## D-018 — Witness placement is part of the guarantee

Test-only, pre-effect veto, nonblocking pre-effect monitoring, and post-effect audit are not
interchangeable. Placement determines the live states covered and what consequence can still be
prevented or only observed. A runtime witness may carry veto/availability authority even without
selection authority.

---

## D-019 — Minimum Sufficient Embodiment is Pareto/minimal pressure, not one scalar optimum

Choose the minimum incidental causal/maintenance burden that satisfies the required consequence,
credible interaction field, assurance, and operating envelope. Multiple incomparable lawful
embodiments may exist.

`MINIMUM_SUFFICIENT_EMBODIMENT != UNIQUE_SCALAR_OPTIMUM`

---

## D-020 — Operating reserve planning and qualification are separate

For redline-able dimensions, use approximately 20% as the Commander-origin default planning
challenge where percentage headroom is meaningful. Keep distinct:

- rated/design requirement;
- planned/provisioned capacity target;
- tested/qualified envelope;
- operational/admission boundary;
- survival/degraded envelope;
- resource/physical failure boundary.

Planning reserve does not qualify reserve. Survival may mean rejection/degradation rather than
processing all offered load.

`PLANNED_HEADROOM != QUALIFIED_HEADROOM`

---

## D-021 — Circuit breaker is a donor pattern, not the generic name for overload protection

Use overload/redline protection as the generic concept. Circuit breakers specifically address
operations/dependencies likely to fail and help prevent repeated failing calls/cascades. Capacity
protection may instead use admission control, backpressure, bounded queues, rate limiting, load
shedding, bulkheads, quotas, or degradation.

`CAPACITY_RESERVE != CIRCUIT_BREAKER`

---

## D-022 — Exact-property proof and probabilistic evidence are different claim classes

V7 proxy factorization remains a strong gate for **exact** inheritance of a property from an
observable. It must not be read as saying a non-deterministically-sufficient proxy is evidentially
useless. Calibrated statistical evidence can support bounded probabilistic claims when its error
model and scope are explicit.

`EXACT_GUARANTEE != PROBABILISTIC_SUPPORT`

---

## D-023 — Verifiers should not contaminate the specimen they are qualifying

The sealed V7 verifier creates `__pycache__/*.pyc` during runtime verification after hygiene has
already passed. A second in-place run then fails hygiene. Running with `PYTHONDONTWRITEBYTECODE=1`
or on a disposable fresh copy yields replayable verification without changing V7 bytes.

`VERIFIER_PASS_THAT_DIRTIES_SPECIMEN != REPLAYABLE_VERIFIER`

---

## D-024 — Review-axis diversity and reviewer diversity are separate values

Multiple reviewers on the same axis can still add evidence; different axes can still share common
assumptions. Deliberately vary failure axis **and** seek independent information sources where the
claim warrants it.

`REVIEWER_COUNT != FAILURE_AXIS_DIVERSITY != EVIDENCE_INDEPENDENCE`

---

## D-025 — Procedure must serve an explicit engineering obligation

Uncertainty reduction is one obligation, not the only one. Procedure may also protect safety,
attribution, reproducibility, auditability, custody, fairness/compliance, reviewability, or
continuity. Remove ceremony when its causal job disappears.

---

## D-026 — Assembly order is a default causal strategy, not a universal pipeline

Recover semantics/ownership before building decorative orchestration by default. But walking
skeletons, API/contract-first work, integration-risk reconnaissance, or substrate discovery can
justify earlier end-to-end scaffolding. The scaffold must not acquire semantic authority merely
because it arrived first.

---

## D-027 — 20-pass cadence is an operator preference, not an epistemic unit

Bounded 20-pass slices remain a useful Commander planning default where a campaign benefits from
that cadence. Pass count carries no evidence strength and should not force a campaign whose
question is better answered in fewer or differently shaped experiments.

`PASS_COUNT != EVIDENCE_STRENGTH`

---

## D-028 — Option value must pay carrying cost

A future extension seam is current complexity. Preserve it when the credible future option is
worth the present carrying cost; otherwise a later replacement may be the better engineering
choice.

`OPTION_VALUE != FREE_OPTION`


---

## D-029 — Observation is evidence about reality, not reality itself

Reality outranks intent and narrative, but observation is mediated by instrumentation, sampling,
coverage, censoring, representation, and evaluator assumptions. A positive observed outcome carries
only the scope earned by that observation channel.

`OBSERVATION != REALITY`

`NO_OBSERVED_FAILURE != NO_FAILURE`

---

## D-030 — Incumbent ownership is not permanent entitlement

Recover the live/ancestral owner before adding parallel machinery. Prefer continuation when the owner
remains causally sound. If extending it preserves a known bad boundary, increases coupling, or blocks
credible evolution/recovery, explicit extraction, replacement, split, or migration can be the minimum
lawful surgery.

`CURRENT_OWNER != PERMANENT_OWNER`

---

## D-031 — Capacity reserve is typed, scoped, and currentness-bearing

Use ~20% as a Commander planning challenge only after naming a meaningful scalar dimension. Capacity
is often a vector/workload distribution. Separate demand variance, growth uncertainty, performance
headroom, redundancy/fault reserve, maintenance reserve, recovery reserve, and human operational
reserve when they have different failure roles. Do not double-count shared reserve against simultaneous
or correlated demands. Requalify after material system/workload/topology change.

`HEADROOM_ON_ONE_AXIS != SYSTEM_HEADROOM`

`SHARED_RESERVE != INDEPENDENT_RESERVES`

---

## D-032 — Quality axes are consequence- and obligation-relative

The query/request selects emphasis, not permission to drop standing invariants. Keep safety, security,
durability, compatibility, legal/custody, and other already-earned obligations active when relevant
even if the immediate request does not repeat them.

`QUERY_PRIORITY != PERMISSION_TO_DROP_STANDING_OBLIGATION`

---

## D-033 — Authorship continuity needs a novelty escape and currentness

Coherent authorship means continuity of engineering grammar, not incumbent-pattern lock-in. Genuine
semantic novelty may require new local vocabulary/structure. Professional appearance alone has no
authority. Generative/hereditary quality is relative to model/tool/task/context populations and must
carry currentness.

`COHERENT_AUTHORSHIP != INCUMBENT_PATTERN_LOCK_IN`

`GENERATIVE_QUALITY_AT_MODEL_M != UNIVERSAL_GENERATIVE_QUALITY`

---

## D-034 — Durability is an as-of-checkpoint property

A continuity package can only be current through its declared checkpoint. New load-bearing work after
release must be checkpointed before that work unit is continuity-complete.

`CHECKPOINT_COMPLETE_AT_T1 != CONTINUITY_CURRENT_AT_T2`

---

## D-035 — Verification needs membership completeness as well as identity

Checking every present required-looking member for byte equality does not prove all required members
are present. Verifiers for selected sets must carry an independent membership contract.

`ALL_PRESENT_MATCH != ALL_REQUIRED_PRESENT`

---

## D-036 — Known hostile-suite survival is bounded evidence

A mechanism or doctrine can overfit its known scar/mutation suite. Broader robustness claims require
renewed axes, held-out specimens/mutations, or other evidence beyond the current attack catalogue.

`KNOWN_ATTACK_SURVIVAL != GENERAL_ROBUSTNESS`

---

## D-037 — Minimum causal surface can be architecturally broad

Minimum lawful surgery is not a local-patch rule. When the cause spans ownership, schema, lifecycle,
or architecture, the smallest causal correction can be coordinated and broad.

`MINIMUM_CAUSAL_SURFACE != LOCAL_PATCH`

---

## D-038 — Rough research code must stay quarantined or requalify

Fast spikes may trade polish for information when explicitly research-only/disposable. If they gain
dependents, become examples/training context, or approach promotion, they owe the relevant authorship
and engineering gates.

`THROWAWAY_LABEL != ACTUALLY_THROWAWAY`


---

## D-039 — Optimize only inside the admissible design region

**Decision:** Standing obligations and admissibility constraints define which designs are admissible.
Minimality, performance, authorship, reserve, option value, and other optimization pressures operate
inside that set rather than overriding it.

`OPTIMIZATION_PRESSURE != AUTHORITY_TO_BREAK_A_CONSTRAINT`

---

## D-040 — Preserve UNKNOWN without converting uncertainty into paralysis

**Decision:** Keep uncertainty explicit. Permit bounded, reversible, observable evidence-gathering
actions when their authority and downside are acceptable; escalate qualification with irreversibility
and consequence.

`UNKNOWN != DO_NOT_ACT`

---

## D-041 — External contract semantics constrain host-native lowering

**Decision:** Use host-native representations internally, but do not let local idiom silently alter
wire, ABI, schema, persistence, or other standing interchange contracts.

`HOST_NATIVE_INTERNAL_REPRESENTATION != AUTHORITY_TO_CHANGE_EXTERNAL_CONTRACT`

---

## D-042 — Preserve scar evidence rather than obsolete machinery by default

**Decision:** Retain enough evidence to reconstruct and prevent the failure. Dead implementation may be
deleted when it has no live responsibility and the scar survives independently.

`SCAR_PRESERVATION != DEAD_CODE_RETENTION`

---

## D-043 — Time may be causal without serving as epistemic decay

**Decision:** Reject elapsed-time-only truth/currentness claims. Permit clocks, intervals, deadlines,
TTLs, wear models, leases, maintenance intervals, and other time variables when the system contract or
causal model actually depends on them.

`TIME_AS_CAUSE != TIME_AS_EPISTEMIC_PROXY`

---

## D-044 — Doctrine is not a universal scalarizer

**Decision:** Do not invent a global score to choose among all lawful designs. Preserve material Pareto
tradeoffs and name the authority/evidence required to resolve them.

`DOCTRINE != UNIVERSAL_SCALARIZER`

---

## D-045 — Classify doctrine statements by role

**Decision:** Distinguish admissibility constraints, standing obligations, qualification rules, defaults,
heuristics, triggers, scars, and research candidates. Typography or memorable wording does not equalize
their authority.

`DEFAULT != ADMISSIBILITY_CONSTRAINT`

`SCAR != PROHIBITION`
