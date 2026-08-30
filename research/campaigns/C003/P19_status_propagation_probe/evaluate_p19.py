from __future__ import annotations
import hashlib,json,sys
from pathlib import Path
EVALUATOR_VERSION='C003-P19-status-propagation-v1'
EXPECTED=['GOOD_MISS_STATUS=M','GOOD_MISS_PROGRESS=0','GOOD_OK_STATUS=O','GOOD_OK_PROGRESS=1','BAD_MISS_STATUS=O','BAD_MISS_PROGRESS=1','DONE']
def sha256(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:return 64
 d=Path(sys.argv[1]);r=Path(sys.argv[2]);o=d.read_text(encoding='ascii').splitlines()
 c={'exact_lines':o==EXPECTED,'good_missing':len(o)>=2 and o[:2]==['GOOD_MISS_STATUS=M','GOOD_MISS_PROGRESS=0'],'good_success':len(o)>=4 and o[2:4]==['GOOD_OK_STATUS=O','GOOD_OK_PROGRESS=1'],'bad_hidden_failure':len(o)>=6 and o[4:6]==['BAD_MISS_STATUS=O','BAD_MISS_PROGRESS=1']}
 passed=all(c.values());p={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':o,'checks':c,'debugcon_sha256':sha256(d),'passed':passed,'authority_ceiling':'one leaf plus one middle explicit status-propagation discriminator only; no exception/error-runtime architecture claim'};r.write_text(json.dumps(p,indent=2)+'\n',encoding='utf-8');print('EVAL_PASS' if passed else 'EVAL_FAIL');print('debugcon_sha256='+p['debugcon_sha256']);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
