from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-IRQ01-binding-resource-coherence-v1'
EXPECTED=[
'S1_8K_OK',
'BAD_BIND_IRQ_BIND=00','BAD_BIND_IRQ_RID=51','BAD_BIND_IRQ_LIVE=0001','BAD_BIND_POST_BIND=01','BAD_BIND_POST_RID=51','BAD_BIND_POST_LIVE=0001',
'GOOD_BIND_IRQ_BIND=01','GOOD_BIND_IRQ_RID=51','GOOD_BIND_IRQ_LIVE=0001',
'BAD_DETACH_IRQ_BIND=00','BAD_DETACH_IRQ_RID=51','BAD_DETACH_IRQ_LIVE=0001','BAD_DETACH_POST_BIND=00','BAD_DETACH_POST_RID=00','BAD_DETACH_POST_LIVE=0000',
'GOOD_DETACH_IRQ_BIND=00','GOOD_DETACH_IRQ_RID=00','GOOD_DETACH_IRQ_LIVE=0000','DONE']
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main():
 if len(sys.argv)!=3: return 64
 dbg=Path(sys.argv[1]); out=Path(sys.argv[2]); obs=dbg.read_text(encoding='ascii').splitlines(); passed=obs==EXPECTED
 r={'evaluator_version':VERSION,'debugcon_sha256':sha(dbg),'expected_lines':EXPECTED,'observed_lines':obs,'passed':bool(passed),'authority_ceiling':'one-core QEMU IRQ0 observer over D64 binding/resource bind/detach transition only'}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print('EVAL_PASS' if passed else 'EVAL_FAIL'); return 0 if passed else 1
if __name__=='__main__': raise SystemExit(main())
