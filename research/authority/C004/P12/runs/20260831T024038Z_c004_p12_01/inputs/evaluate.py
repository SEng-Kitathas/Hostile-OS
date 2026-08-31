from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C004_P12','IO_GP=1','MEDIATED_IO=1','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines();checks={'trace_exact':trace==expected,'direct_ring3_io_faulted':('IO_GP=1' in trace),'no_raw_user_marker':all('X' not in x for x in trace),'trusted_mediated_io_path':('MEDIATED_IO=1' in trace)};out={'format':'C004_P12_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
