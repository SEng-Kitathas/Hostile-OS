from __future__ import annotations
import hashlib,json,re
from pathlib import Path
H=Path(__file__).resolve().parent
PARENT=H.parent/'H1_PHYSICAL_PROBE'

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''): h.update(c)
 return h.hexdigest()

def ah_before_int13(text:str):
 lines=text.splitlines(); out=[]
 for i,line in enumerate(lines):
  if 'int $0x13' in line:
   fn=None
   for j in range(i-1,max(-1,i-8),-1):
    m=re.search(r'movb \$(0x[0-9a-fA-F]+),%ah',lines[j])
    if m: fn=m.group(1).lower(); break
   out.append(fn)
 return out

def main():
 s1=(H/'wrapper_stage1.S').read_text(encoding='utf-8')
 loader=(H/'text_loader.S').read_text(encoding='utf-8')
 man=json.loads((H/'build'/'build_manifest.json').read_text(encoding='utf-8'))
 phys=(H/'build'/'h1_probe_text_physical.img').read_bytes(); qemu=(H/'build'/'h1_probe_text_qemu.img').read_bytes()
 parent_phys=(PARENT/'build'/'stage2.bin').read_bytes(); parent_qemu=(PARENT/'build'/'stage2_QEMU_EXIT.bin').read_bytes()
 probe_off=9*512
 low=(s1+'\n'+loader).lower()
 checks={
  'wrapper_stage1_exact_512': man['wrapper_stage1']['bytes']==512,
  'wrapper_stage1_signature': phys[510:512]==b'\x55\xaa',
  'wrapper_stage1_int13_only_ah02': ah_before_int13(s1)==['0x02'],
  'text_loader_int13_readonly_set': ah_before_int13(loader)==['0x41','0x08','0x42','0x02'],
  'no_disk_write_functions': not re.search(r'movb \$(0x03|0x43|0x05|0x06|0x07),%ah',s1+loader,re.I),
  'loader_within_4096': man['text_loader']['bytes']<=4096,
  'physical_probe_stage2_exact': phys[probe_off:probe_off+len(parent_phys)]==parent_phys and sha(PARENT/'build'/'stage2.bin')==man['parent_probe']['physical_stage2_sha256'],
  'qemu_probe_stage2_exact': qemu[probe_off:probe_off+len(parent_qemu)]==parent_qemu and sha(PARENT/'build'/'stage2_QEMU_EXIT.bin')==man['parent_probe']['qemu_stage2_sha256'],
  'no_explicit_video_mode_set': '$0x0013,%ax' not in low and '$0x0003,%ax' not in low,
  'no_vga_dac_ports': '0x03c8' not in low and '0x03c9' not in low,
  'no_framebuffer_segment': '$0xa000' not in low,
  'bios_teletype_only_video_call': 'movb $0x0e,%ah' in low and 'int $0x10' in low,
  'dual_disk_mode_logic_present': '$0x41,%ah' in loader and '$0x42,%ah' in loader and '$0x08,%ah' in loader and '$0x02,%ah' in loader,
  'required_text_markers_present': 'H1TEXT_WRAPPER_OK' in loader and 'H1TEXT_CHAIN_PROBE' in loader,
  'physical_image_1440k': len(phys)==1474560,
 }
 out={'format':'HOSTILE_H1_TEXT_WRAPPER_STATIC_V1','checks':checks,'stage1_int13':ah_before_int13(s1),'loader_int13':ah_before_int13(loader),'pass':all(checks.values())}
 (H/'build'/'static_verification.json').write_text(json.dumps(out,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(out,indent=2,sort_keys=True)); return 0 if out['pass'] else 1
if __name__=='__main__': raise SystemExit(main())
