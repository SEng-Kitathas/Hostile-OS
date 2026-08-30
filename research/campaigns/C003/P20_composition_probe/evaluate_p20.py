from __future__ import annotations
import hashlib,json,sys
from pathlib import Path
EVALUATOR_VERSION='C003-P20-final-composition-v1'
EXPECTED=['A_ACQ=W','A_GEN=1','MISS=M','M_PROG=0','M_CONT=2','OK=O','O_PROG=2','FULL=F','F_OWNER=A','B_ACQ=W','B_GEN=2','B_PROG=0','B_CONT=0','FRESH=W','F_READ=Y','STALE=R','S_READ=0','BAD=W','B_READ=Y','DONE']
def sha256(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:return 64
 d=Path(sys.argv[1]);r=Path(sys.argv[2]);o=d.read_text(encoding='ascii').splitlines()
 c={'exact_lines':o==EXPECTED,'a_acquire':len(o)>=2 and o[:2]==['A_ACQ=W','A_GEN=1'],'missing_preserves':len(o)>=5 and o[2:5]==['MISS=M','M_PROG=0','M_CONT=2'],'success_applies':len(o)>=7 and o[5:7]==['OK=O','O_PROG=2'],'full_preserves':len(o)>=9 and o[7:9]==['FULL=F','F_OWNER=A'],'b_clean_reuse':len(o)>=13 and o[9:13]==['B_ACQ=W','B_GEN=2','B_PROG=0','B_CONT=0'],'fresh':len(o)>=15 and o[13:15]==['FRESH=W','F_READ=Y'],'stale':len(o)>=17 and o[15:17]==['STALE=R','S_READ=0'],'bad_retarget':len(o)>=19 and o[17:19]==['BAD=W','B_READ=Y']}
 passed=all(c.values());p={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':o,'checks':c,'debugcon_sha256':sha256(d),'passed':passed,'authority_ceiling':'final one-slot bounded composition replay only; no architecture promotion'};r.write_text(json.dumps(p,indent=2)+'\n',encoding='utf-8');print('EVAL_PASS' if passed else 'EVAL_FAIL');print('debugcon_sha256='+p['debugcon_sha256']);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
