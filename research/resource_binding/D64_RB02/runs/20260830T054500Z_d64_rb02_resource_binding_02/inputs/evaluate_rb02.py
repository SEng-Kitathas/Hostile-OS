from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-RB02-resource-binding-v1'
EXPECTED=[
'S1_8K_OK','ACT_CAP=40','BIND_PER_ACT=14','RES_CAP=40','CELL_COUNT=0500',
'SHARE_COUNT=0500','SHARE_FULL=F','SHARE_COUNT_POST=0500','SHARE_LAST=W','SHARE_VAL=7E',
'A_FULL=F','RES_AFTER_A=0014','GLOBAL_COUNT=0040','GLOBAL_FULL=F','D_BIND5=00','R0_LIVE2=0002',
'DETACH_A=W','R0_AFTER_A=0001','B_READ=W','B_VAL=80','DETACH_B=W','R0_AFTER_B=0000','R0_ID_AFTER_B=00',
'REUSE_NEW=W','REUSE_BIND=05','REUSE_RES=00','REUSE_RGEN=02','A_REBIND=W','A_BGEN=02','R0_LIVE=0002',
'OLD_BIND=R','NEW_BIND=W','NEW_BIND_VAL=EE','BAD_BIND=W','BAD_BIND_VAL=EE',
'OLD_RES=R','NEW_RES=W','NEW_RES_VAL=EE','BAD_RES=W','BAD_RES_VAL=EE','DONE']
def sha(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main()->int:
 if len(sys.argv)!=3: return 64
 dbg=Path(sys.argv[1]); out=Path(sys.argv[2]); obs=dbg.read_text(encoding='ascii').splitlines(); passed=obs==EXPECTED
 r={'evaluator_version':VERSION,'debugcon_sha256':sha(dbg),'expected_lines':EXPECTED,'observed_lines':obs,'passed':bool(passed),'authority_ceiling':'bounded D64 64x20 binding / 64-resource relation scale only; no File/POSIX/resource-rekey/final-architecture claim'}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
