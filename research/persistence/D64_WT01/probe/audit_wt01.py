from __future__ import annotations
import argparse,hashlib,json
from pathlib import Path
VERSION='D64-WT01-independent-audit-v1'
def sha(p):
 h=hashlib.sha256();
 with Path(p).open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def main()->int:
 ap=argparse.ArgumentParser();ap.add_argument('run_dir');ap.add_argument('out');a=ap.parse_args();r=Path(a.run_dir);m=json.loads((r/'inputs_manifest.json').read_text());c=json.loads((r/'campaign_receipt.json').read_text());e=json.loads((r/'evaluation.json').read_text());s=json.loads((r/'static_closure.json').read_text())
 input_ok=all(sha(r/x['snapshot_path'])==x['sha256'] for x in m['inputs']); cal=c['calibration']; terms=c['terminations']; T=c.get('transition_step'); no_other=all(x.get('b_class') in ('ZERO','FULL') for x in terms); overlay=all(x.get('overlay_a_preserved') and x.get('overlay_b_preserved') for x in terms); proc=all(x['recovery']['status']=='COMPLETED' and x['recovery']['exit_code']==33 and ((x['class']=='CLEAN' and x['writer']['status']=='COMPLETED' and x['writer']['exit_code']==33) or (x['class']!='CLEAN' and x['writer']['status']=='FORCED_TERMINATED' and x['writer']['terminal_verified'])) for x in terms)
 # verify sealed reader hashes captured in manifest against controlling FR01 known hashes from campaign receipt metadata
 checks={
  'input_manifest_hashes':bool(input_ok),
  'writer_stage1_512_55aa':bool((r/'writer_stage1.bin').stat().st_size==512 and (r/'writer_stage1.bin').read_bytes()[510:]==b'\x55\xaa'),
  'writer_stage2_within_8192':bool((r/'writer_stage2.raw.bin').stat().st_size<=8192),
  'calibration_5_same_t':bool(len(cal)==5 and len({x['transition_step'] for x in cal})==1 and T==cal[0]['transition_step']),
  'calibration_full_only':bool(all(x['first_change_class']=='FULL' and x['prior_states_all_zero'] for x in cal)),
  'termination_population_20':bool(len(terms)==20),
  'recovery_population_20':bool(c.get('recovery_process_count')==20),
  'all_process_statuses':bool(proc),
  'no_other_b_state':bool(no_other),
  'overlay_preserves_a_b':bool(overlay),
  'sealed_fr01_reader_hashes':bool(c['fr01_reader']['stage1_sha256']==sha(r/'inputs/fr01_stage1.bin') and c['fr01_reader']['stage2_padded_sha256']==sha(r/'inputs/fr01_stage2.padded.bin')),
  'evaluation_passed':bool(e.get('passed') is True),
  'static_passed':bool(s.get('passed') is True),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'check_count':len(checks),'transition_step':T};Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result,indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
