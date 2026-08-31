from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C005_P01','CPU_COUNT=02','AP_READY=1','BAD_MIXED=1','BAD_FINAL=1','GOOD_MIXED=0','GOOD_FINAL=1','AP_DONE=1','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines()
checks={
 'trace_exact':trace==expected,
 'two_cpu_participation':all(x in trace for x in ['CPU_COUNT=02','AP_READY=1','AP_DONE=1']),
 'cli_only_allows_mixed_observation':'BAD_MIXED=1' in trace and 'BAD_FINAL=1' in trace,
 'atomic_shared_exclusion_prevents_mixed':'GOOD_MIXED=0' in trace and 'GOOD_FINAL=1' in trace,
}
out={'format':'C005_P01_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace}
Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
