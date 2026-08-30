from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-RK01-quiescent-rekey-v1'
EXPECTED=[
 'S1_OK','CAP=40','LIVE_REKEY=R','LIVE_EPOCH=01','LIVE_ID=41','LIVE_GEN=01','RELEASE=W',
 'COMP_REKEY=R','BACKING_REKEY=R','ACTIVE_REKEY=R','QUIESCENT_REKEY=W','NEW_EPOCH=02',
 'TAIL_GEN=00','TAIL_CONT=00','NEW_ACQ=W','NEW_SLOT=00','NEW_GEN=01','OLD=R','NEW=W',
 'NEW_ID=42','BAD_OLD=W','BAD_READ=42','WRAP_REKEY=W','WRAP_EPOCH=01','WRAP_OLD=R',
 'WRAP_NEW=W','WRAP_ID=44','DONE'
]
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: evaluate_rk01.py DEBUGCON RESULT_JSON',file=sys.stderr); return 64
 dbg=Path(sys.argv[1]); out=Path(sys.argv[2]); obs=dbg.read_text(encoding='ascii').splitlines(); passed=obs==EXPECTED
 r={'evaluator_version':VERSION,'debugcon_sha256':sha(dbg),'expected_lines':EXPECTED,'observed_lines':obs,'passed':bool(passed),'authority_ceiling':'bounded cooperative 64-slot quiescent activity-namespace rekey only; no arbitrary external revocation/live rekey/general capability claim'}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
