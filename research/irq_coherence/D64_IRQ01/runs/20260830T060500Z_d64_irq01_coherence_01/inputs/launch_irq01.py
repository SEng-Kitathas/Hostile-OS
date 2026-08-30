from __future__ import annotations
import datetime as dt, hashlib, json, shutil, subprocess, sys, time
from pathlib import Path
IMAGE_BYTES=1474560
STAGE2_EXTENT=8192
QEMU_TIMEOUT=12
PREREG_COMMIT='0c14b605e6b29c4767d9fbf6a03e5ee1bcd4b36f'
LLVM=Path(r'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin')
CLANG=LLVM/'clang.exe'; LLD=LLVM/'ld.lld.exe'; OBJCOPY=LLVM/'llvm-objcopy.exe'; SIZE=LLVM/'llvm-size.exe'; NM=LLVM/'llvm-nm.exe'
QEMU=Path(r'C:\Program Files\qemu\qemu-system-i386.exe'); PYTHON=Path(r'C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe')
def now(): return dt.datetime.now(dt.timezone.utc).isoformat()
def sha(p:Path): h=hashlib.sha256(); h.update(p.read_bytes()); return h.hexdigest()
def cap(argv,so,se,timeout=30):
 with so.open('wb') as o,se.open('wb') as e: return subprocess.run(argv,stdout=o,stderr=e,timeout=timeout,check=False).returncode
def git_head(repo): return subprocess.run(['git','rev-parse','HEAD'],cwd=repo,capture_output=True,text=True,check=True).stdout.strip()
def region_counts(p:Path,a:str,b:str,write_terms:list[str]):
 t=p.read_text(encoding='utf-8').replace('\r\n','\n').split(a+':\n',1)[1].split('\n'+b+':',1)[0]
 lines=[]
 for raw in t.splitlines():
  s=raw.split('#',1)[0].strip()
  if not s or s.endswith(':') or s.startswith('.'): continue
  lines.append(s)
 return len(lines),sum(1 for s in lines if any(x in s for x in write_terms))
def main():
 if len(sys.argv)!=2: return 64
 rid=sys.argv[1]; src=Path(__file__).resolve().parent; repo=src.parents[3]; run=src.parent/'runs'/rid
 if run.exists(): print('run exists',file=sys.stderr); return 65
 run.mkdir(parents=True); inp=run/'inputs'; inp.mkdir()
 qual=repo/'research/qualifications/D64_STAGE2_8K_LOADER_QUALIFICATION_2026-08-30'
 originals={
  'preregistration':src.parent/'D64_IRQ01_PREREGISTRATION.md',
  'irq_plan':repo/'research/plans/D64_BINDING_RESOURCE_IRQ_COHERENCE_PLAN_2026-08-30.md',
  'p14_result':repo/'research/campaigns/C003/C003_P14_RESULT.md',
  'rb02_result':repo/'research/resource_binding/D64_RB02/D64_RB02_RESULT.md',
  'arb01_result':repo/'research/composition/D64_ARB01/D64_ARB01_RESULT.md',
  'rr01_result':repo/'research/resource_rekey/D64_RR01/D64_RR01_RESULT.md',
  'rr01_adoption':repo/'research/architecture/D64_RR01_RESOURCE_REKEY_ADOPTION_REVIEW_2026-08-30.md',
  'loader_qualification_result':qual/'QUALIFICATION_RESULT.md',
  'stage1_s':qual/'stage1.S','stage1_ld':qual/'stage1.ld',
  'stage2_s':src/'stage2.S','stage2_ld':src/'stage2.ld','launcher':Path(__file__).resolve(),'evaluator':src/'evaluate_irq01.py','static_checker':src/'static_check_irq01.py'}
 names={k:(p.name if k not in ['preregistration','irq_plan','p14_result','rb02_result','arb01_result','rr01_result','rr01_adoption','loader_qualification_result'] else k+'.md') for k,p in originals.items()}
 head=git_head(repo); items=[]; oh={}
 for k,p in originals.items():
  d=inp/names[k]; shutil.copyfile(p,d); oh[k]=sha(p); items.append({'key':k,'source_project_relative':p.relative_to(repo).as_posix(),'snapshot_path':d.relative_to(run).as_posix(),'bytes':d.stat().st_size,'sha256':sha(d)})
 manifest={'run_id':rid,'snapshot_utc':now(),'controlling_git_head':head,'controlling_preregistration_commit':PREREG_COMMIT,'declared_working_directory':str(repo),'launcher_path':str(originals['launcher']),'launcher_sha256':oh['launcher'],'tools':{k:str(v) for k,v in {'clang':CLANG,'lld':LLD,'objcopy':OBJCOPY,'size':SIZE,'nm':NM,'qemu':QEMU,'python':PYTHON}.items()},'inputs':items}
 mp=run/'inputs_manifest.json'; mp.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8'); msha=sha(mp)
 s1s=inp/'stage1.S'; s1ld=inp/'stage1.ld'; s2s=inp/'stage2.S'; s2ld=inp/'stage2.ld'; evaluator=inp/'evaluate_irq01.py'; checker=inp/'static_check_irq01.py'; launcher_snap=inp/'launch_irq01.py'
 s1o=run/'stage1.o'; s1elf=run/'stage1.elf'; s1bin=run/'stage1.bin'; s2o=run/'stage2.o'; s2elf=run/'stage2.elf'; s2raw=run/'stage2.raw.bin'; s2pad=run/'stage2.padded.bin'; disk=run/'disk.img'
 build=[('01_stage1_clang',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(s1s),'-o',str(s1o)]),('02_stage1_link',[str(LLD),'-m','elf_i386','-T',str(s1ld),str(s1o),'-o',str(s1elf)]),('03_stage1_objcopy',[str(OBJCOPY),'-O','binary',str(s1elf),str(s1bin)]),('04_stage2_clang',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(s2s),'-o',str(s2o)]),('05_stage2_link',[str(LLD),'-m','elf_i386','-T',str(s2ld),str(s2o),'-o',str(s2elf)]),('06_stage2_objcopy',[str(OBJCOPY),'-O','binary',str(s2elf),str(s2raw)])]
 for name,argv in build:
  rc=cap(argv,run/f'{name}.stdout.txt',run/f'{name}.stderr.txt')
  if rc:
   (run/'failure.json').write_text(json.dumps({'stage':name,'input_manifest_sha256':msha},indent=2)+'\n'); print(f'{name} failed exit={rc}',file=sys.stderr); return 2
 changed=[k for k,p in originals.items() if sha(p)!=oh[k]]
 if changed:
  (run/'failure.json').write_text(json.dumps({'stage':'INPUT_CHANGED_AFTER_SNAPSHOT','changed':changed,'input_manifest_sha256':msha},indent=2)+'\n'); return 4
 b1=s1bin.read_bytes(); b2=s2raw.read_bytes()
 if len(b1)!=512 or b1[-2:]!=b'\x55\xaa' or len(b2)>STAGE2_EXTENT: print(f'image contract fail s1={len(b1)} s2={len(b2)}',file=sys.stderr); return 2
 s2pad.write_bytes(b2+bytes(STAGE2_EXTENT-len(b2))); img=bytearray(IMAGE_BYTES); img[:512]=b1; img[512:512+STAGE2_EXTENT]=s2pad.read_bytes(); disk.write_bytes(img)
 dbg=run/'debugcon.txt'; qso=run/'07_qemu.stdout.txt'; qse=run/'07_qemu.stderr.txt'; qargv=[str(QEMU),'-accel','tcg','-display','none','-monitor','none','-serial','none','-no-reboot','-boot','a','-drive',f'file={disk.as_posix()},format=raw,if=floppy','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{dbg.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 started=now(); t0=time.perf_counter()
 with qso.open('wb') as o,qse.open('wb') as e:
  proc=subprocess.Popen(qargv,stdout=o,stderr=e); pid=proc.pid
  try: qexit=proc.wait(timeout=QEMU_TIMEOUT); qstatus='COMPLETED'
  except subprocess.TimeoutExpired: proc.kill(); proc.wait(timeout=5); qexit=None; qstatus='UNKNOWN_TIMEOUT'
 wall=(time.perf_counter()-t0)*1000; ended=now()
 evaluation=run/'evaluation.json'; eso=run/'08_evaluator.stdout.txt'; ese=run/'08_evaluator.stderr.txt'; eval_exit=cap([str(PYTHON),str(evaluator),str(dbg),str(evaluation)],eso,ese) if dbg.exists() else None
 size_so=run/'09_size.stdout.txt'; size_se=run/'09_size.stderr.txt'; size_exit=cap([str(SIZE),str(s2elf)],size_so,size_se)
 nm_so=run/'10_nm.stdout.txt'; nm_se=run/'10_nm.stderr.txt'; nm_exit=cap([str(NM),'-n',str(s2elf)],nm_so,nm_se); runtime=None
 if nm_exit==0:
  sy={}
  for line in nm_so.read_text(errors='replace').splitlines():
   q=line.split()
   if len(q)>=3:
    try: sy[q[2]]=int(q[0],16)
    except ValueError: pass
  if 'runtime_state_start' in sy and 'runtime_state_end' in sy: runtime=sy['runtime_state_end']-sy['runtime_state_start']
 bi,bw=region_counts(s2s,'good_bind_region_begin','good_bind_region_end',['resource_generation','resource_identity','resource_value','resource_live_count','binding_generation','binding_resource_plus1'])
 di,dw=region_counts(s2s,'good_detach_region_begin','good_detach_region_end',['binding_resource_plus1','decw resource_live_count','movb $0,resource_identity','movb $0,resource_value'])
 source={i['key']:i['sha256'] for i in items}
 pre={'run_id':rid,'run_class':'D64_IRQ01_BINDING_RESOURCE_IRQ_COHERENCE','scientific_status':qstatus,'authority_ceiling':'one-core QEMU IRQ0 observer over D64 binding/resource transition only','input_manifest_sha256':msha,'controlling_git_head':head,'controlling_preregistration_commit':PREREG_COMMIT,'qemu':{'pid':pid,'argv':qargv,'started_utc':started,'ended_utc':ended,'wall_ms':wall,'status':qstatus,'exit_code':qexit,'timeout_seconds':QEMU_TIMEOUT},'source_sha256':source,'tools':{k:{'path':str(v),'sha256':sha(v)} for k,v in {'clang':CLANG,'lld':LLD,'objcopy':OBJCOPY,'size':SIZE,'nm':NM,'qemu':QEMU,'python':PYTHON}.items()},'artifacts':{'stage1_bin':{'bytes':len(b1),'sha256':sha(s1bin),'boot_signature':'55aa'},'stage2_raw':{'bytes':len(b2),'sha256':sha(s2raw)},'stage2_padded':{'bytes':len(s2pad.read_bytes()),'sha256':sha(s2pad)},'disk':{'bytes':len(img),'sha256':sha(disk)},'debugcon':{'sha256':sha(dbg) if dbg.exists() else None},'evaluation':{'sha256':sha(evaluation) if evaluation.exists() else None,'exit':eval_exit},'size':{'sha256':sha(size_so),'exit':size_exit},'nm':{'sha256':sha(nm_so),'exit':nm_exit}},'pareto':{'stage2_raw_bytes':len(b2),'stage2_extent_bytes':STAGE2_EXTENT,'runtime_state_bytes':runtime,'activity_capacity':64,'binding_cell_count':1280,'resource_capacity':64,'protected_bind_instruction_count':bi,'protected_bind_memory_write_count':bw,'protected_detach_instruction_count':di,'protected_detach_memory_write_count':dw,'pit_divisor':4096}}
 prep=run/'receipt_pre_static.json'; prep.write_text(json.dumps(pre,indent=2)+'\n')
 static=run/'static_closure.json'; sso=run/'11_static.stdout.txt'; sse=run/'11_static.stderr.txt'; static_exit=cap([str(PYTHON),str(checker),str(s2s),str(launcher_snap),str(evaluator),str(mp),str(prep),str(static)],sso,sse)
 rec=json.loads(prep.read_text()); rec['artifacts']['static_closure']={'sha256':sha(static) if static.exists() else None,'exit':static_exit}; rec['artifacts']['receipt_pre_static']={'sha256':sha(prep)}; rp=run/'receipt.json'; rp.write_text(json.dumps(rec,indent=2)+'\n')
 print('RUN_DIR='+str(run)); print(f'QEMU_PID={pid} STATUS={qstatus} EXIT={qexit} WALL_MS={wall:.3f}'); print('TRACE='+repr(dbg.read_text(encoding='ascii').splitlines() if dbg.exists() else [])); print(f'EVALUATOR_EXIT={eval_exit} STATIC_EXIT={static_exit} STAGE2_RAW_BYTES={len(b2)} RUNTIME_STATE_BYTES={runtime} BIND_REGION={bi}/{bw} DETACH_REGION={di}/{dw}'); print('INPUT_MANIFEST_SHA256='+msha); print('RECEIPT_SHA256='+sha(rp))
 return 0 if qstatus=='COMPLETED' and qexit==33 and eval_exit==0 and static_exit==0 and size_exit==0 and nm_exit==0 else 1
if __name__=='__main__': raise SystemExit(main())
