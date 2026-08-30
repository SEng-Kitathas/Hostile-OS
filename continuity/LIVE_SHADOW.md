# LIVE SHADOW

## Thread Identity
- Thread: HOSTILE-OS PCMMAD reincarnation
- Last Updated: 2026-08-30T06:45Z
- Mode: BUILD-COMMIT — PR01 persistence implementation plus overnight regression campaign
- Dominant Objective: preserve closed D64/PR01 clean-restart persistence while three isolated overnight reliability/integrity campaigns run against immutable or read-only surfaces

## Active User Intent
- Continue HOSTILE-OS continuously from verified persisted state.
- Publish the full project, including research, to `https://github.com/SEng-Kitathas/Hostile-OS.git` at the end of every substantive pass.
- Keep `research/` in the full historical repository but do not force OS installers/builders to fetch it; installable surface is `os/`.
- Preserve R3.1 as normal in-house SOP, R6 as lineage/fallback, and exact scientific provenance.

## Current Authoritative State
- C001/C002/C003 closed at bounded scopes; C003 hard-stopped 20/20.
- HOSTILE-OS architecture remains `INTEGRATED_SHADOW_CANDIDATE`; final=false, canonical=false, production-ready=false.
- R3.1 is `ADOPTED_IN_HOUSE_SOP`; R6 remains parent lineage/fallback; foundation promotion=false.
- D64/A01 closed: generic 64-slot activity lifecycle scale.
- D64/RK01 closed/adopted: checked quiescent activity namespace rekey.
- D64/RB02 closed: 64x20 / 1,280 binding cells, 64 resources, 16-bit live count reaching `0x0500`, shared lifetime/currentness.
- D64/ARB01 closed/adopted: checked activity release requires empty owned binding row; activity rekey requires complete activity/binding/resource quiescence and preserves resource namespace history.
- D64/RR01 closed/adopted: checked resource rekey at binding/resource quiescence changes resource epoch/reset while preserving current activity/binding namespace.
- D64/IRQ01 science closed at `c5c3fff717f49f35f6a5eaf6e1f41b75d8841e83`. Controlling run `20260830T060500Z_d64_irq01_coherence_01`: QEMU exit33; exact evaluator PASS; 16 static checks true; 14 independent checks true; stage2 4,773/8,192 bytes; runtime state 3,615 bytes.
- D64/PR01 science closed at `50e33085805d3bb5b74eba4df1ca23683c8d0283`. Controlling run `20260830T065500Z_d64_pr01_persistence_05`: two distinct fresh QEMU processes exit33; exact evaluator PASS; 27/27 static checks true; independent audit PASS; stage2 3,057/8,192 bytes; runtime state 3,653 bytes; durable 20-byte record survives runtime reclamation and explicit rebind under fresh activity/resource epochs while old handles reject after intentional slot/gen reuse.
- IRQ01 directly observed mixed/orphan state `binding=0, resource_identity=0x51, live_count=1` when real IRQ0 was admitted inside unprotected bind publication and final detach. Protected paths exposed coherent states only.
- IRQ01 current protected witness cost: bind 6 instructions/6 tested writes; final detach 6 instructions/4 tested writes.
- IRQ01 adoption review: coherence requirement is incumbent for current single-core maskable-IRQ D64 scope; literal six-instruction count is witness cost, not universal architecture law.
- GitHub publication bootstrap CLOSED. First verified publication: canonical local `1ac99c83e5eaf99435a0d65601f2df931d4d36db` -> GitHub `main` `d10c6e398ed815b3042ff0f4beee960c2f16f458`; research included=true; oversized 115,808,623-byte IA-16 toolchain payload carried through Git LFS.
- Publication workspaces are isolated under ignored `.pcmmad_sync_runs/github_publish_mirrors/<head>_<pid>` to avoid concurrent mirror races.
- Publication snapshot source is now an immutable captured Git commit exported with `git archive <canonical_local_head>`; concurrent local HEAD advancement does not invalidate that captured publication and instead creates a later publication obligation.
- `os/` is the future install/build tree. `INSTALL_FROM_GIT.md` defines partial clone + sparse checkout so `research/` is not an install dependency.
- Verified GitHub publication at 2026-08-30T06:35:24Z: canonical `0f1146f5782b729f77cfa8d4292e956f5c5f28a8` -> remote publication `5f1bb224b5e32bbe93df52d313dd0bc3115dbf3f`; 1,594 tracked files; research included; install surface remains `os/`.
- Overnight isolated regression campaign PID `24520` (child `24156`) is RUNNING under `.pcmmad_sync_runs/overnight/campaign_20260830T063648Z`; current coverage A01/RK01/RB02/ARB01/RR01/IRQ01/I001; sampled cycles PASS.
- PR01 overnight sealed-fixture soak PID `29312` is RUNNING from immutable close commit `50e3308...`; iteration1 full PASS; stop-on-first-failure; compact retention.
- Overnight read-only integrity/provenance sweep PID `27376` is RUNNING; first git fsck/LFS/critical-artifact/remote sweep PASS; 300-second interval.
- Exact final C002 Python source remains unrecovered; source-dependent historical subsidy details remain UNKNOWN.

## Active Constraints
- Git/runtime evidence outranks chat narrative. Recheck HEAD/status around every mutation because concurrent writers exist.
- One bounded server action at a time; short synchronous waits; missing/incomplete return = UNKNOWN; re-inspect before retry.
- Every mutating experiment snapshots exact controlling inputs before build/execution.
- No `git add .`; stage explicit paths.
- GitHub publication success requires exact remote-head readback.
- Canonical local scientific Git history is not rewritten to satisfy GitHub transport limits; publication history binds each snapshot to canonical local HEAD.
- Research remains publication evidence, not automatic architecture authority.
- Released install/build logic must not require `research/`.
- Current concurrency authority is single-core + maskable IRQ only; SMP/NMI/DMA/weak-memory remain unearned.
- Activity/binding and resource namespaces remain separate currentness domains.
- Both rekeys are cooperative/quiescent and may be starved by permanently live state.
- Persistence authority is clean restart only; crash/partial-write durability remains outside current scope.

## Decisions Locked In
- End each substantive pass with canonical commit, GitHub publication snapshot, and remote SHA readback.
- Full tracked `research/` is published. `os/` remains separately sparse-checkout/installable.
- Coupled bind publication and final resource detach/reclaim require one IRQ-coherent mutation region at current one-core maskable-IRQ scope.
- Six instructions is current measured protected-region cost, not a frozen architecture constant.
- No higher architecture promotion follows from IRQ01.
- Next discriminator targets expanded D64 clean-restart persistence, not stronger concurrency by momentum.

## Open Loops
- P0: expanded 64x20 binding/resource clean-restart persistence/rebind under fresh runtime namespaces.
- P0: quiescent activity/resource rekey availability ceiling when state never becomes quiescent.
- P1: native post-takeover storage/device transport if later target removes firmware borrowing.
- Scope-dependent: physical hardware, SMP/NMI/DMA/weak-memory, crash/partial-write durability, general capability/memory safety.
- P1 process scar: sealed R3.1 Windows path-separator verifier portability issue.

## Immediate Next Step
- Leave all three overnight campaigns isolated and running. End this substantive pass with a canonical continuity/timestamp commit and GitHub publication SHA readback. On return, read campaign terminal/status journals first; treat any missing process return as UNKNOWN and review failures before promotion.

## Last 10 Turn Reinforcement Window
1. User established GitHub as project-wide timestamp repository and ordered publication after each substantive pass; research included, installation independent.
2. Publication policy, `os/` install surface, sparse/partial clone docs, and research README were committed.
3. Canonical history contained a >100 MB toolchain blob, so GitHub publication mirror + LFS was chosen without rewriting canonical scientific history.
4. Several publication bootstrap failures were preserved as scars: mirror lock, helper selector, inherited helper chain, shared mirror race.
5. Helper reset + isolated publication workspace repaired those control-plane failures.
6. First verified GitHub publication succeeded: canonical `1ac99c83...` -> remote `d10c6e398...`, research included.
7. IRQ01 was preregistered before implementation at `0c14b605...`.
8. IRQ01 controlling QEMU run directly exposed mixed binding/resource state under unprotected real IRQ0 cuts and coherent state under protected regions.
9. IRQ01 science closed at `c5c3fff...`; evaluator/static/independent audits all passed.
10. Current action adopts the bounded IRQ-coherence rule and moves the next frontier to expanded clean-restart persistence.

## Delta Since Previous Shadow
- PR01 closed PASS at canonical `50e3308...` after five visible engineering attempts; controlling run `_05` satisfies exact traces, 27 static checks, durable bytes, and independent audit.
- Three overnight lanes are now actually RUNNING: full earned-chain regression PID24520, PR01 persistence soak PID29312, integrity/provenance sweep PID27376.
- First PR01 soak iteration PASS; first integrity sweep PASS.
