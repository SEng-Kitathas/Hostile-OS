from __future__ import annotations
from pathlib import Path
import hashlib, json, shutil, zipfile, os, textwrap, subprocess, sys

DATE='2026-08-29'
NAME=f'HOSTILE_OS_PCMMAD_MAXIMUM_REINCARNATION_{DATE}'
ROOT=Path('/mnt/data')/NAME
if ROOT.exists(): shutil.rmtree(ROOT)
for d in ['00_START','01_AUTHORITY','02_HISTORY','03_THEORY','04_CAMPAIGNS/C001','04_CAMPAIGNS/C002','04_CAMPAIGNS/C003','05_LINEAGE','06_SCARS','07_PCMMAD_MIGRATION','08_PAYLOADS/authority','08_PAYLOADS/foundation','08_PAYLOADS/campaigns','08_PAYLOADS/lab_tooling','09_MACHINE','10_TOOLS','11_RECEIPTS']:
    (ROOT/d).mkdir(parents=True, exist_ok=True)

def write(rel, s):
    p=ROOT/rel; p.parent.mkdir(parents=True,exist_ok=True); p.write_text(textwrap.dedent(s).lstrip(),encoding='utf-8',newline='\n'); return p

def sha(p):
    h=hashlib.sha256();
    with open(p,'rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
    return h.hexdigest()

sources = {
 'sop_r3_1': Path('/mnt/data/RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29(4).zip'),
 'genesis': Path('/mnt/data/hostile_os_foundation/HOSTILE_OS_GENESIS_2026-08-26.zip'),
 'c001_init': Path('/mnt/data/hostile_os_foundation/HOSTILE_OS_CAMPAIGN_001_INIT_2026-08-26.zip'),
 'c001_ontology': Path('/mnt/data/hostile_os_foundation/HOSTILE_OS_CAMPAIGN_001_INIT_ONTOLOGY_INTEGRATED_2026-08-26.zip'),
 'c001_close': Path('/mnt/data/hostile_os_lab_live/HOSTILE_OS_C001_CLOSE_2026-08-27.zip'),
 'smuggle001': Path('/mnt/data/HOSTILE_OS_SMUGGLE_001.zip'),
 'patch002': Path('/mnt/data/HOSTILE_OS_SMUGGLE_PATCH_002.zip'),
 'backdoor003': Path('/mnt/data/HOSTILE_OS_BACKDOOR_003_PERIOD_RECON.zip'),
 'backdoor004': Path('/mnt/data/HOSTILE_OS_BACKDOOR_004_IA16_TOOLCHAIN.zip'),
}

copy_map = {
 'sop_r3_1':'08_PAYLOADS/authority/RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29.zip',
 'genesis':'08_PAYLOADS/foundation/HOSTILE_OS_GENESIS_2026-08-26.zip',
 'c001_init':'08_PAYLOADS/campaigns/HOSTILE_OS_CAMPAIGN_001_INIT_2026-08-26.zip',
 'c001_ontology':'08_PAYLOADS/campaigns/HOSTILE_OS_CAMPAIGN_001_INIT_ONTOLOGY_INTEGRATED_2026-08-26.zip',
 'c001_close':'08_PAYLOADS/campaigns/HOSTILE_OS_C001_CLOSE_2026-08-27.zip',
 'smuggle001':'08_PAYLOADS/lab_tooling/HOSTILE_OS_SMUGGLE_001.zip',
 'patch002':'08_PAYLOADS/lab_tooling/HOSTILE_OS_SMUGGLE_PATCH_002.zip',
 'backdoor003':'08_PAYLOADS/lab_tooling/HOSTILE_OS_BACKDOOR_003_PERIOD_RECON.zip',
 'backdoor004':'08_PAYLOADS/lab_tooling/HOSTILE_OS_BACKDOOR_004_IA16_TOOLCHAIN.zip',
}
for k, rel in copy_map.items():
    shutil.copy2(sources[k], ROOT/rel)

# Exact R3.1 extracted surface for cold start.
sop_extract=ROOT/'01_AUTHORITY/RAHL_ENGINEERING_R3_1_EXACT_EXTRACTED'
with zipfile.ZipFile(sources['sop_r3_1']) as z: z.extractall(sop_extract)

# Key historical docs copied out for direct cold-start reading.
gtmp=Path('/mnt/data/_hos_reinc_gen'); ctmp=Path('/mnt/data/_hos_reinc_c1')
for t in [gtmp,ctmp]:
    if t.exists(): shutil.rmtree(t)
    t.mkdir()
with zipfile.ZipFile(sources['genesis']) as z:z.extractall(gtmp)
with zipfile.ZipFile(sources['c001_close']) as z:z.extractall(ctmp)
groot=next(p for p in gtmp.iterdir() if p.is_dir())
croot=next(p for p in ctmp.iterdir() if p.is_dir())
for srcname,dst in [
 ('00_REINCARNATION_BOOTLOADER.md','02_HISTORY/FOUNDATION_F0_REINCARNATION_BOOTLOADER.md'),
 ('01_CONTINUOUS_FORENSIC_HISTORY.md','02_HISTORY/CONTINUOUS_FORENSIC_HISTORY_THROUGH_F0.md'),
 ('02_CONSTITUTION_AND_LAWS.md','03_THEORY/FOUNDING_CONSTITUTION_AND_LAWS.md'),
 ('03_CROSS_PROJECT_QUARRY_LEDGER.md','05_LINEAGE/CROSS_PROJECT_QUARRY_LEDGER_F0.md'),
 ('04_DONOR_LOCK_AND_CONTAMINATION_LEDGER.md','05_LINEAGE/DONOR_LOCK_AND_CONTAMINATION_LEDGER_F0.md'),
 ('08_NEVER_SILENTLY_REINTRODUCE.md','06_SCARS/NEVER_SILENTLY_REINTRODUCE_F0.md'),
 ('SOURCE_REGISTRY.md','05_LINEAGE/SOURCE_REGISTRY_F0.md'),
]: shutil.copy2(groot/srcname, ROOT/dst)
for srcname,dst in [
 ('CAMPAIGN_SUMMARY.md','04_CAMPAIGNS/C001/C001_P20_SUMMARY.md'),
 ('SEMANTIC_HELIX_LEDGER.md','04_CAMPAIGNS/C001/C001_SEMANTIC_HELIX_LEDGER.md'),
 ('HSP_CAMPAIGN_EXECUTION_MAP.md','04_CAMPAIGNS/C001/C001_HSP_EXECUTION_MAP.md'),
 ('CSC_AUDIT.json','04_CAMPAIGNS/C001/C001_CSC_AUDIT.json'),
 ('NEXT_CAMPAIGN_C002_PREREG.md','04_CAMPAIGNS/C001/C002_ORIGINAL_PREREG_FROM_C001.md'),
 ('CONTINUITY_BOOTLOADER.txt','04_CAMPAIGNS/C001/C001_CONTINUITY_BOOTLOADER.txt'),
]: shutil.copy2(croot/srcname, ROOT/dst)

# Supporting receipts already in sandbox.
receipt_candidates={
 'HOSTILE_OS_SMUGGLE_001_QUALIFICATION_RECEIPT.txt':Path('/mnt/data/HOSTILE_OS_SMUGGLE_001_QUALIFICATION_RECEIPT.txt'),
 'HOSTILE_OS_SMUGGLE_PATCH_002_QUALIFICATION_RECEIPT.txt':Path('/mnt/data/HOSTILE_OS_SMUGGLE_PATCH_002_QUALIFICATION_RECEIPT.txt'),
 'LAB_STATE_THROUGH_RUN018.txt':Path('/mnt/data/hostile_os_lab_live/HOSTILE_OS_LAB_STATE_THROUGH_RUN018_2026-08-27.txt'),
}
for name,p in receipt_candidates.items():
    if p.exists(): shutil.copy2(p,ROOT/'11_RECEIPTS'/name)

# C002 recovered exact visible content from File Library view; provenance is explicit.
c002 = r'''# C002 / P20 — campaign reconciliation and hard stop

**Disposition:** CAMPAIGN CLOSED / WHOLE-P01 RELATION COMPOSITION SURVIVED AFTER REPAIR / NO ARCHITECTURE PROMOTION  
**Scientific pass:** 20 of 20  
**Hard stop:** ACTIVE — no C002/P21 is lawful.

## Question actually answered

C002 asked whether the relation-level distinctions earned in C001 could compose into the complete qualified P01 consequence workload without making historical nouns such as Process, Scheduler, File, Manager, or Service into primitives.

Within the bounded Python research descendant, the answer is **yes, after a real hostile failure and repair**. P16 first closed the whole workload. P17 then broke that closure in 18 of 72 timing/order cases when child completion happened before the parent installed its wait. P18 repaired the actual missing distinction by retaining bounded, generation-scoped **current completion condition** rather than relying only on a one-shot notification. P19 replayed the unchanged 72-case matrix and reached 72/72 after a separate stale-evaluator bug was found, preserved, and corrected.

That sequence matters more than the final green matrix. The campaign earned its closure by failing twice in two different places: first in the mechanism, then in the evaluator.

## Strongest relation/mechanism survivors

C002 supports these narrow claims under P01 conditions:

- Representation can close over identity, resource identity, lineage, eligibility, waiting, continuation binding/state, memory binding, access/backing binding, and durable bytes without historical subsystem nouns in the machine schema.
- Selection can remain separate from execution application.
- Wait/event matching can remain separate from execution application.
- Narrow parent-child return composes from lineage plus generic wait/wake; P01 did not require a special return mechanism or return-binding primitive.
- Lineage qualifies that narrow dependency but does **not** become general authority.
- Bounded multi-eligible choice can be separate policy state. Equal rotation needs some history/fairness state; a memoryless fixed tie can starve.
- Raw numeric policy position can drift when membership changes. Identity-bound policy history plus coherent lifecycle repair survived the tested mutation.
- Lifecycle and policy can be semantically separate while still requiring one coherent/atomic mutation boundary.
- Idle identity is not required by the cross-donor responsibility. The required responsibility is no eligible useful work -> relinquish/wait while remaining wakeable.
- The empty-to-wait boundary needs a lost-wake-safe arm/recheck/wait contract.
- Reused one-shot relation labels need instance/currentness distinction in the tested cases; elapsed time was not used as freshness.
- Durable resource identity can survive restart while runtime access currentness expires.
- Clean-restart persistence composes from durable bytes plus a fresh qualified rebind; stale runtime bindings are not hydrated as current.
- Bounded local failure can preserve coherent later progress without a global error-manager object.
- Async event observation can update current wait/eligibility and ordinary execution can resume; event provenance remains separate and UNKNOWN when fixture-supplied.
- A terminal condition that remains relevant to a later wait is not equivalent to a one-shot transition notification. Bounded current completion state was required by the hostile ordering matrix.

These are semantic/mechanism claims. They do not require one struct per relation, ECS storage, a graph database, or the Python representation used by the descendant.

## Major scars

**P01 harness scar:** an invalid representation harness and an over-complete repair were preserved before the final narrow representation test. Clean output from a bad harness does not count.

**P17 mechanism scar:** 18/72 whole-workload scenarios failed. The child could finish before the parent installed its wait; the one-shot completion notification disappeared, and the parent could wait forever. This was not a harness failure.

**P19 evaluator scar:** the first replay still reported those 18 cases because the evaluator knew only the old success path, `notification wakes waiting parent`. P18 had lawfully added `already complete` as a second success path. The stale evaluator was preserved as invalid evidence, then corrected without changing the scenario matrix.

Together they reinforce the execution law:

`action/trace/test output != qualified consequence`

The mechanism, fixture, launcher, and evaluator are separate things that can each fail.

## What C002 did not earn

C002 did **not** promote its Python prototype into an OS architecture. It did not earn ECS/holons, schedulerlessness, a capability kernel, universal generations on all events, a general authority system, namespace/name-binding semantics, crash/partial-write recovery, multi-waiter/reaping semantics, real device timing, multicore/coherency behavior, priority inversion handling, energy/thermal claims, or machine-code implementation of the relation composition.

The campaign also did not complete destructive relation ablation or a full Pareto burden comparison. P17's real failure lawfully consumed the remaining campaign budget. That work stays in the Reservoir; it is not squeezed into P20.

## Pareto result

C002 reduced the need for several historical subsystem primitives under the qualified workload, but it did not prove the descendant globally smallest. Some state distinctions earned their cost only after hostile timing attacks: arbitration history, current wait/access instance, wake-entry state, and current terminal completion condition all prevent concrete failures. They therefore cannot be deleted merely because they add state.

The largest remaining burden may be hidden in the **Python host itself**: containers, dynamic allocation, object identity, exceptions, collection behavior, and host execution semantics may be silently paying for capabilities the explicit descendant schema does not name.

That is now the highest-value anti-toy pressure.

## Hard stop and next campaign

C002 ends here at exactly 20 scientific passes. No C002/P21 is lawful.

After the Attention Reservoir breadth check, C003 is selected as **freestanding low-level embodiment of the C002 whole-P01 relation composition**. Its first job is not to build a mature OS. It is to find what the Python scaffold was secretly doing for us by translating the smallest qualified composition into explicit x86/QEMU state and behavior.

Architecture promotion remains forbidden. Failure during translation is evidence about a missing distinction, hidden dependency, or representation cost—not permission to recreate Process/Scheduler/File by name.
'''
write('04_CAMPAIGNS/C002/C002_P20_RECOVERED_FILE_LIBRARY_VIEW.md',c002)
write('04_CAMPAIGNS/C002/PROVENANCE.md', '''
# C002 recovered-state provenance

The exact C002 campaign tree/archive was not materialized in the active sandbox used to build this reincarnation package.

The P20 result above was recovered from the user's OpenAI File Library on 2026-08-29 from `P20_RESULT.md` (File Library id surfaced as `file_000000001d8481f59035f8a81bb68fb1`, created/modified 2026-08-27T06:56:00Z). It is a recovered text view, not a claim of byte-identical possession of the original file or the full C002 run tree.

Do not invent missing C002 per-pass artifacts. The recovered P20 state is sufficient to preserve the campaign's lawful result/frontier; if full forensic replay is needed, retrieve the original C002 artifacts from the prior OpenAI file corpus or re-run from an explicitly reconstructed checkpoint with the gap declared.
''')

# Authority/adoption docs.
write('00_START/00_READ_ME_FIRST.md', '''
# HOSTILE-OS — PCMMAD Maximum Reincarnation Package

**Built:** 2026-08-29  
**Purpose:** move HOSTILE-OS from the OpenAI sandbox/file-shuttle workflow to a PCMMAD server with direct development-machine access without losing history, authority, theory, scars, evidence boundaries, or the current research frontier.

## Read order

1. `01_AUTHORITY/ADOPTION_STATE.md`
2. `00_START/01_COMMANDERS_INTENT.md`
3. `00_START/02_CURRENT_STATE_AND_FRONTIER.md`
4. `03_THEORY/FULL_THEORY_OF_WORK.md`
5. `02_HISTORY/PROJECT_CHRONOLOGY.md`
6. `05_LINEAGE/LINEAGE_AND_CONTAMINATION_MAP.md`
7. `06_SCARS/EXECUTION_AND_INFERENCE_SCARS.md`
8. `04_CAMPAIGNS/C002/C002_P20_RECOVERED_FILE_LIBRARY_VIEW.md`
9. `04_CAMPAIGNS/C003/C003_PREREGISTRATION.md`
10. `07_PCMMAD_MIGRATION/PCMMAD_SERVER_MIGRATION.md`
11. `00_START/03_REINCARNATION_BOOT_PROMPT.txt`

## Current state in one paragraph

HOSTILE-OS has completed two 20-pass scientific campaigns. C001 used Linux 0.01 and FreeDOS as competing live donors to strip historical `Process` / `Scheduler` / `File` bundles into future-relevant relations. C002 then showed, inside a bounded Python research descendant and after real hostile failures/repairs, that the whole qualified P01 workload can compose from those relations without granting the historical nouns primitive status. No OS architecture has been promoted. C003 is selected next: freestanding low-level x86/QEMU embodiment whose job is to expose what Python was secretly doing for the relation substrate.

The engineering SOP adopted for this package is **R3.1 in `SHADOW_USE_CANDIDATE` mode exactly as packaged**. R3.1 is compression-only, inherits no new authority, and R6 remains parent authority. R1/R2 remain rejected.
''')

write('01_AUTHORITY/ADOPTION_STATE.md', f'''
# Engineering / Research SOP adoption state

Adopted surface: `RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29`

- Status: `SHADOW_USE_CANDIDATE`
- Replacement ready: `false`
- Candidate authority: `COMPRESSION_ONLY_INHERITS_NO_NEW_AUTHORITY`
- Parent authority: `R6`
- Parent R6 SHA-256 declared by R3.1: `69721b7b6c4b8c04d5377f1b7c0afa044530a6352496c7cb564f4cb4ef2df257`
- Foundation promotion: `false`
- R1 / R2: rejected as replacement candidates
- Uploaded R3.1 ZIP SHA-256: `{sha(sources['sop_r3_1'])}`
- Local verifier result during this build: PASS
- Assurance ceiling: `STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY`

## Exact adoption rule

Use R3.1 as the normal in-house engineering/research **shadow surface**, but do not allow it to outrank R6 merely because it is newer or easier to read. When R3.1 and R6 appear to differ, resolve through inherited statement class, exact ancestry, actual project obligations, evidence, and currentness.

Do not silently promote R3.1 to replacement-ready. This reincarnation-package build is recorded as one bounded fresh real-project shadow-use observation in `R3_1_SHADOW_SESSION_REINCARNATION_PACKAGE.md`; it does not itself perform a foundation/replacement promotion.
''')

write('01_AUTHORITY/R3_1_SHADOW_SESSION_REINCARNATION_PACKAGE.md', '''
# R3.1 fresh real-project shadow-use observation

**Project:** HOSTILE-OS PCMMAD reincarnation package  
**Mode:** shadow-use only  
**Parent comparison:** R6 embedded ancestry  
**Promotion authority:** NONE

## Decision-equivalence observation

For this task, R3.1 and R6 drive the same lawful actions: recover exact lineage/current state before synthesis; preserve project-local obligations separately from universal engineering rules; use execution/release readback rather than command-success narration; preserve active scars; retain internal research governance as in-house process rather than product doctrine; seal an exact artifact with hashes/manifest/fresh extraction; state assurance ceiling; keep unresolved/missing evidence UNKNOWN rather than filling it from narrative.

No materially different lawful project decision was found in this bounded session.

## Operator/recovery observation

R3.1 reduced query-to-authority distance for this task because engineering authority, research machinery/modes, in-house governance, execution/release discipline, scars, substrate-profile activation, and cold-start order are separated and directly named. The exact R6 ancestry remained available when a qualifier or ownership question needed checking.

## Result

`SHADOW_SESSION_SURVIVED_BOUNDED_REINCARNATION_TASK`

This is **not** automatic replacement promotion. R3.1 remains `SHADOW_USE_CANDIDATE` in this package. A separate adjudication/promotion action is required if replacement readiness is ever proposed.
''')

write('00_START/01_COMMANDERS_INTENT.md', '''
# Commander's Intent

## Mission

Re-derive a general-purpose operating substrate from reality-facing responsibilities and invariants rather than inheriting modern OS nouns as primitive truth.

Linux 0.01 and FreeDOS are competing historical donors. Prior Rahl projects and outside systems are quarries. The job is not to make a cleaner Linux, a stranger DOS, or a renamed holonic/ECS OS. The job is to discover which distinctions reality actually forces, which mechanisms buy capability, which historical bundles are convenience/scar tissue, and what the smallest powerful whole can be.

## Supreme design pressure

**Pareto-optimal size/power subject to required capability.** There is no single global scalar. Bytes, memory, cycles, latency, jitter, energy, bandwidth, privilege, dependency surface, concept count, synchronization, failure/recovery burden, assurance burden, compatibility burden, and maintenance burden all count. Larger machinery is lawful only when the extra burden buys a real capability or guarantee.

## Research attitude

`MISSING_BEHAVIOR != MISSING_MECHANISM`.

Before creating a primitive, localize the failure and test composition. Before calling a familiar subsystem inevitable, strip its noun and ask what responsibility/invariant it carries. Before trusting a successful experiment, attack the harness, launcher, evaluator, fixture, provenance, and hidden host services.

## End state sought

A substrate that is small because its causal structure is small, not because capability was cut away; powerful because mechanisms compose; explicit about authority/currentness; able to adapt to substrate without runtime adaptation rewriting governance; and capable of moving across machines while requalifying what reality changed.

The current work is still research. No final HOSTILE-OS architecture has been promoted.
''')

write('00_START/02_CURRENT_STATE_AND_FRONTIER.md', '''
# Current State and Frontier

**As-of:** 2026-08-29 package checkpoint  
**Scientific campaigns closed:** C001, C002  
**Scientific passes earned:** 40 total (20 + 20)  
**Architecture promotion:** NONE  
**Selected next campaign:** C003

## C001

`NARROWED_COMPLETE / NO ARCHITECTURE PROMOTION`.

C001 stripped Linux 0.01 and FreeDOS responsibility bundles into a relation-level minimum under the qualified P01 workload. It separated identity, lineage, eligibility, arbitration, continuation, memory interpretation, wait/wake/resume, resource/access/backing, cursor, mode/applicability, persistence/history, and related distinctions. It did not prove ECS, schedulerlessness, or a final OS.

## C002

`CAMPAIGN CLOSED / WHOLE-P01 RELATION COMPOSITION SURVIVED AFTER REPAIR / NO ARCHITECTURE PROMOTION`.

A bounded Python descendant reproduced the whole P01 consequence workload without primitive Process/Scheduler/File/Manager/Service nouns. The campaign earned this only after a real P17 mechanism failure (18/72 lost-wake ordering cases) and a separate P19 stale-evaluator failure. Final unchanged matrix: 72/72 after both repairs.

## Current frontier

C003 is **freestanding low-level embodiment of the C002 whole-P01 relation composition**. Its purpose is not to build a mature OS quickly. Its purpose is to make the Python host stop hiding costs and mechanisms. Translate the smallest qualified relation composition into explicit x86/QEMU state and behavior and use failures to reveal missing distinctions, hidden dependencies, or representation costs.

The first attack target is therefore the host subsidy itself: dynamic allocation, container semantics, object identity, exception behavior, collection ordering, lifetime handling, implicit memory safety, string labels, Python integer width, and other services that may have made C002 look smaller than it really is.

Do not recreate historical subsystem nouns merely because low-level embodiment becomes difficult.
''')

write('00_START/03_REINCARNATION_BOOT_PROMPT.txt', '''
ROLE: HOSTILE-OS R&D / embodiment coprocessor on PCMMAD.

Read the reincarnation package in its declared order before proposing architecture or mutating the project.

Authority: R3.1 is the adopted SHADOW_USE_CANDIDATE engineering/research surface, compression-only, no new authority; R6 remains parent authority. R1/R2 are rejected. Project evidence and exact runtime/source state outrank narrative.

Current research state: C001 20/20 CLOSED; C002 20/20 CLOSED after P17 mechanism and P19 evaluator scars; no architecture promotion; C003 selected next. Do not run C002/P21.

Commander intent: re-derive a general-purpose OS substrate from responsibilities/invariants; Linux 0.01 and FreeDOS are donors, not architecture authority. Pareto-optimal size/power is supreme design pressure. Missing behavior does not imply missing mechanism. Traditional Process/Scheduler/File nouns are hypotheses/bundles, not permitted primitives unless re-earned.

Method: use HSP as the research OS. Keep Loop+/problem expansion, OARR hostile discriminator slices, PDVER, Research/Embodiment arms, Semantic Helix, Attention Reservoir, and CSC/Genome roles distinct. 20-pass campaigns, hard stop at P20. Pass N+1 is earned by Pass N. CSC is audit-only unless separately qualified.

Execution law: mechanism, fixture, launcher, evaluator, environment, and observed consequence are separate. Action/trace/test output != qualified consequence. Use durable launches, exact cwd/interpreter/env, stdout+stderr, exit/completion receipts, stable artifact paths, post-inspection, and non-mutating verification. Timeouts/ambiguous process state remain UNKNOWN.

PCMMAD intent: use the server/dev-machine file and execution plane directly. Do not make the human shuttle files/commands between AI and dev machine when the server exposes the needed capability. The repository becomes durable state; chat becomes discourse/control surface.

Communication: default to plain, compact 1991-ish 10th-grade working English. This is an efficiency preference, not a capability limit. Keep technical terms when they compress real distinctions. Modern slang/profanity are fine. Expression phenotype != underlying capability.

Next lawful operation: instantiate the package on the PCMMAD project root, verify it, initialize/attach Git, inventory the real dev environment, then preregister C003/P01 from `04_CAMPAIGNS/C003/C003_PREREGISTRATION.md`. Do not prewrite the remaining 19 passes.
''')

write('03_THEORY/FULL_THEORY_OF_WORK.md', '''
# Full Theory of the Work

## 1. The inverse problem

A mature operating system shows us an implementation shaped by physics, old hardware, compatibility, organizations, APIs, security history, performance work, accidents, and decades of repair. Looking at the implementation and naming its parts does not tell us which parts are inevitable.

The research question is:

> How much of the modern operating system is forced by reality, and how much is historical ancestry?

Implementation -> behavior is easy to observe. Behavior -> necessary mechanism is underdetermined. HOSTILE-OS treats OS reconstruction as that inverse problem.

## 2. Competing donors instead of one ancestor

Linux 0.01 and FreeDOS were chosen because they solve overlapping responsibilities with very different histories and structures. Agreement can point toward a deeper invariant. Disagreement creates a discriminator. Absence asks whether a mechanism was unnecessary, unavailable, or merely encoded elsewhere.

The donor equation is not `Linux + DOS = new architecture`. It is:

`{Linux 0.01, FreeDOS} -> competing evidence -> responsibilities/invariants/scars -> hostile re-derivation -> candidate substrate`.

## 3. Strip the noun

Historical labels such as Process, Thread, Scheduler, File, Driver, Service, Device, Interrupt, and Task begin as donor vocabulary. A label does not earn primitive ontology.

For each responsibility, recover:

`observed responsibility -> carrier -> required state -> invariant -> plausible alternatives -> ablation/reconstruction`.

C001 showed why. Linux `schedule()` bundled alarm consequence, wake transitions, eligibility filtering, budget replenishment, arbitration, and context switch. FreeDOS parent/child transfer/return exists without the same arbitration shape. Linux and FreeDOS both say “file,” while their access state/backing structure differs. Same label != same mechanism; different label != different mechanism.

## 4. Ontology admission

A state distinction earns existence when collapsing it loses a future-relevant difference under a relevant action/observation. A merge earns admission when hostile testing shows no relevant future behavior is lost. Scars remain so the merge can be reopened later.

This yields the governing test:

> If this distinction disappears, can any reachable future change in behavior, authority, failure, recovery, resource use, timing, or composition?

YES -> candidate distinction. NO -> compression/merge candidate. UNKNOWN -> preserve provisionally and name the missing discriminator.

The project therefore rejects both ontology inflation and premature compression.

## 5. Composition first

`MISSING_BEHAVIOR != MISSING_MECHANISM` is the main anti-cathedral law.

A missing behavior can come from wrong representation, bad binding, stale currentness, missing authority, poor economics, unobservable state, broken execution, or a bad harness. Creating a Manager because a problem has a name is forbidden. Existing relations/mechanisms must first be attacked for lawful composition.

C002 is the first strong embodiment of that law: whole P01 behavior composed without primitive Process/Scheduler/File nouns, but only after timing attacks forced several small state distinctions to exist.

## 6. Pareto-optimal size/power

Small is not a scalar. A mechanism can shrink code while increasing jitter, energy, synchronization, proof burden, or hidden host dependence. Another can spend build-time/offline cost to make runtime tiny. A proof can be too expensive for the risk it controls. A compatibility layer can be larger than the capability it preserves.

The project therefore compares capability and burden as a partial order. Nondominated points can coexist. Context selects among them lawfully.

Every abstraction pays rent. Rent is discriminator-backed capability/guarantee, not cleanliness.

## 7. Scheduler theory as an example

Physics appears to require something like:

`finite compute + multiple progress-capable activities -> decide what may advance now`.

That does not prove a privileged Scheduler species.

C001 separated eligibility/currentness, arbitration, continuation binding, service credit/priority behavior, wait/wake, and context application. Linux's decaying counter carries useful recent CPU non-use and improves wake response, but its exact half-decay is not uniquely required and heterogeneous priority is extra capability beyond P01 minimum.

The narrow earned invariant is bounded lawful arbitration when multiple activities are eligible, plus enough history/fairness state when policy requires it.

## 8. Process theory as an example

Linux's `task_struct` is not proof that all its fields form one irreducible thing. C001 found future-relevant separations among execution identity, lineage, eligibility, continuation, memory interpretation, and resource access.

A continuation needs instruction position, stack position, live machine/register state, flags/condition state, and a current memory-interpretation binding, with extra substrate state only when capability requires it. Identity needs a current binding to continuation; it need not physically contain the continuation.

## 9. File theory as an example

Both donors preserve a split between backing/resource and per-access state. Two accesses can point to the same resource with different cursors/modes and therefore different futures.

Common `read/write` names do not prove one File essence. They are evidence for an operation family whose applicability/consequence depends on backing capability and current access state.

Candidate law:

`operation + access state + backing capability -> applicable consequence | bounded failure`.

## 10. Currentness, history, and authority

Historical truth is not current authority. Restart can preserve durable identity/bytes while expiring current access. Observation, evidence, provenance, currentness, reliability, and permission are different dimensions. Re-entry must requalify what could have changed.

C002 clean-restart persistence survived as durable bytes + fresh qualified rebind, not hydration of stale runtime bindings.

## 11. Events, waits, and the lost-wake scar

A one-shot notification is not always equivalent to a current terminal condition. C002 P17 proved this with 18/72 failures: child completion could occur before the parent installed its wait, and the notification vanished. P18 added bounded generation-scoped current completion condition. This is a concrete example of a state distinction earning its burden from a future-relevant ordering difference.

The empty-to-wait boundary also requires an arm/recheck/wait contract that is safe against a wake arriving in the gap.

## 12. Research/embodiment dual-arm convergence

Research and embodiment are siblings after a PDVER boundary. Research widens/attacks the theory. Embodiment makes abstract claims touch execution reality. Both produce new evidence/scars that feed the next cycle.

Embodiment is not downstream “implementation after research is done.” It is a way research becomes falsifiable.

## 13. Why C003 matters

C002 may be artificially cheap because Python is paying hidden bills: allocator, containers, arbitrary-width integers, object identity, iteration/collection semantics, exceptions, lifetime, host scheduling, memory safety, file I/O, and more.

C003 deliberately removes that subsidy. The target is a freestanding low-level x86/QEMU embodiment of the smallest qualified whole-P01 relation composition. When translation fails, the failure is evidence: either a hidden dependency, a missing distinction, or a real representation cost.

The response is not to recreate `Process`, `Scheduler`, or `File` by reflex.

## 14. Long-term hypothesis

The strongest live hypothesis remains hybrid and conditional: many traditional OS objects may emerge as recurring typed capability/relation bundles, while specialized representations remain where they are Pareto-superior. ECS-like organization is allowed to win only where reality makes it win.

The project has ancestry contamination from Holonix/KarnOS/FtD/Microseed and therefore cannot call such convergence independent discovery. It must be re-derived and supported under HOSTILE-OS conditions.
''')

write('02_HISTORY/PROJECT_CHRONOLOGY.md', '''
# Project Chronology

## Ancestral seed — 2024–2025

A recurring direct-hardware OS idea existed before HOSTILE-OS: use AI plus a sacrificial machine to build upward from firmware/boot, prefer direct hardware contact, and ask whether inherited operating-system structure can be re-derived rather than copied. Later Holonic OS/Holonix/KarnOS work explored related capability/holonic and schedulerless ideas. These are ancestry/contamination, not current authority.

## 2026-08-26 — HOSTILE-OS founded

The mature experiment was formalized as HOSTILE-OS with the joke campaign motto `FREE-DOS + LINUX -> FUCK WINDOWS, AGAIN.` The central question became how much OS structure is inevitable vs historical ancestry. Linux 0.01 and FreeDOS were chosen as competing donors. Law 0 became Pareto-optimal size/power subject to required capability. The foundation package froze authority, contamination, cross-project quarry, the never-reintroduce list, donor locks, durable-launch discipline, and 20-pass campaign cadence.

## 2026-08-26 — ontology quarry integrated

Prior ontology work was pulled in as scar/process quarry, not runtime architecture. Key recovered laws included new label != new mechanism; same label != same concept; identity != classification != current capability != role; binding != applicability != commitment; observation != evidence; history != current status; topology != authority; typed UNKNOWN causes; predictive/future-relevant state admission; no universal complete ontology; ontology itself has Pareto cost.

## 2026-08-26/27 — donor source recon and qualification

Linux 0.01 source was first inspected through the `zavg/linux-0.01` mirror. The user then smuggled canonical donor/runtime material into the sandbox. Canonical `linux-0.01.tar.gz` verified to SHA-256 `24454f830cdb571e2c4ad15481119c43b3cafd48dd869a9b2945d1036d1dc68d`; all 88 historical source files were byte-identical to the zavg mirror, whose only extra was README material. FreeDOS was frozen at exact commit `5ffb5502d39a10a30f5b8a9e8beeba0bf30245d3` / tag `ke2046` lineage.

## BackDoor / smuggle sequence

Smuggle 001 brought canonical donors, QEMU binary, basic tools, and a noncanonical control. It exposed the first runtime scar: `qemu --version` passed while actual machine creation failed because loadable accelerator modules were missing.

Patch 002 added QEMU modules/firmware and a quarantined control filesystem. QEMU then executed the patched Linux 0.01 control.

BackDoor 003 brought tiny frozen Minix-386 checkpoints containing GCC 1.37.1 and a post-Linux-build environment. The actual compile/link/convert/execute chain was qualified with a `Hello World` program. Reconstruction rebuilt deterministically. Canonical 0.01 source was restored 88/88 inside the period-like environment; compatibility moved outside donor source through build adapters; canonical-source-built Linux reached an interactive `bash#` under QEMU with period-compatible userspace.

BackDoor 004 brought the exact missing ia16 toolchain for FreeDOS after an exact-source build localized its first failure to `ia16-elf-gcc`. The FreeDOS fixture subsequently qualified persistence, bounded failure, child EXEC/return, and wait/wake.

## 2026-08-27 — C001

C001 ran exactly 20 scientific passes under HSP/OARR/PDVER/Helix/Attention Reservoir with CSC audit-only. It closed `NARROWED_COMPLETE`, no architecture promotion. A major internal scar occurred at P05: the first scheduler simulator incorrectly re-arbitrated every tick. Its results were invalidated/preserved, the simulator was corrected to donor timer/block semantics, and only corrected evidence counted.

C001 ended with a relation-level decomposition of Process/Scheduler/File bundles and preregistered C002.

## 2026-08-27 — C002

C002 ran exactly 20 passes against the whole qualified P01 workload in a donor-neutral Python relation descendant. P16 first closed the workload. P17 then broke it in 18/72 orderings due a real lost-wake mechanism defect. P18 repaired it with bounded generation-scoped current completion condition. P19 initially still reported the old failures because the evaluator itself was stale; that evaluator evidence was invalidated/preserved, then corrected without changing the scenario matrix, reaching 72/72. P20 hard-stopped C002. No architecture promotion.

## 2026-08-29 — SOP R3.1 + PCMMAD migration

Rahl Engineering In-House SOP Split Candidate R3.1 was adopted as the current in-house shadow-use surface exactly as packaged: compression-only, no new authority, R6 parent authority, R1/R2 rejected. The project is being moved away from the OpenAI-side “AI dev / human middleman” workflow to a PCMMAD server with direct development-machine access. This reincarnation package is the migration seed.

## Next

C003: freestanding low-level embodiment of the C002 whole-P01 relation composition. No C002/P21. No final architecture promotion.
''')

write('05_LINEAGE/LINEAGE_AND_CONTAMINATION_MAP.md', '''
# Lineage and Contamination Map

## Engineering/research machinery lineage

A useful recovered genealogy is:

`LCC/RALPH -> LCC v4 -> Singularity Works -> PDVER / Loop+ -> HSP`

Singularity Works contributed Pattern IR, explicit invariants, execution-state modeling, Genome/CSC ancestry, recovery, adversarial dialectic, validators, evidence ledger, assurance/monitoring, and orchestration. HSP generalized research mechanisms that first appeared there. This is lineage, not proof that every old mechanism remains required.

## HOSTILE-OS design ancestry / quarry

- **Holonic OS / Holonix / KarnOS / KSL / FASM:** direct-hardware, capability dispatch, proof obligations, holonic/ECS-like structure, schedulerless/stigmergic proposals, energy concerns. Strong contamination warning: no-scheduler and ECS-like OS are not epistemically fresh.
- **FtD:** role from current capability, recursive holons, resource economy, UNKNOWN/stale under partition, local reflex + higher awareness, substrate-native compute as accelerators/oracles/actuators.
- **Aedifex / Genesis-Ω:** genotype -> expression -> phenotype -> lifetime -> environment; environment consequence authority; developmental admission; action issued != observed outcome != causation.
- **Microseed:** composition-first developmental organism; proposal before qualification; current capability; emergent capability != emergent authority; useful wholes can become parts.
- **PAL:** provenance independence, current relations/capabilities, authorization/use licensing, reliability != currentness, DiscriminationNeed, nondiscriminating repetition gives no information.
- **TRCH:** query-relative YES/NO/UNKNOWN premise licensing; Binding/Applicability/Commitment split; rich evidence under coarse closure; predictive-state split/merge control.
- **CIC / NERV:** source/runtime/deployment/assurance separation; reboot creates a new runtime epoch; restore history then re-probe/requalify; UI not authority; bounded dependency re-evaluation.
- **Forge / Singularity Works / LCC-RALPH:** recover grammar/protocol/invariants before transform; evidence ledger; static discharge + runtime checks; property/metamorphic/mutation/differential testing.
- **Ergo-Light / VoidStar / Chainwraith:** expensive offline work can buy tiny runtime; layout by measured co-use; adaptive scar cache; resource asymmetry. Scars include cardinality != topology, vector position != identity, clamping can erase semantics, type alignment != serialized alignment, hash != auth, rollback attempt != atomicity, deterministic control flow != bit determinism.
- **CogOS:** whole-machine resource envelope, allostatic degradation, event decoupling, typed boundaries, chaos tests; rejects magic optimal thresholds and universal busy-spin/thread-per-core/zero-syscall claims.
- **CIL / Quipu / RuneFlow:** exact history != consolidated live view; contradictions visible; bounded task-conditioned projections; explicit side effects; universal semantic filesystem/brain rejected.
- **TQ2 / Z80-μLM:** compact representations must be judged under matched budgets; boring baselines can win; compactness requires functional equivalence.
- **Semantic Quarry / Ontology / CFE:** labels/classes are not mechanisms; source asserted != inferred; event/world record separations; ontology leakage and reification attacks; curator vocabulary != required learner ontology.
- **Codex Omega / GODSPEC:** keep invariants, proof pressure, cross-domain attack; reject grandiose labels, thermodynamic metaphor as measurement, persona pressure, and self-certifying specifications.

## Donor authority rule

All of the above are quarry. None may silently become HOSTILE-OS architecture. Same shape across projects earns a discriminator, not shared identity or authority.
''')

write('06_SCARS/EXECUTION_AND_INFERENCE_SCARS.md', '''
# Execution and Inference Scars — High Priority

These scars are active because this project repeatedly demonstrated that a plausible result can be manufactured by the wrong execution path.

## Core law

`action / command / trace / test output != qualified consequence`

Mechanism, fixture, launcher, evaluator, environment, source identity, and observed consequence are separate failure planes.

## HOSTILE-OS scars

1. **QEMU version smoke != machine execution.** `qemu-system-i386 --version` worked while machine creation failed because accelerator modules were absent.
2. **Fixture mismatch != kernel failure.** A modern/quarantined control root produced Linux child `ff00`; period-compatible userspace removed it.
3. **Shell invocation mode mattered.** Old shell `sh SCRIPT` stalled while `. SCRIPT` worked. The bad fixture path was not OS mechanism evidence.
4. **Foreground tool window != durable scientific run.** Long builds/emulation outlived or were killed by tool-call windows. Detached durable launch + owned receipt became mandatory.
5. **Modern compiler failure != donor source defect.** GCC 14 incompatibilities were moved to external build adapters while preserving 88/88 canonical source bytes.
6. **Missing tool != donor failure.** FreeDOS exact-source build was allowed to fail at the first `ia16-elf-gcc` boundary; the missing tool was supplied rather than patching donor code.
7. **P05 invalid simulator.** First scheduler simulator re-arbitrated every tick instead of matching Linux timer/block continuation semantics. Attractive metrics from that run were invalidated and retained as scar evidence.
8. **P01 C002 bad harness.** Clean output from an invalid/over-complete representation harness did not count.
9. **P17 real mechanism failure.** 18/72 cases lost child completion when it happened before wait installation. The fix was a real current completion condition, not evaluator massage.
10. **P19 evaluator failure.** After the mechanism was fixed, a stale evaluator still knew only the old success path. It produced false red. The evaluator was corrected without changing the scenario matrix.
11. **Verifier mutation scar.** Earlier package verification created new logs/receipts inside the specimen and thereby mutated what it was verifying. Final closure verification must be non-mutating; receipts live outside the sealed payload.
12. **Storage layout can become hidden policy.** Linux equal-counter tie choice depended on task-table position. Swapping storage slots swapped the winner.

## Execution discipline that follows

- Name the discriminator before consequential execution.
- Record cwd, interpreter/toolchain, environment, exact donor/source hashes, start/end, stdout/stderr, PID where relevant, exit status, completion marker/receipt, and result hashes.
- Inspect final artifact/state; do not infer it from command success.
- Timeout or ambiguous process state remains UNKNOWN until resolved.
- Keep invalid evidence; label it invalid rather than deleting the scar.
- Keep evaluator independent enough that new lawful success paths do not silently become false failures.
- Preserve source/runtime/tooling boundaries.
- Prefer exact current bytes/logs over narrative continuity.
''')

write('06_SCARS/ACTIVE_NEVER_REINTRODUCE_CURRENT.md', '''
# Never silently reintroduce — current HOSTILE-OS list

Do not silently bring back: named Manager/Scheduler/etc. because a problem has that noun; KarnOS schedulerlessness because ancestry proposed it; ECS/holons because they are attractive; global ternary state; global append-only-everything; CIL universal semantic filesystem/brain; ternary as physical-compression proof; Hilbert locality as universal security/layout; universal branchless/thread-per-core/busy-spin/zero-syscall rules; fixed “optimal” thresholds; Landauer as instruction-cost oracle; hash/parity/address binding as security/correctness; cardinality as topology; vector/index as identity; rollback attempt as atomicity; control-flow determinism as bit determinism; one process per holon; process/microservice boundaries where the boundary does not pay; UI as authority; cached history as current after reboot; IDs as independence; descendant restatement as corroboration; project resemblance as shared architecture; green tests as external truth; FINAL/SEALED/aerospace-grade/Omega labels as evidence; emulation success as proof of physical-hardware behavior outside the boundary; rejected mechanisms under a new name; research success auto-mutating mainline; CSC runtime/promotion authority; narrative handoff over exact state; naive foreground launches; silent source/runtime splits; unbounded journal/cache without economics; “smaller always better”; or “capability excuses bloat.”

This is attack pressure, not a ban on re-earning a mechanism. Resurrection requires a new discriminator that addresses the old failure.
''')

write('04_CAMPAIGNS/C003/C003_PREREGISTRATION.md', '''
# C003 preregistration — Freestanding low-level embodiment / host-subsidy exposure

**Status:** selected next campaign; not started by this package  
**Cadence:** exactly 20 scientific passes; hard stop after C003/P20  
**Architecture promotion:** forbidden by campaign success alone

## Primary question

Can the C002 whole-P01 relation composition be embodied in freestanding low-level x86/QEMU state and behavior without primitive Process/Scheduler/File/Manager/Service species, and what hidden capabilities/costs was the Python host silently providing?

## P01 only

Build the smallest explicit inventory/mapping of Python-host services that C002 relied on and bind each to one of: explicit relation state, low-level mechanism to be embodied, test/harness-only support, or UNKNOWN. Then choose the first smallest freestanding executable slice that can falsify one high-value hidden dependency.

Do **not** prewrite P02-P20. P01 earns P02.

## Whole-workload obligations inherited from C002

Boot/initialization boundary; finite activity; multiple progress-capable activities; block/wait; wake; child/parent return; persistent bytes across restart; bounded missing-operation failure; asynchronous/event consequence; idle/no-useful-work behavior.

## High-value hidden-host suspects

Dynamic allocation; Python object identity; dict/list/set ordering and membership semantics; arbitrary-width integers; automatic lifetime/reference handling; exception control flow; strings/labels; host file I/O; collection mutation semantics; implicit memory safety; implicit atomicity; host scheduling/timing; interpreter stack/continuation; default initialization; serialization/conversion helpers.

These are suspects, not assumed requirements.

## Forbidden shortcuts

- do not create Process/Scheduler/File/Manager/Service primitives by name;
- do not promote ECS/holons merely because typed relations map nicely to structs;
- do not copy Linux/FreeDOS algorithms as target architecture;
- do not let the test harness perform missing control behavior;
- do not hide low-level complexity behind a host runtime and call the result freestanding;
- do not claim x86/QEMU success as physical-hardware proof outside the tested boundary;
- do not delete state solely because it is ugly; require a future-equivalence discriminator;
- do not count a pass without durable execution evidence and post-inspection.

## Success shape

A useful C003 result can be failure. A translation failure that identifies a hidden host dependency or a newly irreducible state distinction is progress. The campaign is about exposing the real causal/burden surface, not forcing a green low-level port.
''')

write('07_PCMMAD_MIGRATION/PCMMAD_SERVER_MIGRATION.md', '''
# PCMMAD Server Migration

## Why move

The OpenAI-side workflow forced a ridiculous but productive loop: AI designs/inspects -> human copies commands/files -> dev machine runs/downloads -> human uploads artifacts -> AI resumes. The BackDoor/Smuggle sequence proved the research can survive that boundary, but the boundary is now pure friction.

The PCMMAD target should make the AI able to inspect the project tree, execute on the dev machine, read logs/results, manage a Git-backed durable state surface, and continue campaigns without using the human as a file-transfer protocol.

## Authority change

Moving execution location does **not** change research authority. Currentness must be re-earned on the new server/dev machine. Historical successful QEMU/compiler runs become history/evidence, not proof the new environment is ready.

## Recommended target tree

Use any actual PCMMAD-visible root. Do not hard-code an old sandbox path. Inside it:

```text
HOSTILE_OS/
  authority/        # R3.1 exact package + extracted surface
  continuity/       # bootloader, current state, Commander intent
  research/
    campaigns/C001/
    campaigns/C002/
    campaigns/C003/
    helix/
    reservoir/
  donors/           # canonical/pinned donor bytes and provenance
  lab/
    runtime/         # QEMU/toolchains if retained locally
    fixtures/
    runs/            # durable run directories
  evidence/
  scars/
  lineage/
  handoffs/
  logs/
  tools/
  payload_history/  # original smuggle/backdoor packages; forensic only
```

## First PCMMAD session

1. Extract this reincarnation package to a new target root.
2. Run `python 10_TOOLS/verify_reincarnation.py` from outside or inside the extracted root; it is non-mutating.
3. Run `07_PCMMAD_MIGRATION/bootstrap_pcmmad.ps1 -TargetRoot <path>` if a fresh working tree is wanted. It refuses to overwrite a non-empty target unless explicitly told otherwise.
4. Initialize or attach Git. Commit the exact reincarnation seed before new research mutations.
5. Inventory the real dev environment: OS, CPU, memory, compiler/binutils, QEMU, NASM/ia16 tools, Git, Python, filesystem behavior, and any PCMMAD file/exec bridge versions.
6. Re-materialize canonical donors from package payloads or trusted upstream; verify exact hashes/commit again.
7. Re-run **infrastructure qualification**, not scientific P01: QEMU real machine instantiation, canonical Linux interactive baseline, exact FreeDOS build/fixture baseline or the smallest needed equivalent.
8. Only then start C003/P01.

## Runtime discipline

Every substantive run gets its own stable directory with `intent/discriminator`, environment snapshot, launcher command, stdout, stderr, PID/start/end/exit/completion receipt, result artifacts, hashes, and post-run interpretation. The AI should inspect these directly through PCMMAD rather than asking the user to paste terminal output.

## Git discipline

Git is the durable embodiment surface, not research authority by itself. Suggested branches/tags:

- `main`: current durable research workspace, not automatically canonical architecture;
- `campaign/C003`: C003 working branch if useful;
- annotated checkpoint tags at campaign hard stops;
- keep donor bytes/toolchain archives outside normal source history if their size makes Git unsuitable, but track exact hashes/locations in source registry.

Never rewrite forensic campaign history to make the current theory look cleaner.

## What becomes obsolete

BackDoor/Smuggle human transport should become historical process scar, not normal operation. Keep the packages because they document how the OpenAI lab was constructed and give fallback offline tooling. Do not keep using the human as middleman when PCMMAD can read/run directly.
''')

write('07_PCMMAD_MIGRATION/bootstrap_pcmmad.ps1', r'''
param(
    [Parameter(Mandatory=$true)][string]$TargetRoot,
    [switch]$InitializeGit,
    [switch]$AllowNonEmpty
)
$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $PSScriptRoot
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
if (Test-Path $TargetRoot) {
    $items = @(Get-ChildItem -Force $TargetRoot -ErrorAction SilentlyContinue)
    if ($items.Count -gt 0 -and -not $AllowNonEmpty) {
        throw "TargetRoot is not empty. Refusing overwrite: $TargetRoot"
    }
} else { New-Item -ItemType Directory -Path $TargetRoot | Out-Null }

$dirs = @('authority','continuity','research\campaigns\C001','research\campaigns\C002','research\campaigns\C003','research\helix','research\reservoir','donors','lab\runtime','lab\fixtures','lab\runs','evidence','scars','lineage','handoffs','logs','tools','payload_history')
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path (Join-Path $TargetRoot $d) | Out-Null }

Copy-Item -Recurse -Force (Join-Path $Here '01_AUTHORITY\*') (Join-Path $TargetRoot 'authority')
Copy-Item -Recurse -Force (Join-Path $Here '00_START\*') (Join-Path $TargetRoot 'continuity')
Copy-Item -Recurse -Force (Join-Path $Here '04_CAMPAIGNS\C001\*') (Join-Path $TargetRoot 'research\campaigns\C001')
Copy-Item -Recurse -Force (Join-Path $Here '04_CAMPAIGNS\C002\*') (Join-Path $TargetRoot 'research\campaigns\C002')
Copy-Item -Recurse -Force (Join-Path $Here '04_CAMPAIGNS\C003\*') (Join-Path $TargetRoot 'research\campaigns\C003')
Copy-Item -Recurse -Force (Join-Path $Here '05_LINEAGE\*') (Join-Path $TargetRoot 'lineage')
Copy-Item -Recurse -Force (Join-Path $Here '06_SCARS\*') (Join-Path $TargetRoot 'scars')
Copy-Item -Recurse -Force (Join-Path $Here '10_TOOLS\*') (Join-Path $TargetRoot 'tools')
Copy-Item -Recurse -Force (Join-Path $Here '08_PAYLOADS\*') (Join-Path $TargetRoot 'payload_history')

$state = Join-Path $TargetRoot 'continuity\PCMMAD_BOOTSTRAP_RECEIPT.txt'
@(
  "target_root=$TargetRoot",
  "source_package=$Here",
  "bootstrapped_utc=$([DateTime]::UtcNow.ToString('o'))",
  "authority=R3.1_SHADOW_USE_CANDIDATE_PARENT_R6",
  "scientific_state=C001_20_C002_20_C003_NOT_STARTED_BY_PACKAGE"
) | Set-Content -Encoding UTF8 $state

if ($InitializeGit) {
    Push-Location $TargetRoot
    if (-not (Test-Path '.git')) { git init | Out-Host }
    git add .
    git commit -m 'HOSTILE-OS PCMMAD reincarnation seed 2026-08-29' | Out-Host
    Pop-Location
}
Write-Host "PCMMAD HOSTILE-OS root staged at: $TargetRoot"
''')

write('00_START/04_OPERATOR_INTERFACE.md', '''
# Operator / Communication Interface

Default working register: roughly **1991-ish 10th-grade English** — plain, direct, compact, normal grammar/spelling, low academic/corporate ornament. Keep technical terms or advanced vocabulary when they compress a real concept or preserve precision. Modern slang and profanity are acceptable in working discourse.

This is an efficiency preference, not a language-capability ceiling.

Global epistemic interface law:

`expression phenotype != demonstrated capability != latent/unknown capability != preference != task-optimal form`

Absence from a representation is not evidence of absence from the system unless a discriminator tests it. Apply this agnostically to people, models, software, ontology, interfaces, and observed behavior.
''')

# File locations and source registry.
entries=[]
for k,p in sources.items():
    entries.append({'id':k,'original_sandbox_path':str(p),'package_path':copy_map[k],'size_bytes':p.stat().st_size,'sha256':sha(p)})
write('09_MACHINE/SOURCE_ARTIFACTS.json',json.dumps({'schema':'hostile-os.reincarnation.sources.v1','built':DATE,'artifacts':entries},indent=2))
write('09_MACHINE/CURRENT_STATE.json',json.dumps({
 'project':'HOSTILE-OS','as_of':DATE,'scientific_passes_earned':40,'campaigns':{
  'C001':{'status':'NARROWED_COMPLETE','passes':20,'architecture_promotion':'NONE'},
  'C002':{'status':'WHOLE_P01_RELATION_COMPOSITION_SURVIVED_AFTER_REPAIR','passes':20,'architecture_promotion':'NONE','p17_failures':'18/72','p19_final':'72/72'},
  'C003':{'status':'SELECTED_NEXT_NOT_STARTED_BY_THIS_PACKAGE','passes':0}},
 'engineering_sop':{'surface':'R3.1','status':'SHADOW_USE_CANDIDATE','authority':'COMPRESSION_ONLY_INHERITS_NO_NEW_AUTHORITY','parent':'R6','replacement_ready':False},
 'next_operation':'Migrate/verify on PCMMAD, qualify dev environment and donor baselines, then start C003/P01.',
 'architecture_promotion':'NONE'
},indent=2))

locations='''# File Locations and Relocation Map\n\nThe old OpenAI sandbox paths are historical provenance only. The package is relocation-safe; use package-relative paths after migration.\n\n| Artifact | Historical sandbox location | Reincarnation-package location |\n|---|---|---|\n'''
for e in entries:
    locations += f"| `{e['id']}` | `{e['original_sandbox_path']}` | `{e['package_path']}` |\n"
locations += '''\nImportant old working roots:\n\n- `/mnt/data/hostile_os_foundation/` — F0 and campaign-init artifacts.\n- `/mnt/data/hostile_os_lab_live/` — live reconstruction runs and C001 close artifacts in the OpenAI sandbox.\n- The exact C002 full campaign tree is **not present** in this package's build sandbox; only its recovered P20 File Library view is included.\n\nOn PCMMAD, the new Git/project root becomes the operational location. Never treat an old `/mnt/data` path as a required runtime dependency.\n'''
write('02_HISTORY/FILE_LOCATIONS_AND_RELOCATION.md',locations)

# README for payload history.
write('08_PAYLOADS/README.md', '''
# Payload history

These nested ZIPs are exact historical inputs/tooling packages carried for forensic continuity and offline recovery. Their presence does not make them current runtime authority on the PCMMAD machine.

- Foundation/genesis + C001 init/ontology/C001 close preserve project authority/history.
- Smuggle/BackDoor archives preserve the path by which the OpenAI sandbox acquired QEMU, canonical donors, Minix/GCC 1.37.1 reconstruction checkpoints, and ia16 FreeDOS tooling.
- The exact R3.1 SOP ZIP is current shadow-use engineering/research surface; R6 inside it remains parent authority.

Requalify tool/runtime behavior on the PCMMAD machine before using it as current evidence.
''')

# Build notes / assurance.
write('11_RECEIPTS/R3_1_LOCAL_VERIFICATION.txt', Path('/mnt/data/sop_r3_1_verify_output.txt').read_text() if Path('/mnt/data/sop_r3_1_verify_output.txt').exists() else 'verification output unavailable\n')

# Verification script. Manifest excludes itself and package receipt.
write('10_TOOLS/verify_reincarnation.py', r'''
from pathlib import Path
import hashlib, json, sys, zipfile
root = Path(__file__).resolve().parents[1]
manifest_path = root / 'MANIFEST_SHA256.json'
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
errors=[]
expected=set()
for rec in manifest['files']:
    rel=rec['path']; expected.add(rel); p=root/rel
    if not p.is_file(): errors.append(f'MISSING {rel}'); continue
    h=hashlib.sha256(p.read_bytes()).hexdigest()
    if h != rec['sha256']: errors.append(f'HASH {rel} expected={rec["sha256"]} actual={h}')
    if p.stat().st_size != rec['size_bytes']: errors.append(f'SIZE {rel}')
actual={str(p.relative_to(root)).replace('\\','/') for p in root.rglob('*') if p.is_file() and p.name not in {'MANIFEST_SHA256.json'}}
# PACKAGE_VERIFICATION_RECEIPT is intentionally outside manifested payload semantics if added after sealing.
actual.discard('PACKAGE_VERIFICATION_RECEIPT.txt')
extra=sorted(actual-expected); missing=sorted(expected-actual)
if extra: errors.append('EXTRA '+repr(extra))
if missing: errors.append('MEMBERSHIP_MISSING '+repr(missing))
# ZIP CRC smoke for carried payloads.
for p in (root/'08_PAYLOADS').rglob('*.zip'):
    try:
        with zipfile.ZipFile(p) as z:
            bad=z.testzip()
            if bad: errors.append(f'ZIP_CRC {p.relative_to(root)} member={bad}')
    except Exception as e: errors.append(f'ZIP_OPEN {p.relative_to(root)} {e}')
if errors:
    print('FAIL: reincarnation verification')
    for e in errors: print(e)
    sys.exit(1)
print(f'PASS: reincarnation manifest/membership/hash closure files={len(expected)}')
print('ASSURANCE_CEILING=PACKAGE_INTEGRITY_AND_DECLARED_PROVENANCE_NOT_SEMANTIC_OR_ARCHITECTURE_PROOF')
''')

# Create manifest over all files except manifest/verification receipt.
records=[]
for p in sorted(ROOT.rglob('*')):
    if p.is_file() and p.name not in {'MANIFEST_SHA256.json','PACKAGE_VERIFICATION_RECEIPT.txt'}:
        records.append({'path':str(p.relative_to(ROOT)).replace('\\','/'),'size_bytes':p.stat().st_size,'sha256':sha(p)})
manifest={'schema':'hostile-os.reincarnation.manifest.v1','built':DATE,'package':NAME,'assurance_ceiling':'PACKAGE_INTEGRITY_AND_DECLARED_PROVENANCE_NOT_SEMANTIC_OR_ARCHITECTURE_PROOF','files':records}
(ROOT/'MANIFEST_SHA256.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')

print(ROOT)
