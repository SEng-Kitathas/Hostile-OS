from __future__ import annotations
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent;BUILD=HERE/'build'
SMP=['S1_8K_OK','TEST=H1_SMP_MIN03','IDS=0001','OWNER=BSP','MAIL=WW11','SMP_DONE']
CORE=['S1_8K_OK','TEST=D64_V2_CORE','ACT_FILLED=40','ACT_OVER=F','ROW_FILLED=14','ROW_OVER=F','SHARE_LIVE=0002','STALE_BIND=R','FRESH_BIND=W','FRESH_BIND_VAL=7E','MISSING_BIND=M','RELEASE_BOUND=B','DETACH_ONE_LIVE=0001','DETACH_LAST_LIVE=0000','OLD_RES=R','NEW_RES=W','NEW_RES_VAL=55','DONE','TEST=D64_V2_IRQ','IRQ1_EVENT=01','IRQ1_REL=1','IRQ1_WAKE=1','IRQ1_PROG=02','IRQ2_EVENT=02','IRQ2_REL=1','IRQ2_WAKE=1','IRQ2_PROG=02','IRQBAD_EVENT=02','IRQBAD_REL=0','IRQBAD_WAKE=0','IRQBAD_PROG=00','IRQ_DONE']
R1=['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=R','PHASE=WRITE','WRITE=A','PERSIST_DONE']
R2=['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=R','PHASE=RECOVER','SELECT=A','DUR_VAL=71','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE']
FAULT={'old_empty':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=A','DUR_VAL=71','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE'],'newer_valid':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=B','DUR_VAL=72','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=72','PERSIST_DONE'],'newer_corrupt':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=A','DUR_VAL=71','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE'],'equal_conflict':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=X','DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','PERSIST_DONE'],'both_invalid':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=N','DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','PERSIST_DONE']}
def good(x):return x.get('status')=='COMPLETED' and x.get('exit_code')==33
def main():
 b=json.loads((BUILD/'build_manifest.json').read_text(encoding='utf-8'));r=json.loads((BUILD/'run_receipt.json').read_text(encoding='utf-8'));checks={}
 checks['stage1_512_55aa']=bool(b['stage1']['bytes']==512 and b['stage1']['signature_55aa'] is True)
 checks['stage2_raw_exact_4494']=bool(b['stage2']['raw_bytes']==4494)
 checks['stage2_memory_exact_8089']=bool(b['stage2']['image_memory_bytes']==8089)
 checks['headroom_exact_103']=bool(b['stage2']['headroom_bytes']==103)
 checks['named_state_exact_3467']=bool(b['state']['actual_bytes']==3467)
 checks['scratch_used_exact_62']=bool(b['implementation_scratch']['used_bytes']==62)
 checks['h1_profile_exact']=bool(r['h1_profile']['machine']=='pc-q35-11.1' and r['h1_profile']['cpu']=='phenom' and r['h1_profile']['smp']=='2,sockets=1,cores=2,threads=1' and r['h1_profile']['memory_mib']==4096 and r['target_disk_virtual_bytes']==500*1024**3)
 checks['smp_exact']=bool(good(r['smp']) and r['smp']['trace']==SMP)
 checks['core_irq_exact']=bool(good(r['core']) and r['core']['trace']==CORE)
 rr=r['restart'];checks['restart_boot1_exact']=bool(good(rr['boot1']) and rr['boot1']['trace']==R1);checks['restart_record_exact']=bool(rr['a_after_boot1_exact_expected'] is True and rr['b_after_boot1_zero'] is True);checks['restart_no_host_write_between']=bool(rr['no_host_write_between_boots'] is True);checks['restart_boot2_exact']=bool(good(rr['boot2']) and rr['boot2']['trace']==R2);checks['restart_boot2_readonly']=bool(rr['disk_unchanged_during_recovery_boot'] is True)
 for name,exp in FAULT.items():
  x=r['faulted_media'][name];checks['fault_'+name]=bool(good(x['boot']) and x['boot']['trace']==exp and x['disk_unchanged'] is True)
 texts='\n'.join((HERE/n).read_text(encoding='utf-8',errors='replace') for n in ['build.py','run.py']);checks['os_only_no_parent_runtime_dependency']=bool('HERE.parents' not in texts and "../" not in texts and 'research/' not in texts and 'continuity/' not in texts and 'handoffs/' not in texts and 'authority/' not in texts)
 result={'format':'HOSTILE_OS_D64_V3_VERIFY_V1','body_class':'research-only','passed':all(checks.values()),'checks':checks,'check_count':len(checks)};(BUILD/'verification.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result,indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
