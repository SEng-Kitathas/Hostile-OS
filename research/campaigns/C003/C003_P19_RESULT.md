# C003 / P19 — explicit nested status propagation

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P19 of 20
**Architecture promotion:** NONE
**P20 earned:** YES — final C003 pass only

## Controlling preregistration

`C003_P19_PREREGISTRATION.md` was sealed at Git commit `d30ba4820d2b983c1fd314055b93e0a5afee0e07` before P19 source or execution existed.

## Controlling run

Run: `20260830T022600Z_p19_status_propagation_01`

QEMU:
- PID: `1804`
- started: `2026-08-30T02:25:58.989797+00:00`
- ended: `2026-08-30T02:25:59.196809+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds

Evaluator exit: `0`.
QEMU/evaluator stderr: empty.

## Exact raw observation

```text
GOOD_MISS_STATUS=M
GOOD_MISS_PROGRESS=0
GOOD_OK_STATUS=O
GOOD_OK_PROGRESS=1
BAD_MISS_STATUS=O
BAD_MISS_PROGRESS=1
DONE
```

Evaluator version: `C003-P19-status-propagation-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `13a4f55218eabe9865f27da1c9e6fc320c746e7508009771b54d621fcc9f0c52`
- fixture: `04bd14396b7f4c62ddea5b31cb9b3db1bc4accd9375c97d010404a74e1f0daf9`
- linker: `f76e148d5e3df74c12f71e684fa11f649b67ec244a043eaf2d252fc00354d92f`
- evaluator: `219cb8ff440fa73d6fd64ba7441df883504fdc064c48846302918df14278816a`
- launcher: `2770f1a106c3d11ddf23056f4292c45bc60b0f0e02f4411876edbe3b6b554a56`

## Exact run hashes

- boot image: `42f445821522126f6f40a6edd464bc82f1ce7c62598793cc33d9372e49644edd`
- debugcon: `392a253620f207fba69fb664c4a9b7edaae31c2f692450ac360c3e4f533f9cb1`
- evaluation: `c823377e4c2e747f6185f3027f680e9cdd1a4b9e4dc6387bc60db18d60170f81`
- receipt: `032a13773b4119856e8ba4a546a4fef8ae6e27ed65b4a6434bac817087a4a5f1`
- evaluator stdout: `00764c1ca0f8b94da92559b9276a29c4a907b0c4bba0d6fac3aca53ead40e301`

Post-run receipt closure matched all recorded source/run hashes, exact raw output, evaluator pass, and QEMU `COMPLETED/33` state.

## Static/source closure

Instruction-aware source inspection confirmed:
- `leaf_execute` returns `O` for known request K and `M` otherwise;
- the leaf contains no progress operand/write;
- `middle_checked` calls the leaf, compares status before its progress write, and does not overwrite the returned failure status;
- `middle_ignore_failure` calls the same leaf, performs no post-call status branch, writes progress 1, and reports `O`.

### Inspection scar

The first non-mutating source-closure helper falsely flagged `leaf_no_progress` because it searched raw text and found the word `progress` inside a comment. It did not modify source, run artifacts, or evaluation. The check was rerun against parsed instruction lines and passed. This is an inspection-tool false positive, not a scientific mechanism failure.

## Qualified consequence

For this bounded leaf + middle call path:
- the missing leaf returned `M` without changing progress;
- the checked middle propagated `M` and left progress 0;
- the same checked middle accepted a known `O` result and applied progress 1, so it was not a reject-all path;
- the bad middle ignored the leaf's `M`, applied progress 1, and reported `O`;
- explicit status propagation is therefore a real low-level control obligation when host exception/control-flow help is removed.

## Authority ceiling / nonclaims

P19 does **not** establish:
- an exception runtime;
- general error-handling architecture;
- stack unwinding;
- transactional rollback;
- a global error manager;
- scheduler behavior;
- architecture promotion.

## P20 discriminator earned by P19

P19 closes the last isolated host-subsidy seam currently selected by C003. The final pass should therefore be a **bounded composition replay**, not another historical subsystem noun.

P20 should compose several already-earned mechanisms in one fixed-slot lifecycle without adding a new primitive species:
- checked one-slot admission and explicit full result before release;
- explicit continuation held across a missing request;
- nested status propagation that prevents missing work from advancing progress;
- successful request that applies the bound continuation;
- release and clean reuse of the same slot for a new owner/value;
- generation advance on reuse;
- fresh-handle success and stale-handle rejection;
- address-only stale negative control still retargets to the new value.

P20 is the C003 hard-stop pass. It must be preregistered only after P19 is durably closed, and after P20 reconciliation **no C003/P21 may be created or executed**. P20 success would show bounded composition only; it would not promote a final OS architecture.
