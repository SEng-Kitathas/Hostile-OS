from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
VERSION='I001-IRQCOUNT01-independent-audit-v1'
def sha(p:Path)->str:
 h=hashlib.sha256();
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''): h.update(c)
 return h.hexdigest()
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('run_dir'); ap.add_argument('out'); a=ap.parse_args(); r=Path(a.run_dir)
 ev=json.loads((r/'evaluation.json').read_text(encoding='utf-8')); st=json.loads((r/'static_closure.json').read_text(encoding='utf-8')); im=json.loads((r/'inputs_manifest.json').read_text(encoding='utf-8'))
 trace=(r/'debugcon.txt').read_text(encoding='ascii',errors='replace').splitlines(); stage1=r/'stage1.bin'; stage2=r/'stage2.raw.bin'; image=r/'irqcount01.img'
 input_ok=all(sha(r/item['snapshot_path'])==item['sha256'] for item in im['inputs'])
 checks={
  'evaluation_passed':ev.get('passed') is True,
  'static_passed':st.get('passed') is True,
  'input_snapshots_match_manifest':input_ok,
  'stage1_512':stage1.stat().st_size==512,
  'stage1_55aa':stage1.read_bytes()[510:]==b'\x55\xaa',
  'stage2_within_4096':stage2.stat().st_size<=4096,
  'image_1440k':image.stat().st_size==1474560,
  'trace_has_one_and_multi':all(x in trace for x in ['ONE_EVENT=1','MULTI_EVENT=2']),
  'trace_has_negative_control':all(x in trace for x in ['BADREL_EVENT=2','BADREL_REL=0','BADREL_SEM=R']),
  'same_progress_one_multi':all(x in trace for x in ['ONE_PROG=2','MULTI_PROG=2']),
  'exact_control_rejects_multi':all(x in trace for x in ['ONE_EXACT=W','MULTI_EXACT=R']),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'hashes':{'trace':sha(r/'debugcon.txt'),'stage1':sha(stage1),'stage2':sha(stage2),'image':sha(image)}}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
