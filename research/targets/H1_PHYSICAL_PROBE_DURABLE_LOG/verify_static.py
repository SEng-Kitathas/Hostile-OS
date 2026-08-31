from __future__ import annotations
import hashlib,json,re,subprocess,sys
from pathlib import Path
H=Path(__file__).resolve().parent; ROOT=H.parents[2]; PARENT=ROOT/'research'/'targets'/'H1_PHYSICAL_PROBE'
LOG_BASE=256; LOG_SECTORS=128; SECTOR=512

def sha(p:Path)->str:
 h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def ah_before_int13(text:str):
 lines=text.splitlines(); out=[]
 for i,line in enumerate(lines):
  if 'int $0x13' in line:
   fn=None
   for j in range(i-1,max(-1,i-10),-1):
    m=re.search(r'movb \$(0x[0-9a-fA-F]+),%ah',lines[j])
    if m: fn=m.group(1).lower(); break
   out.append(fn)
 return out

def main():
 s1=(H/'wrapper_stage1.S').read_text(encoding='utf-8').replace('\r\n','\n')
 loader=(H/'text_loader.S').read_text(encoding='utf-8').replace('\r\n','\n')
 probe=(H/'stage2.S').read_text(encoding='utf-8').replace('\r\n','\n')
 parent=(PARENT/'stage2.S').read_text(encoding='utf-8').replace('\r\n','\n')
 expected_parent=probe.replace('    call *0x0500\n','',1)
 man=json.loads((H/'build'/'build_manifest.json').read_text(encoding='utf-8'))
 phys=(H/'build'/'h1_probe_durable_log_physical.img').read_bytes(); qemu=(H/'build'/'h1_probe_durable_log_qemu.img').read_bytes()
 a=LOG_BASE*SECTOR; z=(LOG_BASE+LOG_SECTORS)*SECTOR
 loader_calls=ah_before_int13(loader); probe_calls=ah_before_int13(probe); s1_calls=ah_before_int13(s1)
 checks={
  'stage1_exact_512': man['wrapper_stage1']['bytes']==512,
  'stage1_signature': phys[510:512]==b'\x55\xaa',
  'stage1_readonly_ah02': s1_calls==['0x02'],
  'logger_loader_within_4096': man['logger_loader']['bytes']<=4096,
  'probe_physical_within_8192': man['probe_physical']['bytes']<=8192,
  'probe_qemu_within_8192': man['probe_qemu']['bytes']<=8192,
  'probe_derivation_parent_plus_one_hook': expected_parent==parent and probe.count('call *0x0500')==1,
  'probe_only_readonly_int13': all(x in {'0x08','0x41'} for x in probe_calls) and len(probe_calls)==2,
  'loader_write_functions_exact': loader_calls.count('0x43')==1 and loader_calls.count('0x03')==1,
  'loader_no_other_disk_write_functions': not re.search(r'movb \$(0x05|0x06|0x07),%ah',loader,re.I),
  'journal_bounds_constants': '.equ LOG_BASE_LBA,256' in loader and '.equ LOG_SECTORS,128' in loader and 'cmpw $LOG_SECTORS,%ax' in loader and 'addl $LOG_BASE_LBA,%eax' in loader,
  'journal_header_magic': 'movl $0x474c3148,log_buffer' in loader,
  'journal_session_from_bios_ticks': 'movw 0x046c,%ax' in loader,
  'hook_pointer_installed': 'movw $logger_char,LOGGER_HOOK_PTR' in loader and '.equ LOGGER_HOOK_PTR,0x0500' in loader,
  'flush_on_newline': 'cmpb $0x0a,%al' in loader and 'call logger_flush' in loader,
  'physical_journal_initially_zero': phys[a:z]==bytes(z-a),
  'qemu_journal_initially_zero': qemu[a:z]==bytes(z-a),
  'physical_image_size_1440k': len(phys)==1474560,
  'qemu_image_size_1440k': len(qemu)==1474560,
  'no_graphics_mode13': '$0x0013,%ax' not in loader,
  'no_vga_framebuffer_programming': '0xa000' not in loader.lower() and '0x03c8' not in loader.lower(),
  'extractor_self_test': subprocess.run([sys.executable,str(H/'extract_log.py'),'--self-test'],stdout=subprocess.PIPE).returncode==0,
 }
 out={'format':'HOSTILE_H1_DURABLE_LOG_STATIC_V1','checks':checks,'stage1_int13':s1_calls,'loader_int13':loader_calls,'probe_int13':probe_calls,'pass':all(checks.values())}
 (H/'build'/'static_verification.json').write_text(json.dumps(out,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(out,indent=2,sort_keys=True)); return 0 if out['pass'] else 1
if __name__=='__main__': raise SystemExit(main())
