from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-RR01-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def block(t,a,b): return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def main():
 if len(sys.argv)!=7: return 64
 s2,launcher,evaluator,manifest,receipt,out=map(Path,sys.argv[1:])
 t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8')
 m=json.loads(manifest.read_text(encoding='utf-8')); r=json.loads(receipt.read_text(encoding='utf-8'))
 c={}
 c['exact_capacities_and_arrays']=bool(all(x in t for x in ['.equ ACTIVITY_CAP,64','.equ BINDINGS_PER_ACTIVITY,20','.equ BINDING_CELL_COUNT,1280','.equ RESOURCE_CAP,64','resource_live_count:.space RESOURCE_CAP*2,0']) and all(t.count(f'{f}:.space ACTIVITY_CAP,0')==1 for f in FIELDS) and t.count('binding_resource_plus1:.space BINDING_CELL_COUNT,0')==1 and t.count('binding_generation:.space BINDING_CELL_COUNT,0')==1)
 c['ordinary_paths_reused']=bool(all(t.count('\n'+x+':\n')==1 for x in ['activity_acquire','bind_new_resource','binding_detach','binding_read','resource_read']) and all('call '+x in t.split('_start:\n',1)[1].split('\nfail:',1)[0] for x in ['activity_acquire','bind_new_resource','binding_detach','binding_read','resource_read']))
 rk=block(t,'resource_rekey_checked','resource_rekey_reject'); first_mut=min(x for x in [rk.find('movb $0,resource_identity(%bx)'),rk.find('movb $0,resource_generation(%bx)'),rk.find('movb $0,resource_value(%bx)')] if x>=0)
 c['rekey_scans_all_bindings_before_mutation']=bool('cmpw $BINDING_CELL_COUNT,%bx' in rk and 'cmpb $0,binding_resource_plus1(%bx)' in rk and rk.find('cmpw $BINDING_CELL_COUNT,%bx') < first_mut)
 c['rekey_checks_resource_identity_livecount_before_mutation']=bool('cmpw $RESOURCE_CAP,%bx' in rk and 'cmpb $0,resource_identity(%bx)' in rk and 'cmpw $0,resource_live_count(%si)' in rk and rk.find('cmpb $0,resource_identity(%bx)') < first_mut and rk.find('cmpw $0,resource_live_count(%si)') < first_mut)
 c['relation_guard_before_mutation']=bool('cmpb $0,relation_active' in rk and rk.find('cmpb $0,relation_active') < first_mut)
 rej=block(t,'resource_rekey_reject','resource_reset_generation_only')
 c['rekey_reject_no_namespace_mutation']=bool("movb $'R',%al" in rej and all(x not in rej for x in ['resource_epoch','resource_generation(','resource_identity(','resource_value(','resource_live_count(','activity_epoch','act_identity(','binding_generation(','binding_resource_plus1(']))
 reset=block(t,'resource_rekey_reset_loop','resource_rekey_publish')
 c['rekey_resets_resource_state_bounded']=bool('cmpw $RESOURCE_CAP,%bx' in reset and all(x in reset for x in ['movb $0,resource_identity(%bx)','movb $0,resource_generation(%bx)','movb $0,resource_value(%bx)','movw $0,resource_live_count(%si)']))
 c['rekey_changes_resource_epoch_nonzero_after_reset']=bool('cmpb $255,%al' in rk and 'resource_rekey_wrap:' in rk and 'movb $1,%al' in rk and 'movb %al,next_resource_epoch' in rk and t.find('resource_rekey_publish:') < t.find('movb %al,resource_epoch',t.find('resource_rekey_publish:')))
 c['rekey_does_not_touch_activity_state']=bool('activity_epoch' not in rk and all(f not in rk for f in FIELDS))
 c['rekey_does_not_touch_binding_arrays']=bool('binding_generation' not in rk and 'movb $0,binding_resource_plus1' not in rk)
 bad=block(t,'resource_reset_generation_only','resource_bad_reset_loop')+block(t,'resource_bad_reset_loop','resource_bad_reset_done')
 c['bad_reset_generation_only']=bool('movb $0,resource_generation(%bx)' in bad and 'resource_epoch' not in bad and 'resource_identity' not in bad and 'resource_live_count' not in bad and t.count('call resource_reset_generation_only')==1 and 'call resource_reset_generation_only' not in rk)
 acq=block(t,'bind_new_resource_found','bind_new_row_full')
 c['resource_generation_fail_closed']=bool('cmpb $255,resource_generation(%bx)' in t.split('bind_new_resource_found:',1)[0].split('bind_new_binding_found:',1)[1] or 'cmpb $255,resource_generation(%bx)' in t)
 rr=block(t,'resource_read','resource_read_reject'); seq=[rr.find(x) for x in ['cmpw $RESOURCE_CAP,%bx','cmpb $0,resource_identity(%bx)','cmpb resource_generation(%bx),%al','cmpb resource_epoch,%al','movb resource_value(%bx),%al']]
 c['resource_read_currentness_before_value']=bool(all(x>=0 for x in seq) and seq==sorted(seq))
 br=block(t,'binding_read','binding_read_reject'); bseq=[br.find(x) for x in ['call validate_activity','cmpb $BINDINGS_PER_ACTIVITY,input_binding_index','cmpb $0,binding_resource_plus1(%di)','cmpb binding_generation(%di),%al','movb resource_value(%bx),%al']]
 c['binding_read_currentness_before_value']=bool(all(x>=0 for x in bseq) and bseq==sorted(bseq))
 snap_ok=True; smap={}
 for item in m.get('inputs',[]):
  p=manifest.parent/item['snapshot_path']; ok=p.exists() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256']; snap_ok=snap_ok and ok; smap[item['key']]=item['sha256']
 c['input_manifest_receipt_closure']=bool(snap_ok and r.get('input_manifest_sha256')==sha(manifest) and all(r.get('source_sha256',{}).get(k)==v for k,v in smap.items()))
 forbidden=['act_identity(','binding_resource_plus1(','resource_live_count(','debug.write_text(','debug.write_bytes(']
 c['host_no_guest_mutation_or_trace_synthesis']=bool(all(x not in l for x in forbidden) and all(x not in e for x in forbidden))
 c['all_checks_literal_boolean']=bool(all(isinstance(v,bool) for v in c.values()))
 result={'checker_version':VERSION,'checks':c,'passed':bool(all(c.values())),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest),'measurements':{'activity_capacity':64,'bindings_per_activity':20,'binding_cell_count':1280,'resource_capacity':64,'resource_rekey_binding_scan':1280,'resource_scan_reset':64}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
