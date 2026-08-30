from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P09-lineage-wait-wake-return-v1"
EXPECTED = [
    "GOOD_COMPLETE=S",
    "GOOD_WAKE=1",
    "GOOD_PRE_PROGRESS=0",
    "GOOD_PARENT_STATUS=S",
    "GOOD_POST_PROGRESS=1",
    "BAD_COMPLETE=S",
    "BAD_WAKE=0",
    "BAD_POST_PROGRESS=0",
    "DONE",
]

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
    return h.hexdigest()

def main() -> int:
    if len(sys.argv)!=3:
        print('usage: evaluate_p09.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
    debug=Path(sys.argv[1]); result=Path(sys.argv[2])
    observed=debug.read_text(encoding='ascii').splitlines()
    checks={
        'exact_lines': observed==EXPECTED,
        'completion_present_both': len(observed)>=6 and observed[0]=='GOOD_COMPLETE=S' and observed[5]=='BAD_COMPLETE=S',
        'good_wake_precedes_progress': len(observed)>=5 and observed[1]=='GOOD_WAKE=1' and observed[2]=='GOOD_PRE_PROGRESS=0' and observed[3]=='GOOD_PARENT_STATUS=S' and observed[4]=='GOOD_POST_PROGRESS=1',
        'bad_lineage_blocks_wake_progress': len(observed)>=8 and observed[6]=='BAD_WAKE=0' and observed[7]=='BAD_POST_PROGRESS=0',
    }
    passed=all(checks.values())
    payload={
        'evaluator_version':EVALUATOR_VERSION,
        'expected_lines':EXPECTED,
        'observed_lines':observed,
        'checks':checks,
        'debugcon_sha256':sha256(debug),
        'passed':passed,
        'interpretation':('bounded parent-child return composed from completion + lineage/current wait generic wake + separate parent application; lineage mismatch prevented wake despite same completion' if passed else 'P09 lineage/wait/wake return discriminator did not satisfy preregistration'),
        'authority_ceiling':'bounded one-parent/one-child lineage + generic wait/wake + separate application only; no general process tree, join, scheduler, or architecture claim',
    }
    result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
    print('EVAL_PASS' if passed else 'EVAL_FAIL')
    print('debugcon_sha256='+payload['debugcon_sha256'])
    return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
