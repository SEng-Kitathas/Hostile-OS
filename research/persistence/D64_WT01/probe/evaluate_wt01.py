from __future__ import annotations
import argparse,json
from pathlib import Path
VERSION='D64-WT01-evaluator-v1'

def crc16(data:bytes)->int:
 c=0xffff
 for b in data:
  c ^= b<<8
  for _ in range(8): c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c

def valid(r:bytes)->bool:
 return len(r)>=30 and r[:4]==b'H4F1' and r[16:18]==b'4\x12' and r[18]==1 and r[19]==0 and r[26:30]==b'CMIT' and int.from_bytes(r[24:26],'little')==crc16(r[:24])
def seq(r):return int.from_bytes(r[20:24],'little')
def select(a,b):
 av,bv=valid(a),valid(b)
 if not av and not bv:return 'N',None
 if av and not bv:return 'A',a
 if bv and not av:return 'B',b
 if seq(a)>seq(b):return 'A',a
 if seq(b)>seq(a):return 'B',b
 if a[:30]==b[:30]:return 'A',a
 return 'X',None
def expected_recovery(case_id,a,b):
 sel,r=select(a,b)
 if r is not None and (r[6]==255 or r[7]==255):sel='G';r=None
 val=r[5] if r is not None else 0
 def nav():
  am=a[:4]==b'H4F1';bm=b[:4]==b'H4F1'
  if not am and not bm:return 'N'
  if am and not bm:return 'A'
  if bm and not am:return 'B'
  return 'B' if seq(b)>seq(a) else 'A'
 ok=r is not None
 return ['S1_8K_OK','TEST=D64_FR01',f'CASE={case_id}',f'A_VALID={1 if valid(a) else 0}',f'A_SEQ={seq(a):08X}',f'B_VALID={1 if valid(b) else 0}',f'B_SEQ={seq(b):08X}',f'SELECT={sel}',f'NAIVE={nav()}',f'DUR_VAL={val:02X}',f'OLD_BIND={"R" if ok else "-"}',f'OLD_RES={"R" if ok else "-"}',f'FRESH_BIND={"W" if ok else "-"}',f'FRESH_BIND_VAL={val:02X}',f'FRESH_RES={"W" if ok else "-"}',f'FRESH_RES_VAL={val:02X}','DONE']
def main()->int:
 ap=argparse.ArgumentParser();ap.add_argument('run_dir');ap.add_argument('out');a=ap.parse_args();r=Path(a.run_dir);c=json.loads((r/'campaign_receipt.json').read_text(encoding='utf-8'))
 cal=c['calibration']; classes={'K0':[],'KPRE':[],'KPOST':[],'CLEAN':[]}
 for x in c['terminations']: classes[x['class']].append(x)
 checks={}
 checks['calibration_five_same_transition']=bool(len(cal)==5 and len({x.get('transition_step') for x in cal})==1 and all(x.get('transition_step',0)>=2 for x in cal))
 checks['calibration_first_change_full']=bool(all(x.get('first_change_class')=='FULL' and x.get('prior_states_all_zero') is True for x in cal))
 T=cal[0]['transition_step'] if cal else None; checks['measured_transition_used']=bool(T is not None and c.get('transition_step')==T)
 expected_class={'K0':'ZERO','KPRE':'ZERO','KPOST':'FULL','CLEAN':'FULL'}; expected_sel={'K0':'A','KPRE':'A','KPOST':'B','CLEAN':'B'}; expected_val={'K0':'71','KPRE':'71','KPOST':'72','CLEAN':'72'}
 exact_recovery=True; boundary=True; proc=True; overlays=True; a_stable=True; no_other=True; clean=True; handles=True
 for klass,items in classes.items():
  if len(items)!=5: boundary=False
  for x in items:
   boundary &= x.get('b_class')==expected_class[klass]
   no_other &= x.get('b_class')!='OTHER'
   a_stable &= x.get('a_sha_before')==x.get('a_sha_after_writer')
   overlays &= x.get('overlay_a_preserved') is True and x.get('overlay_b_preserved') is True
   if klass=='CLEAN': proc &= x['writer']['status']=='COMPLETED' and x['writer']['exit_code']==33; clean &= x.get('writer_trace')==['S1_8K_OK','WRITE_READY','WRITE_RETURN','DONE']
   else: proc &= x['writer']['status']=='FORCED_TERMINATED' and x['writer'].get('terminal_verified') is True
   proc &= x['recovery']['status']=='COMPLETED' and x['recovery']['exit_code']==33
   d=r/x['relative_dir']; disk=(d/'writer_terminal.img').read_bytes(); aa=disk[17*512:18*512];bb=disk[18*512:19*512]; exp=expected_recovery(x['case_id'],aa,bb); obs=x.get('recovery_trace',[]); exact_recovery &= obs==exp
   handles &= f'SELECT={expected_sel[klass]}' in obs and f'DUR_VAL={expected_val[klass]}' in obs and 'OLD_BIND=R' in obs and 'OLD_RES=R' in obs and 'FRESH_BIND=W' in obs and 'FRESH_RES=W' in obs
 checks['termination_boundary_media_classes']=bool(boundary)
 checks['all_a_sectors_unchanged']=bool(a_stable)
 checks['no_controlling_other_b_state']=bool(no_other)
 checks['process_statuses_verified']=bool(proc)
 checks['recovery_overlays_preserve_a_b']=bool(overlays)
 checks['all_recovery_traces_exact_from_actual_bytes']=bool(exact_recovery)
 checks['recovery_selection_and_handles']=bool(handles)
 checks['clean_writer_trace_exact']=bool(clean)
 checks['population_5_calibration_20_writer_20_recovery']=bool(len(cal)==5 and len(c['terminations'])==20 and c.get('recovery_process_count')==20)
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'transition_step':T,'check_count':len(checks)};Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result,indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
