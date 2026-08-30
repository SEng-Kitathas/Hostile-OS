from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
EVALUATOR_VERSION='C003-P14-irq-coherence-v1'
EXPECTED=['GOOD_IRQ_OWNER=B','GOOD_IRQ_CONT=2','GOOD_POST_OWNER=B','GOOD_POST_CONT=2','BAD_IRQ_OWNER=B','BAD_IRQ_CONT=1','BAD_POST_OWNER=B','BAD_POST_CONT=2','DONE']
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3: print('usage: evaluate_p14.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); result=Path(sys.argv[2]); observed=debug.read_text(encoding='ascii').splitlines()
 checks={'exact_lines':observed==EXPECTED,'good_irq_coherent':len(observed)>=2 and observed[0:2]==['GOOD_IRQ_OWNER=B','GOOD_IRQ_CONT=2'],'good_post_coherent':len(observed)>=4 and observed[2:4]==['GOOD_POST_OWNER=B','GOOD_POST_CONT=2'],'bad_irq_torn':len(observed)>=6 and observed[4:6]==['BAD_IRQ_OWNER=B','BAD_IRQ_CONT=1'],'bad_post_complete':len(observed)>=8 and observed[6:8]==['BAD_POST_OWNER=B','BAD_POST_CONT=2']}
 passed=all(checks.values()); payload={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':observed,'checks':checks,'debugcon_sha256':sha256(debug),'passed':passed,'interpretation':('IRQ masking across both relation writes kept the observer snapshot coherent while enabling IRQ after the first write exposed B/1 torn state' if passed else 'P14 IRQ coherence discriminator did not satisfy preregistration'),'authority_ceiling':'two-byte relation coherence against one real QEMU IRQ0 observer only; no general atomicity or locking claim'}
 result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+payload['debugcon_sha256']); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
