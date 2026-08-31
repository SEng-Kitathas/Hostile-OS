from __future__ import annotations
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent;BUILD=HERE/'build'
CORE=['S1_8K_OK', 'TEST=D64_V2_CORE', 'ACT_FILLED=40', 'ACT_OVER=F', 'ROW_FILLED=14', 'ROW_OVER=F', 'SHARE_LIVE=0002', 'STALE_BIND=R', 'FRESH_BIND=W', 'FRESH_BIND_VAL=7E', 'MISSING_BIND=M', 'RELEASE_BOUND=B', 'DETACH_ONE_LIVE=0001', 'DETACH_LAST_LIVE=0000', 'OLD_RES=R', 'NEW_RES=W', 'NEW_RES_VAL=55', 'DONE', 'TEST=D64_V2_IRQ', 'IRQ1_EVENT=01', 'IRQ1_REL=1', 'IRQ1_WAKE=1', 'IRQ1_PROG=02', 'IRQ2_EVENT=02', 'IRQ2_REL=1', 'IRQ2_WAKE=1', 'IRQ2_PROG=02', 'IRQBAD_EVENT=02', 'IRQBAD_REL=0', 'IRQBAD_WAKE=0', 'IRQBAD_PROG=00', 'IRQ_DONE']
RESTART1=['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=R', 'PHASE=WRITE', 'WRITE=A', 'PERSIST_DONE']
RESTART2=['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=R', 'PHASE=RECOVER', 'SELECT=A', 'DUR_VAL=71', 'OLD_BIND=R', 'OLD_RES=R', 'FRESH_BIND=W', 'FRESH_BIND_VAL=71', 'PERSIST_DONE']
FAULT={'old_empty': ['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=F', 'PHASE=RECOVER', 'SELECT=A', 'DUR_VAL=71', 'OLD_BIND=R', 'OLD_RES=R', 'FRESH_BIND=W', 'FRESH_BIND_VAL=71', 'PERSIST_DONE'], 'newer_valid': ['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=F', 'PHASE=RECOVER', 'SELECT=B', 'DUR_VAL=72', 'OLD_BIND=R', 'OLD_RES=R', 'FRESH_BIND=W', 'FRESH_BIND_VAL=72', 'PERSIST_DONE'], 'newer_corrupt': ['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=F', 'PHASE=RECOVER', 'SELECT=A', 'DUR_VAL=71', 'OLD_BIND=R', 'OLD_RES=R', 'FRESH_BIND=W', 'FRESH_BIND_VAL=71', 'PERSIST_DONE'], 'equal_conflict': ['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=F', 'PHASE=RECOVER', 'SELECT=X', 'DUR_VAL=00', 'OLD_BIND=-', 'OLD_RES=-', 'FRESH_BIND=-', 'FRESH_BIND_VAL=00', 'PERSIST_DONE'], 'both_invalid': ['S1_8K_OK', 'TEST=D64_V2_PERSIST', 'MODE=F', 'PHASE=RECOVER', 'SELECT=N', 'DUR_VAL=00', 'OLD_BIND=-', 'OLD_RES=-', 'FRESH_BIND=-', 'FRESH_BIND_VAL=00', 'PERSIST_DONE']}
def goodboot(x):return x.get('status')=='COMPLETED' and x.get('exit_code')==33
def main()->int:
 b=json.loads((BUILD/'build_manifest.json').read_text(encoding='utf-8'));r=json.loads((BUILD/'run_receipt.json').read_text(encoding='utf-8'));checks={}
 checks['stage1_size_512']=bool(b['stage1']['bytes']==512)
 checks['stage1_signature_55aa']=bool(b['stage1']['signature_55aa'] is True)
 checks['stage2_raw_within_8192']=bool(b['stage2']['raw_bytes']<=8192)
 checks['stage2_memory_within_8192']=bool(b['stage2']['image_memory_bytes']<=8192)
 checks['v2_named_state_exact_3467']=bool(b['state']['actual_bytes']==3467)
 checks['integrated_has_at_least_512_memory_headroom']=bool((8192-b['stage2']['image_memory_bytes'])>=512)
 checks['core_irq_boot_exact']=bool(goodboot(r['core']) and r['core']['trace']==CORE)
 rr=r['restart'];checks['restart_boot1_exact']=bool(goodboot(rr['boot1']) and rr['boot1']['trace']==RESTART1)
 checks['restart_guest_record_exact']=bool(rr['a_after_boot1_exact_expected'] is True and rr['b_after_boot1_zero'] is True)
 checks['restart_no_host_write_between_boots']=bool(rr['no_host_write_between_boots'] is True)
 checks['restart_boot2_exact']=bool(goodboot(rr['boot2']) and rr['boot2']['trace']==RESTART2)
 checks['restart_recovery_boot_read_only']=bool(rr['disk_unchanged_during_recovery_boot'] is True)
 for name,exp in FAULT.items():
  x=r['faulted_media'][name];checks['fault_'+name]=bool(goodboot(x['boot']) and x['boot']['trace']==exp and x['disk_unchanged'] is True)
 result={'format':'HOSTILE_OS_D64_V2_VERIFY_V4','body_status':'CURRENT_RESEARCH_REFERENCE','passed':all(checks.values()),'checks':checks,'check_count':len(checks)}
 (BUILD/'verification.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(result,indent=2))
 return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
