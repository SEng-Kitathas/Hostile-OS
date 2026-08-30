from __future__ import annotations
import hashlib,json,sys
from pathlib import Path
EVALUATOR_VERSION='C003-P16-shared-lifetime-v1'
EXPECTED=['GOOD_START=2','GOOD_AFTER_A=1','GOOD_B_OWNER=B','GOOD_B_READ=X','GOOD_AFTER_B=0','GOOD_BACKING=0','BAD_START=2','BAD_AFTER_A=1','BAD_B_OWNER=B','BAD_B_READ=0','DONE']
def sha256(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:return 64
 d=Path(sys.argv[1]);r=Path(sys.argv[2]);o=d.read_text(encoding='ascii').splitlines()
 c={'exact_lines':o==EXPECTED,'good_shared':len(o)>=4 and o[:4]==['GOOD_START=2','GOOD_AFTER_A=1','GOOD_B_OWNER=B','GOOD_B_READ=X'],'good_final':len(o)>=6 and o[4:6]==['GOOD_AFTER_B=0','GOOD_BACKING=0'],'bad_still_live':len(o)>=9 and o[6:9]==['BAD_START=2','BAD_AFTER_A=1','BAD_B_OWNER=B'],'bad_backing_lost':len(o)>=10 and o[9]=='BAD_B_READ=0'}
 passed=all(c.values());p={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':o,'checks':c,'debugcon_sha256':sha256(d),'passed':passed,'authority_ceiling':'one backing shared by two bindings only; no general GC/reference/lifetime architecture claim'};r.write_text(json.dumps(p,indent=2)+'\n',encoding='utf-8');print('EVAL_PASS' if passed else 'EVAL_FAIL');print('debugcon_sha256='+p['debugcon_sha256']);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
