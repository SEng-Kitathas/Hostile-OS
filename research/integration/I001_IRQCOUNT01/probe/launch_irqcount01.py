from __future__ import annotations
import hashlib, json, os, shutil, subprocess, sys, time
from datetime import datetime, timezone
from pathlib import Path
VERSION='I001-IRQCOUNT01-launcher-v2'
INPUTS=['stage1.S','stage1.ld','stage2.S','stage2.ld','evaluate_irqcount01.py','static_check_irqcount01.py','audit_irqcount01.py']
def sha(p:Path)->str:
 h=hashlib.sha256();
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''): h.update(c)
 return h.hexdigest()
def utc()->str: return datetime.now(timezone.utc).isoformat()
def find(env,names,llvm=None,common=None):
 if os.environ.get(env):
  p=Path(os.environ[env]);
  if p.is_file(): return p.resolve()
  raise SystemExit(f'{env} missing: {p}')
 if llvm:
  for n in names:
   p=llvm/n
   if p.is_file(): return p.resolve()
 for n in names:
  f=shutil.which(n)
  if f: return Path(f).resolve()
 if common and common.is_file(): return common.resolve()
 raise SystemExit(f'missing {env}: {names}')
def version(p:Path):
 cp=subprocess.run([str(p),'--version'],text=True,capture_output=True,timeout=10,check=False); lines=(cp.stdout+cp.stderr).splitlines(); return lines[0] if lines else '<none>'
def cmd(argv,cwd,stdout,stderr):
 cp=subprocess.run(argv,cwd=cwd,text=True,capture_output=True,check=False); Path(stdout).write_text(cp.stdout,encoding='utf-8',newline='\n'); Path(stderr).write_text(cp.stderr,encoding='utf-8',newline='\n'); return cp.returncode
def main()->int:
 here=Path(__file__).resolve().parent; repo=here.parents[3]; parent=here.parent
 run_id=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'_i001_irqcount01_01'; run=parent/'runs'/run_id; inp=run/'inputs'; inp.mkdir(parents=True)
 records=[]
 for name in INPUTS:
  src=here/name; dst=inp/name; shutil.copy2(src,dst); records.append({'key':name,'source_project_relative':src.relative_to(repo).as_posix(),'snapshot_path':'inputs/'+name,'sha256':sha(dst),'bytes':dst.stat().st_size})
 prereg=parent/'I001_IRQCOUNT01_PREREGISTRATION.md'; dst=inp/prereg.name; shutil.copy2(prereg,dst); records.append({'key':'preregistration','source_project_relative':prereg.relative_to(repo).as_posix(),'snapshot_path':'inputs/'+prereg.name,'sha256':sha(dst),'bytes':dst.stat().st_size})
 amendment=parent/'I001_IRQCOUNT01_PREREGISTRATION_AMENDMENT_A.md'
 if amendment.exists():
  adst=inp/amendment.name; shutil.copy2(amendment,adst); records.append({'key':'preregistration_amendment_a','source_project_relative':amendment.relative_to(repo).as_posix(),'snapshot_path':'inputs/'+amendment.name,'sha256':sha(adst),'bytes':adst.stat().st_size})
 manifest={'format':'I001_IRQCOUNT01_INPUTS_V2','created_utc':utc(),'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'inputs':records}
 (run/'inputs_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
 llvm_env=os.environ.get('HOSTILE_LLVM_BIN'); llvm=Path(llvm_env).resolve() if llvm_env else None
 clang=find('HOSTILE_CLANG',['clang','clang.exe'],llvm); lld=find('HOSTILE_LLD',['ld.lld','ld.lld.exe'],llvm); obj=find('HOSTILE_OBJCOPY',['llvm-objcopy','llvm-objcopy.exe'],llvm); qemu=find('HOSTILE_QEMU',['qemu-system-i386','qemu-system-i386.exe'],common=Path(r'C:\Program Files\qemu\qemu-system-i386.exe'))
 steps=[
  ([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'stage1.S'),'-o',str(run/'stage1.o')],'01_stage1_compile'),
  ([str(lld),'-m','elf_i386','-T',str(inp/'stage1.ld'),str(run/'stage1.o'),'-o',str(run/'stage1.elf')],'02_stage1_link'),
  ([str(obj),'-O','binary',str(run/'stage1.elf'),str(run/'stage1.bin')],'03_stage1_objcopy'),
  ([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'stage2.S'),'-o',str(run/'stage2.o')],'04_stage2_compile'),
  ([str(lld),'-m','elf_i386','-T',str(inp/'stage2.ld'),str(run/'stage2.o'),'-o',str(run/'stage2.elf')],'05_stage2_link'),
  ([str(obj),'-O','binary',str(run/'stage2.elf'),str(run/'stage2.raw.bin')],'06_stage2_objcopy')]
 step_rc={}
 for argv,label in steps:
  rc=cmd(argv,repo,run/(label+'.stdout.txt'),run/(label+'.stderr.txt')); step_rc[label]=rc
  if rc: print(json.dumps({'run_dir':run.as_posix(),'failed_step':label,'return_code':rc})); return rc
 s1=(run/'stage1.bin').read_bytes(); s2=(run/'stage2.raw.bin').read_bytes()
 if len(s1)!=512 or s1[510:]!=b'\x55\xaa' or len(s2)>4096: raise SystemExit('binary envelope failure')
 padded=s2+bytes(4096-len(s2)); (run/'stage2.padded.bin').write_bytes(padded); image=bytearray(1474560); image[:512]=s1; image[512:512+4096]=padded; (run/'irqcount01.img').write_bytes(image)
 debug=run/'debugcon.txt'; debug.unlink(missing_ok=True)
 qargv=[str(qemu),'-accel','tcg','-display','none','-monitor','none','-serial','none','-no-reboot','-boot','a','-drive',f'file={(run/"irqcount01.img").as_posix()},format=raw,if=floppy','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 started=utc(); t0=time.perf_counter(); p=subprocess.Popen(qargv,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 try:
  _,err=p.communicate(timeout=10); qstatus='COMPLETED'; qexit=p.returncode
 except subprocess.TimeoutExpired:
  p.kill(); _,err=p.communicate(); qstatus='UNKNOWN_TIMEOUT'; qexit=None
 (run/'07_qemu.stderr.txt').write_text(err.decode('utf-8',errors='replace') if err else '',encoding='utf-8',newline='\n')
 qrec={'pid':p.pid,'status':qstatus,'exit_code':qexit,'started_utc':started,'ended_utc':utc(),'wall_ms':(time.perf_counter()-t0)*1000,'argv':qargv}
 evrc=cmd([sys.executable,str(inp/'evaluate_irqcount01.py'),str(debug),str(run/'evaluation.json')],repo,run/'08_evaluator.stdout.txt',run/'08_evaluator.stderr.txt')
 strc=cmd([sys.executable,str(inp/'static_check_irqcount01.py'),str(inp/'stage2.S'),str(inp/'stage1.S'),str(run/'static_closure.json')],repo,run/'09_static.stdout.txt',run/'09_static.stderr.txt')
 original_unchanged=all(sha(repo/r['source_project_relative'])==r['sha256'] for r in records)
 preliminary={'version':VERSION,'run_id':run_id,'git_head':manifest['git_head'],'qemu':qrec,'build_return_codes':step_rc,'evaluator_exit':evrc,'static_exit':strc,'original_inputs_unchanged':original_unchanged,'input_manifest_sha256':sha(run/'inputs_manifest.json'),'tools':{k:{'path':str(v),'version':version(v),'sha256':sha(v)} for k,v in [('clang',clang),('lld',lld),('objcopy',obj),('qemu',qemu),('python',Path(sys.executable))]},'artifacts':{n:{'bytes':(run/n).stat().st_size,'sha256':sha(run/n)} for n in ['stage1.bin','stage2.raw.bin','stage2.padded.bin','irqcount01.img','debugcon.txt']}}
 (run/'receipt_pre_audit.json').write_text(json.dumps(preliminary,indent=2)+'\n',encoding='utf-8',newline='\n')
 audrc=cmd([sys.executable,str(inp/'audit_irqcount01.py'),str(run),str(run/'independent_audit.json')],repo,run/'10_audit.stdout.txt',run/'10_audit.stderr.txt')
 audit=json.loads((run/'independent_audit.json').read_text(encoding='utf-8')) if (run/'independent_audit.json').exists() else {'passed':False}
 all_pass=qstatus=='COMPLETED' and qexit==33 and evrc==0 and strc==0 and audrc==0 and audit.get('passed') is True and original_unchanged
 receipt=preliminary|{'audit_exit':audrc,'audit_passed':audit.get('passed') is True,'all_pass':all_pass,'evaluation_sha256':sha(run/'evaluation.json'),'static_sha256':sha(run/'static_closure.json'),'audit_sha256':sha(run/'independent_audit.json')}
 (run/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps({'run_dir':run.relative_to(repo).as_posix(),'qemu':qrec,'evaluator_exit':evrc,'static_exit':strc,'audit_exit':audrc,'all_pass':all_pass,'stage2_bytes':len(s2),'trace':debug.read_text(encoding='ascii',errors='replace').splitlines()},indent=2)); return 0 if all_pass else 1
if __name__=='__main__': raise SystemExit(main())
