# C005/P14 post-closure mutation scar — 2026-08-31

Status: **LINEAGE DEFECT RECORDED / CONTROLLING RESULT UNCHANGED**

P14 was scientifically CLOSED using controlling run `P14/runs/20260831T053118Z_c005_p14_01`, whose exact implementation snapshot is bound to implementation commit `46c3855` and recorded in `P14_RESULT.md`.

After closure and after P15 preregistration, commit `ef6bf6728d5b9753ba165e839863a6c9712e5861` modified live `P14/stage2.S` and `P14/evaluate.py`. This violated the intended sealed-source lineage even though the semantic question and expected trace remained the same.

A subsequent run `P14/runs/20260831T053202Z_c005_p14_01` used the post-closure variant and independently produced the same exact PASS trace. That run is admitted only as **POST_CLOSURE_REPRODUCTION / NON_CONTROLLING**. It does not replace the controlling run or implementation binding.

Recovery action:
- preserve `ef6bf67` in Git history;
- preserve the post-closure reproduction run intact;
- restore live P14 source bytes for `stage2.S` and `evaluate.py` to the exact controlling-run input snapshot;
- keep `P14_RESULT.md` unchanged;
- do not claim the post-closure source as the sealed scientific implementation.

This scar changes no P14 scientific conclusion.
