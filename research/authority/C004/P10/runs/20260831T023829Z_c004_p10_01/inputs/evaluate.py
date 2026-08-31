from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C004_P10','GOOD_C_RIGHTS=01','BAD_C_RIGHTS=03','GP_SEEN=1','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines();checks={'trace_exact':trace==expected,'boundary_active':('GP_SEEN=1' in trace),'protected_attenuation':('GOOD_C_RIGHTS=01' in trace),'protected_bad_mediator_amplifies':('BAD_C_RIGHTS=03' in trace)};out={'format':'C004_P10_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
