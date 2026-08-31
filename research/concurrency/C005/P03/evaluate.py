from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C005_P03','AP_READY=1','BAD_SEEN=7E','BAD_FINAL=55','GOOD_SEEN=55','GOOD_FINAL=55','AP_DONE=1','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines();checks={'trace_exact':trace==expected,'two_cpu_participation':all(x in trace for x in ['AP_READY=1','AP_DONE=1']),'bad_indicator_precedes_payload':'BAD_SEEN=7E' in trace and 'BAD_FINAL=55' in trace,'good_payload_precedes_indicator':'GOOD_SEEN=55' in trace and 'GOOD_FINAL=55' in trace};out={'format':'C005_P03_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
