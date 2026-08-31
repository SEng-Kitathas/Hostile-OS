from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C004_P01','OWNER_CHECKED=W','OWNER_VAL=7E','B_CALLER_AWARE=U','B_CALLER_AWARE_VAL=00','B_CURRENT_ONLY=W','B_CURRENT_ONLY_VAL=7E','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines()
checks={'trace_exact':trace==expected,'owner_succeeds':trace[2:4]==['OWNER_CHECKED=W','OWNER_VAL=7E'] if len(trace)>=4 else False,'b_caller_aware_rejects':('B_CALLER_AWARE=U' in trace and 'B_CALLER_AWARE_VAL=00' in trace),'b_currentness_only_succeeds':('B_CURRENT_ONLY=W' in trace and 'B_CURRENT_ONLY_VAL=7E' in trace)}
out={'format':'C004_P01_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
