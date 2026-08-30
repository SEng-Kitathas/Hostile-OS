from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

EVALUATOR_VERSION='C003-P10-explicit-continuation-v1'
EXPECTED=[
 'BOUND_ID=A','BOUND_CONT=2','BOUND_WAKE=1','BOUND_PRE=0','BOUND_POST=2',
 'BAD_ID=A','BAD_WAKE=1','BAD_POST=1','DONE'
]
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: evaluate_p10.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); result=Path(sys.argv[2])
 observed=debug.read_text(encoding='ascii').splitlines()
 checks={
  'exact_lines': observed==EXPECTED,
  'same_identity': len(observed)>=6 and observed[0]=='BOUND_ID=A' and observed[5]=='BAD_ID=A',
  'bound_continuation_created': len(observed)>=2 and observed[1]=='BOUND_CONT=2',
  'wake_does_not_apply': len(observed)>=4 and observed[2]=='BOUND_WAKE=1' and observed[3]=='BOUND_PRE=0',
  'bound_resume_step2': len(observed)>=5 and observed[4]=='BOUND_POST=2',
  'identity_only_fixed_step1': len(observed)>=8 and observed[6]=='BAD_WAKE=1' and observed[7]=='BAD_POST=1',
 }
 passed=all(checks.values())
 payload={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':observed,'checks':checks,'debugcon_sha256':sha256(debug),'passed':passed,'interpretation':('explicit continuation binding selected logical resume step 2 while identity-only fixed resume selected step 1' if passed else 'P10 explicit-continuation discriminator did not satisfy preregistration'),'authority_ceiling':'bounded explicit activity continuation identity only; no arbitrary stack/register context, coroutine, scheduler, or architecture claim'}
 result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
 print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+payload['debugcon_sha256'])
 return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
