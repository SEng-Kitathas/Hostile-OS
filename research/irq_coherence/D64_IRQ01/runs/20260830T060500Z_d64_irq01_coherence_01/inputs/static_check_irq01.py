from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-IRQ01-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def between(t,a,b): return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def instr_lines(block:str):
 out=[]
 for raw in block.splitlines():
  s=raw.split('#',1)[0].strip()
  if not s or s.endswith(':') or s.startswith('.'): continue
  out.append(s)
 return out
def main():
 if len(sys.argv)!=7: return 64
 s2,launcher,evaluator,manifest,receipt,out=map(Path,sys.argv[1:])
 t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8')
 m=json.loads(manifest.read_text(encoding='utf-8')); r=json.loads(receipt.read_text(encoding='utf-8'))
 c={}
 c['exact_d64_arrays']=bool(all(x in t for x in ['.equ ACTIVITY_CAP,64','.equ BINDINGS_PER_ACTIVITY,20','.equ BINDING_CELL_COUNT,1280','.equ RESOURCE_CAP,64','resource_live_count:.space RESOURCE_CAP*2,0']) and all(t.count(f'{f}:.space ACTIVITY_CAP,0')==1 for f in FIELDS) and t.count('binding_resource_plus1:.space BINDING_CELL_COUNT,0')==1 and t.count('binding_generation:.space BINDING_CELL_COUNT,0')==1)
 c['real_irq0_plumbing']=bool(all(x in t for x in ['movw $irq0_handler,0x0020','movw $0x0000,0x0022','.equ PIT_DIVISOR,4096','movw $PIT_CMD,%dx','movw $PIT_CH0,%dx','movb $0xfe,%al','movw $PIC_MASTER_CMD,%dx','iret']))
 h=between(t,'irq0_handler','print_matrix')
 c['single_read_only_irq_observer']=bool(t.count('irq0_handler:')==1 and all(x in h for x in ['movb binding_resource_plus1,%al','movb resource_identity,%al','movw resource_live_count,%ax','movb %al,irq_bind_snapshot','movb %al,irq_rid_snapshot','movw %ax,irq_live_snapshot']) and all(x not in h for x in ['movb $0,binding_resource_plus1','movb $1,binding_resource_plus1','movb $0,resource_identity','movb $0x51,resource_identity','movw $0,resource_live_count','movw $1,resource_live_count']))
 start=between(t,'_start','fail')
 p=[start.find(x) for x in ['incb resource_generation','movb $0x51,resource_identity','movb $0x7e,resource_value','movw $1,resource_live_count','call unmask_irq0','sti','bad_bind_wait:','incb binding_generation','movb $1,binding_resource_plus1']]
 c['bad_bind_cut_order']=bool(all(x>=0 for x in p) and p==sorted(p))
 gb=instr_lines(between(t,'good_bind_region_begin','good_bind_region_end')); gb_w=[x for x in gb if any(k in x for k in ['resource_generation','resource_identity','resource_value','resource_live_count','binding_generation','binding_resource_plus1'])]
 c['good_bind_region_exact_6_6']=bool(len(gb)==6 and len(gb_w)==6 and gb==['incb resource_generation','movb $0x51,resource_identity','movb $0x7e,resource_value','movw $1,resource_live_count','incb binding_generation','movb $1,binding_resource_plus1'])
 c['good_bind_irq_after_region']=bool(t.find('good_bind_region_end:') < t.find('call unmask_irq0',t.find('good_bind_region_end:')) < t.find('sti',t.find('good_bind_region_end:')))
 bd_start=start.find('# C: bad final detach'); bd=start[bd_start:] if bd_start>=0 else ''
 pd=[bd.find(x) for x in ['movb $0,binding_resource_plus1','call unmask_irq0','sti','bad_detach_wait:','decw resource_live_count','cmpw $0,resource_live_count','movb $0,resource_identity','movb $0,resource_value']]
 c['bad_detach_cut_order']=bool(all(x>=0 for x in pd) and pd==sorted(pd))
 gd=instr_lines(between(t,'good_detach_region_begin','good_detach_region_end')); gd_w=[x for x in gd if any(k in x for k in ['binding_resource_plus1','decw resource_live_count','movb $0,resource_identity','movb $0,resource_value'])]
 c['good_detach_region_exact_6_4']=bool(len(gd)==6 and len(gd_w)==4 and gd==['movb $0,binding_resource_plus1','decw resource_live_count','cmpw $0,resource_live_count','jne good_detach_nonzero','movb $0,resource_identity','movb $0,resource_value'])
 c['good_detach_irq_after_region']=bool(t.find('good_detach_region_end:') < t.find('call unmask_irq0',t.find('good_detach_region_end:')) < t.find('sti',t.find('good_detach_region_end:')))
 c['snapshot_storage_separate']=bool(all(t.count(x+':')==1 for x in ['irq_bind_snapshot','irq_rid_snapshot','irq_live_snapshot']) and all(x not in ['binding_resource_plus1','resource_identity','resource_live_count'] for x in ['irq_bind_snapshot','irq_rid_snapshot','irq_live_snapshot']))
 c['same_arrays_all_paths']=bool(t.count('binding_resource_plus1:.space BINDING_CELL_COUNT,0')==1 and t.count('resource_identity:.space RESOURCE_CAP,0')==1 and t.count('resource_live_count:.space RESOURCE_CAP*2,0')==1)
 c['bad_paths_complete_post_state']=bool('movb $1,binding_resource_plus1' in start[start.find('bad_bind_wait:'):start.find('# B: good bind')] and all(x in bd for x in ['decw resource_live_count','movb $0,resource_identity','movb $0,resource_value','movb %al,o_bad_detach_post_bind','movb %al,o_bad_detach_post_rid','movw %ax,o_bad_detach_post_live']))
 c['protected_measurements_exact']=bool(len(gb)==6 and len(gb_w)==6 and len(gd)==6 and len(gd_w)==4)
 snap_ok=True; smap={}
 for item in m.get('inputs',[]):
  pth=manifest.parent/item['snapshot_path']; ok=pth.exists() and pth.stat().st_size==item['bytes'] and sha(pth)==item['sha256']; snap_ok=snap_ok and ok; smap[item['key']]=item['sha256']
 c['input_manifest_receipt_closure']=bool(snap_ok and r.get('input_manifest_sha256')==sha(manifest) and all(r.get('source_sha256',{}).get(k)==v for k,v in smap.items()))
 forbidden=['debug.write_text(','debug.write_bytes(','binding_resource_plus1(','resource_live_count(']
 c['host_no_guest_mutation_or_trace_synthesis']=bool(all(x not in l for x in forbidden) and all(x not in e for x in forbidden))
 c['all_checks_literal_boolean']=bool(all(isinstance(v,bool) for v in c.values()))
 result={'checker_version':VERSION,'checks':c,'passed':bool(all(c.values())),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest),'measurements':{'protected_bind_instruction_count':len(gb),'protected_bind_memory_write_count':len(gb_w),'protected_detach_instruction_count':len(gd),'protected_detach_memory_write_count':len(gd_w),'pit_divisor':4096,'activity_capacity':64,'binding_cell_count':1280,'resource_capacity':64}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
