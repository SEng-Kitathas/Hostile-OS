# HOSTILE-OS Engineering Decision Ledger — 2026-08-30

Purpose: preserve not only what was chosen, but why, what evidence earned it, what it does not mean, and what would justify reopening it.

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| Donors are witnesses, not architecture parents | Prevent historical subsystem nouns from becoming primitives by inheritance | Research method | A discriminator shows the historical bundle is strictly cheaper/stronger than surviving composition for required capability |
| `MISSING_BEHAVIOR != MISSING_MECHANISM` | Missing consequence may be fixture/evaluator/composition failure | Global engineering law | Never casually demote; only replace with stronger evidence discipline |
| Architecture posture = `INTEGRATED_SHADOW_CANDIDATE` | I001 integrated the main earned relation families in one freestanding workload | Candidate only, not final/canonical/production | New evidence breaks load-bearing composition or promotion review earns stronger posture |
| Finite configured capacity is lawful | D64/A01/RB02 show explicit full status can preserve state without dynamic allocator | Tested capacities only | Required workload needs larger/dynamic capacity and Pareto pressure favors it |
| Location/index is not identity/currentness | Slot reuse controls retarget stale handles | Tested reuse domains | A different mechanism proves equivalent stale-reference rejection more cheaply |
| Activity/binding and resource namespaces are separate | RR01 shows resource rekey can change resource epoch while activity remains current | D64 shadow scope | Integrated pressure proves one domain can safely subsume the other without alias risk |
| Rekey is quiescent/cooperative | RK01/ARB01/RR01 earn safe reset only after relevant live state is gone | Availability ceiling explicit | Higher availability requires renewal with permanently live state |
| Epoch is load-bearing across restart | PR01 old handles reject after intentional gen/slot reuse only because namespace epochs changed | Clean-restart scope | Alternative restart-currentness mechanism passes the same stale-handle discriminators |
| Persist durable meaning, not volatile topology | PR01 reconstructs fresh runtime relation from 20-byte durable logical record | Clean restart, no crash consistency | Crash/power-loss/storage semantics force additional durable state |
| Separate wake/notification from progress/application | P08-P10/I001 controls show collapsed paths can hide responsibility | Tested workloads | New discriminator proves collapse preserves all required semantics at lower burden |
| Explicit live-count lifetime for shared resource | P16/RB02 expose premature reclaim otherwise | Tested shared backing/resource scope | Different ownership/lifetime mechanism beats it on burden and consequence |
| Mask IRQ0 around coupled bind/final-detach publication | IRQ01 observed mixed/orphan state without protection | One core, maskable IRQ, tested six-instruction regions | Different atomicity mechanism or broader concurrency gate earns replacement |
| Generation/epoch width is parametric and fail-closed before wrap | P12 and D64 rekey show silent finite wrap can alias stale token | No production width chosen | Credible lifetime/reuse bound plus proof supports fixed width/recovery policy |
| Firmware is an explicit borrowed boundary | Early evidence uses BIOS transport; I001 exposed IRQ/PIC firmware-boundary interaction | Current qualification boundary | Owned/native transport is implemented/qualified or firmware assumptions become unacceptable |
| Future mutating experiments build from run-local snapshots | Concurrent source drift can invalidate provenance | Mandatory experiment discipline | Only replace with stronger immutable-input mechanism |
| Exact evaluator success is not automatically semantic truth | C002 P19 and overnight I001 count sensitivity show evaluators can be stale/overbound | Global verification scar | Never remove; qualify evaluators independently |
| PR01 240-run soak = reliability evidence, not 240 architecture passes | Repetition tests stability, not new mechanism distinctions | Reliability only | A replay exposes new failure mechanism, which becomes a new seam |
| I001 660/3304 replay reds are unresolved evaluator/timer-count sensitivity | Both boots/static closure pass; mismatch is `IRQ_EVENT=2` vs exact `1` | Not enough to demote I001 | New preregistered discriminator proves exact event count semantically required or proves it incidental |
| Canonical local Git history is science lineage; GitHub is publication ledger | GitHub 100MB transport constraints must not rewrite cited local history | Publication architecture | A future migration preserves exact lineage with stronger guarantees |
| GitHub snapshots use immutable captured commit + isolated mirror + LFS for oversized payloads | Shared/moving mirrors caused races; GitHub rejects >100MB ordinary blobs | Publication transport | Only replace after verified race-free equivalent |
| Continuity is persisted every meaningful turn | Repeated thread loss caused backward motion/re-explanation | Operating policy | Only replace with a stronger automatic continuity surface |
| `os/` must remain independently obtainable | Full R&D ledger can be huge; installation must not require research/history | Repository contract | Never relax without explicit operator decision |

## 2026-08-30 embodiment/reproducibility decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| GitHub carries all unique project data | Operator requires GitHub to be the durable continuity/project repository, not a selective source mirror | Repository policy | Only explicit operator policy change |
| Scratch cannot be sole home of unique evidence | Prevent tool/process data from disappearing across thread/server failure | Operating policy | Replace only with stronger automatic durable capture |
| Bulk evidence may be losslessly archived + hashed | Millions of expanded Git blobs add transport burden without adding evidence | Transport only | If reviewer access requires a browsable expansion, add a derived expansion without deleting archive |
| `os/research_only/` is required | Reviewers/contributors need a real OS they can build/boot while architecture remains research candidate | Research embodiment only | Superseded by a newer verified embodied revision or eventual release tree |
| I001 is initial research-only seed | First whole-workload integrated freestanding witness with exact controlling binary targets | Does not silently include later D64 refinements | New embodied revision deliberately integrates later earned mechanisms |
| Rebuild must check machine bytes | Turns recorded command lines into executable reproduction evidence | Reproduction claim only | Different toolchain output requires explicit adjudication |
| Root canonical text is LF | Prevent clone-specific source hash confusion and cross-platform review failures | Repository text transport | Only if a stronger content-addressed source packaging policy replaces it |
| Historical CRLF receipts remain sealed | Old hashes describe actual original Windows snapshots; rewriting would destroy provenance | Historical evidence | Never rewrite; use normalization-aware verifier |
| Research-only semantic verifier does not replace historical evaluator | Long replay showed exact IRQ count may be timing-sensitive | Reproduction convenience, not science closure | Dedicated I001 IRQ-count discriminator resolves semantic requirement |

## 2026-08-30 IRQCOUNT01 decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| I001 exact IRQ count `1` is not load-bearing for tested wake/progress | IRQCOUNT01 produced the same valid relation/wake/progress at real IRQ counts 1 and 2 while exact-one control rejected 2 | Counts 1 and 2 only; one core real IRQ0 | Count >2, loss/coalescing, wrap, stronger concurrency, or physical hardware changes consequence |
| Relation validity remains required under repeated IRQ | BADREL received two real IRQs but stale generation kept relation invalid and semantic gate rejected | Tested generation/continuation/wait relation only | Different wait/currentness mechanism is adopted |
| Living verifier accepts `{1,2}`, not arbitrary positive counts | Implements actual earned scope instead of overgeneralizing prereg predicate | Reviewer/reproduction gate only | New experiment earns larger count set |
| Historical I001 evaluator remains unchanged | Preserve preregistered historical evidence and 660 red records | Historical evidence | Never rewrite; add superseding interpretation only |
| Next P0 = deterministic faulted-restart durable-record integrity | Clean restart is closed; faulted media recovery is the next direct durability pressure without pretending physical power-cut proof | BUILD-PLAN candidate only | Another seam outranks it under new evidence |

## 2026-08-30 external reproduction portability decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| Tool invocation path and binary identity are distinct | POSIX LLVM multi-call symlinks can change behavior based on argv[0]; resolving before exec destroys dispatch identity | Build/reproduction infrastructure | Toolchain proves basename-independent execution or stronger explicit driver invocation replaces it |
| Resolve tool path only for identity/hash metadata | We still need content identity without mutating invocation semantics | Provenance tooling | Replace with stronger content-addressed tool packaging |
| Transplanted binary != transplanted environment | QEMU executable alone did not carry module search path/ROM/default-device environment | Reproduction infrastructure | Fully hermetic launcher/package supersedes it |
| Disable unrelated default devices in scientific runner | Default NIC introduced irrelevant option-ROM failure into non-network workload | I001 research embodiment | A future workload explicitly requires networking |
| Historical smuggle archives are immutable; PATCH_003 supersedes behavior | Preserve exact payload lineage while fixing transplant environment | Tooling lineage | Newer append-only patch supersedes PATCH_003 |
| External full-rerun report is distinct from locally hash-verified foreign packet | User supplied report but not foreign raw files/manifests | Evidence classification | Upgrade only when raw external packet is supplied and verified |

## 2026-08-30 FR01 durable-record decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| Two independent durable sectors | Older complete meaning must survive when newer candidate is invalid/torn in deterministic media state | Tested two-candidate sector layout only | Real interruption/hardware shows coupled failure or different atomicity |
| CRC16/CCITT-FALSE + explicit `CMIT` | Same 30-byte cost as additive16 but rejects tested balanced corruption; smaller than complement duplicate | Error detection, not authenticity | Stronger corruption/authenticity or hardware evidence requires more |
| Validity before sequence | F03 showed naive highest-sequence logic chooses corrupt newer B | Tested bounded sequences1..3 | Sequence wrap/order model is expanded |
| Equal-sequence conflicting valid records fail closed | Two independently valid meanings with same ordering key are ambiguous | Two-record tested format | A stronger conflict-resolution identity/order mechanism is earned |
| Epoch255 blocks recovery before reconstruction | Restart currentness must not silently wrap | Existing one-byte epoch shadow width | Wider/rekeyed durable epoch mechanism is earned |
| Durable storage persists meaning/currentness, not runtime topology | FR01 successful cases rebuild fresh D64 relation and stale handles reject | Tested scalar durable record/D64 relation | Durable graph requirements demonstrate additional necessary state |
| Next P0 pressures actual writer interruption, not reader redesign | Reader/selector now survives deterministic corrupt/torn states | BUILD-PLAN only | Feasibility inspection shows QEMU/BIOS cannot expose meaningful interruption window |

## 2026-08-30 original-thesis audit guards

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| `activity`, `binding`, `resource` are working nouns, not primitives | Prevent the successful relation vocabulary from becoming the next inherited ontology | Continuity/architecture guard | A later promotion explicitly earns one as constitutional primitive |
| Research-only I001 embodiment may lag current science but may not outrank it | Runnable convenience can otherwise become accidental architecture authority | Reviewer/contributor embodiment policy | Deliberate integration gate refreshes the body |
| Do not alter WT01 method mid-preregistration because of the thesis audit | Preserve experiment question/order and avoid audit-induced HARKing | WT01 only | WT01 closes or is explicitly aborted |
| 20-pass versus targeted-descendant cadence requires explicit post-WT01 adjudication | Original doctrine and current practice genuinely differ | Process doctrine revisit, not science | Formal method decision is made and recorded |
| Pareto claims remain bounded to measured dimensions | Current work measures bytes/state/capacity/critical windows better than energy/latency/maintenance/proof burden | Interpretive guard | New measurements expand the justified vector |

## 2026-08-30 WT01 and cadence/embodiment decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| WT01 adopts whole-old/whole-new persistence only at tested QEMU/directsync stop boundary | 5/5 calibration + 20 controlled writers + 20 sealed-FR01 recoveries matched persisted bytes exactly | QEMU i386 TCG + BIOS floppy + raw directsync only | OTHER media state, different cache/device envelope, physical hardware, or multi-sector protocol changes the result |
| `T=547` is telemetry, not architecture | It was measured repeatably but belongs to the exact BIOS/QEMU execution path | Current campaign only | Never promote without a new discriminator |
| Broad research keeps 20-pass HSP campaigns; localized seams may use targeted descendants | Preserves original anti-drift purpose without pass-count theater | Process doctrine | A future process audit shows the two-level cadence is too weak/rigid |
| Maximum 5 targeted descendants per tranche before reconciliation | Prevents endless descendant chains and forces architecture/Pareto/embodiment review | Governance bound, not science constant | Explicit process decision changes it |
| Preserve I001 reference body; create versioned D64 v2 body | Historical reproducibility and current reviewer relevance both matter | Research-only embodiment | v2 plan proves too large/contaminating or another integration strategy dominates |
| Exact uploaded frozen-intent bytes remain an explicit Git-ingress seam | Local action server has not received a byte bridge from upload `/mnt/data` plane | Durability bookkeeping | Close only on exact byte/hash readback inside tracked Git state |

## 2026-08-30 D64 v2 embodiment admission decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| `d64_reference_v2` is CURRENT_RESEARCH_REFERENCE | It integrates current adopted D64-era mechanisms and passes exact isolated `os/`-only build/run/verify | Reviewer embodiment only | Any mapped parent science is demoted, body diverges from parent consequence, or isolated reproducibility breaks |
| Historical I001 body remains immutable/reference generation | Preserve independent historical machine-byte/reproduction lineage | Historical embodiment | Never mutate in place; supersede with another versioned body |
| Preserve 8 KiB loader envelope for v2 | Integrated body closes at7440 bytes; enlargement has not earned its cost | Current v2 body | Needed mechanism cannot fit after explicit Pareto pressure |
| 752 bytes remaining is a pressure budget, not free space | Prevent convenience features from silently consuming a qualified constraint | Embodiment engineering | New mechanism proves its consequence/cost and is admitted deliberately |
| Admission does not promote final architecture/release | Reviewer convenience cannot become constitutional authority | Project-wide | Separate final architecture/release gates close |

## 2026-08-30 QEMU data-directory portability decision

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| Treat QEMU executable/modules/firmware-data as separate transplant runtime surfaces | Independent host found binary could run only after module and firmware paths moved with it | Reproduction infrastructure only | Another required relocated runtime component appears |
| Current v2 runner discovers/overrides firmware data dir and maps it to `-L` | Removes hidden system-path dependence for direct Python launch | Current research reference runner | Different QEMU layout/data contract invalidates discovery |
| Historical I001 runner stays frozen; PATCH_003 remains its transplant wrapper | Preserve exact historical I001 tree while keeping official transplanted execution working | Historical embodiment lineage | A versioned successor I001 body is deliberately created |
| Foreign second-run report remains reported, not raw-hash-verified | Reviewer supplied conclusions, not artifacts | External evidence only | Foreign manifest/traces/verify packet is supplied and locally hashed |

## 2026-08-30 PARETO01 / mature comparison decisions

| Decision | Why it exists | Authority ceiling | Reopen / demote when |
|---|---|---|---|
| Do not spend the remaining752 v2 bytes without a capability/burden discriminator | PARETO01 found no semantic instability or missing mechanism across320 boots | Embodiment engineering | A new capability test earns additional state/code |
| Treat measured command/boot wall times as reproduction burden, not OS latency | Large tails preserved exact guest traces and were host/QEMU/toolchain localized | Exact host/QEMU envelope only | Guest-cycle/hardware timing instrumentation exists |
| Mature-OS blind comparison is now eligible to open | Independent derivation, integrated os-only body, and first burden baseline now exist | Research comparison/quarry only | Comparison contaminates architecture authority or gate prerequisites regress |
| External comparison findings cannot directly add mechanisms | Mature systems supply questions/disagreement, not design answers | Project-wide | Never waive without explicit doctrine change |

## 2026-08-31 C004 authority adoption

| Decision | Why | Ceiling / reopen |
|---|---|---|
| Adopt checked authority relation distinct from current resource/reference | C004 P01-P20 repeatedly loses futures when collapsed | Bounded C004 scope; reopen under new targets/concurrency |
| Trusted caller provenance is load-bearing | P09/P20 forged-claim controls fail | Hardware boundary mechanism remains target-specific |
| Operation-specific rights + attenuation + currentness remain separate | P02/P03/P08/P10/P11 | No universal policy language earned |
| Effect-time revalidation required when revocation can intervene | P17 cached authorization wrote after revoke | Only delayed-effect situations |
| Authority lifetime != resource lifetime | P16 bad revoke/reclaim destroyed A future | No universal ownership model |
| Authority restart epoch may be required on namespace reconstruction | P18 old handle alias without fresh epoch | Only reusable authority namespaces surviving durable meaning |
| Do not retrofit C004 into v2's remaining752 bytes by convenience | Current embodiment is behind science; byte pressure is real | Separate convergence/Pareto review required |
| C004 hard-stops at P20 | Original campaign law | P21 forbidden |

## 2026-08-31 H1 / donor / per-turn freshness decisions

| Decision | Why | Ceiling / reopen |
|---|---|---|
| H1 HP Pavilion p2-1120 is first physical target | Operator supplied dormant machine intended for real qualification; developing toward it now reduces late port shock | VM proxies are not physical identity; replace assumptions with measured H1 probe facts |
| QEMU H1 profile is a constraint proxy, not exact emulation | Q35/Phenom/SeaBIOS differ from E2-1800/A45/HP firmware | Physical H1 remains hardware authority |
| Bochs 3.1 is admitted as independent emulator/debug witness | Cross-emulator agreement pressures hidden QEMU dependencies | Not an exact E2-1800/A45 clone; no hardware-specific authority |
| Orthogonal OS architectures are donor pressure, never architecture authority | Avoid local-optimum rediscovery without allowing donor ontology capture | Seam must be stated locally first; local experiment/adoption required |
| Every meaningful turn refreshes living decision/research/intent/continuity surfaces | Commander requires no repeated re-explanation and no hidden chat-only state | Historical sealed evidence is hash-attested, not rewritten |
| Per-turn freshness includes exact continuity-tree hashes | Makes “reviewed/unchanged” distinguishable from “forgotten/stale” | Replace only with stronger automatic content-addressed continuity system |

## 2026-08-31 C005 close / H1 SMP convergence / D64 v3 promotion decisions

| Decision | Why | Ceiling / reopen |
|---|---|---|
| C005 hard-stops at P20; no P21 | Exact campaign law and all20 passes closed | Reopen concurrency only as a separately scoped new campaign/frontier, never as C005/P21 |
| Adopt C005 responsibilities, not donor synchronization nouns | Twenty hostile passes earned atomic/current transitions, publication, lifetime/progress/recovery/provenance distinctions | Mechanism witnesses remain target-specific; no universal Lock/RCU/Seqlock/Scheduler primitive |
| H1 second-core transport fits without loader-envelope expansion | MIN01 linked7811/8192 | Reopen if physical H1 startup differs or stronger target capability is required |
| Candidate A whole-operation gate remains valid but is not selected | MIN02 PASS with direct BSP/AP relation callers | Current implementation leaves only3 bytes headroom; reopen if direct multicore relation mutation becomes required or representation shrinks |
| Select Candidate B for current H1 successor body | MIN03 preserves one relation owner, exact mailbox publication, linked8089 with103 headroom, same H1 consequence | Owner-service dependency accepted only at current scope; reopen on measured availability/latency blocker, direct-caller requirement, >2 CPUs, or physical H1 failure |
| Candidate C is deferred, not disproven | It adds per-CPU call scratch/narrower gate capability not yet required | Price it when a concrete workload earns direct multicore relation callers or A/B becomes insufficient |
| `d64_reference_v3` is CURRENT_RESEARCH_REFERENCE | Selected B passed isolated os-only build/run/verify20/20 and current H1 cross-emulator replay | Research embodiment only; demote on parent-science demotion, reproduction break, physical H1 contradiction, or stronger admitted version |
| v2/I001 remain immutable prior lineage | New capability must not rewrite historical machine/reproduction evidence | Supersede only with versioned bodies; never mutate history for “current” status theater |
| Current-reference tooling follows v3 | A “current” helper/checker pointing at v2 would create false authority surfaces | Update atomically with future current-reference promotion |
| First v3 isolated run is a runner scar, not guest result | QEMU rejected read-only auxiliary Q35 target disk before guest boot | Preserve host-side failure; body conclusion comes only from amended committed rerun |
| Current v3 all-mode admission = nine QEMU boots | Actual composition is1 SMP +1 core +2 restart +5 faults | Correct any earlier “eight boot” narration; count is execution fact, not architecture |
| QEMU+Bochs agreement does not qualify H1 hardware | Neither emulator is the E2-1800/A45/HP firmware machine | Replace VM assumptions only with physical probe/boot evidence |
| Do not spend v3's103-byte headroom by convenience | H1 remains physically untested and C004 embodiment pressure still exists | New bytes must buy an earned capability/guarantee after explicit Pareto pressure |

## 2026-08-31 zero-re-explanation reincarnation decision

| Decision | Why | Ceiling / reopen |
|---|---|---|
| Git/GitHub must contain enough current + historical context for a fresh thread to continue without operator re-explanation | Repeated long-thread recovery can otherwise move the project backward or cause old assumptions/frontiers to be reintroduced | Standing continuity policy; replace only with a stronger automatically verified reincarnation mechanism |
| Add one current zero-re-explanation ingress contract rather than rewriting older handoffs | Historical handoffs are valid chronology but can become stale as frontiers move | New ingress must be refreshed when current architecture/frontier materially changes |
| Explicitly mark older state paragraphs as historical/superseded when newer verified state exists | Prevent a fresh model from selecting a stale frontier because it appears earlier in a long state document | Newest verified artifact/Git state always wins |
| Preserve full project ledger while keeping `os/` independently retrievable | Continuity completeness and OS usability are separate responsibilities | Only explicit commander policy may weaken either side |

## 2026-08-31 publication scratch-capacity decision

| Decision | Why | Ceiling / reopen |
|---|---|---|
| Publication scratch location is transport, not canonical state | Full snapshot needs archive+mirror space; E: exhausted while D: had ample free space | Scratch may move drives through `HOSTILE_GITHUB_PUBLISH_SCRATCH_ROOT`; exact canonical commit capture/readback rules remain unchanged |
| Never drop research to solve publication disk pressure | GitHub is whole-project durability ledger | Adapt scratch/storage/LFS transport instead; only explicit commander policy may weaken inclusion |

---

## D-UNKNOWN-ASK-2026-08-31 — unresolved load-bearing unknowns require commander escalation

**Decision:** Adopt as standing in-house SOP: inspect durable evidence first; if a load-bearing unknown remains, ask the commander. If traces of an artifact/state/decision/dependency exist but their identity or role cannot be recovered, ask rather than infer across the gap.

**Why:** Evidence-before-inference already preserves UNKNOWN, but without an explicit escalation rule a model can still smooth over traces or route around uncertainty. The new rule makes the human escalation boundary explicit while preserving zero-re-explanation for facts already in Git/project state.

**Authority:** Operator-directed local SOP delta under the adopted R3.1 operational surface. No foundation or architecture promotion.

**Controlling artifact:** `authority/R3_1_LOCAL_SOP_DELTA_UNKNOWN_TRACE_ASK_2026-08-31.md`.
