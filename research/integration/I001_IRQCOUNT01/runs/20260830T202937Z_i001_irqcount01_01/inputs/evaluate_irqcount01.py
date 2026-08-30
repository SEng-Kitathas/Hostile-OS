from __future__ import annotations
import argparse, json
from pathlib import Path
VERSION='I001-IRQCOUNT01-evaluator-v1'
EXPECTED=[
'S1_OK','TEST=I001_IRQCOUNT01_1',
'ONE_EVENT=1','ONE_REL=1','ONE_SEM=W','ONE_WAKE=1','ONE_PREPROG=0','ONE_PROG=2','ONE_EXACT=W',
'MULTI_EVENT=2','MULTI_REL=1','MULTI_SEM=W','MULTI_WAKE=1','MULTI_PREPROG=0','MULTI_PROG=2','MULTI_EXACT=R',
'BADREL_EVENT=2','BADREL_REL=0','BADREL_SEM=R','BADREL_WAKE=0','BADREL_PROG=0','DONE']
def main()->int:
 ap=argparse.ArgumentParser(); ap.add_argument('trace'); ap.add_argument('out'); a=ap.parse_args()
 lines=Path(a.trace).read_text(encoding='ascii',errors='replace').splitlines()
 checks={
  'exact_trace':lines==EXPECTED,
  'one_semantic_accept':all(x in lines for x in ['ONE_EVENT=1','ONE_REL=1','ONE_SEM=W','ONE_WAKE=1','ONE_PREPROG=0','ONE_PROG=2']),
  'multi_same_semantic_consequence':all(x in lines for x in ['MULTI_EVENT=2','MULTI_REL=1','MULTI_SEM=W','MULTI_WAKE=1','MULTI_PREPROG=0','MULTI_PROG=2']),
  'exact_count_control_discriminates':all(x in lines for x in ['ONE_EXACT=W','MULTI_EXACT=R']),
  'bad_relation_rejects':all(x in lines for x in ['BADREL_EVENT=2','BADREL_REL=0','BADREL_SEM=R','BADREL_WAKE=0','BADREL_PROG=0']),
 }
 result={'version':VERSION,'passed':all(checks.values()),'checks':checks,'observed_lines':lines,'expected_lines':EXPECTED}
 Path(a.out).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(result,indent=2)); return 0 if result['passed'] else 1
if __name__=='__main__': raise SystemExit(main())
