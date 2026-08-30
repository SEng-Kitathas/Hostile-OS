from __future__ import annotations
import argparse, json, re
from pathlib import Path
VERSION='D64-FR01-static-v1'
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('stage1'); ap.add_argument('stage2'); ap.add_argument('launcher'); ap.add_argument('out'); a=ap.parse_args()
 s1=Path(a.stage1).read_text(encoding='utf-8',errors='replace'); s2=Path(a.stage2).read_text(encoding='utf-8',errors='replace'); l=Path(a.launcher).read_text(encoding='utf-8',errors='replace')
 # label isolation: inspect only the dedicated functions and CASE print reference.
 refs=[line.strip() for line in s2.splitlines() if 'BUF_CASE' in line]
 checks={
  'stage1_loads_16_stage2_sectors':bool('movb $0x10,%al' in s1 and 'movb $0x02,%cl' in s1),
  'qualified_stage1_boot_drive_handoff':bool('.equ QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b' in s2 and 'movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al' in s2 and 'movb %al,boot_drive' in s2 and 'movb boot_drive,%dl' in s2),
  'stage2_reads_lba17_18_19_via_correct_chs':bool(all(x in s2 for x in ['movb $0,%dh\n movb $18,%cl','movb $1,%dh\n movb $1,%cl','movb $1,%dh\n movb $2,%cl'])),
  'separate_record_buffers':bool(all(x in s2 for x in ['.equ BUF_A,0x7000','.equ BUF_B,0x7200'])),
  'validator_checks_magic_marker_version_reserved_commit_crc':bool(all(x in s2 for x in ['$0x3448','$0x3146','$0x1234','cmpb $1,18(%si)','cmpb $0,19(%si)','$0x4d43','$0x5449','call crc16_payload'])),
  'crc16_poly_init_24':bool('movw $0xffff,%dx' in s2 and 'movw $24,%cx' in s2 and 'xorw $0x1021,%dx' in s2),
  'checked_selector_validity_before_sequence':bool(s2.index("cmpb $1,a_valid") < s2.index('movw 22(%si),%ax')),
  'equal_identical_selects_a':bool('repe cmpsb' in s2 and 'jmp checked_choose_a' in s2),
  'equal_conflict_ambiguous_x':bool("movb $'X',selected_kind" in s2),
  'neither_valid_n':bool("movb $'N',selected_kind" in s2),
  'epoch255_g_before_reconstruction':bool('cmpb $255,6(%si)' in s2 and 'cmpb $255,7(%si)' in s2 and "movb $'G',selected_kind" in s2),
  'naive_selector_separate':bool('naive_select:' in s2 and 'call naive_select' in s2 and 'naive_kind' in s2),
  'full_d64_runtime_arrays_present':bool(all(x in s2 for x in ['ACTIVITY_CAP,64','BINDINGS_PER_ACTIVITY,20','BINDING_CELL_COUNT,1280','RESOURCE_CAP,64','.space BINDING_CELL_COUNT,0','.space RESOURCE_CAP*2,0'])),
  'runtime_zeroed_before_reconstruction':bool('call init_runtime' in s2 and 'rep stosb' in s2),
  'historical_handles_checked_before_fresh':bool(s2.index('movb 8(%si),%bl') < s2.index('# fresh binding handle uses current epochs/gen1.')),
  'fresh_relation_explicit':bool(all(x in s2 for x in ['movb $0x41,act_identity','movb $1,binding_resource_plus1','movb $1,resource_generation','movw $1,resource_live_count'])),
  'durable_records_not_runtime_array_serialization':bool('int $0x13' in s2 and 'movb $0x03,%ah' not in s2),
  'fixture_label_references_isolated':bool(len(refs)==4 and all(('movw $BUF_CASE,%bx' in r or 'movw $BUF_CASE,%si' in r or 'movw $(BUF_CASE+4),%si' in r or '.equ BUF_CASE' in r) for r in refs)),
  'launcher_has_30_tear_cases':bool('range(30)' in l),
  'launcher_fixtures_before_qemu':bool('build_fixtures' in l and l.index('build_fixtures') < l.index('subprocess.Popen')),
  'launcher_snapshots_amendment':bool('D64_FR01_PREREGISTRATION_AMENDMENT_A.md' in l),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'check_count':len(checks)}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
