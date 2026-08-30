from __future__ import annotations
import hashlib, json, sys
from pathlib import Path
VERSION='D64-A01-static-v1'
FIELDS=['act_identity','act_gen','act_progress','act_cont','act_waiting','act_woken','act_parent_slot','act_parent_gen','act_wait_slot','act_wait_gen','act_epoch']
def sha(p:Path):
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def block(t,a,b): return t.split(a+':\n',1)[1].split('\n'+b+':',1)[0]
def main():
 if len(sys.argv)!=6:
  print('usage: static_check_a01.py STAGE2 LAUNCHER EVALUATOR INPUT_MANIFEST OUT',file=sys.stderr); return 64
 s2,launcher,evaluator,manifest,out=map(Path,sys.argv[1:])
 t=s2.read_text(encoding='utf-8').replace('\r\n','\n'); l=launcher.read_text(encoding='utf-8'); e=evaluator.read_text(encoding='utf-8'); m=json.loads(manifest.read_text(encoding='utf-8'))
 c={}
 c['cap_named_64']=('.equ ACTIVITY_CAP,64' in t)
 c['eleven_arrays_cap']=all(t.count(f'{f}:.space ACTIVITY_CAP,0')==1 for f in FIELDS)
 c['one_generic_acquire']=t.count('acquire_next:')==1 and 'acquire_slot0:' not in t and 'acquire_slot1:' not in t
 acq=block(t,'acquire_next','acquire_scan'); scan=block(t,'acquire_scan','acquire_found'); found=block(t,'acquire_found','acquire_generation_exhausted'); full=block(t,'acquire_full','release_index')
 c['acquire_bounded_before_mutation']=('cmpw $ACTIVITY_CAP,%bx' in scan and 'jae acquire_full' in scan and scan.find('cmpw $ACTIVITY_CAP,%bx') < scan.find('cmpb $0,act_identity(%bx)'))
 c['full_branch_no_array_write']=all(f not in full for f in FIELDS) and "movb $'F',%al" in full
 rel=block(t,'release_index','release_reject')
 c['generic_release_bounds_first']=('cmpw $ACTIVITY_CAP,%bx' in rel and 'jae release_reject' in rel and rel.find('cmpw $ACTIVITY_CAP,%bx') < rel.find('movb $0,act_identity(%bx)'))
 c['slot31_uses_generic_calls']=('movw $31,%bx\n call release_index' in t and "movb $0x5a,%al" in t and 'call acquire_next' in t and 'release_slot31:' not in t and 'acquire_slot31:' not in t)
 c['generation_fail_closed']=('cmpb $255,act_gen(%bx)' in found and 'je acquire_generation_exhausted' in found and 'incb act_gen(%bx)' in found and "acquire_generation_exhausted:\n movb $'G',%al" in t)
 handle=block(t,'checked_handle','handle_reject')
 c['handle_checks_bounds_gen_epoch_before_identity_expose']=('cmpw $ACTIVITY_CAP,%bx' in handle and 'cmpb act_gen(%bx),%cl' in handle and 'cmpb act_epoch(%bx),%ch' in handle and handle.find('cmpb act_gen(%bx),%cl') < handle.find('movb act_identity(%bx),%al') and handle.find('cmpb act_epoch(%bx),%ch') < handle.find('movb act_identity(%bx),%al'))
 c['no_two_slot_capacity_compare']=('cmpw $2,%bx' not in t and 'ACTIVITY_CAP,2' not in t)
 # Snapshot manifest integrity
 snap_ok=True
 for item in m.get('inputs',[]):
  p=manifest.parent/item['snapshot_path']
  if not p.exists() or p.stat().st_size!=item['bytes'] or sha(p)!=item['sha256']: snap_ok=False; break
 c['input_manifest_snapshots_verify']=snap_ok and m.get('controlling_preregistration_commit')
 c['host_no_guest_mutation_or_debug_synthesis']=all(x not in l for x in ['act_identity','act_gen','debug.write_text','debug.write_bytes']) and all(x not in e for x in ['act_identity','act_gen','debug.write_text','debug.write_bytes'])
 r={'checker_version':VERSION,'checks':c,'passed':all(bool(v) for v in c.values()),'stage2_sha256':sha(s2),'input_manifest_sha256':sha(manifest)}
 out.write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8'); print(json.dumps(r,indent=2)); return 0 if r['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
