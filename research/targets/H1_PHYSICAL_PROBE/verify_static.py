from __future__ import annotations
import json,re
from pathlib import Path
H=Path(__file__).resolve().parent

def main():
 s1=(H/'stage1.S').read_text(encoding='utf-8')
 s2=(H/'stage2.S').read_text(encoding='utf-8')
 phys=(H/'build'/'stage2.bin').read_bytes()
 qemu=(H/'build'/'stage2_QEMU_EXIT.bin').read_bytes()
 checks={
  'stage1_only_bios_disk_read_ah02': 'movb $0x02,%ah' in s1 and 'movb $0x03,%ah' not in s1,
  'stage2_int13_only_readonly_08_41': all(fn in {'0x08','0x41'} for fn in re.findall(r'movb \$(0x[0-9a-fA-F]+),%ah\s+int \$0x13',s2)) and len(re.findall(r'int \$0x13',s2))==2,
  'pci_config_address_write_present': 'movw $0xcf8,%dx\n    outl %eax,%dx' in s2,
  'pci_config_data_read_present': 'movw $0xcfc,%dx\n    inl %dx,%eax' in s2,
  'no_pci_config_data_write': not re.search(r'movw \$0xcfc,%dx\s+out',s2),
  'no_pic_command_write': not re.search(r'movw \$(0x20|0x21|0xa0|0xa1),%dx\s+out',s2),
  'physical_binary_has_no_qemu_exit_sequence': bytes.fromhex('baf400b021ee') not in phys,
  'qemu_binary_has_qemu_exit_sequence': bytes.fromhex('baf400b021ee') in qemu,
  'physical_stage2_within_8192': len(phys)<=8192,
  'output_begin_end': 'H1PROBE_BEGIN' in s2 and 'H1PROBE_END' in s2,
  'firmware_markers': 'FW_EBDA=' in s2 and 'FW_RSDP=' in s2,
  'e820_bounded': 'cmpb $32,e820_count' in s2 and 'E820_TRUNCATED' in s2,
  'pci_full_bdf_bounds': 'cmpw $256,pci_bus' in s2 and 'cmpb $32,pci_dev' in s2 and 'cmpb $8,pci_fn' in s2,
 }
 out={'format':'HOSTILE_H1_PHYSICAL_PROBE_STATIC_V1','checks':checks,'pass':all(checks.values()),'physical_stage2_bytes':len(phys),'qemu_stage2_bytes':len(qemu)}
 (H/'build'/'static_verification.json').write_text(json.dumps(out,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(out,indent=2,sort_keys=True)); return 0 if out['pass'] else 1
if __name__=='__main__':raise SystemExit(main())
