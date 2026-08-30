# D64 / RB02 — independent-audit hash provenance correction

**Mode:** append-only maintenance correction
**Sealed science result:** `research/resource_binding/D64_RB02/D64_RB02_RESULT.md`
**Science close commit:** `7d6b518c5198c6d062dd714e80631182bf897b77`
**Scientific consequence:** UNCHANGED

## Defect

The sealed RB02 result records this SHA-256 for its independent audit:

`0c1cbc9e75ac391fbac591ef841bf13577768e470f7dac7078e22e7615658fe7`

No tracked RB02 artifact has that SHA-256.

The controlling run contains two independent-audit files because one audit script itself had a field-name defect and was then corrected append-only.

## Actual audit lineage

### `12_independent_audit.json` — failed local audit, retained scar

SHA-256:

`6a2363364298000a038bef37f4aa9607c42a681bc228dfc792750ac54a40d30f`

Disposition:

- `passed=false`
- only failed check: `max_live_count=false`
- cause: the audit used a nonexistent receipt key rather than the actual `max_observed_resource_live_count` key

This file is not the controlling independent closure.

### `13_independent_audit.json` — corrected passing independent closure

SHA-256:

`a3747b1b850ed31021775346a2add8fb40ed139c70fae710cd9c9e2c541ba5ae`

Disposition:

- `audit_version=D64-RB02-independent-closure-v2`
- `passed=true`
- explicitly supersedes local `12_independent_audit.json`
- corrects the max-live-count receipt-key lookup

This is the controlling independent audit referenced by the science close.

## Correction

Where the sealed RB02 result says:

`Independent audit SHA-256: 0c1cbc9e...`

read instead:

`Independent controlling audit: 13_independent_audit.json`

`SHA-256: a3747b1b850ed31021775346a2add8fb40ed139c70fae710cd9c9e2c541ba5ae`

The failed `12_independent_audit.json` remains part of the admitted evidence history and is not deleted or rewritten.

## Why science is unchanged

This is a provenance-pointer correction only.

The controlling guest run, exact trace, evaluator pass, static checker pass, receipt, source snapshots, stage-2 bytes, runtime-state measurement, and observed `0x0500` maximum sharing count are unchanged.

The corrected v2 independent audit verifies those same controlling artifacts and is already present in the science-close commit.

## Disposition

`RB02_PROVENANCE_POINTER_CORRECTED / SCIENCE_UNCHANGED / AUDIT12_FAILED_SCAR_RETAINED / AUDIT13_CONTROLLING_PASS`
