from __future__ import annotations
import argparse, hashlib, json, re
from pathlib import Path
VERSION='I001-IRQCOUNT01-static-v1'
def sha(p:Path)->str: return hashlib.sha256(p.read_bytes()).hexdigest()
def body(text:str,label:str,next_label:str)->str:
 m=re.search(rf'(?ms)^{re.escape(label)}:\n(.*?)(?=^{re.escape(next_label)}:)',text)
 return m.group(1) if m else ''
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('stage2'); ap.add_argument('stage1'); ap.add_argument('out'); a=ap.parse_args()
 s=Path(a.stage2).read_text(encoding='utf-8'); st1=Path(a.stage1).read_text(encoding='utf-8')
 irq=body(s,'irq0_handler','print_line'); sem=body(s,'semantic_gate','exact_one_gate'); exact=body(s,'exact_one_gate','apply_continuation'); bad=body(s,'reset_badrel','run_irq_phase'); runp=body(s,'run_irq_phase','semantic_gate')
 checks={
  'real_irq_vector_install':'movw $irq0_handler,0x0020' in s,
  'pit_programmed':'program_pit:' in s and 'movw $0x1000,%ax' in s,
  'handler_increments_event':'incb event_generation' in irq,
  'handler_recomputes_relation':all(x in irq for x in ['cmpb act_wait_gen,%al','cmpb $2,act_cont','cmpb $1,act_waiting','movb $1,irq_rel_ok']),
  'handler_threshold_masks':all(x in irq for x in ['cmpb stop_after,%al','movw $PIC_MASTER_MASK,%dx','movb $0xff,%al','outb %al,%dx']),
  'handler_eoi':'movw $PIC_MASTER_CMD,%dx' in irq and 'movb $0x20,%al' in irq,
  'phase_wait_uses_hlt':'hlt' in runp and 'cmpb stop_after,%al' in runp,
  'semantic_requires_nonzero_event':'cmpb $0,event_generation' in sem,
  'semantic_requires_valid_relation':'cmpb $1,irq_rel_ok' in sem,
  'semantic_does_not_require_exact_one':'cmpb $1,event_generation' not in sem,
  'exact_gate_requires_one':'cmpb $1,event_generation' in exact,
  'badrel_generation_mismatch':'call reset_valid' in bad and 'movb $2,act_wait_gen' in bad,
  'wake_progress_separate':'semantic_gate:' in s and 'apply_continuation:' in s and 'movb $1,act_woken' in sem and 'movb %al,act_progress' in s,
  'stage1_loads_8_sectors':'movb $0x08,%al' in st1,
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'source_sha256':{'stage2':sha(Path(a.stage2)),'stage1':sha(Path(a.stage1))}}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
