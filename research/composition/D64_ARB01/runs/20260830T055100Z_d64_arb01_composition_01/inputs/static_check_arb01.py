from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-ARB01-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def block(t:str,a:str,b:str)->str:
 return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def main()->int:
 if len(sys.argv)!=7:
  print('usage: static_check_arb01.py STAGE2 LAUNCHER EVALUATOR MANIFEST RECEIPT_PRE OUT',file=sys.stderr); return 64
 s2,launcher,evaluator,manifest,receipt,out=map(Path,sys.argv[1:]); t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8'); m=json.loads(manifest.read_text()); r=json.loads(receipt.read_text())
 c={}
 c['named_capacities_and_livecount']=bool(all(x in t for x in ['.equ ACTIVITY_CAP,64','.equ BINDINGS_PER_ACTIVITY,20','.equ BINDING_CELL_COUNT,1280','.equ RESOURCE_CAP,64','resource_live_count:.space RESOURCE_CAP*2,0']))
 c['shared_arrays_good_bad']=bool(t.count('act_identity:.space ACTIVITY_CAP,0')==1 and t.count('binding_resource_plus1:.space BINDING_CELL_COUNT,0')==1 and t.count('binding_generation:.space BINDING_CELL_COUNT,0')==1 and t.count('resource_identity:.space RESOURCE_CAP,0')==1)
 rel=block(t,'activity_release_checked','activity_release_reject')
 c['checked_release_validates_and_scans_row_before_clear']=bool('call validate_activity' in rel and 'call binding_base_from_input' in rel and 'cmpw $BINDINGS_PER_ACTIVITY,%dx' in rel and 'cmpb $0,binding_resource_plus1(%si)' in rel and rel.find('call validate_activity') < rel.find('cmpw $BINDINGS_PER_ACTIVITY,%dx') < rel.find('movb $0,act_identity(%bx)'))
 rej=block(t,'activity_release_reject','activity_release_checked_return'); c['checked_release_reject_no_mutation']=bool(rej.strip()=="movb $'R',%al\n ret" and all(x not in rej for x in ['act_identity(','binding_resource_plus1(','binding_generation(','resource_identity(','resource_live_count(']))
 badrel=block(t,'activity_release_identity_only','activity_release_identity_only_return'); c['unsafe_release_identity_only']=bool('call validate_activity' in badrel and 'movb $0,act_identity(%bx)' in badrel and 'binding_resource_plus1' not in badrel and 'resource_live_count' not in badrel)
 rk=block(t,'activity_rekey_checked','activity_rekey_reject'); first_mut=min(x for x in [rk.find('movb $0,act_identity(%bx)'),rk.find('movb $0,binding_resource_plus1(%bx)'),rk.find('movb %al,activity_epoch')] if x>=0)
 c['rekey_scans_all_activities_before_mutation']=bool('cmpw $ACTIVITY_CAP,%bx' in rk and 'cmpb $0,act_identity(%bx)' in rk and rk.find('cmpw $ACTIVITY_CAP,%bx') < first_mut)
 c['rekey_scans_all_bindings_before_mutation']=bool('cmpw $BINDING_CELL_COUNT,%bx' in rk and 'cmpb $0,binding_resource_plus1(%bx)' in rk and rk.find('cmpw $BINDING_CELL_COUNT,%bx') < first_mut)
 c['rekey_scans_resource_livecount_words_before_mutation']=bool('cmpw $RESOURCE_CAP,%bx' in rk and 'shlw $1,%si' in rk and 'cmpw $0,resource_live_count(%si)' in rk and rk.find('cmpw $0,resource_live_count(%si)') < first_mut)
 c['rekey_checks_resource_identity_before_mutation']=bool('cmpb $0,resource_identity(%bx)' in rk and rk.find('cmpb $0,resource_identity(%bx)') < first_mut)
 c['rekey_other_guards_before_mutation']=bool(all(x in rk for x in ['cmpb $0,completion_status','cmpb $0,backing_live','cmpb $0,relation_active']) and all(rk.find(x)<first_mut for x in ['cmpb $0,completion_status','cmpb $0,backing_live','cmpb $0,relation_active']))
 rkrej=block(t,'activity_rekey_reject','print_matrix'); c['rekey_reject_no_namespace_mutation']=bool("movb $'R',%al" in rkrej and all(x not in rkrej for x in ['act_identity(','binding_resource_plus1(','binding_generation(','resource_identity(','resource_generation(','resource_live_count(','activity_epoch','resource_epoch']))
 resetact=block(t,'activity_rekey_reset_activity','activity_rekey_reset_binding_begin'); c['rekey_resets_eleven_activity_arrays']=bool('cmpw $ACTIVITY_CAP,%bx' in resetact and all(f'movb $0,{f}(%bx)' in resetact for f in FIELDS))
 resetbind=block(t,'activity_rekey_reset_binding','activity_rekey_finish'); c['rekey_resets_full_binding_namespace']=bool('cmpw $BINDING_CELL_COUNT,%bx' in resetbind and 'movb $0,binding_resource_plus1(%bx)' in resetbind and 'movb $0,binding_generation(%bx)' in resetbind)
 c['rekey_changes_activity_epoch_nonzero']=bool('cmpb $255,%al' in rk and 'activity_rekey_wrap:' in rk and 'movb $1,%al' in rk and 'movb %al,next_activity_epoch' in rk and 'movb %al,activity_epoch' in rk)
 c['rekey_preserves_resource_generation_epoch']=bool('resource_generation' not in rk and 'resource_epoch' not in rk)
 guard_end=rk.find('activity_rekey_epoch_ready:'); bgen_reset=rk.find('movb $0,binding_generation(%bx)'); c['binding_generation_reset_after_guards']=bool(guard_end>=0 and bgen_reset>guard_end)
 c['ordinary_rb02_paths_reused']=bool(t.count('binding_detach:')==1 and t.count('binding_read:')==1 and t.count('resource_read:')==1 and 'call binding_detach' in t.split('_start:',1)[1].split('fail:',1)[0] and 'call binding_read' in t.split('_start:',1)[1].split('fail:',1)[0] and 'call resource_read' in t.split('_start:',1)[1].split('fail:',1)[0])
 start=t.split('_start:\n',1)[1].split('\nfail:',1)[0]; c['inheritance_uses_good_binding_read_new_handle']=bool('call activity_release_identity_only' in start and 'call activity_rekey_checked' in start and start.count('call binding_read')>=3 and 'o_inherit_read' in start)
 c['tail_seed_after_detach_before_rekey']=bool(start.find('call binding_detach') < start.find('movb $7,binding_generation+1279') < start.rfind('call activity_rekey_checked'))
 snap_ok=True; smap={}
 for item in m.get('inputs',[]):
  p=manifest.parent/item['snapshot_path']; ok=p.exists() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256']; snap_ok=snap_ok and ok; smap[item['key']]=item['sha256']
 c['snapshot_receipt_and_host_boundary']=bool(snap_ok and r.get('input_manifest_sha256')==sha(manifest) and all(r.get('source_sha256',{}).get(k)==v for k,v in smap.items()) and all(x not in l for x in ['act_identity(','binding_resource_plus1(','resource_live_count(','debug.write_text(','debug.write_bytes(']) and all(x not in e for x in ['act_identity(','binding_resource_plus1(','resource_live_count(','debug.write_text(','debug.write_bytes(']))
 c['all_checks_literal_boolean']=bool(all(isinstance(v,bool) for v in c.values()))
 result={'checker_version':VERSION,'checks':c,'passed':bool(all(c.values())),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest),'measurements':{'activity_capacity':64,'bindings_per_activity':20,'binding_cell_count':1280,'resource_capacity':64,'activity_identity_scan_bound':64,'checked_release_row_scan_bound':20,'rekey_binding_scan_bound':1280,'rekey_resource_scan_bound':64,'activity_reset_bound':64,'binding_reset_bound':1280}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
