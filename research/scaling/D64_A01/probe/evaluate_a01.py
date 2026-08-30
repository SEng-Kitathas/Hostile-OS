from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-A01-activity-capacity-v1'
EXPECTED=[
 'S1_OK','CAP=40','FILL_COUNT=40','FIRST_ID=01','FIRST_GEN=01','LAST_ID=40','LAST_GEN=01',
 'FULL=F','POST_FULL_FIRST=01','POST_FULL_LAST=40','RELEASE=W','REUSE=W','REUSE_SLOT=1F',
 'REUSE_ID=5A','REUSE_GEN=02','STALE=R','FRESH=W','FRESH_ID=5A','DONE'
]
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main():
 if len(sys.argv)!=3: return 64
 dbg=Path(sys.argv[1]); out=Path(sys.argv[2]); obs=dbg.read_text(encoding='ascii').splitlines(); passed=obs==EXPECTED
 r={'evaluator_version':VERSION,'debugcon_sha256':sha(dbg),'expected_lines':EXPECTED,'observed_lines':obs,'passed':passed,'authority_ceiling':'configured 64-slot activity scaling only; no arbitrary capacity/resource/rekey/architecture claim'}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
