# R3.1 In-House SOP Adoption Adjudication — 2026-08-30

**Mode:** BUILD-COMMIT / PROMOTION
**Operator decision:** `Adopt this as SOP and then proceed`
**Adopted surface:** `RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29`
**Operational status after this adjudication:** `ADOPTED_IN_HOUSE_SOP`
**Foundation promotion:** NO
**R6 lineage/fallback authority retained:** YES

## Package identity

The operator-provided ZIP in this turn is byte-identical to the ZIP already recorded in `authority/ADOPTION_STATE.md`.

ZIP SHA-256:

`4d205becc2413889bdb37c6b6ff7513d6f759a7dff1d9f9b8fddaddd8235a278`

The uploaded archive contains 46 files under:

`RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29/`

The existing local extracted authority tree contains the same candidate package. Core file hashes including the candidate manifest, engineering authority surface, internal research governance, execution/release discipline, next discriminator, authority contract, release verification, and verifier match the uploaded package.

## Verification readback

### Uploaded package / Linux-side verifier

The candidate's own `VERIFY_CANDIDATE.py` executed against the uploaded extracted package in the chat-side Linux sandbox and returned exit 0:

`PASS: exact membership, pinned ancestry, source class+body binding, exact human-section binding, governance boundary, active scars, execution/release recovery, honest coverage blockers, and dormant substrate schema`

Declared assurance ceiling:

`STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY`

### Local Windows-side verifier portability scar

The same sealed verifier does not run cleanly against the local extracted tree on Windows because its membership check compares manifest paths using `/` against `Path.relative_to()` strings using `\\`. It reports every nested path as missing plus the same path with backslashes as extra.

This is a verifier portability defect, not package membership drift.

The sealed candidate package is not rewritten to hide this scar.

An independent Windows-side manifest verification normalized local relative paths with `.as_posix()` and then checked exact membership and SHA-256 values:

- manifest entries: 45 non-manifest files
- actual non-manifest files: 45
- missing: none
- extra: none
- hash mismatches: none
- result: PASS

The candidate's own verifier hash remains:

`c76fc12a30da39cb58fdf81beb01887309065caaaf58276220bc909dc94db067`

## Prior gate and project use

The sealed R3.1 package said the only replacement blocker was:

`FRESH_REAL_PROJECT_SHADOW_USE`

The project later recorded `authority/R3_1_SHADOW_SESSION_REINCARNATION_PACKAGE.md`:

`SHADOW_SESSION_SURVIVED_BOUNDED_REINCARNATION_TASK`

That observation found no materially different lawful project decision between R3.1 and R6 for the bounded reincarnation task and found lower query-to-authority distance under R3.1.

Subsequent HOSTILE-OS work continued using the R3.1 split surface while repeatedly preserving the same core authority boundaries: exact evidence before inference, inherited statement classes, execution/readback discipline, scars, UNKNOWN handling, internal-governance separation, and explicit no-promotion ceilings across C003, I001, D64/A01, and D64/RK01.

A later conservative architecture audit still withheld `replacement_ready=true` because that audit did not treat its HOSTILE-OS mechanism corpus as a broad R3.1-vs-R6 equivalence study. That historical decision remains valid for that audit and is not rewritten.

The operator has now supplied the separate promotion/adoption action that the shadow-session record explicitly required.

## Adoption decision

R3.1 is adopted as the normal in-house engineering/research SOP surface.

Operational meaning:

1. Cold start and day-to-day engineering/research work SHALL begin from the R3.1 split surfaces rather than requiring routine traversal of R6.
2. `01_ENGINEERING_AUTHORITY_SURFACE.md` carries the classified engineering rules using their inherited V5/R6 statement classes.
3. `03_INTERNAL_RESEARCH_GOVERNANCE.md` governs in-house research process and SHALL NOT silently become product/foundation engineering content.
4. `04_EXECUTION_AND_RELEASE_DISCIPLINE.md` is load-bearing for consequential execution, release, continuity, and verification work.
5. `05_ACTIVE_SCAR_INDEX.md` remains attack/replay pressure rather than a static ban list.
6. `03A_RESEARCH_MACHINERY_AND_MODES.md` preserves named machinery/modes with bounded process authority; old topology SHALL NOT resume automatically.
7. Project-local obligations and substrate profiles remain separately activated rather than being manufactured by the SOP.
8. R1 and R2 remain rejected as replacement candidates.

## Authority topology after adoption

### R3.1

Status:

`ADOPTED_IN_HOUSE_SOP`

Role:

- default operational engineering/research SOP surface;
- compression/split surface for inherited authority;
- no new foundation authority merely from adoption.

### R6

Status:

`PARENT_LINEAGE_AND_FALLBACK_AUTHORITY`

Role:

- exact embedded ancestry/source authority behind inherited statement classes;
- fallback for ambiguity, omitted context, conflict, or qualification questions;
- no longer the normal first-read/day-to-day operator surface when R3.1 directly covers the question.

R6 is not tombstoned or erased.

## Replacement-ready semantics

`replacement_ready=true` is now lawful **for operational SOP-surface replacement** because:

- the sealed candidate's declared fresh-real-project shadow-use blocker was satisfied at bounded scope;
- long-running project use has not exposed an authority-class collapse or missing operational execution discipline;
- the operator explicitly authorized adoption in a separate promotion action.

This does **not** mean:

- semantic identity to every sentence/context in R6 has been proven;
- R6 ancestry may be deleted;
- R3.1 gains new foundation authority;
- HOSTILE-OS architecture is promoted;
- R3.1 becomes product doctrine;
- every future project obligation is known in advance.

## Conflict rule

When R3.1 and R6 appear to differ:

1. prefer exact project obligation and current evidence;
2. identify the inherited statement class;
3. inspect R6/V5 ancestry when the R3.1 compressed surface is ambiguous or appears incomplete;
4. do not let newer/easier wording silently override a stronger inherited admissibility or qualification rule;
5. record any real semantic mismatch as a scar/revisit and demote the affected R3.1 rule if necessary.

## Demotion triggers

Reopen this adoption if future work shows:

- R3.1 produces a materially unlawful decision that R6 would reject;
- inherited statement-class information is lost in an operational path;
- cold-start use omits a load-bearing scar or execution/release obligation;
- a verifier/source-binding defect permits semantic mutation of a governed rule;
- the split materially increases recovery burden rather than reducing it.

## Verifier portability maintenance item

The Windows nested-path membership bug is now an active maintenance scar:

`MANIFEST_PATH_SEPARATOR_PORTABILITY != PACKAGE_MEMBERSHIP_DRIFT`

Repair may be made only in a descendant verifier/candidate or maintenance wrapper. Do not mutate the sealed R3.1 package in place merely to make its verifier portable.

## Disposition

`R3_1_ADOPTED_IN_HOUSE_SOP / OPERATIONAL_SURFACE_REPLACEMENT_READY / R6_RETAINED_AS_PARENT_LINEAGE_AND_FALLBACK / FOUNDATION_PROMOTION_FALSE / WINDOWS_VERIFIER_PORTABILITY_SCAR_RECORDED`
