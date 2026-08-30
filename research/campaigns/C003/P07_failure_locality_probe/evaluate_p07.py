from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P07-failure-locality-v1"
EXPECTED = [
    "LOCAL_MISS=M",
    "LOCAL_LATER=O",
    "LOCAL_STATE=B",
    "GLOBAL_MISS=M",
    "GLOBAL_LATER=X",
    "GLOBAL_STATE=A",
    "DONE",
]

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024), b''): h.update(b)
    return h.hexdigest()

def main() -> int:
    if len(sys.argv)!=3:
        print('usage: evaluate_p07.py DEBUGCON RESULT_JSON', file=sys.stderr); return 64
    debug=Path(sys.argv[1]); result=Path(sys.argv[2])
    observed=debug.read_text(encoding='ascii').splitlines()
    checks={
        'exact_lines': observed==EXPECTED,
        'same_missing_status': len(observed)>=4 and observed[0]=='LOCAL_MISS=M' and observed[3]=='GLOBAL_MISS=M',
        'local_later_progress': len(observed)>=3 and observed[1]=='LOCAL_LATER=O' and observed[2]=='LOCAL_STATE=B',
        'global_control_blocks_later': len(observed)>=6 and observed[4]=='GLOBAL_LATER=X' and observed[5]=='GLOBAL_STATE=A',
    }
    passed=all(checks.values())
    payload={
        'evaluator_version':EVALUATOR_VERSION,
        'expected_lines':EXPECTED,
        'observed_lines':observed,
        'checks':checks,
        'debugcon_sha256':sha256(debug),
        'passed':passed,
        'interpretation':('local missing-operation result preserved distinct later progress while deliberately global poison blocked the same later present operation' if passed else 'P07 failure-locality/later-progress discriminator did not satisfy preregistration'),
        'authority_ceiling':'bounded fixed-capacity local-vs-global failure control only; no general isolation, process, scheduler, ErrorManager, syscall, or architecture claim',
    }
    result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
    print('EVAL_PASS' if passed else 'EVAL_FAIL')
    print('debugcon_sha256='+payload['debugcon_sha256'])
    return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
