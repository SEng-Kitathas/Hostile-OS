from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
EVALUATOR_VERSION='C003-P13-fixed-slot-init-v1'
EXPECTED=['RELEASE_OWNER=0','RELEASE_WAIT=1','GOOD_OWNER=B','GOOD_WAIT=0','GOOD_CONT=0','GOOD_PROGRESS=0','BAD_OWNER=B','BAD_WAIT=1','BAD_CONT=2','BAD_PROGRESS=7','DONE']
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3: print('usage: evaluate_p13.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); result=Path(sys.argv[2]); observed=debug.read_text(encoding='ascii').splitlines()
 checks={'exact_lines':observed==EXPECTED,'release_dirty':len(observed)>=2 and observed[0]=='RELEASE_OWNER=0' and observed[1]=='RELEASE_WAIT=1','good_owner_b':len(observed)>=3 and observed[2]=='GOOD_OWNER=B','good_defaults':len(observed)>=6 and observed[3:6]==['GOOD_WAIT=0','GOOD_CONT=0','GOOD_PROGRESS=0'],'bad_owner_b':len(observed)>=7 and observed[6]=='BAD_OWNER=B','bad_residue':len(observed)>=10 and observed[7:10]==['BAD_WAIT=1','BAD_CONT=2','BAD_PROGRESS=7']}
 passed=all(checks.values()); payload={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':observed,'checks':checks,'debugcon_sha256':sha256(debug),'passed':passed,'interpretation':('explicit full-field initialization produced clean B reuse while owner-only reuse carried A relation residue' if passed else 'P13 fixed-slot initialization discriminator did not satisfy preregistration'),'authority_ceiling':'one fixed record reuse/default initialization only; no allocator, GC, lifetime, or architecture claim'}
 result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+payload['debugcon_sha256']); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
