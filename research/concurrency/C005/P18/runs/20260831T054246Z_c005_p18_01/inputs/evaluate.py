from pathlib import Path
import json,sys
receipt=json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
checks={
 'boot1_exact':receipt['boot1']['trace']==['S1_8K_OK','TEST=C005_P18','PHASE=WRITE','WRITE=A','DONE'] and receipt['boot1']['exit_code']==33,
 'durable_record_written':receipt['record_after_boot1_hex'].startswith('48354331') and receipt['record_after_boot1_hex'][8:18]=='7e05010101',
 'no_host_write_between_boots':receipt['no_host_write_between_boots'] is True,
 'boot2_exact':receipt['boot2']['trace']==['S1_8K_OK','TEST=C005_P18','PHASE=RECOVER','BAD_HELD=1','BAD_USERS=01','BAD_FRESH_ACQUIRE=0','BAD_PHANTOM_USER=1','GOOD_HELD=0','GOOD_USERS=00','GOOD_EPOCH=02','GOOD_FRESH_ACQUIRE=1','GOOD_VALUE=7E','DONE'] and receipt['boot2']['exit_code']==33,
 'boot2_read_only':receipt['disk_unchanged_boot2'] is True,
}
out={'format':'C005_P18_EVALUATION_V1','passed':all(checks.values()),'checks':checks}
Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
