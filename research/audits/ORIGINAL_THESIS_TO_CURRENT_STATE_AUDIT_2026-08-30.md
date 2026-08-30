# HOSTILE-OS original-thesis -> current-state audit — 2026-08-30

**Mode:** AUDIT
**Role:** R1 Conservative Auditor + R3 Evidence Synthesizer
**Frozen intent reference:** operator-uploaded `HOSTILE_OS_THESIS_COMMANDERS_INTENT_ENGINEERING_RESEARCH_MONOGRAPH_2026-08-30.md` and audited thread artifact
**Current local HEAD inspected:** `10b05576e68c136c9d4f6c098fba41933312bcac`
**Current architecture posture:** `INTEGRATED_SHADOW_CANDIDATE`
**Audit question:** Has the current HOSTILE-OS lineage remained faithful to the original thesis, or has it gradually become a different project while retaining the same story?

## Executive verdict

**THESIS CONTINUITY: STRONG / NOT PERFECT**

The later C002 -> C003 -> I001 -> D64 -> PR01 -> FR01 lineage is materially aligned with the original mission:

> re-derive the minimum capability-complete operating substrate from competing donor evidence; deny inherited architecture automatic authority; preserve only distinctions that change future-relevant consequences; compose before adding; let hostile pressure force mechanisms back in; keep claims bounded and evidence-ranked.

The strongest evidence of continuity is not that the later architecture looks relation-oriented. It is that later experiments repeatedly **forced complexity back in** when simpler forms failed:

- current completion state after lost-wake ordering failure;
- arbitration/history state under contention;
- explicit bounds after adjacent-memory corruption;
- generation/epoch currentness after stale-handle reuse;
- explicit initialization after dirty-slot reuse;
- shared live-count lifetime after premature reclaim;
- small IRQ-protected mutation regions after mixed/orphan observation;
- CRC16 + explicit commit after additive checksum collision;
- two-candidate validation-before-sequence after corrupt-newer negative control.

That pattern matches the frozen thesis better than a one-way simplification program would.

No evidence found that Linux/FreeDOS donor nouns, KarnOS/Holonix, ECS, schedulerlessness, or modern-OS architecture were silently imported as constitutional truth.

However, three meaningful drift risks and two coverage debts now exist and should remain visible.

---

## Audit matrix

| Frozen thesis requirement | Current evidence | Verdict | Notes / risk |
|---|---|---|---|
| Donors are witnesses, not parents | C001 donor extraction; C002/C003 descendants do not copy Process/Scheduler/File ontology; D64 resource-binding work explicitly avoids donor File/Manager ontology | **PASS** | Donor-derived scale numbers are used as pressure profiles, not constants of nature |
| Familiar nouns have no automatic primitive authority | C002 whole-P01 composition without Process/Scheduler/File/Manager/Service; C003/I001/D64 continue noun-hostile mechanism work | **PASS** | New nouns `activity`, `binding`, `resource` are now the main risk of becoming privileged by repetition |
| Composition before adding | Lost-wake repair added current completion only after failure; fixed capacity used before dynamic allocation; shared lifetime added as live count rather than GC/heap; CRC chosen after mechanism comparison | **PASS** | Need continued ablation whenever a new subsystem-like carrier appears |
| A distinction earns statehood only when merge changes reachable futures | P02/P03/P09/P10/P12/P17/R01/IRQCOUNT01 repeatedly distinguish identity, eligibility, continuation, currentness, history, timing telemetry | **PASS** | Currentness fields are increasingly broad; future work should keep proving where they are actually load-bearing |
| Simplification may fail and old-like machinery may return | C002 lost-wake, Linux service-history pressure, C003 explicit bounds/init/lifetime/currentness, IRQ coherence, FR01 integrity all re-earned extra state | **STRONG PASS** | This is one of the strongest anti-ideology signals in the project |
| Minimum incidental complexity subject to capability/guarantees | Stage2 bytes, runtime-state bytes, critical-region instruction counts, table sizes, durable-record bytes and alternative integrity costs are tracked | **PARTIAL PASS** | Energy, latency distribution, maintenance/assurance cost and synchronization cost are not yet measured as systematically as code/state size |
| Whole-workload embodiment, not toy-only success | C002 whole-P01; I001 freestanding integrated workload; D64 scale descendants; PR01/FR01 persistence descendants | **PASS** | D64/FR01 are targeted descendants, not one universal all-current-mechanisms workload |
| Harness/evaluator must be attacked | P05 invalid simulator; C002 stale evaluator; I001 IRQ-count overbinding; FR01 transport failures; Opus portability defects; run-input snapshots | **STRONG PASS** | Later tooling discipline is materially stronger than original C001 infrastructure |
| Preserve scars / do not recolor failures | Invalid simulator retained; failed I001 attempts retained; 660 red I001 runs remain FAIL historically; FR01 pre-QEMU/CHS/boot-drive failures retained | **STRONG PASS** | No evidence of retrospective cleanup found |
| Outcome > intended outcome; live artifact > memory | QEMU exits/debugcon/disk hashes/readback, independent audit, committed-object verification, GitHub remote readback | **PASS** | Live Shadow itself is currently stale relative to WT01 preregistration and must be corrected this turn |
| No architecture promotion from C001/C002 alone | C001/C002 no promotion; C003 no promotion; promotion occurred only after I001 whole-workload freestanding integration and separate review | **PASS** | `INTEGRATED_SHADOW_CANDIDATE` is a real promotion but remains explicitly non-final/demotable |
| Modern OS/prior personal architectures do not become design references during derivation | Current lineage remains donor/reality driven; no identified modern-Linux/NT architecture import | **PASS / WATCH** | External reviewer analogies and prior-project terminology must remain comparison/quarry only |
| Success means every important mechanism can explain why it exists and what breaks without it | Decision ledger/scars/result documents increasingly carry exact discriminator, bad control, authority ceiling and demotion triggers | **STRONG PASS** | This is now better embodied than at C001 |
| 20-pass campaign hard stop | C001/C002/C003 each closed 20/20 | **PASS HISTORICALLY / PROCESS DRIFT LATER** | Post-C003 research moved to targeted preregistered experiments (R01, I001, D64 descendants) rather than packaging each as a new 20-pass campaign |
| Representation before executor for C002 | C002 followed representation-first campaign law before executable whole-P01 closure | **PASS** | Later experiments appropriately test already-earned mechanisms, so this opening constraint need not repeat forever |
| Research object should eventually embody for reviewers without premature release promotion | `os/research_only/i001_reference/` exists and is independently reproducible; research remains separate from release | **PASS / DRIFT RISK** | Embodied reference is older than current D64/FR01 shadow state and could become a de facto anchor if not periodically refreshed |

---

## Strongest evidence that the original thesis is actually being tested

### 1. The project has not simply deleted familiar machinery

A preconceived minimal-OS ideology would tend to reward deletion and reinterpret every failure as a fixture problem.

The actual lineage did the opposite several times:

- Linux P05-P08 showed recent-service history carries real behavior under contention; one-bit wake credit was too weak.
- C002 lost-wake ordering forced a persistent completion distinction back into the mechanism.
- C003 P11 forced explicit bounds checking back in.
- P12/RK01/RR01 forced finite-width currentness and epoch/rekey logic back in.
- P13 forced explicit initialization of reused records.
- P16/RB02 forced shared-resource lifetime accounting.
- P14/IRQ01 forced actual coherence protection around coupled mutation.
- FR01 forced CRC16 + completion marker and validity-before-sequence.

These are not cosmetic additions. Each exists because a simpler state model lost a future-relevant consequence.

This is direct agreement with the frozen admission law.

### 2. Historical bundles have weakened without their responsibilities disappearing

The lineage has repeatedly preserved responsibilities while refusing to grant historical bundles primitive status:

- scheduling pressure became eligibility + arbitration/history + selection/application rather than immediate Scheduler object;
- process-like behavior became identity/currentness + lineage + continuation + wait/wake + progress rather than one Process object;
- file-like sharing became checked bindings + backing/resource identity + cursor/mode/lifetime/currentness rather than one File species.

Importantly, the lower distinctions then survived freestanding embodiment and D64 scaling.

That does **not** prove Process/Scheduler/File abstractions are universally wrong. It does show they are not required as primitive species for the tested workloads.

### 3. Representation accidents have repeatedly been exposed as semantics

The frozen thesis predicted that historical phenotype can hide semantics in accidental carriers.

Later work continued finding exactly that shape:

- Linux table position carried tie behavior;
- bare slot/index silently retargeted after reuse;
- generation alone aliased after reset without epoch;
- an IRQ could observe coupled relation state half-published;
- exact IRQ event count was evaluator telemetry, not the tested wake/progress meaning;
- QEMU executable bytes without module environment were not a usable transplanted runtime;
- LLVM resolved path was not equivalent to invocation identity.

This continuity is conceptually strong: the project keeps asking *where the future-relevant meaning actually lives* rather than trusting names/locations.

---

## Drift risk 1 — `activity / binding / resource` can become the new cathedral nouns

### Verified current condition

The current interpretive synthesis uses:

`activity -> checked binding -> resource`

as the strongest surviving conceptual shape.

That is currently lawful as a **working compression** because many descendants have exercised those relations.

### Risk

Repetition can turn these words into privileged ontology in exactly the way `Process`, `Scheduler`, and `File` were originally denied privilege.

For example:
- an `activity` could still be bundling identity, continuation, eligibility, lineage, wait state and policy history;
- a `binding` could bundle applicability, currentness, authority, cursor, mode and lifetime relation;
- a `resource` could bundle durable identity, backing value, live runtime representation and policy.

### Required guard

Treat these as incumbent **working names**, not constitutional atoms.

Future promotion must still permit:
- splitting them if a discriminator exposes independent futures;
- merging pieces if future-equivalence permits it;
- replacing the names entirely if a lower grammar is cheaper/clearer.

**Disposition:** WATCH / no current demotion.

---

## Drift risk 2 — research-only I001 body can become an accidental architecture anchor

### Verified current condition

`os/research_only/i001_reference/` is a useful independently reproducible body. It is explicitly labeled research-only and not final.

But the scientific frontier has moved materially beyond it:
- D64 capacity/currentness/resource-binding work;
- IRQ01;
- PR01 clean restart;
- IRQCOUNT01;
- FR01 deterministic faulted-media recovery;
- WT01 preregistered writer-boundary pressure.

### Risk

Reviewers/contributors may begin treating the only easily runnable body as “what HOSTILE-OS is,” while newer research remains only under `research/`.

That would reverse the intended authority relationship: embodiment convenience would begin to outrank newer science.

### Required guard

Keep explicit documentation that:

`research-only embodiment != current full shadow architecture != release`

and plan periodic **embodiment convergence reviews** where newly adopted mechanisms are either deliberately incorporated into a newer research body or explicitly left out with reasons.

Do not continuously mutate the body after every experiment; that would contaminate science and create churn. Update it at deliberate integration gates.

**Disposition:** WATCH / integration-governance debt.

---

## Drift risk 3 — post-C003 research no longer literally follows the 20-pass campaign unit

### Frozen rule

The original monograph states the current campaign unit as exactly 20 scientific passes with a P20 hard stop.

### Current behavior

C001, C002, and C003 obeyed this exactly: 60 passes total.

After C003 the project shifted to individually preregistered targeted experiments:
- POST-C003/R01;
- I001;
- D64/A01;
- RK01/RB02/ARB01/RR01/IRQ01/PR01/IRQCOUNT01/FR01;
- WT01 preregistered.

These experiments generally have sharper individual questions, explicit preregistration, independent closure, adoption review and authority ceilings.

### Audit interpretation

This is a **real process change**, not imaginary continuity.

It is not automatically methodological regression. In fact, after C003 the unknowns became narrower engineering/science seams where forcing every question into another 20-pass campaign could manufacture low-value pass count and violate the frozen warning against endless story-building.

However, the change should be explicitly adjudicated rather than silently treated as if the original 20-pass rule were still literally controlling every science unit.

Recommended reconciliation:

- retain 20-pass HSP campaigns for broad exploratory domains where each pass naturally exposes the next discriminator;
- permit single preregistered descendant experiments for already-localized seams;
- require the same HSP/PDVER/Helix evidence laws, stop condition, scar retention and promotion separation;
- after a bounded set of descendants, run a campaign-level reconciliation/integration review rather than accumulating experiments indefinitely.

**Disposition:** PROCESS DRIFT / REQUIRES DOCTRINE CLARIFICATION, not science demotion.

---

## Coverage debt 1 — Pareto accounting is still uneven

The frozen thesis defines complexity as a vector, not a scalar.

Current work tracks several dimensions unusually well:
- binary size;
- runtime-state bytes;
- durable-record bytes;
- table capacity;
- instruction count in critical windows;
- dependency/tooling burden;
- ontology/primitives qualitatively;
- assurance burden through auditors/manifests/scars.

But the following remain mostly qualitative or unmeasured:
- energy/power;
- latency/jitter distributions outside selected cases;
- cache/bandwidth effects;
- maintenance cost;
- debugging/operator cost;
- proof cost as architecture scales;
- synchronization overhead under stronger concurrency.

This does not invalidate the current architecture candidate, but it means “Pareto-optimal” is still a hypothesis for many dimensions.

**Disposition:** OPEN MEASUREMENT DEBT.

---

## Coverage debt 2 — modern-system blind convergence has not yet reached the mature comparison phase

The frozen thesis intentionally held modern Linux/Windows/BSD/Plan9/microkernels and prior personal architectures behind glass until independent derivation matured.

Current HOSTILE-OS is now substantially more mature than at C001 and has an `INTEGRATED_SHADOW_CANDIDATE`, but the project has not yet performed a systematic **blind convergence classification** against mature systems.

This is probably correct timing: physical hardware, stronger concurrency, memory/protection/device models, and interrupted-write persistence are still open.

Still, the comparison phase is now visible on the horizon. It should happen only after a deliberate maturity gate, not casually through architecture borrowing.

**Disposition:** NOT YET DUE / FUTURE GATE.

---

## Architecture-promotion audit

The separate I001 promotion from `NO ARCHITECTURE PROMOTION` to `INTEGRATED_SHADOW_CANDIDATE` is consistent with the frozen thesis **provided its current authority ceiling remains intact**.

Why it is lawful:
- C001/C002 did not promote architecture;
- C003 remained bounded and non-promoted;
- I001 provided one freestanding integrated workload across two fresh QEMU boots;
- promotion happened in a separate conservative audit rather than being implied by a green test;
- the posture remains demotable and explicitly not final/canonical/production-ready.

Current D64/FR01 descendants strengthen several incumbent rules but still do not justify final promotion.

**Verdict:** promotion is consistent with original Commander’s Intent; no demotion is required by this audit.

---

## Thesis continuity scorecard

These scores are audit shorthand, not scientific measurements.

- Donor neutrality: **strong**
- Noun-hostility / ontology discipline: **strong, with new-noun watch**
- Composition-first: **strong**
- Failure localization: **very strong**
- Harness/evaluator skepticism: **very strong**
- Scar preservation: **very strong**
- Whole-workload embodiment: **strong at bounded scopes**
- Pareto burden tracking: **moderate / uneven**
- Non-preconceived outcome discipline: **strong**
- Architecture-promotion discipline: **strong**
- Original 20-pass process continuity: **changed after C003; needs explicit doctrine reconciliation**
- Reviewer embodiment/current-science convergence: **useful but lagging**

Overall:

`ORIGINAL_THESIS_CONTINUITY = STRONG`

`PROJECT_DRIFTED_INTO_DIFFERENT_MISSION = false`

`PROCESS_DOCTRINE_DRIFT_EXISTS = true`

`NEW_ONTOLOGY_LOCK_IN_RISK = true`

`EMBODIMENT_LAG_RISK = true`

`ARCHITECTURE_DEMOTION_REQUIRED = false`

---

## Immediate actions recommended by this audit

1. **Do not interrupt WT01 science merely to redesign the architecture.** Its preregistration directly pressures a currently open persistence seam and is consistent with the thesis.
2. Before executing WT01, seal the current implementation only after smoke/static checks as already planned.
3. Add a doctrine clarification after WT01 or before the next broad research branch: 20-pass campaigns remain the broad-domain unit, while localized descendants may run as individually preregistered experiments with periodic integration reconciliation.
4. Add an explicit `WORKING_NOUNS_ARE_NOT_PRIMITIVES` rule covering `activity`, `binding`, and `resource`.
5. Schedule an embodiment convergence review after WT01/next persistence closure rather than immediately mutating the I001 research body.
6. Begin extending Pareto receipts to include at least measured wall time/latency distributions and explicit synchronization/firmware dependency burden where relevant.
7. Do not open mature-OS comparison yet; define the maturity gate first.

## Final audit statement

The current project is recognizably the same experiment described by the frozen Commander’s Intent.

The strongest evidence is behavioral: later work repeatedly refused both easy historical answers and easy minimalist answers. When a simpler composition failed, the project added the smallest observed missing distinction and preserved the failed branch. When a familiar noun was unnecessary, it stayed out. When hidden infrastructure behavior contaminated evidence, the infrastructure was corrected rather than promoted into OS meaning.

That is the original thesis operating as a method, not merely surviving as prose.

The project should continue, but with the three drift guards above made explicit so the successful relation vocabulary, runnable reference body, and descendant-experiment cadence do not themselves become the next generation of cathedral smoke.
