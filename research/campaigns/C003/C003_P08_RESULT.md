# C003 / P08 â€” selection remains separate from execution application

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P08 of 20
**Architecture promotion:** NONE
**P09 earned:** YES

## Question

Can a bounded selector choose activity `B` from two eligible identities while leaving both activity progress states untouched until a separate application relation runs; and does a deliberately conflated select-and-apply control expose an observable mutation during selection?

## Controlling preregistration

`C003_P08_PREREGISTRATION.md` was sealed at Git commit `e2a3e3faab4d1f9e49cb6e0468c2ec99794eac7e` before execution.

## Controlling run

Run: `20260829T214100Z_p08_selection_application_01`

This run is controlling because its launcher/receipt carries the corrected P08 authority ceiling: `bounded two-eligible selection/application separation only`.

QEMU:
- PID: `23668`
- started: `2026-08-29T21:41:32.668906+00:00`
- ended: `2026-08-29T21:41:32.867269+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator stderr: empty.

## Exact raw observation

```text
SEP_SELECTED=B
SEP_SELECT_A=0
SEP_SELECT_B=0
SEP_APPLY_A=0
SEP_APPLY_B=1
BAD_SELECTED=B
BAD_SELECT_A=0
BAD_SELECT_B=1
DONE
```

Evaluator version: `C003-P08-selection-application-v1`
Evaluator result: `passed=true`.

## Exact source hashes â€” controlling run

- mechanism: `b9ad3c85ebbef51f1a44304a78bb9f2683c618306905b8a2ab6b208d04a7d0cb`
- fixture: `b2ef713f080779626eea0bc84eb8acb7119bdf0ee8a6f889264e97ac35211a40`
- linker: `57e6ac0c9ec6df79b2cbb4a025516424273108f886e7895d7b0c814a72815419`
- evaluator: `7872e3d65ec212ba69c74912dea03e11874e660411e9e9990495e398b0c2a898`
- launcher: `329b17d928e7a0d910ec73113336b21359a799c6ff67286a719494ac1ea98955`

## Exact run hashes â€” controlling run

- boot image: 512 bytes
- boot image SHA-256: `d296c8dd406cb4b64b435e88c0cde32088e0754afd0f39599047ab6f879c5d5e`
- debugcon SHA-256: `61a83c4f6b51a50dda381a9623c7fd5403826ffad38e49591e6fc147d847fbca`
- evaluation SHA-256: `256cee894ef13143dc190983a9b19169e641beaff7725ecab144829db0f18bb7`
- receipt SHA-256: `8ed3d91e6fc1974c52788633af61fef88593efe63a5b825229b24a4255036676`
- evaluator stdout SHA-256: `b176fb63dca8029042881abb160d2d339e383eb3bff8b295a3b9fba803f6991a`
- all build/QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating inspection matched the receipt.

Static source inspection confirms:
- `select_next` reads/updates policy/selected identity but contains no write to `progress_a` or `progress_b`;
- `apply_selected` contains the only separated-path progress mutation;
- `select_and_apply_bad` explicitly calls both selection and application in one relation and is therefore an intentional negative control.

## Qualified consequence

For this bounded two-eligible fixture:

- policy selection chose identity `B` while both activity progress bytes remained `0`;
- selection can therefore be embodied independently of progress/execution mutation in this slice;
- a separate application relation then advanced only selected B from `0` to `1`, leaving A at `0`;
- an intentionally conflated select-and-apply control made B=`1` immediately at the selection observation boundary, making the collapse externally distinguishable;
- a Scheduler object, Python host dispatch/runtime machinery, and implicit host continuation mutation are not required for this tested separation.

This is an absence-of-necessity result for the tested bounded relation, not a general scheduler claim.

## What P08 does not earn

P08 does not establish:
- general scheduling;
- fairness beyond this two-member fixture;
- preemption;
- arbitrary activity count;
- real CPU-context switching;
- multicore execution;
- priority semantics;
- architecture promotion.

## P09 discriminator earned by P08

The next still-unembodied C002 survivor is narrow **parent-child return composed from lineage plus generic wait/wake**, without a special return mechanism or return-binding primitive.

P05 already qualified a generic wake relation under asynchronous virtual hardware, while P07 qualified distinct activity identities and P08 separated selection from application. P09 SHALL now pressure whether parent/child return itself requires any additional primitive beyond explicit lineage, waiting/current completion state, and an ordinary wake transition.

Bounded P09 pressure:
- fixture supplies parent identity `P`, child identity `C`, lineage `C -> P`, parent waiting-on identity `C`, and initial progress/status bytes;
- child completion relation records bounded child completion status and marks the current completion condition;
- generic wake relation matches the completed child identity to the parent's explicit wait target through lineage/current wait state and makes parent eligible/woken;
- separate parent application step consumes the child status and advances parent progress;
- there SHALL be no `return_to_parent`, `return_binding`, or special parent-return operation in the mechanism;
- negative control omits or corrupts the lineage/wait match while keeping completion bytes present, demonstrating that durable/terminal child completion alone is insufficient to wake an unrelated/nonmatching parent.

The fixture may supply identities/lineage/wait facts only. It may not execute the wake or parent progress step.

P10-P20 remain unwritten.

