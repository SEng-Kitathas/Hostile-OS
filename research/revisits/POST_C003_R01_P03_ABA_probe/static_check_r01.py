from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
CHECKER_VERSION='POST-C003-R01-static-v1'
def sha256(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def main():
 if len(sys.argv)!=3:
  print('usage: static_check_r01.py MECHANISM_S RESULT_JSON',file=sys.stderr); return 64
 src=Path(sys.argv[1]); out=Path(sys.argv[2]); text=src.read_text(encoding='utf-8').replace('\r\n','\n')
 checks={}
 expected={'state_owner':'0x0500','state_history':'0x0501','state_active':'0x0502','state_version':'0x0503'}
 for label,addr in expected.items():
  checks[f'one_{label}']=text.count(f'.equ {label},{addr}')==1
 checks['same_mutation_routine_twice']=text.count('call mutate_complete')==2
 mut=text.split('mutate_complete:\n',1)[1].split('\nflag_accept:',1)[0]
 seq=['movb $1,state_active','movb target_owner,%al','movb %al,state_owner','movb target_history,%al','movb %al,state_history','incb state_version','movb $0,state_active','ret']
 pos=[mut.find(x) for x in seq]
 checks['mutation_order_exact']=all(x>=0 for x in pos) and pos==sorted(pos) and mut.count('incb state_version')==1
 flag=text.split('flag_accept:\n',1)[1].split('\nversion_accept:',1)[0]
 checks['flag_path_no_version_compare']='state_version' not in flag and 'o5' not in flag and 'o8' not in flag
 ver=text.split('version_accept:\n',1)[1].split('\nstable_accept:',1)[0]
 checks['version_compares_saved_pre_post']='movb o5,%al' in ver and 'cmpb o8,%al' in ver and ver.find('cmpb o8,%al') < ver.find("movb $'C',%al")
 stable=text.split('stable_accept:\n',1)[1].split('\nprint_string:',1)[0]
 checks['stable_compare_and_accept']='movb o10,%al' in stable and 'cmpb o13,%al' in stable and 'movb o11,%al' in stable and 'cmpb o12,%al' in stable and "movb $'C',%al" in stable
 checks['fixture_results_not_embedded']=all(s not in text for s in ['FLAG_ACCEPT=S','VER_ACCEPT=R','STABLE_ACCEPT=C'])
 checks['single_record_no_second_record']=all(x not in text.lower() for x in ['record2','state2','second_record'])
 result={'checker_version':CHECKER_VERSION,'mechanism_sha256':sha256(src),'checks':checks,'passed':all(checks.values())}
 out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(result,indent=2))
 return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
