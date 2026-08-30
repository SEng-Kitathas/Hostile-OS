from __future__ import annotations
import hashlib,json,sys
from pathlib import Path
EVALUATOR_VERSION='C003-P17-stale-handle-v1'
EXPECTED=['OLD_GEN=1','NEW_GEN=2','FRESH_STATUS=W','FRESH_READ=Y','STALE_STATUS=R','STALE_READ=0','BAD_STATUS=W','BAD_READ=Y','DONE']
def sha256(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:return 64
 d=Path(sys.argv[1]);r=Path(sys.argv[2]);o=d.read_text(encoding='ascii').splitlines()
 c={'exact_lines':o==EXPECTED,'gens':len(o)>=2 and o[:2]==['OLD_GEN=1','NEW_GEN=2'],'fresh':len(o)>=4 and o[2:4]==['FRESH_STATUS=W','FRESH_READ=Y'],'stale_reject':len(o)>=6 and o[4:6]==['STALE_STATUS=R','STALE_READ=0'],'bad_retarget':len(o)>=8 and o[6:8]==['BAD_STATUS=W','BAD_READ=Y']}
 passed=all(c.values());p={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':o,'checks':c,'debugcon_sha256':sha256(d),'passed':passed,'authority_ceiling':'one reused slot generation-check discriminator only; no general pointer/capability safety claim'};r.write_text(json.dumps(p,indent=2)+'\n',encoding='utf-8');print('EVAL_PASS' if passed else 'EVAL_FAIL');print('debugcon_sha256='+p['debugcon_sha256']);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
