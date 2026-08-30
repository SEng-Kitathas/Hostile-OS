from __future__ import annotations
import hashlib
import json
import sys
from pathlib import Path

VERSION='I001-integrated-two-boot-v1'
BOOT1_EXPECTED=[
'S1_OK','BOOT=1','P_ACQ=W','P_GEN=1','C_ACQ=W','C_GEN=1','B_FULL=F','FULL_OWNER=C','WAIT_CONT=2','MISS=M','MISS_PROG=0','MISS_CONT=2','IDLE_ENTER=1','IRQ_EVENT=1','IRQ_REL=1','WAKE=1','WAKE_PROG=0','APPLY_PROG=2','BAD_WAKE_PROG=2','C_RELEASE=W','LIFE_C_COUNT=1','LIFE_C_VALUE=Z','B_ACQ=W','B_GEN=2','B_PROG=1','STALE_C=R','BAD_STALE=B','FLAG_CTL=S','VER_CTL=R','STABLE_CTL=C','DURABLE_WRITE=W','P_RELEASE=W','LIFE_P_COUNT=0','LIFE_P_VALUE=0','GEN_EXHAUST=G','GEN_OWNER=0','BAD_GLOBAL_B=X','BAD_FULL_OWNER=B','DONE']
BOOT2_EXPECTED=['S1_OK','BOOT=2','DURABLE=PASS','PREBIND=R','BAD_RESTART_USE=W','REBIND=W','POSTBIND=W','OLD_TOKEN=R','EPOCH=2','DURABLE_REWRITE=W','DONE']


def sha256(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()


def check_sector_boot1(b:bytes)->dict:
 expected=bytes([0x48,0x34,0x49,0x31,0x52,0x5a,0x34,0x12,0x01,0x00,0x01,0x01])
 return {'len_512':len(b)==512,'prefix_exact':b[:12]==expected,'tail_zero':len(b)==512 and all(x==0 for x in b[12:])}

def check_sector_boot2(b:bytes)->dict:
 expected=bytes([0x48,0x34,0x49,0x31,0x52,0x5a,0x34,0x12,0x02,0x00,0x01,0x01])
 return {'len_512':len(b)==512,'prefix_exact':b[:12]==expected,'tail_zero':len(b)==512 and all(x==0 for x in b[12:])}


def main()->int:
 if len(sys.argv)!=6:
  print('usage: evaluate_i001.py BOOT1_DEBUG BOOT2_DEBUG SECTOR1 SECTOR2 RESULT_JSON',file=sys.stderr); return 64
 b1p,b2p,s1p,s2p,out=map(Path,sys.argv[1:])
 b1=b1p.read_text(encoding='ascii').splitlines(); b2=b2p.read_text(encoding='ascii').splitlines(); s1=s1p.read_bytes(); s2=s2p.read_bytes()
 c1=check_sector_boot1(s1); c2=check_sector_boot2(s2)
 checks={'boot1_exact_trace':b1==BOOT1_EXPECTED,'boot2_exact_trace':b2==BOOT2_EXPECTED,'boot1_sector':all(c1.values()),'boot2_sector':all(c2.values()),'durable_identity_value_serialization_unchanged':s1[:8]==s2[:8],'epoch_advanced_1_to_2':len(s1)>=9 and len(s2)>=9 and s1[8]==1 and s2[8]==2,'historical_handle_unchanged':s1[9:12]==s2[9:12]==bytes([0,1,1])}
 result={'evaluator_version':VERSION,'passed':all(checks.values()),'checks':checks,'boot1_observed':b1,'boot2_observed':b2,'boot1_expected':BOOT1_EXPECTED,'boot2_expected':BOOT2_EXPECTED,'boot1_sector_checks':c1,'boot2_sector_checks':c2,'sha256':{'boot1_debug':sha256(b1p),'boot2_debug':sha256(b2p),'boot1_sector':sha256(s1p),'boot2_sector':sha256(s2p)},'authority_ceiling':'bounded I001 two-boot integration under qualified QEMU/BIOS envelope only; no architecture promotion'}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print('EVAL_PASS' if result['passed'] else 'EVAL_FAIL')
 return 0 if result['passed'] else 1

if __name__=='__main__': raise SystemExit(main())
