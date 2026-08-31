from __future__ import annotations
import argparse,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;BUILD=HERE/'build';RUNS=BUILD/'reviewer_runs';SECTOR=512

def sha_bytes(b):return hashlib.sha256(b).hexdigest()
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def find_qemu():
 v=os.environ.get('HOSTILE_QEMU')
 if v:
  p=Path(v).expanduser()
  if p.is_file():return p
  raise SystemExit(f'HOSTILE_QEMU missing: {p}')
 q=shutil.which('qemu-system-i386') or shutil.which('qemu-system-i386.exe')
 if q:return Path(q)
 p=Path(r'C:\Program Files\qemu\qemu-system-i386.exe')
 if p.is_file():return p
 raise SystemExit('qemu-system-i386 not found')
def qemu_runtime(qemu):
 env=os.environ.copy()
 module_explicit=os.environ.get('HOSTILE_QEMU_MODULE_DIR') or os.environ.get('QEMU_MODULE_DIR')
 module_dir=None
 if module_explicit:
  p=Path(module_explicit).expanduser()
  if not p.is_dir():raise SystemExit(f'QEMU module directory missing: {p}')
  module_dir=str(p);env['QEMU_MODULE_DIR']=module_dir
 else:
  for c in (qemu.parent/'modules',qemu.parent.parent/'modules'):
   if c.is_dir():module_dir=str(c);env['QEMU_MODULE_DIR']=module_dir;break
 data_explicit=os.environ.get('HOSTILE_QEMU_DATA_DIR') or os.environ.get('HOSTILE_QEMU_FIRMWARE')
 data_dir=None
 if data_explicit:
  p=Path(data_explicit).expanduser()
  if not p.is_dir():raise SystemExit(f'QEMU data/firmware directory missing: {p}')
  data_dir=str(p)
 else:
  for c in (qemu.parent/'share/qemu',qemu.parent/'share',qemu.parent.parent/'share/qemu',qemu.parent.parent/'share'):
   if c.is_dir() and (c/'bios-256k.bin').is_file():data_dir=str(c);break
 return env,module_dir,data_dir
def crc16(data):
 c=0xffff
 for b in data:
  c ^= b<<8
  for _ in range(8):c=((c<<1)^0x1021)&0xffff if c&0x8000 else (c<<1)&0xffff
 return c
def record(seq,val,ae,re):
 p=bytearray(24);p[:4]=b'H4F1';p[4]=0x51;p[5]=val;p[6]=ae;p[7]=re;p[8]=0;p[9]=1;p[10]=ae;p[11]=0;p[12]=1;p[13]=0;p[14]=1;p[15]=re;p[16:18]=b'4\x12';p[18]=1;p[19]=0;p[20:24]=seq.to_bytes(4,'little');q=bytes(p)+crc16(bytes(p)).to_bytes(2,'little')+b'CMIT';return q+bytes(SECTOR-len(q))
def corrupt(r):
 x=bytearray(r);x[5]^=1;return bytes(x)
def control(mode):
 b=bytearray(SECTOR);b[:4]=b'V2MD';b[4]=ord(mode);return bytes(b)
def sector(path,lba):
 with Path(path).open('rb') as f:f.seek(lba*SECTOR);return f.read(SECTOR)
def make_image(base,path,mode,a=None,b=None):
 im=bytearray(base);im[19*SECTOR:20*SECTOR]=control(mode)
 if a is not None:im[17*SECTOR:18*SECTOR]=a
 if b is not None:im[18*SECTOR:19*SECTOR]=b
 Path(path).write_bytes(im)
def boot(qemu,env,data_dir,disk,debug,readonly):
 debug.unlink(missing_ok=True);ro=',readonly=on' if readonly else '';argv=[str(qemu)]
 if data_dir:argv += ['-L',data_dir]
 argv += ['-accel','tcg','-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a','-drive',f'file={Path(disk).as_posix()},format=raw,if=floppy{ro}','-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9'];t=time.perf_counter();p=subprocess.Popen(argv,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,env=env)
 try:_,err=p.communicate(timeout=10);status='COMPLETED';code=p.returncode
 except subprocess.TimeoutExpired:p.kill();_,err=p.communicate();status='UNKNOWN_TIMEOUT';code=None
 return {'pid':p.pid,'status':status,'exit_code':code,'wall_ms':(time.perf_counter()-t)*1000,'disk_sha256':sha(disk),'trace':debug.read_text(encoding='ascii',errors='replace').splitlines() if debug.exists() else [],'stderr':err.decode('utf-8',errors='replace') if err else '','argv':argv}
def run_core(base,q,env,data):
 d=RUNS/'core';d.mkdir(parents=True,exist_ok=True);disk=d/'core.img';make_image(base,disk,'C');return boot(q,env,data,disk,d/'debugcon.txt',True)
def run_restart(base,q,env,data):
 d=RUNS/'restart';d.mkdir(parents=True,exist_ok=True);disk=d/'restart.img';make_image(base,disk,'R',bytes(SECTOR),bytes(SECTOR));initial=sha(disk);b1=boot(q,env,data,disk,d/'boot1.txt',False);after1=sha(disk);a1=sector(disk,17);b1sec=sector(disk,18);expected_a=record(1,0x71,1,1);before2=sha(disk);b2=boot(q,env,data,disk,d/'boot2.txt',True);after2=sha(disk);return {'initial_disk_sha256':initial,'boot1':b1,'a_after_boot1_sha256':sha_bytes(a1),'a_after_boot1_exact_expected':a1==expected_a,'b_after_boot1_zero':b1sec==bytes(SECTOR),'disk_sha256_after_boot1':after1,'no_host_write_between_boots':before2==after1,'boot2':b2,'disk_unchanged_during_recovery_boot':before2==after2,'disk_sha256_after_boot2':after2}
def run_faults(base,q,env,data):
 a1=record(1,0x71,1,1);b2=record(2,0x72,2,2);cases={
  'old_empty':(a1,bytes(SECTOR)),
  'newer_valid':(a1,b2),
  'newer_corrupt':(a1,corrupt(b2)),
  'equal_conflict':(record(2,0x72,2,2),record(2,0x73,2,2)),
  'both_invalid':(corrupt(a1),corrupt(b2)),
 }
 out={}
 for name,(a,b) in cases.items():
  d=RUNS/'faulted_media'/name;d.mkdir(parents=True,exist_ok=True);disk=d/(name+'.img');make_image(base,disk,'F',a,b);before=sha(disk);br=boot(q,env,data,disk,d/'debugcon.txt',True);out[name]={'boot':br,'disk_unchanged':before==sha(disk),'a_sha256':sha_bytes(a),'b_sha256':sha_bytes(b)}
 return out
def main()->int:
 ap=argparse.ArgumentParser();ap.add_argument('--mode',choices=['all','core','restart','faulted-media'],default='all');args=ap.parse_args();base_path=BUILD/'d64_v2.img';assert base_path.is_file(),'run build.py first';base=base_path.read_bytes();RUNS.mkdir(exist_ok=True);q=find_qemu();env,module,data=qemu_runtime(q);receipt={'format':'HOSTILE_OS_D64_V2_RUN_V2','body_status':'CURRENT_RESEARCH_REFERENCE','mode':args.mode,'qemu_module_dir':module,'qemu_data_dir':data,'base_disk_sha256':sha(base_path)}
 if args.mode in ('all','core'):receipt['core']=run_core(base,q,env,data)
 if args.mode in ('all','restart'):receipt['restart']=run_restart(base,q,env,data)
 if args.mode in ('all','faulted-media'):receipt['faulted_media']=run_faults(base,q,env,data)
 (BUILD/'run_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(receipt,indent=2));return 0
if __name__=='__main__':raise SystemExit(main())
