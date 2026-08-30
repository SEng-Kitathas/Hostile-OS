from __future__ import annotations
import argparse,json,re
from pathlib import Path
VERSION='D64-WT01-static-v1'
EXPECTED_RECORD='4834463151720202000102000100010234120100020000006c36434d4954'
def main()->int:
 ap=argparse.ArgumentParser();ap.add_argument('writer');ap.add_argument('launcher');ap.add_argument('out');a=ap.parse_args();w=Path(a.writer).read_text(encoding='utf-8');l=Path(a.launcher).read_text(encoding='utf-8')
 byte_tokens=re.search(r'record_b:\.byte ([0-9a-fx,]+)',w)
 embedded=''.join(f'{int(x,16):02x}' for x in byte_tokens.group(1).split(',')) if byte_tokens else ''
 checks={
  'qualified_boot_drive_7c4b':bool('QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b' in w and 'movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al' in w),
  'writer_target_c0_h1_s1':bool('movb $0x00,%ch' in w and 'movb $0x01,%cl' in w and 'movb $0x01,%dh' in w),
  'writer_bios_ah03_one_sector':bool('movb $0x03,%ah' in w and 'movb $0x01,%al' in w),
  'int13_symbol_exact':bool('writer_int13_site:\n int $0x13' in w),
  'embedded_record_exact':bool(embedded==EXPECTED_RECORD),
  'writer_zero_tail':bool('movw $512,%cx' in w and 'rep stosb' in w and 'movw $30,%cx' in w and 'rep movsb' in w),
  'writer_no_other_int13_write':bool(w.count('movb $0x03,%ah')==1),
  'launcher_derives_symbol':bool("'writer_int13_site'" in l and 'llvm-nm' in l and 'int13_addr' in l),
  'launcher_verifies_cd13':bool("b'\\xcd\\x13'" in l or "bytes([0xcd,0x13])" in l),
  'five_calibration_runs':bool('CALIBRATION_COUNT=5' in l),
  'five_repetitions_each':bool('REPETITIONS=5' in l),
  'uses_measured_transition':bool("T=calibration[0]['transition_step']" in l and "T-1" in l),
  'force_kill_only_when_stopped':bool("assert ctx['stopped'] is True" in l and 'def force_terminate' in l and 'p.kill()' in l),
  'overlay_only_code_and_label':bool('recovery[:512]=' in l and 'recovery[512:512+8192]=' in l and 'recovery[19*512:20*512]=' in l),
  'sealed_fr01_reader_snapshotted':bool('fr01_stage1.bin' in l and 'fr01_stage2.padded.bin' in l),
  'snapshots_prereg_and_feasibility':bool('D64_WT01_PREREGISTRATION.md' in l and 'D64_IW00_FEASIBILITY_2026-08-30' in l),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'check_count':len(checks),'embedded_record_hex':embedded};Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result,indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
