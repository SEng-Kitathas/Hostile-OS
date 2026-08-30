from __future__ import annotations
import hashlib,json,sys
from pathlib import Path
EVALUATOR_VERSION='C003-P15-fixed-capacity-v1'
EXPECTED=['GOOD_A=W','GOOD_B=W','GOOD_C=F','GOOD_SLOT0=A','GOOD_SLOT1=B','BAD_A=W','BAD_B=W','BAD_C=W','BAD_SLOT0=C','BAD_SLOT1=B','DONE']
def sha256(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:return 64
 d=Path(sys.argv[1]);r=Path(sys.argv[2]);o=d.read_text(encoding='ascii').splitlines()
 c={'exact_lines':o==EXPECTED,'good_fill':len(o)>=2 and o[:2]==['GOOD_A=W','GOOD_B=W'],'good_full':len(o)>=5 and o[2:5]==['GOOD_C=F','GOOD_SLOT0=A','GOOD_SLOT1=B'],'bad_fill':len(o)>=7 and o[5:7]==['BAD_A=W','BAD_B=W'],'bad_overwrite':len(o)>=10 and o[7:10]==['BAD_C=W','BAD_SLOT0=C','BAD_SLOT1=B']}
 passed=all(c.values());p={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':o,'checks':c,'debugcon_sha256':sha256(d),'passed':passed,'authority_ceiling':'two-slot explicit capacity/full behavior only; no allocator or dynamic-growth architecture claim'};r.write_text(json.dumps(p,indent=2)+'\n',encoding='utf-8');print('EVAL_PASS' if passed else 'EVAL_FAIL');print('debugcon_sha256='+p['debugcon_sha256']);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
