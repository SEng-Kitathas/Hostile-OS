from __future__ import annotations
import hashlib, json, os, shutil, subprocess, sys, time
from datetime import datetime, timezone
from pathlib import Path
VERSION='D64-FR01-launcher-v4'
IMAGE_BYTES=1_474_560
SECTOR=512

def utc(): return datetime.now(timezone.utc).isoformat()
def sha_bytes(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def crc16(data:bytes)->int:
 c=0xffff
 for b in data:
  c ^= b<<8
  for _ in range(8): c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c
def additive(data:bytes)->int:return sum(data)&0xffff
def record(seq:int,val:int,act:int,res:int,ident:int=0x51)->bytes:
 p=bytearray(24); p[0:4]=b'H4F1'; p[4]=ident; p[5]=val; p[6]=act; p[7]=res; p[8]=0; p[9]=1; p[10]=act; p[11]=0; p[12]=1; p[13]=0; p[14]=1; p[15]=res; p[16:18]=b'4\x12'; p[18]=1; p[19]=0; p[20:24]=seq.to_bytes(4,'little'); logical=bytes(p)+crc16(bytes(p)).to_bytes(2,'little')+b'CMIT'; return logical+bytes(SECTOR-len(logical))
def label(case_id:str)->bytes:
 raw=case_id.encode('ascii'); assert 0<len(raw)<=31; b=bytearray(SECTOR); b[:4]=b'CASE'; b[4:4+len(raw)]=raw; return bytes(b)
def corrupt_crc(r:bytes)->bytes:
 b=bytearray(r); b[24]^=1; return bytes(b)
def build_fixtures():
 zero=bytes(SECTOR); a1=record(1,0x71,1,1); b2=record(2,0x72,2,2); b3=record(3,0x73,3,3); fixtures=[]
 def add(cid,a,b):fixtures.append({'case_id':cid,'a':a,'b':b})
 add('F01',a1,zero)
 add('F02',a1,b2)
 x=bytearray(b3); x[5]^=1; add('F03',a1,bytes(x))
 x=bytearray(b2); x[26:30]=bytes(4); add('F04',a1,bytes(x))
 x=bytearray(b2); x[26]^=1; add('F05',a1,bytes(x))
 x=bytearray(b2); x[4]+=1; x[5]-=1; f06=bytes(x); add('F06',a1,f06)
 add('F07',corrupt_crc(a1),b2)
 add('F08',corrupt_crc(a1),corrupt_crc(b2))
 add('F09',b2,b2)
 add('F10',record(2,0x72,2,2),record(2,0x73,2,2))
 add('F11',record(1,0x71,255,3),zero)
 for k in range(30):
  x=bytearray(b2); x[k:30]=bytes(30-k); add(f'F12_tear_{k:02d}',a1,bytes(x))
 control={'original_sum':additive(b2[:24]),'corrupted_sum':additive(f06[:24]),'stored_crc':int.from_bytes(f06[24:26],'little'),'corrupted_crc':crc16(f06[:24]),'base_b_sha256':sha_bytes(b2),'corrupt_b_sha256':sha_bytes(f06)}
 return fixtures,control
def find_tool(env,names,llvm=None,common=None):
 v=os.environ.get(env)
 if v:
  p=Path(v)
  if p.is_file():return p
  raise SystemExit(f'{env} missing: {p}')
 if llvm:
  for n in names:
   p=llvm/n
   if p.is_file():return p
 for n in names:
  f=shutil.which(n)
  if f:return Path(f)
 if common and common.is_file():return common
 raise SystemExit(f'missing {env}: {names}')
def run_capture(argv,cwd,out,err):
 cp=subprocess.run(argv,cwd=cwd,text=True,capture_output=True,check=False); Path(out).write_text(cp.stdout,encoding='utf-8',newline='\n'); Path(err).write_text(cp.stderr,encoding='utf-8',newline='\n'); return cp.returncode
def main()->int:
 here=Path(__file__).resolve().parent; repo=here.parents[3]; parent=here.parent; run_id=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'_d64_fr01_01'; run=parent/'runs'/run_id; inp=run/'inputs'; inp.mkdir(parents=True)
 source_map={
  'qualified_stage1.S':'research/qualifications/D64_STAGE2_8K_LOADER_QUALIFICATION_2026-08-30/stage1.S',
  'qualified_stage1.ld':'research/qualifications/D64_STAGE2_8K_LOADER_QUALIFICATION_2026-08-30/stage1.ld',
  'stage2.S':'research/persistence/D64_FR01/probe/stage2.S','stage2.ld':'research/persistence/D64_FR01/probe/stage2.ld','launcher':'research/persistence/D64_FR01/probe/launch_fr01.py','evaluator':'research/persistence/D64_FR01/probe/evaluate_fr01.py','static':'research/persistence/D64_FR01/probe/static_check_fr01.py','audit':'research/persistence/D64_FR01/probe/audit_fr01.py',
  'prereg':'research/persistence/D64_FR01/D64_FR01_PREREGISTRATION.md','amendment_a':'research/persistence/D64_FR01/D64_FR01_PREREGISTRATION_AMENDMENT_A.md','amendment_b':'research/persistence/D64_FR01/D64_FR01_PREREGISTRATION_AMENDMENT_B.md','amendment_c':'research/persistence/D64_FR01/D64_FR01_PREREGISTRATION_AMENDMENT_C.md','mechanism_selection':'research/persistence/D64_FR01/D64_FR01_INTEGRITY_MECHANISM_SELECTION.md','parent_plan':'research/plans/D64_FAULTED_RESTART_DURABLE_RECORD_PLAN_2026-08-30.md','pr01_prereg':'research/persistence/D64_PR01/D64_PR01_PREREGISTRATION.md','pr01_result':'research/persistence/D64_PR01/D64_PR01_RESULT_2026-08-30.md'}
 records=[]
 for key,rel in source_map.items():
  src=repo/rel; dst=inp/(key.replace('/','_')+(src.suffix if not key.endswith(src.suffix) else ''))
  # stable explicit filenames for build/tool scripts
  if key=='qualified_stage1.S': dst=inp/'stage1.S'
  elif key=='qualified_stage1.ld': dst=inp/'stage1.ld'
  elif key in ('stage2.S','stage2.ld'): dst=inp/key
  elif key=='launcher': dst=inp/'launch_fr01.py'
  elif key=='evaluator': dst=inp/'evaluate_fr01.py'
  elif key=='static': dst=inp/'static_check_fr01.py'
  elif key=='audit': dst=inp/'audit_fr01.py'
  else: dst=inp/Path(rel).name
  shutil.copy2(src,dst); records.append({'key':key,'source_project_relative':rel,'snapshot_path':dst.relative_to(run).as_posix(),'sha256':sha(dst),'bytes':dst.stat().st_size})
 git_head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(); manifest={'format':'D64_FR01_INPUTS_V1','created_utc':utc(),'git_head':git_head,'inputs':records}; (run/'inputs_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
 llvm=Path(os.environ['HOSTILE_LLVM_BIN']) if os.environ.get('HOSTILE_LLVM_BIN') else None; clang=find_tool('HOSTILE_CLANG',['clang','clang.exe'],llvm); lld=find_tool('HOSTILE_LLD',['ld.lld','ld.lld.exe'],llvm); obj=find_tool('HOSTILE_OBJCOPY',['llvm-objcopy','llvm-objcopy.exe'],llvm); qemu=find_tool('HOSTILE_QEMU',['qemu-system-i386','qemu-system-i386.exe'],common=Path(r'C:\Program Files\qemu\qemu-system-i386.exe'))
 steps=[([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'stage1.S'),'-o',str(run/'stage1.o')],'01_stage1_compile'),([str(lld),'-m','elf_i386','-T',str(inp/'stage1.ld'),str(run/'stage1.o'),'-o',str(run/'stage1.elf')],'02_stage1_link'),([str(obj),'-O','binary',str(run/'stage1.elf'),str(run/'stage1.bin')],'03_stage1_objcopy'),([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'stage2.S'),'-o',str(run/'stage2.o')],'04_stage2_compile'),([str(lld),'-m','elf_i386','-T',str(inp/'stage2.ld'),str(run/'stage2.o'),'-o',str(run/'stage2.elf')],'05_stage2_link'),([str(obj),'-O','binary',str(run/'stage2.elf'),str(run/'stage2.raw.bin')],'06_stage2_objcopy')]
 for argv,name in steps:
  rc=run_capture(argv,repo,run/(name+'.stdout.txt'),run/(name+'.stderr.txt'))
  if rc: print(json.dumps({'run_dir':run.as_posix(),'failed_step':name,'return_code':rc})); return rc
 s1=(run/'stage1.bin').read_bytes(); s2=(run/'stage2.raw.bin').read_bytes(); assert len(s1)==512 and s1[510:]==b'\x55\xaa' and len(s2)<=8192; padded=s2+bytes(8192-len(s2)); (run/'stage2.padded.bin').write_bytes(padded)
 fixtures,f06=build_fixtures(); (run/'f06_additive_control.json').write_text(json.dumps(f06,indent=2)+'\n',encoding='utf-8',newline='\n')
 fixture_root=run/'fixtures'; fixture_root.mkdir(); results=[]
 # All fixture bytes exist before first QEMU starts.
 for f in fixtures:
  d=fixture_root/f['case_id']; d.mkdir(); image=bytearray(IMAGE_BYTES); image[:512]=s1; image[512:512+8192]=padded; image[17*512:18*512]=f['a']; image[18*512:19*512]=f['b']; image[19*512:20*512]=label(f['case_id']); (d/'fr01.img').write_bytes(image)
 for f in fixtures:
  d=fixture_root/f['case_id']; disk=d/'fr01.img'; debug=d/'debugcon.txt'; before=sha(disk); argv=[str(qemu),'-accel','tcg','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={disk.as_posix()},format=raw,if=floppy,readonly=on','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9']; started=utc(); t0=time.perf_counter(); p=subprocess.Popen(argv,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
  try: _,err=p.communicate(timeout=10); status='COMPLETED'; exit_code=p.returncode
  except subprocess.TimeoutExpired: p.kill(); _,err=p.communicate(); status='UNKNOWN_TIMEOUT'; exit_code=None
  (d/'qemu.stderr.txt').write_text(err.decode('utf-8',errors='replace') if err else '',encoding='utf-8',newline='\n'); after=sha(disk); rec={'case_id':f['case_id'],'relative_dir':d.relative_to(run).as_posix(),'disk_path':disk.relative_to(run).as_posix(),'disk_sha256_before':before,'disk_sha256_after':after,'qemu':{'pid':p.pid,'started_utc':started,'ended_utc':utc(),'status':status,'exit_code':exit_code,'wall_ms':(time.perf_counter()-t0)*1000,'argv':argv},'trace_sha256':sha(debug) if debug.exists() else None}; (d/'fixture_receipt.json').write_text(json.dumps(rec,indent=2)+'\n',encoding='utf-8',newline='\n'); results.append(rec)
 campaign={'version':VERSION,'run_id':run_id,'git_head':git_head,'fixture_count':len(results),'fixtures':results,'stage1':{'bytes':len(s1),'sha256':sha(run/'stage1.bin')},'stage2':{'bytes':len(s2),'sha256':sha(run/'stage2.raw.bin')},'input_manifest_sha256':sha(run/'inputs_manifest.json'),'original_inputs_unchanged':all(sha(repo/x['source_project_relative'])==x['sha256'] for x in records)}; (run/'campaign_receipt.json').write_text(json.dumps(campaign,indent=2)+'\n',encoding='utf-8',newline='\n')
 ev=run_capture([sys.executable,str(inp/'evaluate_fr01.py'),str(run),str(run/'evaluation.json')],repo,run/'07_evaluator.stdout.txt',run/'07_evaluator.stderr.txt'); st=run_capture([sys.executable,str(inp/'static_check_fr01.py'),str(inp/'stage1.S'),str(inp/'stage2.S'),str(inp/'launch_fr01.py'),str(run/'static_closure.json')],repo,run/'08_static.stdout.txt',run/'08_static.stderr.txt'); au=run_capture([sys.executable,str(inp/'audit_fr01.py'),str(run),str(run/'independent_audit.json')],repo,run/'09_audit.stdout.txt',run/'09_audit.stderr.txt')
 def maybe_sha(name):
  p=run/name; return sha(p) if p.exists() else None
 all_pass=ev==0 and st==0 and au==0 and all(x['qemu']['status']=='COMPLETED' and x['qemu']['exit_code']==33 for x in results) and campaign['original_inputs_unchanged']
 summary={'run_id':run_id,'git_head':git_head,'fixture_count':len(results),'evaluator_exit':ev,'static_exit':st,'audit_exit':au,'all_pass':all_pass,'stage2_bytes':len(s2),'campaign_receipt_sha256':maybe_sha('campaign_receipt.json'),'evaluation_sha256':maybe_sha('evaluation.json'),'static_sha256':maybe_sha('static_closure.json'),'audit_sha256':maybe_sha('independent_audit.json')}
 (run/'result_summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(summary,indent=2)); return 0 if all_pass else 1
if __name__=='__main__': raise SystemExit(main())
