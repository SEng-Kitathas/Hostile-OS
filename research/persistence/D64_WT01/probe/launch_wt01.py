from __future__ import annotations
import hashlib,json,os,re,shutil,socket,subprocess,sys,time
from datetime import datetime,timezone
from pathlib import Path
VERSION='D64-WT01-launcher-v1'
CALIBRATION_COUNT=5
REPETITIONS=5
IMAGE_BYTES=1_474_560
SECTOR=512
ZERO_SECTOR=bytes(SECTOR)

def utc():return datetime.now(timezone.utc).isoformat()
def sha_bytes(b):return hashlib.sha256(b).hexdigest()
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def crc16(data):
 c=0xffff
 for b in data:
  c ^= b<<8
  for _ in range(8):c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c
def record(seq,val,act,res):
 p=bytearray(24);p[:4]=b'H4F1';p[4]=0x51;p[5]=val;p[6]=act;p[7]=res;p[8]=0;p[9]=1;p[10]=act;p[11]=0;p[12]=1;p[13]=0;p[14]=1;p[15]=res;p[16:18]=b'4\x12';p[18]=1;p[19]=0;p[20:24]=seq.to_bytes(4,'little');q=bytes(p)+crc16(bytes(p)).to_bytes(2,'little')+b'CMIT';return q+bytes(SECTOR-len(q))
A_SECTOR=record(1,0x71,1,1)
B_SECTOR=record(2,0x72,2,2)
ZERO_SHA=sha_bytes(ZERO_SECTOR);A_SHA=sha_bytes(A_SECTOR);B_SHA=sha_bytes(B_SECTOR)
def sector(path,lba):
 with Path(path).open('rb') as f:f.seek(lba*SECTOR);return f.read(SECTOR)
def classify_b(b):return 'ZERO' if b==ZERO_SECTOR else ('FULL' if b==B_SECTOR else 'OTHER')
def label(case_id):
 raw=case_id.encode('ascii');assert len(raw)<=31;b=bytearray(SECTOR);b[:4]=b'CASE';b[4:4+len(raw)]=raw;return bytes(b)
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
  q=shutil.which(n)
  if q:return Path(q)
 if common and common.is_file():return common
 raise SystemExit(f'missing {env}: {names}')
def capture(argv,cwd,out,err):
 cp=subprocess.run(argv,cwd=cwd,text=True,capture_output=True,check=False);Path(out).write_text(cp.stdout,encoding='utf-8',newline='\n');Path(err).write_text(cp.stderr,encoding='utf-8',newline='\n');return cp.returncode

def rsp_checksum(b):return sum(b)%256
class RSP:
 def __init__(self,s):self.s=s;self.s.settimeout(20)
 @classmethod
 def connect(cls,port):
  last=None
  for _ in range(200):
   try:return cls(socket.create_connection(('127.0.0.1',port),timeout=.2))
   except OSError as e:last=e;time.sleep(.025)
  raise RuntimeError(f'GDB connect failed: {last}')
 def _packet(self,cmd):
  b=cmd.encode();return b'$'+b+b'#'+f'{rsp_checksum(b):02x}'.encode()
 def command(self,cmd):
  self.s.sendall(self._packet(cmd));a=self.s.recv(1)
  if a==b'+':
   while True:
    c=self.s.recv(1)
    if c==b'$':break
  elif a!=b'$':raise RuntimeError(f'GDB ack {a!r}')
  data=bytearray()
  while True:
   c=self.s.recv(1)
   if not c:raise RuntimeError('GDB EOF')
   if c==b'#':break
   data.extend(c)
  self.s.recv(2);self.s.sendall(b'+');return data.decode(errors='replace')
 def continue_async(self):
  self.s.sendall(self._packet('c'));a=self.s.recv(1)
  if a!=b'+':raise RuntimeError(f'GDB continue ack {a!r}')
 def close(self):
  try:self.s.close()
  except:pass

def create_writer_disk(path,writer_s1,writer_s2):
 im=bytearray(IMAGE_BYTES);im[:512]=writer_s1;im[512:512+8192]=writer_s2;im[17*512:18*512]=A_SECTOR;im[18*512:19*512]=ZERO_SECTOR;Path(path).write_bytes(im)
def start_writer(qemu,root,d,port,int13_addr):
 disk=d/'writer_terminal.img';debug=d/'writer.debugcon.txt';create_writer_disk(disk,(root/'writer_stage1.bin').read_bytes(),(root/'writer_stage2.padded.bin').read_bytes());argv=[str(qemu),'-accel','tcg','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-S','-gdb',f'tcp:127.0.0.1:{port}','-drive',f'file={disk.as_posix()},format=raw,if=floppy,cache=directsync','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9'];err=open(d/'writer_qemu.stderr.txt','wb');p=subprocess.Popen(argv,stdout=subprocess.DEVNULL,stderr=err);r=RSP.connect(port);r.command('qSupported');r.command('?');assert r.command(f'Z0,{int13_addr:x},1')=='OK';stop=r.command('c');stopped=True;trace=debug.read_text(encoding='ascii',errors='replace').splitlines() if debug.exists() else [];assert trace==['S1_8K_OK','WRITE_READY'];assert sector(disk,18)==ZERO_SECTOR
 return {'process':p,'rsp':r,'stderr_handle':err,'disk':disk,'debug':debug,'argv':argv,'break_stop':stop,'stopped':stopped,'a_initial':sha_bytes(sector(disk,17)),'b_breakpoint':sha_bytes(sector(disk,18))}
def force_terminate(ctx):
 assert ctx['stopped'] is True
 req=utc();p=ctx['process'];p.kill();p.wait(timeout=5);ctx['stderr_handle'].close();ctx['rsp'].close();return {'pid':p.pid,'status':'FORCED_TERMINATED','exit_code':p.returncode,'termination_requested_utc':req,'terminal_verified':p.poll() is not None}
def step_n(ctx,n,track=False):
 assert ctx['stopped'] is True; states=[];prior_zero=True
 for i in range(1,n+1):
  ctx['rsp'].command('s');b=sector(ctx['disk'],18);cl=classify_b(b);prior_zero &= (cl=='ZERO') if i<n else True
  if track:states.append({'step':i,'sha256':sha_bytes(b),'class':cl})
 return states,prior_zero
def normal_continue(ctx):
 assert ctx['stopped'] is True;ctx['rsp'].continue_async();p=ctx['process'];p.wait(timeout=10);ctx['stderr_handle'].close();ctx['rsp'].close();return {'pid':p.pid,'status':'COMPLETED' if p.returncode is not None else 'UNKNOWN','exit_code':p.returncode,'terminal_verified':p.poll() is not None}
def recovery_overlay(writer_disk,recovery_path,fr01_s1,fr01_s2,case_id):
 shutil.copy2(writer_disk,recovery_path);recovery=bytearray(Path(recovery_path).read_bytes());a0=sha_bytes(recovery[17*512:18*512]);b0=sha_bytes(recovery[18*512:19*512]);recovery[:512]=fr01_s1;recovery[512:512+8192]=fr01_s2;recovery[19*512:20*512]=label(case_id);Path(recovery_path).write_bytes(recovery);a1=sha_bytes(recovery[17*512:18*512]);b1=sha_bytes(recovery[18*512:19*512]);return a0,b0,a1,b1
def run_recovery(qemu,d,disk):
 debug=d/'recovery.debugcon.txt';argv=[str(qemu),'-accel','tcg','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={disk.as_posix()},format=raw,if=floppy,readonly=on','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9'];t0=time.perf_counter();p=subprocess.Popen(argv,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 try:_,err=p.communicate(timeout=10);status='COMPLETED';ex=p.returncode
 except subprocess.TimeoutExpired:p.kill();_,err=p.communicate();status='UNKNOWN_TIMEOUT';ex=None
 (d/'recovery_qemu.stderr.txt').write_text(err.decode('utf-8',errors='replace') if err else '',encoding='utf-8',newline='\n');return {'pid':p.pid,'status':status,'exit_code':ex,'wall_ms':(time.perf_counter()-t0)*1000,'argv':argv},debug.read_text(encoding='ascii',errors='replace').splitlines() if debug.exists() else []
def main()->int:
 here=Path(__file__).resolve().parent;repo=here.parents[3];parent=here.parent;run_id=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'_d64_wt01_01';run=parent/'runs'/run_id;inp=run/'inputs';inp.mkdir(parents=True)
 source_map={
 'stage1.S':'research/persistence/D64_WT01/probe/stage1.S','stage1.ld':'research/persistence/D64_WT01/probe/stage1.ld','writer.S':'research/persistence/D64_WT01/probe/writer.S','writer.ld':'research/persistence/D64_WT01/probe/writer.ld','launcher':'research/persistence/D64_WT01/probe/launch_wt01.py','evaluator':'research/persistence/D64_WT01/probe/evaluate_wt01.py','static':'research/persistence/D64_WT01/probe/static_check_wt01.py','audit':'research/persistence/D64_WT01/probe/audit_wt01.py','prereg':'research/persistence/D64_WT01/D64_WT01_PREREGISTRATION.md','plan':'research/plans/D64_INTERRUPTED_DURABLE_WRITE_PLAN_2026-08-30.md','feasibility':'research/persistence/D64_IW00_FEASIBILITY_2026-08-30/FEASIBILITY_RESULT.md','fr01_result':'research/persistence/D64_FR01/D64_FR01_RESULT_2026-08-30.md','fr01_adoption':'research/persistence/D64_FR01/D64_FR01_ADOPTION.md','fr01_stage1':'research/persistence/D64_FR01/runs/20260830T212145Z_d64_fr01_01/stage1.bin','fr01_stage2':'research/persistence/D64_FR01/runs/20260830T212145Z_d64_fr01_01/stage2.padded.bin'}
 names={'launcher':'launch_wt01.py','evaluator':'evaluate_wt01.py','static':'static_check_wt01.py','audit':'audit_wt01.py','fr01_stage1':'fr01_stage1.bin','fr01_stage2':'fr01_stage2.padded.bin'};records=[]
 for key,rel in source_map.items():
  src=repo/rel;dst=inp/names.get(key,Path(rel).name);shutil.copy2(src,dst);records.append({'key':key,'source_project_relative':rel,'snapshot_path':dst.relative_to(run).as_posix(),'bytes':dst.stat().st_size,'sha256':sha(dst)})
 head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip();(run/'inputs_manifest.json').write_text(json.dumps({'format':'D64_WT01_INPUTS_V1','git_head':head,'created_utc':utc(),'inputs':records},indent=2)+'\n',encoding='utf-8',newline='\n')
 llvm=Path(os.environ['HOSTILE_LLVM_BIN']) if os.environ.get('HOSTILE_LLVM_BIN') else None;clang=find_tool('HOSTILE_CLANG',['clang','clang.exe'],llvm);lld=find_tool('HOSTILE_LLD',['ld.lld','ld.lld.exe'],llvm);obj=find_tool('HOSTILE_OBJCOPY',['llvm-objcopy','llvm-objcopy.exe'],llvm);nm=find_tool('HOSTILE_NM',['llvm-nm','llvm-nm.exe'],llvm);qemu=find_tool('HOSTILE_QEMU',['qemu-system-i386','qemu-system-i386.exe'],common=Path(r'C:\Program Files\qemu\qemu-system-i386.exe'))
 steps=[([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'stage1.S'),'-o',str(run/'writer_stage1.o')],'01_s1_compile'),([str(lld),'-m','elf_i386','-T',str(inp/'stage1.ld'),str(run/'writer_stage1.o'),'-o',str(run/'writer_stage1.elf')],'02_s1_link'),([str(obj),'-O','binary',str(run/'writer_stage1.elf'),str(run/'writer_stage1.bin')],'03_s1_objcopy'),([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',str(inp/'writer.S'),'-o',str(run/'writer_stage2.o')],'04_writer_compile'),([str(lld),'-m','elf_i386','-T',str(inp/'writer.ld'),str(run/'writer_stage2.o'),'-o',str(run/'writer_stage2.elf')],'05_writer_link'),([str(obj),'-O','binary',str(run/'writer_stage2.elf'),str(run/'writer_stage2.raw.bin')],'06_writer_objcopy')]
 for argv,name in steps:
  rc=capture(argv,repo,run/(name+'.stdout.txt'),run/(name+'.stderr.txt'))
  if rc:return rc
 s1=(run/'writer_stage1.bin').read_bytes();s2=(run/'writer_stage2.raw.bin').read_bytes();assert len(s1)==512 and s1[510:]==b'\x55\xaa' and len(s2)<=8192;(run/'writer_stage2.padded.bin').write_bytes(s2+bytes(8192-len(s2)))
 nmout=subprocess.check_output([str(nm),'-n',str(run/'writer_stage2.elf')],cwd=repo,text=True);(run/'writer_nm.txt').write_text(nmout,encoding='utf-8',newline='\n');match=re.search(r'^([0-9A-Fa-f]+)\s+\w\s+writer_int13_site$',nmout,re.M);assert match;int13_addr=int(match.group(1),16);off=int13_addr-0x8000;assert s2[off:off+2]==bytes([0xcd,0x13]);(run/'writer_symbol.json').write_text(json.dumps({'writer_int13_site':int13_addr,'raw_offset':off,'bytes':s2[off:off+2].hex()},indent=2)+'\n',encoding='utf-8',newline='\n')
 fr01_s1=(inp/'fr01_stage1.bin').read_bytes();fr01_s2=(inp/'fr01_stage2.padded.bin').read_bytes();calroot=run/'calibration';calroot.mkdir();calibration=[];port=24600
 for i in range(CALIBRATION_COUNT):
  d=calroot/f'CAL_{i:02d}';d.mkdir();ctx=start_writer(qemu,run,d,port+i,int13_addr);ctx['rsp'].command(f'z0,{int13_addr:x},1');first=None;prior=True
  for step in range(1,2001):
   ctx['rsp'].command('s');b=sector(ctx['disk'],18);cl=classify_b(b)
   if cl!='ZERO':first={'transition_step':step,'first_change_class':cl,'first_change_sha256':sha_bytes(b)};break
   prior &= True
  if first is None:first={'transition_step':None,'first_change_class':'NONE','first_change_sha256':None}
  term=force_terminate(ctx);item={'case_id':f'CAL_{i:02d}','relative_dir':d.relative_to(run).as_posix(),'writer':term,'pre_b_sha256':ctx['b_breakpoint'],'prior_states_all_zero':prior}|first;(d/'calibration_receipt.json').write_text(json.dumps(item,indent=2)+'\n',encoding='utf-8',newline='\n');calibration.append(item)
 if not (all(x['transition_step'] is not None and x['first_change_class']=='FULL' and x['prior_states_all_zero'] for x in calibration) and len({x['transition_step'] for x in calibration})==1):
  (run/'campaign_receipt.json').write_text(json.dumps({'version':VERSION,'git_head':head,'calibration':calibration,'aborted_after_calibration':True},indent=2)+'\n',encoding='utf-8',newline='\n');return 1
 T=calibration[0]['transition_step'];termroot=run/'terminations';termroot.mkdir();terms=[];port=24700;idx=0
 for klass in ['K0','KPRE','KPOST','CLEAN']:
  for rep in range(REPETITIONS):
   cid=f'{klass}_{rep:02d}';d=termroot/cid;d.mkdir();ctx=start_writer(qemu,run,d,port+idx,int13_addr);idx+=1;a_before=sha_bytes(sector(ctx['disk'],17));boundary_sha=ctx['b_breakpoint'];boundary_class='ZERO'
   if klass=='K0':writer=force_terminate(ctx)
   elif klass=='KPRE':
    assert ctx['rsp'].command(f'z0,{int13_addr:x},1')=='OK';states,_=step_n(ctx,T-1);b=sector(ctx['disk'],18);boundary_sha=sha_bytes(b);boundary_class=classify_b(b);writer=force_terminate(ctx)
   elif klass=='KPOST':
    assert ctx['rsp'].command(f'z0,{int13_addr:x},1')=='OK';states,_=step_n(ctx,T);b=sector(ctx['disk'],18);boundary_sha=sha_bytes(b);boundary_class=classify_b(b);writer=force_terminate(ctx)
   else:
    assert ctx['rsp'].command(f'z0,{int13_addr:x},1')=='OK';writer=normal_continue(ctx)
   a_after=sha_bytes(sector(ctx['disk'],17));b_after_bytes=sector(ctx['disk'],18);b_after=sha_bytes(b_after_bytes);bclass=classify_b(b_after_bytes);wtrace=ctx['debug'].read_text(encoding='ascii',errors='replace').splitlines() if ctx['debug'].exists() else []
   recovery_disk=d/'recovery.img';a0,b0,a1,b1=recovery_overlay(ctx['disk'],recovery_disk,fr01_s1,fr01_s2,cid);recovery,rtrace=run_recovery(qemu,d,recovery_disk)
   item={'case_id':cid,'class':klass,'repetition':rep,'relative_dir':d.relative_to(run).as_posix(),'transition_step':T,'a_sha_before':a_before,'a_sha_after_writer':a_after,'b_boundary_sha256':boundary_sha,'b_boundary_class':boundary_class,'b_sha_after_writer':b_after,'b_class':bclass,'writer':writer,'writer_trace':wtrace,'overlay_a_before':a0,'overlay_a_after':a1,'overlay_b_before':b0,'overlay_b_after':b1,'overlay_a_preserved':a0==a1,'overlay_b_preserved':b0==b1,'recovery':recovery,'recovery_trace':rtrace};(d/'case_receipt.json').write_text(json.dumps(item,indent=2)+'\n',encoding='utf-8',newline='\n');terms.append(item)
 campaign={'version':VERSION,'git_head':head,'writer_int13_site':int13_addr,'transition_step':T,'calibration':calibration,'terminations':terms,'writer_process_count':25,'recovery_process_count':20,'expected_hashes':{'A':A_SHA,'B_ZERO':ZERO_SHA,'B_FULL':B_SHA},'fr01_reader':{'stage1_sha256':sha(inp/'fr01_stage1.bin'),'stage2_padded_sha256':sha(inp/'fr01_stage2.padded.bin')},'original_inputs_unchanged':all(sha(repo/x['source_project_relative'])==x['sha256'] for x in records)};(run/'campaign_receipt.json').write_text(json.dumps(campaign,indent=2)+'\n',encoding='utf-8',newline='\n')
 ev=capture([sys.executable,str(inp/'evaluate_wt01.py'),str(run),str(run/'evaluation.json')],repo,run/'07_eval.stdout.txt',run/'07_eval.stderr.txt');st=capture([sys.executable,str(inp/'static_check_wt01.py'),str(inp/'writer.S'),str(inp/'launch_wt01.py'),str(run/'static_closure.json')],repo,run/'08_static.stdout.txt',run/'08_static.stderr.txt');au=capture([sys.executable,str(inp/'audit_wt01.py'),str(run),str(run/'independent_audit.json')],repo,run/'09_audit.stdout.txt',run/'09_audit.stderr.txt');all_pass=ev==st==au==0 and campaign['original_inputs_unchanged'];summary={'run_id':run_id,'git_head':head,'transition_step':T,'evaluator_exit':ev,'static_exit':st,'audit_exit':au,'all_pass':all_pass,'writer_stage2_bytes':len(s2),'campaign_sha256':sha(run/'campaign_receipt.json'),'evaluation_sha256':sha(run/'evaluation.json'),'static_sha256':sha(run/'static_closure.json'),'audit_sha256':sha(run/'independent_audit.json')};(run/'result_summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(summary,indent=2));return 0 if all_pass else 1
if __name__=='__main__':raise SystemExit(main())
