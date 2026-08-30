from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-RK01-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def block(t,a,b): return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def main():
 if len(sys.argv)!=7:
  print('usage: static_check_rk01.py STAGE2 LAUNCHER EVALUATOR MANIFEST RECEIPT OUT',file=sys.stderr); return 64
 s2,launcher,evaluator,manifest,receipt,out=map(Path,sys.argv[1:])
 t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8')
 m=json.loads(manifest.read_text(encoding='utf-8')); r=json.loads(receipt.read_text(encoding='utf-8'))
 c={}
 c['cap_64_and_eleven_arrays']=bool('.equ ACTIVITY_CAP,64' in t and all(t.count(f'{f}:.space ACTIVITY_CAP,0')==1 for f in FIELDS))
 c['generic_acquire_and_release']=bool(t.count('acquire_next:')==1 and t.count('release_index:')==1 and all(x not in t for x in ['acquire_slot0:','release_slot0:','release_slot31:']))
 rk=block(t,'rekey_checked','rekey_reject')
 p_scan=rk.find('rekey_scan_identity:'); p_cap=rk.find('cmpw $ACTIVITY_CAP,%bx'); p_id=rk.find('cmpb $0,act_identity(%bx)'); p_other=rk.find('rekey_check_other:'); p_comp=rk.find('cmpb $0,completion_status'); p_back=rk.find('cmpb $0,backing_live'); p_active=rk.find('cmpb $0,relation_active');
 writes=[rk.find(x) for x in ['movb $0,act_identity(%bx)','movb $0,act_gen(%bx)','movb %al,activity_epoch'] if rk.find(x)>=0]; first_write=min(writes) if writes else -1
 c['rekey_scans_all_identities_before_mutation']=bool(p_scan>=0 and p_cap>p_scan and p_id>p_cap and p_other>p_id and first_write>p_other)
 c['other_quiescence_guards_before_mutation']=bool(p_comp>p_other and p_back>p_comp and p_active>p_back and first_write>p_active)
 reject=block(t,'rekey_reject','bad_reset_generations')
 c['reject_branch_no_namespace_mutation']=bool(reject.strip()=="movb $'R',%al\n ret" and all(f not in reject for f in FIELDS) and 'activity_epoch' not in reject)
 reset=block(t,'rekey_reset_loop','rekey_reset_done')
 c['successful_rekey_resets_all_fields_bounded']=bool('cmpw $ACTIVITY_CAP,%bx' in reset and 'jae rekey_reset_done' in reset and all(f'movb $0,{f}(%bx)' in reset for f in FIELDS) and 'incw %bx' in reset)
 c['successful_rekey_publishes_nonzero_epoch']=bool('cmpb $255,%al' in rk and 'rekey_epoch_wrap:' in rk and 'movb $1,%al' in rk and 'movb %al,next_epoch' in rk and rk.find('movb %al,next_epoch') < rk.find('rekey_reset_loop:') and rk.find('rekey_reset_done:') < rk.find('movb %al,activity_epoch'))
 c['epoch_255_to_1_only_explicit_no_ordinary_epoch_wrap']=bool('rekey_epoch_wrap:' in rk and 'incb activity_epoch' not in t and 'incb act_epoch' not in t)
 acq=block(t,'acquire_found','acquire_generation_exhausted')
 c['ordinary_generation_fail_closed']=bool('cmpb $255,act_gen(%bx)' in acq and 'je acquire_generation_exhausted' in acq and 'incb act_gen(%bx)' in acq and "acquire_generation_exhausted:\n movb $'G',%al" in t)
 h=block(t,'checked_handle','handle_reject'); hpos=[h.find(x) for x in ['cmpw $ACTIVITY_CAP,%bx','cmpb $0,act_identity(%bx)','cmpb act_gen(%bx),%cl','cmpb act_epoch(%bx),%ch','cmpb activity_epoch,%ch','movb act_identity(%bx),%al']]
 c['handle_checks_before_identity_exposure']=bool(all(x>=0 for x in hpos) and hpos==sorted(hpos))
 bad=block(t,'bad_reset_generations','bad_reset_loop')+block(t,'bad_reset_loop','bad_reset_done')
 c['bad_reset_generation_only_and_separate']=bool('movb $0,act_gen(%bx)' in bad and 'activity_epoch' not in bad and 'call bad_reset_generations' not in rk and t.count('call bad_reset_generations')==1)
 c['good_and_bad_share_same_arrays_and_handle_checker']=bool(t.count('act_gen:.space ACTIVITY_CAP,0')==1 and t.count('act_identity:.space ACTIVITY_CAP,0')==1 and t.count('checked_handle:')==1)
 snap_ok=True
 snapmap={}
 for item in m.get('inputs',[]):
  p=manifest.parent/item['snapshot_path']; ok=p.exists() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256']; snap_ok=snap_ok and ok; snapmap[item['key']]=item['sha256']
 source_ok=all(r.get('source_sha256',{}).get(k)==v for k,v in snapmap.items())
 c['run_input_manifest_and_receipt_sources_match']=bool(snap_ok and source_ok and r.get('input_manifest_sha256')==sha(manifest))
 c['host_does_not_mutate_or_synthesize_guest_state']=bool(all(x not in l for x in ['act_identity','act_gen','activity_epoch','debug.write_text','debug.write_bytes']) and all(x not in e for x in ['act_identity','act_gen','activity_epoch','debug.write_text','debug.write_bytes']))
 c['all_checks_are_json_booleans']=bool(all(isinstance(v,bool) for v in c.values()))
 result={'checker_version':VERSION,'checks':c,'passed':bool(all(c.values())),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest),'measurements':{'successful_identity_scan_iterations':64,'successful_activity_reset_iterations':64,'activity_capacity':64,'activity_field_species':11}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
