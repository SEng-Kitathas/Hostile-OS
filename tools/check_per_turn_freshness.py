from __future__ import annotations
from pathlib import Path
import hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
MAN=ROOT/'continuity/CURRENT_TURN_FRESHNESS.json'
required_living=[
 'continuity/01_COMMANDERS_INTENT.md','continuity/02_CURRENT_STATE_AND_FRONTIER.md',
 'continuity/10_ENGINEERING_DECISION_LEDGER_2026-08-30.md','continuity/LIVE_SHADOW.md',
 'continuity/DESIGN_THREAD_STREAM.md','handoffs/THIS_CONVERSATION.md',
 'continuity/15_PER_TURN_SEMANTIC_AND_HASH_FRESHNESS_POLICY_2026-08-31.md']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 if not MAN.is_file(): print('FAIL missing freshness manifest'); return 1
 m=json.loads(MAN.read_text(encoding='utf-8'))
 checks={}
 checks['schema']=m.get('schema')=='hostile_os.turn_freshness.v1'
 checks['required_living_present']=all((ROOT/p).is_file() for p in required_living)
 current={}
 for p in sorted((ROOT/'continuity').rglob('*')):
  if p.is_file() and p!=MAN:
   rel=p.relative_to(ROOT).as_posix(); current[rel]={'bytes':p.stat().st_size,'sha256':sha(p)}
 recorded={x['path']:{'bytes':x['bytes'],'sha256':x['sha256']} for x in m.get('continuity_files',[])}
 checks['continuity_tree_exact']=current==recorded
 semantic={x['path']:x.get('status') for x in m.get('living_surfaces',[])}
 checks['living_status_complete']=all(semantic.get(p) in {'updated','verified_unchanged'} for p in required_living)
 checks['decision_delta_present']=isinstance(m.get('decision_deltas'),list)
 checks['research_delta_present']=isinstance(m.get('research_deltas'),list)
 checks['intent_delta_present']=isinstance(m.get('commanders_intent_deltas'),list)
 ok=all(checks.values())
 print(json.dumps({'format':'HOSTILE_OS_TURN_FRESHNESS_CHECK_V1','passed':ok,'checks':checks,'continuity_files':len(current)},indent=2))
 return 0 if ok else 1
if __name__=='__main__': raise SystemExit(main())
