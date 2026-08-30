from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-RB02-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def block(t:str,a:str,b:str)->str:
 return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def main()->int:
 if len(sys.argv)!=7:
  print('usage: static_check_rb02.py STAGE2 LAUNCHER EVALUATOR MANIFEST RECEIPT_PRE OUT',file=sys.stderr); return 64
 s2,launcher,evaluator,manifest,receipt,out=map(Path,sys.argv[1:]); t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8'); m=json.loads(manifest.read_text()); r=json.loads(receipt.read_text())
 c={}
 c['named_capacities']=bool(all(x in t for x in ['.equ ACTIVITY_CAP,64','.equ BINDINGS_PER_ACTIVITY,20','.equ BINDING_CELL_COUNT,1280','.equ RESOURCE_CAP,64']))
 c['activity_arrays_64']=bool(all(t.count(f'{f}:.space ACTIVITY_CAP,0')==1 for f in FIELDS))
 c['binding_arrays_1280']=bool(t.count('binding_resource_plus1:.space BINDING_CELL_COUNT,0')==1 and t.count('binding_generation:.space BINDING_CELL_COUNT,0')==1)
 c['resource_arrays_and_livecount_16bit']=bool(all(t.count(f'{f}:.space RESOURCE_CAP,0')==1 for f in ['resource_identity','resource_generation','resource_value']) and t.count('resource_live_count:.space RESOURCE_CAP*2,0')==1)
 c['generic_activity_acquire']=bool(t.count('activity_acquire:')==1 and 'activity_acquire_slot0:' not in t and 'activity_acquire_slot63:' not in t)
 base=block(t,'binding_base_from_input','bind_new_resource'); c['binding_row_math_20']=bool('shlw $2,%di' in base and 'shlw $4,%ax' in base and 'addw %ax,%di' in base)
 bn=block(t,'bind_new_resource','bind_new_binding_scan')+block(t,'bind_new_binding_scan','bind_new_binding_found')+block(t,'bind_new_binding_found','bind_new_resource_scan')+block(t,'bind_new_resource_scan','bind_new_resource_found')+block(t,'bind_new_resource_found','bind_new_row_full')
 c['bind_new_capacity_checks_before_mutation']=bool('cmpw $BINDINGS_PER_ACTIVITY,%dx' in bn and 'jae bind_new_row_full' in bn and 'cmpw $RESOURCE_CAP,%bx' in bn and 'jae bind_new_global_full' in bn and bn.find('cmpw $BINDINGS_PER_ACTIVITY,%dx') < bn.find('incb resource_generation(%bx)') and bn.find('cmpw $RESOURCE_CAP,%bx') < bn.find('incb resource_generation(%bx)'))
 c['binding_generation_fail_closed']=bool('cmpb $255,binding_generation(%si)' in t and 'je bind_new_generation_exhausted' in t and "bind_new_generation_exhausted:\n movb $'G',%al" in t)
 c['resource_generation_fail_closed']=bool('cmpb $255,resource_generation(%bx)' in t and 'je bind_new_generation_exhausted' in t and 'incb resource_generation(%bx)' in t)
 pub=block(t,'bind_new_resource_found','bind_new_row_full'); pos=[pub.find(x) for x in ['incb resource_generation(%bx)','movb %al,resource_identity(%bx)','movb %al,resource_value(%bx)','movw $1,resource_live_count(%si)','incb binding_generation(%si)','movb %al,binding_resource_plus1(%si)']]; c['resource_initialized_before_binding_publish']=bool(all(x>=0 for x in pos) and pos==sorted(pos))
 be=block(t,'bind_existing_resource','bind_existing_binding_scan'); c['bind_existing_validates_resource_first']=bool(all(x in be for x in ['cmpw $RESOURCE_CAP,%bx','cmpb $0,resource_identity(%bx)','cmpb resource_generation(%bx),%al','cmpb resource_epoch,%al']) and 'incw resource_live_count' not in be and 'binding_resource_plus1' not in be)
 c['livecount_word_ops']=bool('incw resource_live_count(%si)' in t and 'decw resource_live_count(%si)' in t and 'movw resource_live_count(%si),%ax' in t)
 det=block(t,'binding_detach','binding_detach_done'); c['detach_lifetime_order']=bool(det.find('movb $0,binding_resource_plus1(%di)') < det.find('decw resource_live_count(%si)') < det.find('cmpw $0,resource_live_count(%si)') and 'resource_generation' not in det)
 br=block(t,'binding_read','binding_read_reject'); bp=[br.find(x) for x in ['call validate_activity','cmpb $BINDINGS_PER_ACTIVITY,input_binding_index','cmpb $0,binding_resource_plus1(%di)','cmpb binding_generation(%di),%al','movb resource_value(%bx),%al']]; c['binding_read_checks_currentness_before_value']=bool(all(x>=0 for x in bp) and bp==sorted(bp))
 rr=block(t,'resource_read','resource_read_reject'); rp=[rr.find(x) for x in ['cmpw $RESOURCE_CAP,%bx','cmpb $0,resource_identity(%bx)','cmpb resource_generation(%bx),%al','cmpb resource_epoch,%al','movb resource_value(%bx),%al']]; c['resource_read_checks_currentness_before_value']=bool(all(x>=0 for x in rp) and rp==sorted(rp))
 badb=block(t,'bad_binding_read','bad_binding_reject'); badr=block(t,'bad_resource_read','bad_resource_reject'); c['negative_controls_omit_currentness']=bool('binding_generation' not in badb and 'resource_generation' not in badr and 'resource_epoch' not in badr and 'resource_value' in badb and 'resource_value' in badr)
 full=block(t,'bind_new_row_full','bind_new_generation_exhausted'); c['full_branches_no_protected_mutation']=bool("movb $'F',%al" in full and all(x not in full for x in ['binding_resource_plus1(','binding_generation(','resource_identity(','resource_generation(','resource_value(','resource_live_count(']))
 c['max_share_64x20_generic_path']=bool(all(x in t for x in ['share_acquire_activity_loop:','cmpw $ACTIVITY_CAP,%di','share_activity_loop:','cmpb $ACTIVITY_CAP,share_activity_slot','movb $20,%al','movb $19,%al','call bind_existing_resource','movw %ax,o_share_count']))
 snap_ok=True; smap={}
 for item in m.get('inputs',[]):
  p=manifest.parent/item['snapshot_path']; ok=p.exists() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256']; snap_ok=snap_ok and ok; smap[item['key']]=item['sha256']
 c['snapshot_receipt_source_closure']=bool(snap_ok and r.get('input_manifest_sha256')==sha(manifest) and all(r.get('source_sha256',{}).get(k)==v for k,v in smap.items()))
 c['host_no_guest_mutation_or_trace_synthesis']=bool(all(x not in l for x in ['binding_resource_plus1','resource_live_count','debug.write_text','debug.write_bytes']) and all(x not in e for x in ['binding_resource_plus1','resource_live_count','debug.write_text','debug.write_bytes']))
 c['all_checks_literal_boolean']=bool(all(isinstance(v,bool) for v in c.values()))
 result={'checker_version':VERSION,'checks':c,'passed':bool(all(c.values())),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest),'measurements':{'activity_capacity':64,'bindings_per_activity':20,'binding_cell_count':1280,'resource_capacity':64,'resource_live_count_bits':16,'max_binding_row_scan':20,'max_resource_scan':64}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
