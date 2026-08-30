from __future__ import annotations
import hashlib
import json
import re
import sys
from pathlib import Path

VERSION='I001-static-source-v1'

def sha256(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()

def block(text:str,start:str,end:str)->str:
 return text.split(start+':\n',1)[1].split('\n'+end+':',1)[0]

def main()->int:
 if len(sys.argv)!=5:
  print('usage: static_check_i001.py STAGE1_S STAGE2_S LAUNCHER_PY RESULT_JSON',file=sys.stderr); return 64
 s1p,s2p,lp,out=map(Path,sys.argv[1:]); s1=s1p.read_text().replace('\r\n','\n'); s2=s2p.read_text().replace('\r\n','\n'); launcher=lp.read_text().replace('\r\n','\n')
 checks={}
 checks['stage1_exact_8_sector_load']=all(x in s1 for x in ['movw $0x8000,%bx','movb $0x02,%ah','movb $0x08,%al','movb $0x02,%cl','int $0x13','ljmp $0x0000,$0x8000'])
 checks['two_activity_slots']=s2.count('act_identity:.byte 0,0')==1 and 'act_identity:.byte 0,0,0' not in s2
 acq=block(s2,'acquire_checked','acquire_full')
 needed_order=['cmpw $2,%bx','cmpb $0,act_identity(%bx)','cmpb $255,act_gen(%bx)','incb act_gen(%bx)','movb %al,act_identity(%bx)','movb %ah,act_epoch(%bx)']
 pos=[acq.find(x) for x in needed_order]
 checks['acquire_checks_before_mutation']=all(i>=0 for i in pos) and pos==sorted(pos)
 init_fields=['act_progress(%bx)','act_cont(%bx)','act_waiting(%bx)','act_woken(%bx)','act_parent_slot(%bx)','act_parent_gen(%bx)','act_wait_slot(%bx)','act_wait_gen(%bx)']
 checks['acquire_initializes_all_runtime_fields']=all(f'movb $0,{x}' in acq for x in init_fields)
 checks['same_checked_acquire_reused']=s2.count('call acquire_checked')>=5
 checks['lineage_bound_to_current_parent']='movb $0,act_parent_slot+1' in s2 and 'movb %al,act_parent_gen+1' in s2
 bind=block(s2,'bind_parent_wait','request_execute')
 checks['wait_target_includes_slot_generation']=all(x in bind for x in ['movb $1,act_wait_slot','movb act_gen+1,%al','movb %al,act_wait_gen','movb $2,act_cont'])
 crit=block(s2,'critical_wait_begin','critical_wait_end')
 crit_lines=[ln.strip() for ln in crit.splitlines() if ln.strip() and not ln.strip().startswith('#')]
 checks['named_critical_region_present_and_measured']=len(crit_lines)>0
 irq=block(s2,'irq0_handler','read_durable')
 checks['irq_does_not_apply_progress']='act_progress' not in irq and 'irq_rel_ok' in irq and 'act_wait_slot' in irq and 'act_cont' in irq
 checks['completion_wake_apply_separate']=all((x+':') in s2 for x in ['record_child_completion','generic_wait_match','apply_parent'])
 checks['missing_status_checked_before_b_application']="call request_execute\n cmpb $'O',%al\n jne fatal_state\n movb $1,act_progress+1" in s2
 badglob=block(s2,'bad_global_control','bad_full_control')
 before_bad=s2.split('bad_global_control:',1)[0]
 checks['global_poison_only_in_bad_control']='bad_global_latch' not in before_bad and 'bad_global_latch' in badglob
 rel=block(s2,'release_binding_activity','release_fail')
 checks['lifetime_release_preserves_until_zero']='decb backing_live' in rel and 'cmpb $0,backing_live' in rel and 'movb $0,backing_value' in rel
 handle=block(s2,'checked_use_handle','handle_reject')
 horder=['cmpb $0,act_identity(%bx)','movb act_gen(%bx),%al','cmpb %dl,%al','movb act_epoch(%bx),%al','cmpb %dh,%al',"movb $'W',%al"]
 hp=[handle.find(x) for x in horder]
 checks['checked_handle_generation_epoch_before_success']=all(i>=0 for i in hp) and hp==sorted(hp)
 checks['address_only_control_reads_reused_identity']='movb act_identity+1,%al\n movw $lab_bad_stale,%si' in s2
 cur=block(s2,'run_currentness_controls','reset_relation')
 checks['r01_controls_version_and_flag_split']='ctl_flag' in cur and 'ctl_ver_pre' in cur and 'cmpb ctl_ver_post,%al' in cur and 'ctl_stable' in cur
 checks['durable_bytes_written_by_guest']=all(f'movb ${v},BUF+{i}' in s2 for i,v in [(0,"'H'"),(1,"'4'"),(2,"'I'"),(3,"'1'"),(4,"'R'"),(5,"'Z'"),(6,'0x34'),(7,'0x12'),(8,'1'),(9,'0'),(10,'1'),(11,'1')])
 boot2=block(s2,'boot2','init_runtime')
 checks['boot2_prebind_before_rebind']=boot2.find('call checked_use_handle')>=0 and boot2.find('call checked_use_handle') < boot2.find('call rebind_boot2')
 rebind=block(s2,'rebind_boot2','install_irq')
 checks['rebind_fail_closed_before_epoch_increment']=rebind.find('cmpb $255,%al')>=0 and rebind.find('cmpb $255,%al') < rebind.find('incb %al')
 checks['acquire_fail_closed_before_generation_increment']=acq.find('cmpb $255,act_gen(%bx)') < acq.find('incb act_gen(%bx)')
 checks['old_token_epoch_is_compared']='movb $1,%dh\n call checked_use_handle\n movw $lab_old_token' in s2
 checks['negative_controls_in_same_payload']=all((x+':') in s2 for x in ['bad_wake_apply','bad_global_control','bad_full_control','bad_restart_use','run_currentness_controls']) and 'lab_bad_stale' in s2
 checks['runtime_state_symbols']='runtime_state_start:' in s2 and 'runtime_state_end:' in s2
 checks['launcher_no_guest_debug_synthesis']='debug.write_' not in launcher and 'boot1.debugcon' in launcher and 'boot2.debugcon' in launcher
 checks['launcher_no_between_boot_sector_mutation']='durable_after_boot1' in launcher and 'BOOT2_MUTATION_FORBIDDEN' in launcher
 species=['activity_slots','shared_backing','completion_record','irq_event','runtime_epoch','coherence_control']
 result={'checker_version':VERSION,'passed':all(checks.values()),'checks':checks,'critical_wait_instruction_count':len(crit_lines),'critical_wait_instructions':crit_lines,'state_block_species':species,'state_block_species_count':len(species),'source_sha256':{'stage1':sha256(s1p),'stage2':sha256(s2p),'launcher':sha256(lp)}}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(result,indent=2))
 return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
