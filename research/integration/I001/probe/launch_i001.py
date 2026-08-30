from __future__ import annotations
import datetime as dt
import hashlib
import json
import subprocess
import sys
import time
from pathlib import Path

IMAGE_BYTES=1474560
SECTOR_BYTES=512
STAGE2_SECTORS=8
STAGE2_EXTENT=4096
DURABLE_INDEX=9
QEMU_TIMEOUT=8
BOOT2_MUTATION_FORBIDDEN=True

LLVM=Path(r'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin')
CLANG=LLVM/'clang.exe'; LLD=LLVM/'ld.lld.exe'; OBJCOPY=LLVM/'llvm-objcopy.exe'; SIZE=LLVM/'llvm-size.exe'; NM=LLVM/'llvm-nm.exe'; OBJDUMP=LLVM/'llvm-objdump.exe'
QEMU=Path(r'C:\Program Files\qemu\qemu-system-i386.exe')
PYTHON=Path(r'C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe')

def now(): return dt.datetime.now(dt.timezone.utc).isoformat()
def sha256(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
 return h.hexdigest()
def cap(argv:list[str],so:Path,se:Path,timeout:int=30)->int:
 with so.open('wb') as o,se.open('wb') as e:
  return subprocess.run(argv,stdout=o,stderr=e,timeout=timeout,check=False).returncode
def extract_sector(disk:Path,out:Path)->None:
 b=disk.read_bytes(); out.write_bytes(b[DURABLE_INDEX*SECTOR_BYTES:(DURABLE_INDEX+1)*SECTOR_BYTES])
def run_qemu(disk:Path,debug:Path,so:Path,se:Path):
 argv=[str(QEMU),'-accel','tcg','-display','none','-monitor','none','-serial','none','-no-reboot','-boot','a','-drive',f'file={disk.as_posix()},format=raw,if=floppy','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 started=now(); t0=time.perf_counter()
 with so.open('wb') as o,se.open('wb') as e:
  proc=subprocess.Popen(argv,stdout=o,stderr=e); pid=proc.pid
  try: exit_code=proc.wait(timeout=QEMU_TIMEOUT); status='COMPLETED'
  except subprocess.TimeoutExpired:
   proc.kill(); proc.wait(timeout=5); exit_code=None; status='UNKNOWN_TIMEOUT'
 elapsed_ms=(time.perf_counter()-t0)*1000.0; ended=now()
 return {'pid':pid,'argv':argv,'started_utc':started,'ended_utc':ended,'wall_ms':elapsed_ms,'status':status,'exit_code':exit_code,'timeout_seconds':QEMU_TIMEOUT}

def main()->int:
 if len(sys.argv)!=2:
  print('usage: launch_i001.py RUN_ID',file=sys.stderr); return 64
 rid=sys.argv[1]; src=Path(__file__).resolve().parent; repo=src.parents[3]; run=src.parent/'runs'/rid
 if run.exists(): print(f'run exists: {run}',file=sys.stderr); return 65
 run.mkdir(parents=True)
 s1s=src/'stage1.S'; s1ld=src/'stage1.ld'; s2s=src/'stage2.S'; s2ld=src/'stage2.ld'; evaluator=src/'evaluate_i001.py'; checker=src/'static_check_i001.py'; launcher=Path(__file__).resolve()
 s1o=run/'stage1.o'; s1elf=run/'stage1.elf'; s1bin=run/'stage1.bin'; s2o=run/'stage2.o'; s2elf=run/'stage2.elf'; s2raw=run/'stage2.raw.bin'; s2pad=run/'stage2.padded.bin'; disk=run/'disk.img'
 build=[('01_stage1_clang',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(s1s),'-o',str(s1o)]),('02_stage1_link',[str(LLD),'-m','elf_i386','-T',str(s1ld),str(s1o),'-o',str(s1elf)]),('03_stage1_objcopy',[str(OBJCOPY),'-O','binary',str(s1elf),str(s1bin)]),('04_stage2_clang',[str(CLANG),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(s2s),'-o',str(s2o)]),('05_stage2_link',[str(LLD),'-m','elf_i386','-T',str(s2ld),str(s2o),'-o',str(s2elf)]),('06_stage2_objcopy',[str(OBJCOPY),'-O','binary',str(s2elf),str(s2raw)])]
 for name,argv in build:
  rc=cap(argv,run/f'{name}.stdout.txt',run/f'{name}.stderr.txt')
  if rc!=0: print(f'{name} failed exit={rc}',file=sys.stderr); return 2
 stage1=s1bin.read_bytes(); stage2=s2raw.read_bytes()
 if len(stage1)!=512 or stage1[510:]!=b'\x55\xaa': print('stage1 contract failed',file=sys.stderr); return 2
 if len(stage2)>STAGE2_EXTENT: print(f'stage2 too large {len(stage2)}',file=sys.stderr); return 2
 padded=stage2+bytes(STAGE2_EXTENT-len(stage2)); s2pad.write_bytes(padded)
 image=bytearray(IMAGE_BYTES); image[:512]=stage1; image[512:512+STAGE2_EXTENT]=padded; disk.write_bytes(image)
 initial_sha=sha256(disk)
 b1dbg=run/'boot1.debugcon.txt'; b1so=run/'07_qemu_boot1.stdout.txt'; b1se=run/'07_qemu_boot1.stderr.txt'; b1=run_qemu(disk,b1dbg,b1so,b1se)
 sector1=run/'durable_after_boot1.bin'; extract_sector(disk,sector1); after1_sha=sha256(disk)
 if b1['status']!='COMPLETED' or b1['exit_code']!=33:
  print(f"BOOT1 status={b1['status']} exit={b1['exit_code']}",file=sys.stderr); return 3 if b1['status']=='UNKNOWN_TIMEOUT' else 1
 # BOOT2_MUTATION_FORBIDDEN: host performs no disk mutation here. Only read/hash/extract operations occurred after Boot 1.
 b2dbg=run/'boot2.debugcon.txt'; b2so=run/'08_qemu_boot2.stdout.txt'; b2se=run/'08_qemu_boot2.stderr.txt'; b2=run_qemu(disk,b2dbg,b2so,b2se)
 sector2=run/'durable_after_boot2.bin'; extract_sector(disk,sector2); after2_sha=sha256(disk)
 evaluation=run/'evaluation.json'; eso=run/'09_evaluator.stdout.txt'; ese=run/'09_evaluator.stderr.txt'; eval_exit=cap([str(PYTHON),str(evaluator),str(b1dbg),str(b2dbg),str(sector1),str(sector2),str(evaluation)],eso,ese)
 static=run/'static_closure.json'; sso=run/'10_static.stdout.txt'; sse=run/'10_static.stderr.txt'; static_exit=cap([str(PYTHON),str(checker),str(s1s),str(s2s),str(launcher),str(static)],sso,sse)
 size_so=run/'11_stage2_size.stdout.txt'; size_se=run/'11_stage2_size.stderr.txt'; size_exit=cap([str(SIZE),str(s2elf)],size_so,size_se)
 nm_so=run/'12_stage2_nm.stdout.txt'; nm_se=run/'12_stage2_nm.stderr.txt'; nm_exit=cap([str(NM),'-n',str(s2elf)],nm_so,nm_se)
 obj_so=run/'13_stage2_objdump.stdout.txt'; obj_se=run/'13_stage2_objdump.stderr.txt'; obj_exit=cap([str(OBJDUMP),'-d',str(s2elf)],obj_so,obj_se)
 runtime_bytes=None
 if nm_exit==0:
  symbols={}
  for line in nm_so.read_text(errors='replace').splitlines():
   parts=line.split()
   if len(parts)>=3 and parts[0].isalnum():
    try: symbols[parts[2]]=int(parts[0],16)
    except ValueError: pass
  if 'runtime_state_start' in symbols and 'runtime_state_end' in symbols: runtime_bytes=symbols['runtime_state_end']-symbols['runtime_state_start']
 static_json=json.loads(static.read_text()) if static.exists() else {}
 receipt={'run_id':rid,'run_class':'I001_WHOLE_WORKLOAD_INTEGRATION','scientific_status':('COMPLETED' if b1['status']=='COMPLETED' and b2['status']=='COMPLETED' else 'UNKNOWN'),'authority_ceiling':'bounded two-boot integrated descendant only; no architecture/authority promotion','layout':{'image_bytes':IMAGE_BYTES,'sector_bytes':SECTOR_BYTES,'stage1_sector_1_based':1,'stage2_start_sector_1_based':2,'stage2_sector_count':STAGE2_SECTORS,'stage2_load_address':'0x8000','durable_sector_1_based':10},'qemu':{'boot1':b1,'boot2':b2},'tools':{k:{'path':str(v),'sha256':sha256(v)} for k,v in {'clang':CLANG,'lld':LLD,'objcopy':OBJCOPY,'size':SIZE,'nm':NM,'objdump':OBJDUMP,'qemu':QEMU,'python':PYTHON}.items()},'source_sha256':{k:sha256(v) for k,v in {'stage1_s':s1s,'stage1_ld':s1ld,'stage2_s':s2s,'stage2_ld':s2ld,'evaluator':evaluator,'static_checker':checker,'launcher':launcher}.items()},'artifacts':{'stage1_bin':{'bytes':len(stage1),'sha256':sha256(s1bin),'signature':stage1[510:].hex()},'stage2_raw':{'bytes':len(stage2),'sha256':sha256(s2raw)},'stage2_padded':{'bytes':len(padded),'sha256':sha256(s2pad)},'disk':{'bytes':disk.stat().st_size,'initial_sha256':initial_sha,'after_boot1_sha256':after1_sha,'after_boot2_sha256':after2_sha},'boot1_debug':{'sha256':sha256(b1dbg)},'boot2_debug':{'sha256':sha256(b2dbg)},'durable_after_boot1':{'sha256':sha256(sector1)},'durable_after_boot2':{'sha256':sha256(sector2)},'evaluation':{'sha256':sha256(evaluation) if evaluation.exists() else None,'exit':eval_exit},'static_closure':{'sha256':sha256(static) if static.exists() else None,'exit':static_exit},'stage2_size':{'sha256':sha256(size_so),'exit':size_exit},'stage2_nm':{'sha256':sha256(nm_so),'exit':nm_exit},'stage2_objdump':{'sha256':sha256(obj_so),'exit':obj_exit}},'pareto':{'runtime_state_bytes':runtime_bytes,'activity_capacity':2,'activity_generation_bits':8,'runtime_epoch_bits':8,'main_path_max_slot_generation':2,'formal_valid_generation_values':'1..255; fail closed before zero-wrap','critical_wait_instruction_count':static_json.get('critical_wait_instruction_count'),'explicit_result_codes':['W','F','M','O','R','G','X'],'state_block_species':static_json.get('state_block_species',[])}}
 rp=run/'receipt.json'; rp.write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
 print('RUN_DIR='+str(run)); print(f"BOOT1_PID={b1['pid']} STATUS={b1['status']} EXIT={b1['exit_code']} WALL_MS={b1['wall_ms']:.3f}"); print(f"BOOT2_PID={b2['pid']} STATUS={b2['status']} EXIT={b2['exit_code']} WALL_MS={b2['wall_ms']:.3f}"); print('BOOT1_TRACE='+repr(b1dbg.read_text(encoding='ascii').splitlines())); print('BOOT2_TRACE='+repr(b2dbg.read_text(encoding='ascii').splitlines())); print(f'EVALUATOR_EXIT={eval_exit} STATIC_EXIT={static_exit} STAGE2_RAW_BYTES={len(stage2)} RUNTIME_STATE_BYTES={runtime_bytes}'); print('RECEIPT_SHA256='+sha256(rp))
 if b2['status']=='UNKNOWN_TIMEOUT': return 3
 return 0 if b2['exit_code']==33 and eval_exit==0 and static_exit==0 and size_exit==0 and nm_exit==0 and obj_exit==0 else 1
if __name__=='__main__': raise SystemExit(main())
