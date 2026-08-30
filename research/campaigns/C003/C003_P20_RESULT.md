# C003 / P20 — final bounded lifecycle composition replay

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P20 of 20 — FINAL PASS
**Architecture promotion:** NONE
**C003 state after durable close:** CLOSED 20/20
**P21 permitted:** NO

## Controlling preregistration

`C003_P20_PREREGISTRATION.md` was sealed at Git commit `2120247338cc972254943a01036191f129d27765` before P20 mechanism source existed.

The preregistered question was whether several already-earned distinctions could coexist in one reusable fixed slot without adding a new primitive species.

## Engineering scars before the controlling run

Three early attempts failed during link and never reached QEMU:

- `20260830T022800Z_p20_composition_01` — one-sector overflow; no scientific consequence.
- `20260830T022900Z_p20_composition_02` — one-sector overflow; no scientific consequence.
- `20260830T023100Z_p20_composition_03` — reduced to a payload ending at `0x7E00`, still beyond the one-sector limit; no scientific consequence.

Run `20260830T023600Z_p20_composition_04` then completed QEMU with exit 33 and passed the independent evaluator, but it is not the controlling P20 success. The size-saving revision had turned `release_slot` into an inline fall-through label. That was too loose for the preregistered static/source requirement that the release operation clear owner only. It was therefore rejected before campaign closure despite matching the runtime matrix.

The final revision restored a real `release_slot` routine and saved the required bytes by zeroing the adjacent `progress` and `continuation` fields with one 16-bit store during checked acquisition. This kept the preregistered behavior and one-sector ceiling intact.

## Controlling run

Run: `20260830T023700Z_p20_composition_05`

QEMU:
- PID: `9180`
- started: `2026-08-30T02:36:51.832523+00:00`
- ended: `2026-08-30T02:36:52.022866+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds

Evaluator exit: `0`.
QEMU/evaluator stderr: empty.

## Exact raw observation

```text
A_ACQ=W
A_GEN=1
MISS=M
M_PROG=0
M_CONT=2
OK=O
O_PROG=2
FULL=F
F_OWNER=A
B_ACQ=W
B_GEN=2
B_PROG=0
B_CONT=0
FRESH=W
F_READ=Y
STALE=R
S_READ=0
BAD=W
B_READ=Y
DONE
```

Evaluator version: `C003-P20-final-composition-v1`.
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `d56fbf90e412a57f11c2120fcd2a4b77d08367712446565c075a2bf77bb5e106`
- fixture: `49e8e1e6e4fef2a48e2c60dd1591a96d8962d7043dd134dd6f56ca54ea56f2d6`
- linker: `50fa4ca46f51b37e6aef77ec85b038e49d9500b68189e75e57b904a00ebba850`
- evaluator: `751ed8bcb9a9c3527289c54b813bc8bc19cb17221198012ff835d45447b7844f`
- launcher: `f41e8b9d1627bbcdbedf0307341a9923eea54b0ad4d554108b071c9137b8f299`

## Exact run hashes

- boot image: `a96bf5e8c3d326d96bcab0ec7542f8e05e6e90155cef541cdc4b23a4fa90303c`
- debugcon: `6f4fc023364ae5059bdb510c2edbe1760055f585837a3703b69a448669f16086`
- evaluation: `d53aff2dea62cd66fefa58704be874316ed657e1b9e221809a4f30b2b99a350a`
- receipt: `a09cde454cdb91555a24d9dc6e523e4b42bcd1ec7ecbb5b861b066f99ff43abf`
- evaluator stdout: `f468d8842e5c6316ee94bfde0ad00a31d8aa4159c06dc3d4b59fe63182ce34ce`
- static closure: `979725328724dbb84a6d037f5fc908fbe56289d831580136bc886f605daf8d92`

The 512-byte image carries boot signature `55aa`. Receipt readback matched the exact mechanism, fixture, linker, evaluator, launcher, boot, debug, and evaluation hashes recorded for the controlling run.

## Static/source closure

`07_static_closure.json` passed every preregistered closure check:

- exactly one slot storage instance exists;
- `progress` and `continuation` are adjacent, so the checked-acquire 16-bit zero store initializes both explicitly;
- `acquire_checked` checks occupancy before mutation;
- successful acquire increments generation and initializes progress, continuation, and waiting;
- continuation 2 is stored before the missing request;
- the middle request checks leaf status before progress application and reads the stored continuation on success;
- the full branch reports `F` without overwriting the occupied slot;
- `release_slot` contains only owner clear plus return;
- A acquisition, full B attempt, and B reuse all use the same checked acquire routine;
- checked read compares generation before reading value;
- stale rejection does not read the slot value and returns observation 0;
- the address-only negative control performs no generation comparison and reads the reused slot value.

## Qualified consequence

For this one-slot bounded lifecycle, the already-earned mechanisms compose without adding a Process, Scheduler, File, Manager, Service, heap, dynamic container, exception runtime, or second slot:

1. A acquires the free slot at generation 1 with clean runtime state.
2. Continuation 2 is bound before waiting.
3. Missing request U returns `M`; progress stays 0 and continuation 2 is preserved.
4. Known request K returns `O`; only then is progress advanced to the stored continuation 2.
5. B cannot acquire while A owns the one slot; the result is explicit `F` and A remains owner.
6. Release clears owner only.
7. B reuses the same slot at generation 2 through the same checked acquire path and gets clean progress/continuation state.
8. Fresh generation 2 reads Y.
9. Stale generation 1 is rejected before value read and observes 0.
10. The address-only stale control ignores generation and silently retargets to Y.

This is composition evidence, not architecture proof.

## Authority ceiling / nonclaims

P20 does **not** establish:
- a final OS architecture;
- general scheduler/process/file/manager/service architecture;
- general memory safety;
- general pointer or capability safety;
- universal lifetime or generation policy;
- arbitrary workload support;
- physical-hardware proof;
- promotion of R3.1 over R6;
- replacement readiness.

The audited historical thread informed the rationale and guardrails for this continuation — donors as evidence rather than architecture authority, composition before new primitives, ontology under test, and Pareto pressure on size/power/complexity — but current Git/runtime evidence remains the authority for campaign state.

## Campaign hard stop

P20 is the final C003 pass.

After this result is durably committed and read back:
- C003 is `CLOSED 20/20`;
- no C003/P21 preregistration, mechanism, run, or result may be created;
- further work must enter a separately named campaign, an audit, a promotion gate, or another explicitly authorized phase;
- no architecture promotion follows automatically from C003 closure.
