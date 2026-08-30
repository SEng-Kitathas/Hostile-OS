from __future__ import annotations
import hashlib, json, sys
from pathlib import Path

EVALUATOR_VERSION='C003-P11-explicit-bounds-v1'
EXPECTED=[
 'VALID_INDEX=1','INVALID_INDEX=2','GOOD_VALID=W','GOOD_SLOT1=X',
 'GOOD_INVALID=R','GOOD_SENT=S','BAD_INVALID=W','BAD_SENT=X','DONE'
]
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: evaluate_p11.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 debug=Path(sys.argv[1]); result=Path(sys.argv[2])
 observed=debug.read_text(encoding='ascii').splitlines()
 checks={
  'exact_lines': observed==EXPECTED,
  'valid_index_1': len(observed)>=1 and observed[0]=='VALID_INDEX=1',
  'invalid_index_2': len(observed)>=2 and observed[1]=='INVALID_INDEX=2',
  'checked_valid_writes': len(observed)>=4 and observed[2]=='GOOD_VALID=W' and observed[3]=='GOOD_SLOT1=X',
  'checked_invalid_rejects': len(observed)>=5 and observed[4]=='GOOD_INVALID=R',
  'checked_preserves_sentinel': len(observed)>=6 and observed[5]=='GOOD_SENT=S',
  'unchecked_invalid_writes': len(observed)>=7 and observed[6]=='BAD_INVALID=W',
  'unchecked_corrupts_adjacent': len(observed)>=8 and observed[7]=='BAD_SENT=X',
 }
 passed=all(checks.values())
 payload={'evaluator_version':EVALUATOR_VERSION,'expected_lines':EXPECTED,'observed_lines':observed,'checks':checks,'debugcon_sha256':sha256(debug),'passed':passed,'interpretation':('explicit index bound accepted valid relation write and rejected invalid write while unchecked index 2 overwrote the adjacent sentinel' if passed else 'P11 explicit-bounds discriminator did not satisfy preregistration'),'authority_ceiling':'fixed two-slot plus adjacent-sentinel bounds distinction only; no general memory-safety, allocator, protection, or architecture claim'}
 result.write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
 print('EVAL_PASS' if passed else 'EVAL_FAIL'); print('debugcon_sha256='+payload['debugcon_sha256'])
 return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
