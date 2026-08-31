from pathlib import Path
import os,shutil,subprocess,hashlib,json,datetime
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];RUNS=HERE/'runs'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def tool(env,names):
 v=os.environ.get(env)
 if v:
  p=Path(v);return p if p.is_file() else p/names[0]
 llvm=os.environ.get('HOSTILE_LLVM_BIN')
 if llvm:
  for n in names:
   p=Path(llvm)/n
   if p.is_file():return p
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 raise SystemExit('missing '+env)
def qemu():
 v=os.environ.get('HOSTILE_QEMU')
 if v and Path(v).is_file():return Path(v)
 q=shutil.which('qemu-system-i386') or shutil.which('qemu-system-i386.exe')
 if q:return Path(q)
 p=Path(r'C:\Program Files\qemu\qemu-system-i386.exe')
 if p.is_file():return p
 raise SystemExit('missing qemu')
def data_dir(q):
 for k in ('HOSTILE_QEMU_DATA_DIR','HOSTILE_QEMU_FIRMWARE'):
  v=os.environ.get(k)
  if v and (Path(v)/'bios-256k.bin').is_file():return Path(v)
 for p in (q.parent/'share/qemu',q.parent/'share',q.parent.parent/'share/qemu'):
  if (p/'bios-256k.bin').is_file():return p
 return None
def main():
 stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ');run=RUNS/(stamp+'_c005_p14_01');inp=run/'inputs';build=run/'build';inp.mkdir(parents=True);build.mkdir()
 inputs=[HERE/'stage1.S',HERE/'stage1.ld',HERE/'stage2.S',HERE/'stage2.ld',HERE/'launch.py',HERE/'evaluate.py',HERE.parent/'P14_PREREGISTRATION.md',HERE.parent/'C005_CAMPAIGN_CHARTER_2026-08-31.md'];rec=[]
 for p in inputs:
  dst=inp/p.name;shutil.copy2(p,dst);rec.append({'source':str(p.relative_to(ROOT)).replace('\\','/'),'snapshot_path':str(dst.relative_to(run)).replace('\\','/'),'bytes':dst.stat().st_size,'sha256':sha(dst)})
 (run/'inputs_manifest.json').write_text(json.dumps({'format':'C005_P14_INPUTS_V1','git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'inputs':rec},indent=2)+'\n',encoding='utf-8',newline='\n')
 clang=tool('HOSTILE_CLANG',['clang.exe','clang']);lld=tool('HOSTILE_LLD',['ld.lld.exe','ld.lld']);obj=tool('HOSTILE_OBJCOPY',['llvm-objcopy.exe','llvm-objcopy'])
 def r(a):subprocess.run([str(x) for x in a],cwd=HERE,check=True)
 for n in ('stage1','stage2'):
  r([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c',inp/(n+'.S'),'-o',build/(n+'.o')]);r([lld,'-m','elf_i386','-T',inp/(n+'.ld'),build/(n+'.o'),'-o',build/(n+'.elf')]);r([obj,'-O','binary',build/(n+'.elf'),build/(n+'.bin')])
 s1=(build/'stage1.bin').read_bytes();s2=(build/'stage2.bin').read_bytes();assert len(s1)==512 and s1[510:]==b'\x55\xaa' and len(s2)<=8192
 disk=bytearray(1474560);disk[:512]=s1;disk[512:512+len(s2)]=s2;(build/'disk.img').write_bytes(disk)
 q=qemu();dd=data_dir(q);dbg=run/'debugcon.txt';argv=[str(q),'-accel','tcg','-smp','2','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={(build/"disk.img").as_posix()},format=raw,if=floppy,readonly=on','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{dbg.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 if dd:argv[1:1]=['-L',str(dd)]
 try:
  cp=subprocess.run(argv,cwd=HERE,capture_output=True,timeout=15);status='COMPLETED';code=cp.returncode;err=cp.stderr
 except subprocess.TimeoutExpired as e:
  status='UNKNOWN_TIMEOUT';code=None;err=e.stderr or b''
 trace=dbg.read_text(encoding='ascii',errors='replace').splitlines() if dbg.exists() else []
 receipt={'format':'C005_P14_RUN_V1','status':status,'exit_code':code,'argv':argv,'qemu_data_dir':str(dd) if dd else None,'stage1_bytes':len(s1),'stage2_bytes':len(s2),'stage1_sha256':sha(build/'stage1.bin'),'stage2_sha256':sha(build/'stage2.bin'),'trace':trace,'stderr':err.decode('utf-8',errors='replace') if isinstance(err,bytes) else str(err or '')};(run/'run_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
 if status!='COMPLETED':print(json.dumps(receipt,indent=2));print(run);return 2
 subprocess.run(['python',str(inp/'evaluate.py'),str(dbg),str(run/'evaluation.json')],cwd=HERE,check=True);print(run);return 0
if __name__=='__main__':raise SystemExit(main())
