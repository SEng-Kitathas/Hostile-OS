from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
VERSION='D64-FR01-evaluator-v1'

def crc16(data:bytes)->int:
 c=0xffff
 for b in data:
  c ^= b<<8
  for _ in range(8): c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c

def valid(r:bytes)->bool:
 return len(r)>=30 and r[:4]==b'H4F1' and r[16:18]==b'4\x12' and r[18]==1 and r[19]==0 and r[26:30]==b'CMIT' and int.from_bytes(r[24:26],'little')==crc16(r[:24])
def seq(r:bytes)->int: return int.from_bytes(r[20:24],'little')
def magic(r:bytes)->bool: return r[:4]==b'H4F1'
def checked(a:bytes,b:bytes):
 av,bv=valid(a),valid(b)
 if not av and not bv:return 'N',None
 if av and not bv:return 'A',a
 if bv and not av:return 'B',b
 sa,sb=seq(a),seq(b)
 if sa>sb:return 'A',a
 if sb>sa:return 'B',b
 if a[:30]==b[:30]:return 'A',a
 return 'X',None
def naive(a:bytes,b:bytes):
 am,bm=magic(a),magic(b)
 if not am and not bm:return 'N'
 if am and not bm:return 'A'
 if bm and not am:return 'B'
 return 'B' if seq(b)>seq(a) else 'A'
def expected_trace(case_id:str,a:bytes,b:bytes):
 sel,rec=checked(a,b); nav=naive(a,b)
 if rec is not None and (rec[6]==255 or rec[7]==255): sel='G'; rec=None
 success=rec is not None
 val=rec[5] if success else 0
 return [
  'S1_8K_OK','TEST=D64_FR01',f'CASE={case_id}',
  f'A_VALID={1 if valid(a) else 0}',f'A_SEQ={seq(a):08X}',
  f'B_VALID={1 if valid(b) else 0}',f'B_SEQ={seq(b):08X}',
  f'SELECT={sel}',f'NAIVE={nav}',f'DUR_VAL={val:02X}',
  f'OLD_BIND={"R" if success else "-"}',f'OLD_RES={"R" if success else "-"}',
  f'FRESH_BIND={"W" if success else "-"}',f'FRESH_BIND_VAL={val:02X}',
  f'FRESH_RES={"W" if success else "-"}',f'FRESH_RES_VAL={val:02X}','DONE']
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('run_dir'); ap.add_argument('out'); a=ap.parse_args(); run=Path(a.run_dir)
 campaign=json.loads((run/'campaign_receipt.json').read_text(encoding='utf-8')); checks={}; cases={}; all_exact=True; no_exposure=True; success_handles=True
 for item in campaign['fixtures']:
  d=run/item['relative_dir']; disk=(d/'fr01.img').read_bytes(); aa=disk[17*512:18*512]; bb=disk[18*512:19*512]; trace=(d/'debugcon.txt').read_text(encoding='ascii',errors='replace').splitlines(); exp=expected_trace(item['case_id'],aa,bb); exact=trace==exp; cases[item['case_id']]={'exact':exact,'expected':exp,'observed':trace}; all_exact &= exact
  sel=[x for x in exp if x.startswith('SELECT=')][0].split('=',1)[1]
  if sel in ('N','X','G'):
   no_exposure &= all(x in exp for x in ['DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','FRESH_RES=-','FRESH_RES_VAL=00'])
  else:
   success_handles &= all(x in exp for x in ['OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_RES=W'])
 checks['all_fixture_traces_exact']=bool(all_exact)
 checks['failed_closed_cases_expose_no_value']=bool(no_exposure)
 checks['successful_cases_reject_old_accept_fresh']=bool(success_handles)
 f03=cases.get('F03',{}).get('observed',[]); checks['f03_naive_discriminator']=bool('SELECT=A' in f03 and 'NAIVE=B' in f03)
 f06=json.loads((run/'f06_additive_control.json').read_text(encoding='utf-8')); checks['f06_additive_sum_collision']=bool(f06['original_sum']==f06['corrupted_sum'] and f06['stored_crc']!=f06['corrupted_crc'])
 tear_ids={f'F12_tear_{i:02d}' for i in range(30)}; checks['f12_full_tear_coverage']=bool(tear_ids=={x['case_id'] for x in campaign['fixtures'] if x['case_id'].startswith('F12_')})
 checks['all_qemu_exit33']=bool(all(x['qemu']['status']=='COMPLETED' and x['qemu']['exit_code']==33 for x in campaign['fixtures']))
 checks['all_disk_hashes_stable']=bool(all(x['disk_sha256_before']==x['disk_sha256_after'] for x in campaign['fixtures']))
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'case_count':len(cases),'cases':cases}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps({'passed':result['passed'],'checks':checks,'case_count':len(cases)},indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
