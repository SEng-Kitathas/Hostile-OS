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
