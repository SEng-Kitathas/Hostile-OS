from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

EVALUATOR_VERSION='C003-P12-generation-wrap-v1'
EXPECTED=[
 'COUNT_HI=1','COUNT_LO=0','STALE_TOKEN=0','NARROW_GEN=0','NARROW_STALE=A',
 'WIDE_HI=1','WIDE_LO=0','WIDE_FRESH=A','WIDE_STALE=R','DONE'
]
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: evaluate_p12.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); result=Path(sys.argv[2])
 observed=debug.read_text(encoding='ascii').splitlines()
 checks={
  'exact_lines': observed==EXPECTED,
  'count_is_256': len(observed)>=2 and observed[0]=='COUNT_HI=1' and observed[1]=='COUNT_LO=0',
  'stale_token_zero': len(observed)>=3 and observed[2]=='STALE_TOKEN=0',
  'narrow_wraps_zero': len(observed)>=4 and observed[3]=='NARROW_GEN=0',
  'narrow_false_accept': len(observed)>=5 and observed[4]=='NARROW_STALE=A',
  'wide_reaches_0100': len(observed)>=7 and observed[5]=='WIDE_HI=1' and observed[6]=='WIDE_LO=0',
  'wide_accepts_fresh': len(observed)>=8 and observed[7]=='WIDE_FRESH=A',
  'wide_rejects_stale': len(observed)>=9 and observed[8]=='WIDE_STALE=R',
 }
 passed=all(checks.values())
 payload={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':observed,'checks':checks,'debugcon_sha256':sha256(debug),'passed':passed,'interpretation':('8-bit generation aliased stale zero after 256 increments while 16-bit generation reached 0x0100, accepted fresh token, and rejected stale zero' if passed else 'P12 generation-wrap discriminator did not satisfy preregistration'),'authority_ceiling':'exact 256-increment 8-bit versus 16-bit generation alias only; no universal width or general ABA-freedom claim'}
 result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
 print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+payload['debugcon_sha256'])
 return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
