from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
VERSION='D64-FR01-independent-audit-v1'
def sha(p:Path)->str:
 h=hashlib.sha256();
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('run_dir'); ap.add_argument('out'); a=ap.parse_args(); r=Path(a.run_dir)
 m=json.loads((r/'inputs_manifest.json').read_text(encoding='utf-8')); c=json.loads((r/'campaign_receipt.json').read_text(encoding='utf-8')); e=json.loads((r/'evaluation.json').read_text(encoding='utf-8')); s=json.loads((r/'static_closure.json').read_text(encoding='utf-8'))
 input_ok=all(sha(r/x['snapshot_path'])==x['sha256'] for x in m['inputs']); fixture_ids={x['case_id'] for x in c['fixtures']}; tears={f'F12_tear_{i:02d}' for i in range(30)}
 no_value=True; success_handles=True
 for x in c['fixtures']:
  lines=(r/x['relative_dir']/'debugcon.txt').read_text(encoding='ascii',errors='replace').splitlines(); sel=next(v.split('=',1)[1] for v in lines if v.startswith('SELECT='))
  if sel in ('N','X','G'): no_value &= all(v in lines for v in ['DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','FRESH_RES=-','FRESH_RES_VAL=00'])
  else: success_handles &= all(v in lines for v in ['OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_RES=W'])
 checks={
  'input_manifest_hashes':bool(input_ok),
  'stage1_512':bool((r/'stage1.bin').stat().st_size==512),
  'stage1_55aa':bool((r/'stage1.bin').read_bytes()[510:]==b'\x55\xaa'),
  'stage2_within_8192':bool((r/'stage2.raw.bin').stat().st_size<=8192),
  'fixture_count_41':bool(len(c['fixtures'])==41),
  'all_qemu_terminal_exit33':bool(all(x['qemu']['status']=='COMPLETED' and x['qemu']['exit_code']==33 for x in c['fixtures'])),
  'fresh_disk_per_fixture':bool(len({x['disk_path'] for x in c['fixtures']})==41),
  'no_guest_disk_mutation':bool(all(x['disk_sha256_before']==x['disk_sha256_after'] for x in c['fixtures'])),
  'evaluation_passed':bool(e.get('passed') is True),
  'static_passed':bool(s.get('passed') is True),
  'f03_discriminator':bool(e['checks'].get('f03_naive_discriminator') is True),
  'f06_collision_control':bool(e['checks'].get('f06_additive_sum_collision') is True),
  'f12_full_coverage':bool(tears=={x for x in fixture_ids if x.startswith('F12_')}),
  'failed_closed_no_value':bool(no_value),
  'successful_old_reject_fresh_accept':bool(success_handles),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'check_count':len(checks),'hashes':{'evaluation':sha(r/'evaluation.json'),'static':sha(r/'static_closure.json'),'campaign_receipt':sha(r/'campaign_receipt.json'),'stage2':sha(r/'stage2.raw.bin')}}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
