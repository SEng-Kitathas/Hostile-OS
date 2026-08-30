from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-ARB01-rekey-binding-composition-v1'
EXPECTED=[
'S1_8K_OK','ACT_CAP=40','BIND_PER_ACT=14','CELL_COUNT=0500',
'UNSAFE_RELEASE=W','BAD_REKEY=R','BAD_EPOCH=01','BAD_BIND0=01','BAD_RLIVE=0001',
'INHERIT_ACQ=W','INHERIT_GEN=02','INHERIT_READ=W','INHERIT_VAL=7E',
'CHECK_RELEASE_LIVE=R','CHECK_ID=41','CHECK_GEN=01','CHECK_BIND0=01','CHECK_RLIVE=0001',
'DETACH=W','AFTER_DETACH=0000','AFTER_RESID=00','AFTER_RGEN=01','CHECK_RELEASE=W',
'GOOD_REKEY=W','NEW_EPOCH=02','BIND0=00','BGEN0=00','TAIL_BIND=00','TAIL_BGEN=00','RES_EPOCH=01','RES_GEN=01',
'NEW_ACQ=W','NEW_ACT_GEN=01','NEW_ACT_EPOCH=02','OLD_BIND=R','NEW_BIND_CREATE=W','NEW_BIND_GEN=01','NEW_RES_GEN=02',
'NEW_BIND_READ=W','NEW_BIND_VAL=EE','OLD_RES=R','NEW_RES=W','NEW_RES_VAL=EE','DONE']
def sha(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main()->int:
 if len(sys.argv)!=3: return 64
 dbg=Path(sys.argv[1]); out=Path(sys.argv[2]); obs=dbg.read_text(encoding='ascii').splitlines(); passed=obs==EXPECTED
 r={'evaluator_version':VERSION,'debugcon_sha256':sha(dbg),'expected_lines':EXPECTED,'observed_lines':obs,'passed':bool(passed),'authority_ceiling':'bounded D64 activity-rekey plus binding-state composition only; no resource-rekey/live-rekey/File/final-architecture claim'}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
