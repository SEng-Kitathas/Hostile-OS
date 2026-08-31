from pathlib import Path
import json,sys
expected=['S1_8K_OK','TEST=C004_P07','GP_SEEN=1','RESOURCE_AFTER=7E','MEDIATED_GATE=1','DONE']
trace=Path(sys.argv[1]).read_text(encoding='ascii',errors='replace').splitlines();checks={'trace_exact':trace==expected,'gp_enforcement_observed':('GP_SEEN=1' in trace),'kernel_resource_preserved':('RESOURCE_AFTER=7E' in trace),'explicit_mediated_gate_reached':('MEDIATED_GATE=1' in trace)};out={'format':'C004_P07_EVALUATION_V1','passed':all(checks.values()),'checks':checks,'trace':trace};Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(out,indent=2));raise SystemExit(0 if out['passed'] else 1)
