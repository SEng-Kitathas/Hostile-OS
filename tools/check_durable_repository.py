from __future__ import annotations
import subprocess, sys
from pathlib import Path

REQUIRED=[
 'os/research_only/i001_reference/README.md',
 'continuity/LIVE_SHADOW.md',
 'continuity/DESIGN_THREAD_STREAM.md',
 'handoffs/THIS_CONVERSATION.md',
 'handoffs/CURRENT_REINCARNATION/MANIFEST_SHA256.json',
 'authority/archives/RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29.zip',
 'PROJECT_TREE.md',
 '.gitattributes',
]

def main()->int:
 root=Path(__file__).resolve().parents[1]; failures=[]
 for rel in REQUIRED:
  if not (root/rel).exists(): failures.append('missing '+rel)
 cp=subprocess.run(['git','status','--porcelain','--untracked-files=all'],cwd=root,text=True,capture_output=True)
 dirty=[]
 for line in cp.stdout.splitlines():
  path=line[3:].replace('\\','/') if len(line)>=4 else line
  # Mutable research-only build products and PCMMAD execution scratch are allowed locally but not unique durable evidence.
  if path.startswith('.pcmmad_sync_runs/') or '/build/' in path or path.startswith('os/research_only/') and '/build/' in path:
   continue
  dirty.append(line)
 if dirty: failures.append('uncommitted/untracked canonical-tree paths:\n'+'\n'.join(dirty))
 if failures:
  print('DURABLE_REPOSITORY_GATE=FAIL')
  print('\n'.join(failures)); return 1
 print('DURABLE_REPOSITORY_GATE=PASS'); return 0

if __name__=='__main__': raise SystemExit(main())
