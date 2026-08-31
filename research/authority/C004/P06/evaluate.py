from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C004_P06','B_CHECKED_WRITE=U','B_CHECKED_AFTER=7E','B_RAW_AFTER=55','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines();checks={'trace_exact':trace==expected,'checked_path_denies':all(x in trace for x in ['B_CHECKED_WRITE=U','B_CHECKED_AFTER=7E']),'raw_same_domain_bypasses':('B_RAW_AFTER=55' in trace)};out={'format':'C004_P06_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
