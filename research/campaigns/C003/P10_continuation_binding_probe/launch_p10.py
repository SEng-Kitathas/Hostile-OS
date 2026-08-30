from __future__ import annotations
import datetime as dt, hashlib, json, subprocess, sys
from pathlib import Path
QEMU_TIMEOUT_SECONDS=5
LLVM=Path(r'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin')
CLANG=LLVM/'clang.exe'; LLD=LLVM/'ld.lld.exe'; OBJCOPY=LLVM/'llvm-objcopy.exe'
QEMU=Path(r'C:\Program Files\qemu\qemu-system-i386.exe'); PYTHON=Path(r'C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe')
def now(): return dt.datetime.now(dt.timezone.utc).isoformat()
def sha256(p:Path):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def cap(argv,so,se,timeout=30):
 with so.open('wb') as o,se.open('wb') as e: return subprocess.run(argv,stdout=o,stderr=e,timeout=timeout,check=False).returncode
def main():
 if len(sys.argv)!=2: print('usage: launch_p10.py RUN_ID',file=sys.stderr); return 64
 rid=sys.argv[1]; src=Path(__file__).resolve().parent; repo=src.parents[3]; run=repo/'research'/'campaigns'/'C003'/'runs'/rid
 if run.exists(): print(f'run directory already exists: {run}',file=sys.stderr); return 65
 run.mkdir(parents=True)
 mechanism=src/'mechanism.S'; fixture=src/'fixture.S'; linker=src/'linker.ld'; evaluator=src/'evaluate_p10.py'; launcher=Path(__file__).resolve()
 mo=run/'mechanism.o'; fo=run/'fixture.o'; elf=run/'probe.elf'; probe=run/'probe.bin'
 build=[('01_clang_mechanism',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(mechanism),'-o',str(mo)]),('02_clang_fixture',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(fixture),'-o',str(fo)]),('03_link',[str(LLD),'-m','elf_i386','-T',str(linker),str(mo),str(fo),'-o',str(elf)]),('04_objcopy',[str(OBJCOPY),'-O','binary',str(elf),str(probe)])]
 for name,argv in build:
  rc=cap(argv,run/f'{name}.stdout.txt',run/f'{name}.stderr.txt')
  if rc!=0: print(f'{name} failed exit={rc}',file=sys.stderr); return 2
 boot=probe.read_bytes()
 if len(boot)!=512 or boot[510:512]!=b'\x55\xaa': print(f'boot contract failed bytes={len(boot)}',file=sys.stderr); return 2
 debug=run/'debugcon.txt'; qso=run/'05_qemu.stdout.txt'; qse=run/'05_qemu.stderr.txt'
 qargv=[str(QEMU),'-accel','tcg','-display','none','-monitor','none','-serial','none','-no-reboot','-drive',f'file={probe.as_posix()},format=raw,if=floppy','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 started=now()
 with qso.open('wb') as o,qse.open('wb') as e:
  proc=subprocess.Popen(qargv,stdout=o,stderr=e); pid=proc.pid
  try: qexit=proc.wait(timeout=QEMU_TIMEOUT_SECONDS); qstatus='COMPLETED'
  except subprocess.TimeoutExpired: proc.kill(); proc.wait(timeout=5); qexit=None; qstatus='UNKNOWN_TIMEOUT'
 ended=now(); evaluation=run/'evaluation.json'; eso=run/'06_evaluator.stdout.txt'; ese=run/'06_evaluator.stderr.txt'; eval_exit=None
 if debug.exists(): eval_exit=cap([str(PYTHON),str(evaluator),str(debug),str(evaluation)],eso,ese)
 else: eso.write_bytes(b''); ese.write_text('debugcon missing; evaluator not run\n',encoding='utf-8')
 receipt={'run_id':rid,'run_class':'C003_P10_EXPLICIT_CONTINUATION_BINDING_DISCRIMINATOR','scientific_status':qstatus,'authority_ceiling':'bounded explicit activity continuation identity only','cwd':str(repo),'qemu':{'pid':pid,'argv':qargv,'started_utc':started,'ended_utc':ended,'status':qstatus,'exit_code':qexit,'timeout_seconds':QEMU_TIMEOUT_SECONDS},'tools':{'clang':{'path':str(CLANG),'sha256':sha256(CLANG)},'lld':{'path':str(LLD),'sha256':sha256(LLD)},'objcopy':{'path':str(OBJCOPY),'sha256':sha256(OBJCOPY)},'qemu':{'path':str(QEMU),'sha256':sha256(QEMU)},'python':{'path':str(PYTHON),'sha256':sha256(PYTHON)}},'source_sha256':{'mechanism':sha256(mechanism),'fixture':sha256(fixture),'linker':sha256(linker),'evaluator':sha256(evaluator),'launcher':sha256(launcher)},'artifacts':{'probe_bin':{'path':str(probe),'bytes':len(boot),'sha256':sha256(probe),'boot_signature':'55aa'},'debugcon':{'path':str(debug),'sha256':sha256(debug) if debug.exists() else None},'evaluation':{'path':str(evaluation),'sha256':sha256(evaluation) if evaluation.exists() else None,'evaluator_exit':eval_exit},'qemu_stdout':{'path':str(qso),'sha256':sha256(qso)},'qemu_stderr':{'path':str(qse),'sha256':sha256(qse)},'evaluator_stdout':{'path':str(eso),'sha256':sha256(eso)},'evaluator_stderr':{'path':str(ese),'sha256':sha256(ese)}}}
 rp=run/'receipt.json'; rp.write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
 print('RUN_DIR='+str(run)); print('QEMU_STATUS='+qstatus); print(f'QEMU_PID={pid} EXIT={qexit} START={started} END={ended}'); print('PROBE_SHA256='+sha256(probe));
 if debug.exists(): print('DEBUGCON='+debug.read_text(encoding='ascii').replace('\n',r'\n'))
 print(f'EVALUATOR_EXIT={eval_exit}'); print('RECEIPT_SHA256='+sha256(rp))
 if qstatus=='UNKNOWN_TIMEOUT': return 3
 return 0 if qexit==33 and eval_exit==0 else 1
if __name__=='__main__': raise SystemExit(main())
