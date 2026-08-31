from __future__ import annotations
from pathlib import Path
import datetime,hashlib,importlib.util,json,os,shutil,subprocess,sys
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]; RUNS=HERE/'runs'; SECTOR=512
S_TRACE=['S1_8K_OK','TEST=H1_SMP_MIN01','BSP_ID=00','AP_ID=01','AP_READY=1','SMP_DONE']
CORE_TRACE=['S1_8K_OK','TEST=D64_V2_CORE','ACT_FILLED=40','ACT_OVER=F','ROW_FILLED=14','ROW_OVER=F','SHARE_LIVE=0002','STALE_BIND=R','FRESH_BIND=W','FRESH_BIND_VAL=7E','MISSING_BIND=M','RELEASE_BOUND=B','DETACH_ONE_LIVE=0001','DETACH_LAST_LIVE=0000','OLD_RES=R','NEW_RES=W','NEW_RES_VAL=55','DONE','TEST=D64_V2_IRQ','IRQ1_EVENT=01','IRQ1_REL=1','IRQ1_WAKE=1','IRQ1_PROG=02','IRQ2_EVENT=02','IRQ2_REL=1','IRQ2_WAKE=1','IRQ2_PROG=02','IRQBAD_EVENT=02','IRQBAD_REL=0','IRQBAD_WAKE=0','IRQBAD_PROG=00','IRQ_DONE']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def tool(env,names):
 v=os.environ.get(env)
 if v:
  p=Path(v); return p if p.is_file() else p/names[0]
 llvm=os.environ.get('HOSTILE_LLVM_BIN')
 if llvm:
  for n in names:
   p=Path(llvm)/n
   if p.is_file(): return p
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 raise SystemExit('missing '+env)
def exe(names,fallback):
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 p=Path(fallback)
 if p.is_file():return p
 raise SystemExit('missing '+names[0])
def qemu_data(q):
 for k in ('HOSTILE_QEMU_DATA_DIR','HOSTILE_QEMU_FIRMWARE'):
  v=os.environ.get(k)
  if v and (Path(v)/'bios-256k.bin').is_file():return Path(v)
 for p in (q.parent/'share/qemu',q.parent/'share',q.parent.parent/'share/qemu',q.parent.parent/'share'):
  if (p/'bios-256k.bin').is_file():return p
 return None
def control(mode):
 b=bytearray(SECTOR);b[:4]=b'V2MD';b[4]=ord(mode);return bytes(b)
def make_image(base,path,mode):
 im=bytearray(base); im[19*SECTOR:20*SECTOR]=control(mode); path.write_bytes(im)
def trace_from(path,marker):
 lines=path.read_text(encoding='ascii',errors='replace').splitlines() if path.exists() else []
 try:i=lines.index('S1_8K_OK')
 except ValueError:return []
 out=[]
 for x in lines[i:]:
  out.append(x)
  if x==marker:break
 return out
def qemu_boot(q,data,disk,dbg,expected,marker,target_disk):
 argv=[str(q)]
 if data:argv+=['-L',str(data)]
 argv+=['-accel','tcg','-machine','pc-q35-11.1','-cpu','phenom','-smp','2,sockets=1,cores=2,threads=1','-m','4096','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={disk.as_posix()},format=raw,if=floppy,readonly=on','-drive',f'file={target_disk.as_posix()},format=qcow2,if=ide,index=0,media=disk','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{dbg.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 cp=subprocess.run(argv,cwd=HERE,capture_output=True,timeout=20); tr=trace_from(dbg,marker)
 return {'passed':cp.returncode==33 and tr==expected,'exit_code':cp.returncode,'trace':tr,'expected':expected,'argv':argv,'stderr':cp.stderr.decode('utf-8',errors='replace')}
def main():
 stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ'); run=RUNS/(stamp+'_h1_smp_min01_01'); inp=run/'inputs'; build=run/'build'; inp.mkdir(parents=True);build.mkdir()
 source_files=['stage1.S','stage1.ld','stage2.S','stage2.ld','launch.py','H1_SMP_MIN01_INTEGRATION_SPEC.md']; manifest=[]
 for n in source_files:
  p=HERE/n; dst=inp/n; shutil.copy2(p,dst); manifest.append({'source':str(p.relative_to(ROOT)).replace('\\','/'),'snapshot':str(dst.relative_to(run)).replace('\\','/'),'bytes':dst.stat().st_size,'sha256':sha(dst)})
 origin=ROOT/'os/research_only/d64_reference_v2/stage2.S'; manifest.append({'source':str(origin.relative_to(ROOT)).replace('\\','/'),'bytes':origin.stat().st_size,'sha256':sha(origin),'role':'parent_body_source'})
 (run/'inputs_manifest.json').write_text(json.dumps({'format':'H1_SMP_MIN01_INPUTS_V1','git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'inputs':manifest},indent=2)+'\n')
 clang=tool('HOSTILE_CLANG',['clang.exe','clang']);lld=tool('HOSTILE_LLD',['ld.lld.exe','ld.lld']);obj=tool('HOSTILE_OBJCOPY',['llvm-objcopy.exe','llvm-objcopy']);nm=tool('HOSTILE_NM',['llvm-nm.exe','llvm-nm'])
 def r(a):subprocess.run([str(x) for x in a],cwd=inp,check=True)
 for n in ('stage1','stage2'):
  r([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c',n+'.S','-o',build/(n+'.o')]); r([lld,'-m','elf_i386','-T',n+'.ld','-Map='+str(build/(n+'.map')),build/(n+'.o'),'-o',build/(n+'.elf')]); r([obj,'-O','binary',build/(n+'.elf'),build/(n+'.raw.bin')])
 s1=(build/'stage1.raw.bin').read_bytes(); raw=(build/'stage2.raw.bin').read_bytes(); assert len(s1)==512 and s1[510:]==b'\x55\xaa'
 nmout=subprocess.check_output([str(nm),'-n',str(build/'stage2.elf')],text=True); syms={}
 for line in nmout.splitlines():
  parts=line.split()
  if len(parts)>=3:
   try:syms[parts[-1]]=int(parts[0],16)
   except ValueError:pass
 image_bytes=syms['__image_end']-syms['__image_start']; state_bytes=syms['v2_state_end']-syms['v2_state_begin']; envelope_ok=image_bytes<=8192 and state_bytes==3467
 padded=raw+bytes(8192-len(raw)); base=bytearray(1474560);base[:512]=s1;base[512:512+8192]=padded;base=bytes(base); (build/'candidate.img').write_bytes(base)
 q=exe(['qemu-system-x86_64','qemu-system-x86_64.exe'],r'C:\Program Files\qemu\qemu-system-x86_64.exe'); qi=exe(['qemu-img','qemu-img.exe'],r'C:\Program Files\qemu\qemu-img.exe'); data=qemu_data(q); target=build/'target_500g.qcow2'; subprocess.run([str(qi),'create','-f','qcow2',str(target),'500G'],check=True,capture_output=True)
 s_disk=build/'s.img';make_image(base,s_disk,'S'); c_disk=build/'c.img';make_image(base,c_disk,'C')
 qs=qemu_boot(q,data,s_disk,run/'qemu_s.txt',S_TRACE,'SMP_DONE',target); qc=qemu_boot(q,data,c_disk,run/'qemu_c.txt',CORE_TRACE,'IRQ_DONE',target)
 spec=importlib.util.spec_from_file_location('h1matrix',ROOT/'tools/run_h1_emulator_matrix.py'); mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod); bochs=mod.find_bochs(); br=mod.run_bochs_all(base,bochs,run/'bochs',20.0)
 checks={'envelope_ok':envelope_ok,'state_bytes_unchanged':state_bytes==3467,'qemu_s_exact':qs['passed'],'qemu_c_exact':qc['passed'],'bochs_core_exact':br['checks']['core_exact'],'bochs_restart_exact':br['checks']['restart_exact_and_invariants'],'bochs_faults_exact':br['checks']['five_fault_cases_exact_and_readonly']}
 receipt={'format':'H1_SMP_MIN01_RUN_V1','status':'COMPLETED','passed':all(checks.values()),'checks':checks,'git_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'stage2_raw_bytes':len(raw),'image_memory_bytes':image_bytes,'state_bytes':state_bytes,'headroom_bytes':8192-image_bytes,'candidate_sha256':sha(build/'candidate.img'),'qemu_s':qs,'qemu_c':qc,'bochs':br};(run/'run_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n'); print(json.dumps({'run':str(run.relative_to(ROOT)).replace('\\','/'),'passed':receipt['passed'],'checks':checks,'stage2_raw_bytes':len(raw),'image_memory_bytes':image_bytes,'headroom_bytes':8192-image_bytes},indent=2));return 0 if receipt['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
