from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
EVALUATOR_VERSION='POST-C003-R01-P03-ABA-v1'
EXPECTED=[
 'FLAG_PRE=0','FLAG_OWNER=A','FLAG_HISTORY=B','FLAG_POST=0','FLAG_ACCEPT=S',
 'VER_PRE=1','VER_OWNER=A','VER_HISTORY=B','VER_POST=2','VER_ACCEPT=R',
 'STABLE_VER_PRE=2','STABLE_OWNER=B','STABLE_HISTORY=B','STABLE_VER_POST=2','STABLE_ACCEPT=C','DONE'
]
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: evaluate_r01.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); out=Path(sys.argv[2]); observed=debug.read_text(encoding='ascii').splitlines(); passed=observed==EXPECTED
 result={'evaluator_version':EVALUATOR_VERSION,'debugcon_sha256':sha256(debug),'expected_lines':EXPECTED,'observed_lines':observed,'passed':passed,'interpretation':('clear/clear active flag accepted an ABA-shaped mixed snapshot; changed version rejected it; unchanged post-mutation version accepted stable B/B' if passed else 'post-C003 R01 matrix mismatch'),'authority_ceiling':'one fixed record, one completed mutation, bounded single-core freestanding discriminator only; no general ABA, seqlock, linearizability, SMP, or architecture claim'}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+result['debugcon_sha256'])
 return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
