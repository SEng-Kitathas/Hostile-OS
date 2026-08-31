from __future__ import annotations
import hashlib,json,re
from pathlib import Path
H=Path(__file__).resolve().parent
PARENT=H.parent/'H1_PHYSICAL_PROBE'

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''):h.update(c)
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
 loader=(H/'splash_loader.S').read_text(encoding='utf-8')
 man=json.loads((H/'build'/'build_manifest.json').read_text(encoding='utf-8'))
 phys=(H/'build'/'h1_probe_splash_physical.img').read_bytes(); qemu=(H/'build'/'h1_probe_splash_qemu.img').read_bytes()
 parent_phys=(PARENT/'build'/'stage2.bin').read_bytes(); parent_qemu=(PARENT/'build'/'stage2_QEMU_EXIT.bin').read_bytes()
 probe_off=135*512
 checks={
  'wrapper_stage1_exact_512': man['wrapper_stage1']['bytes']==512,
  'wrapper_stage1_signature': phys[510:512]==b'\x55\xaa',
  'wrapper_stage1_int13_only_ah02': ah_before_int13(s1)==['0x02'],
  'splash_loader_int13_readonly_set': ah_before_int13(loader)==['0x41','0x08','0x42','0x02'],
  'no_disk_write_functions': not re.search(r'movb \$(0x03|0x43|0x05|0x06|0x07),%ah',s1+loader,re.I),
  'loader_within_4096': man['splash_loader']['bytes']<=4096,
  'palette_exact': phys[9*512:9*512+96]==(H/'splash_palette_32xrgb6.bin').read_bytes(),
  'pixels_exact': phys[10*512:135*512]==(H/'splash_pixels_320x200.bin').read_bytes(),
  'physical_probe_stage2_exact': phys[probe_off:probe_off+len(parent_phys)]==parent_phys and sha(PARENT/'build'/'stage2.bin')==man['parent_probe']['physical_stage2_sha256'],
  'qemu_probe_stage2_exact': qemu[probe_off:probe_off+len(parent_qemu)]==parent_qemu and sha(PARENT/'build'/'stage2_QEMU_EXIT.bin')==man['parent_probe']['qemu_stage2_sha256'],
  'wrapper_has_no_qemu_exit_port_source': '$0x00f4' not in s1.lower() and '$0x00f4' not in loader.lower() and '$0xf4' not in s1.lower() and '$0xf4' not in loader.lower(),
  'no_pci_config_ports_in_wrapper': '0xcf8' not in loader.lower() and '0xcfc' not in loader.lower(),
  'no_pic_apic_programming_ports_in_wrapper': all(x not in loader.lower() for x in ['$0x20,%dx','$0x21,%dx','$0xa0,%dx','$0xa1,%dx']),
  'dual_disk_mode_logic_present': '$0x41,%ah' in loader and '$0x42,%ah' in loader and '$0x08,%ah' in loader and '$0x02,%ah' in loader,
  'splash_markers_present': 'H1SPLASH_VISIBLE' in loader and 'H1SPLASH_CHAIN_PROBE' in loader,
 }
 out={'format':'HOSTILE_H1_SPLASH_STATIC_V1','checks':checks,'stage1_int13':ah_before_int13(s1),'loader_int13':ah_before_int13(loader),'pass':all(checks.values())}
 (H/'build'/'static_verification.json').write_text(json.dumps(out,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(out,indent=2,sort_keys=True)); return 0 if out['pass'] else 1
if __name__=='__main__':raise SystemExit(main())
