from __future__ import annotations
import argparse,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent; BUILD=HERE/'build'; RUNS=BUILD/'reviewer_runs'; SECTOR=512
H1_PROFILE={'machine':'pc-q35-11.1','cpu':'phenom','smp':'2,sockets=1,cores=2,threads=1','memory_mib':4096,'target_disk_bytes':500*1024**3,'accel':'tcg'}

def sha_bytes(b):return hashlib.sha256(b).hexdigest()
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def find_exe(env,names,fallback):
 v=os.environ.get(env)
 if v:
  p=Path(v).expanduser()
  if p.is_file():return p
  raise SystemExit(f'{env} missing: {p}')
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 p=Path(fallback)
 if p.is_file():return p
 raise SystemExit('missing '+names[0])
def qemu_runtime(qemu):
 env=os.environ.copy(); module=None; data=None
 explicit=os.environ.get('HOSTILE_QEMU_MODULE_DIR') or os.environ.get('QEMU_MODULE_DIR')
 if explicit:
  p=Path(explicit).expanduser();
  if not p.is_dir():raise SystemExit(f'QEMU module directory missing: {p}')
  module=str(p);env['QEMU_MODULE_DIR']=module
 else:
  for c in (qemu.parent/'modules',qemu.parent.parent/'modules'):
   if c.is_dir():module=str(c);env['QEMU_MODULE_DIR']=module;break
 explicit=os.environ.get('HOSTILE_QEMU_DATA_DIR') or os.environ.get('HOSTILE_QEMU_FIRMWARE')
 if explicit:
  p=Path(explicit).expanduser();
  if not p.is_dir():raise SystemExit(f'QEMU data directory missing: {p}')
  data=str(p)
 else:
  for c in (qemu.parent/'share/qemu',qemu.parent/'share',qemu.parent.parent/'share/qemu',qemu.parent.parent/'share'):
   if c.is_dir() and (c/'bios-256k.bin').is_file():data=str(c);break
 return env,module,data
def crc16(data):
 c=0xffff
 for b in data:
  c^=b<<8
  for _ in range(8):c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c
def record(seq,val,ae,re):
 p=bytearray(24);p[:4]=b'H4F1';p[4]=0x51;p[5]=val;p[6]=ae;p[7]=re;p[8]=0;p[9]=1;p[10]=ae;p[11]=0;p[12]=1;p[13]=0;p[14]=1;p[15]=re;p[16:18]=b'4\x12';p[18]=1;p[19]=0;p[20:24]=seq.to_bytes(4,'little');q=bytes(p)+crc16(bytes(p)).to_bytes(2,'little')+b'CMIT';return q+bytes(SECTOR-len(q))
def corrupt(r):x=bytearray(r);x[5]^=1;return bytes(x)
def control(mode):b=bytearray(SECTOR);b[:4]=b'V2MD';b[4]=ord(mode);return bytes(b)
def sector(path,lba):
 with Path(path).open('rb') as f:f.seek(lba*SECTOR);return f.read(SECTOR)
def make_image(base,path,mode,a=None,b=None):
 im=bytearray(base);im[19*SECTOR:20*SECTOR]=control(mode)
 if a is not None:im[17*SECTOR:18*SECTOR]=a
 if b is not None:im[18*SECTOR:19*SECTOR]=b
 Path(path).write_bytes(im)
def target_disk(qemu_img):
 p=BUILD/'h1_target_500g.qcow2'
 if not p.exists():subprocess.run([str(qemu_img),'create','-f','qcow2',str(p),'500G'],check=True,capture_output=True)
 return p
def boot(qemu,env,data,disk,debug,readonly,target):
 debug.unlink(missing_ok=True);ro=',readonly=on' if readonly else '';argv=[str(qemu)]
 if data:argv+=['-L',data]
 argv+=['-accel','tcg','-machine',H1_PROFILE['machine'],'-cpu',H1_PROFILE['cpu'],'-smp',H1_PROFILE['smp'],'-m',str(H1_PROFILE['memory_mib']),'-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={Path(disk).as_posix()},format=raw,if=floppy{ro}','-drive',f'file={target.as_posix()},format=qcow2,if=ide,index=0,media=disk','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9']
 t=time.perf_counter();p=subprocess.Popen(argv,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,env=env)
 try:_,err=p.communicate(timeout=15);status='COMPLETED';code=p.returncode
 except subprocess.TimeoutExpired:p.kill();_,err=p.communicate();status='UNKNOWN_TIMEOUT';code=None
 return {'pid':p.pid,'status':status,'exit_code':code,'wall_ms':(time.perf_counter()-t)*1000,'disk_sha256':sha(disk),'trace':debug.read_text(encoding='ascii',errors='replace').splitlines() if debug.exists() else [],'stderr':err.decode('utf-8',errors='replace') if err else '','argv':argv}
def run_simple(base,q,env,data,target,mode,name):
 d=RUNS/name;d.mkdir(parents=True,exist_ok=True);disk=d/(name+'.img');make_image(base,disk,mode);return boot(q,env,data,disk,d/'debugcon.txt',True,target)
def run_restart(base,q,env,data,target):
 d=RUNS/'restart';d.mkdir(parents=True,exist_ok=True);disk=d/'restart.img';make_image(base,disk,'R',bytes(SECTOR),bytes(SECTOR));initial=sha(disk);b1=boot(q,env,data,disk,d/'boot1.txt',False,target);after1=sha(disk);a1=sector(disk,17);b1sec=sector(disk,18);expected=record(1,0x71,1,1);before2=sha(disk);b2=boot(q,env,data,disk,d/'boot2.txt',True,target);after2=sha(disk);return {'initial_disk_sha256':initial,'boot1':b1,'a_after_boot1_exact_expected':a1==expected,'a_after_boot1_sha256':sha_bytes(a1),'b_after_boot1_zero':b1sec==bytes(SECTOR),'disk_sha256_after_boot1':after1,'no_host_write_between_boots':before2==after1,'boot2':b2,'disk_unchanged_during_recovery_boot':before2==after2,'disk_sha256_after_boot2':after2}
def run_faults(base,q,env,data,target):
 a1=record(1,0x71,1,1);b2=record(2,0x72,2,2);cases={'old_empty':(a1,bytes(SECTOR)),'newer_valid':(a1,b2),'newer_corrupt':(a1,corrupt(b2)),'equal_conflict':(record(2,0x72,2,2),record(2,0x73,2,2)),'both_invalid':(corrupt(a1),corrupt(b2))};out={}
 for name,(a,b) in cases.items():
  d=RUNS/'faulted_media'/name;d.mkdir(parents=True,exist_ok=True);disk=d/(name+'.img');make_image(base,disk,'F',a,b);before=sha(disk);br=boot(q,env,data,disk,d/'debugcon.txt',True,target);out[name]={'boot':br,'disk_unchanged':before==sha(disk),'a_sha256':sha_bytes(a),'b_sha256':sha_bytes(b)}
 return out
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--mode',choices=['all','smp','core','restart','faulted-media'],default='all');args=ap.parse_args();basep=BUILD/'d64_v3.img';assert basep.is_file(),'run build.py first';base=basep.read_bytes();RUNS.mkdir(parents=True,exist_ok=True)
 q=find_exe('HOSTILE_QEMU',['qemu-system-x86_64','qemu-system-x86_64.exe'],r'C:\Program Files\qemu\qemu-system-x86_64.exe');qi=find_exe('HOSTILE_QEMU_IMG',['qemu-img','qemu-img.exe'],r'C:\Program Files\qemu\qemu-img.exe');env,module,data=qemu_runtime(q);target=target_disk(qi)
 receipt={'format':'HOSTILE_OS_D64_V3_RUN_V1','body_class':'research-only','mode':args.mode,'h1_profile':H1_PROFILE,'qemu_module_dir':module,'qemu_data_dir':data,'base_disk_sha256':sha(basep),'target_disk_virtual_bytes':H1_PROFILE['target_disk_bytes']}
 if args.mode in ('all','smp'):receipt['smp']=run_simple(base,q,env,data,target,'S','smp')
 if args.mode in ('all','core'):receipt['core']=run_simple(base,q,env,data,target,'C','core')
 if args.mode in ('all','restart'):receipt['restart']=run_restart(base,q,env,data,target)
 if args.mode in ('all','faulted-media'):receipt['faulted_media']=run_faults(base,q,env,data,target)
 (BUILD/'run_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(receipt,indent=2));return 0
if __name__=='__main__':raise SystemExit(main())
