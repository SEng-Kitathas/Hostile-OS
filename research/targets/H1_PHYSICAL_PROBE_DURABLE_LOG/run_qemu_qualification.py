from __future__ import annotations
import datetime as dt,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
from extract_log import decode_image_bytes
H=Path(__file__).resolve().parent; ROOT=H.parents[2]
QEMU=Path(os.environ.get('HOSTILE_QEMU_X86_64',r'C:\Program Files\qemu\qemu-system-x86_64.exe'))
LOG_BASE=256; LOG_SECTORS=128; SECTOR=512

def sha_bytes(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def sha(p:Path)->str:return sha_bytes(p.read_bytes())
def git(*a):return subprocess.check_output(['git',*a],cwd=ROOT,text=True).strip()
def require_clean_source():
 cp=subprocess.run(['git','status','--porcelain','--','research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG'],cwd=ROOT,text=True,stdout=subprocess.PIPE,check=True)
 if cp.stdout.strip():raise SystemExit('durable-log qualification refuses dirty source:\n'+cp.stdout)
def outside_log_hash(b:bytes):
 a=LOG_BASE*SECTOR;z=(LOG_BASE+LOG_SECTORS)*SECTOR;return sha_bytes(b[:a]+b[z:])

def run_mode(mode:str,run:Path,base_image:Path):
 rd=run/mode;rd.mkdir(parents=True);image=rd/'boot.img';shutil.copy2(base_image,image)
 before=image.read_bytes();debug=rd/'debugcon.txt';out=rd/'qemu.stdout.txt';err=rd/'qemu.stderr.txt'
 cmd=[str(QEMU),'-machine','pc-q35-11.1,accel=tcg','-cpu','phenom','-smp','2,sockets=1,cores=2,threads=1','-m','4096','-nic','none','-display','none','-no-reboot','-debugcon',f'file:{debug}','-global','isa-debugcon.iobase=0xe9','-device','isa-debug-exit,iobase=0xf4,iosize=0x04']
 if mode=='floppy':cmd+=['-drive',f'file={image},format=raw,if=floppy','-boot','a']
 elif mode=='ide':cmd+=['-drive',f'if=none,id=bootdisk,file={image},format=raw','-device','ide-hd,drive=bootdisk,bootindex=1']
 else:raise ValueError(mode)
 st=dt.datetime.now(dt.timezone.utc);t0=time.monotonic()
 with out.open('wb') as fo,err.open('wb') as fe:
  p=subprocess.Popen(cmd,cwd=rd,stdout=fo,stderr=fe);pid=p.pid
  try:rc=p.wait(timeout=30);status='COMPLETED'
  except subprocess.TimeoutExpired:p.kill();p.wait();rc=None;status='TIMEOUT'
 en=dt.datetime.now(dt.timezone.utc);after=image.read_bytes();dbg=debug.read_text(encoding='ascii',errors='replace') if debug.exists() else ''
 journal=decode_image_bytes(after);jt=journal['text']
 required_debug=['H1LOG_BEGIN','H1LOG_PROBE_LOADED','H1LOG_CHAIN_PROBE','H1PROBE_BEGIN','CPU_VENDOR=','FW_RSDP=','E820_END','PCI_END','H1PROBE_END']
 required_debug.append('H1LOG_DISK=CHS' if mode=='floppy' else 'H1LOG_DISK=EDD')
 dmarks={x:x in dbg for x in required_debug};jmarks={x:x in jt for x in required_debug}
 a=LOG_BASE*SECTOR;z=(LOG_BASE+LOG_SECTORS)*SECTOR
 outside_same=outside_log_hash(before)==outside_log_hash(after)
 region_changed=before[a:z]!=after[a:z]
 qualified=status=='COMPLETED' and rc==67 and all(dmarks.values()) and all(jmarks.values()) and outside_same and region_changed and journal['record_count']>0
 (rd/'journal.txt').write_text(jt,encoding='ascii',errors='replace',newline='\n');(rd/'journal.json').write_text(json.dumps({k:v for k,v in journal.items() if k!='text_bytes'},indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 return {'mode':mode,'pid':pid,'status':status,'exit_code':rc,'started_utc':st.isoformat(),'ended_utc':en.isoformat(),'duration_s':round(time.monotonic()-t0,6),'qemu_argv':cmd,'debug_markers':dmarks,'journal_markers':jmarks,'journal_session':journal['session'],'journal_records':journal['record_count'],'journal_text_sha256':journal['text_sha256'],'outside_log_unchanged':outside_same,'journal_region_changed':region_changed,'image_sha256_before':sha_bytes(before),'image_sha256_after':sha_bytes(after),'qualified':qualified}

def main():
 require_clean_source()
 if not QEMU.is_file():raise SystemExit('QEMU missing')
 base=H/'build'/'h1_probe_durable_log_qemu.img'
 if not base.is_file():raise SystemExit('build first')
 ts=dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ');run=H/'runs'/f'{ts}_h1_durable_log_qemu_01';inp=run/'inputs';inp.mkdir(parents=True)
 files=['H1_DURABLE_LOG_PREREGISTRATION_2026-08-31.md','wrapper_stage1.S','wrapper_stage1.ld','text_loader.S','text_loader.ld','stage2.S','stage2.ld','build.py','verify_static.py','extract_log.py','run_qemu_qualification.py']
 for n in files:shutil.copy2(H/n,inp/n)
 for n in ['build_manifest.json','static_verification.json','h1_probe_durable_log_qemu.img']:shutil.copy2(H/'build'/n,inp/n)
 results=[run_mode(m,run,inp/'h1_probe_durable_log_qemu.img') for m in ('floppy','ide')]
 receipt={'format':'HOSTILE_H1_DURABLE_LOG_QEMU_DUAL_MODE_V1','source_head':git('rev-parse','HEAD'),'source_tree':git('rev-parse','HEAD:research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG'),'input_hashes':{p.name:sha(p) for p in inp.iterdir() if p.is_file()},'results':results,'qualified':all(r['qualified'] for r in results)}
 (run/'run_receipt.json').write_text(json.dumps(receipt,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps({'run_dir':str(run.relative_to(ROOT)),'source_head':receipt['source_head'],'qualified':receipt['qualified'],'modes':[{k:r[k] for k in ('mode','pid','status','exit_code','journal_records','journal_session','outside_log_unchanged','qualified')} for r in results]},indent=2));return 0 if receipt['qualified'] else 1
if __name__=='__main__':raise SystemExit(main())
