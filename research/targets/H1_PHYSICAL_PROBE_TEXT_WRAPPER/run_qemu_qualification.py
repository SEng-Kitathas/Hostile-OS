from __future__ import annotations
import datetime as dt,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
H=Path(__file__).resolve().parent; ROOT=H.parents[2]
QEMU=Path(os.environ.get('HOSTILE_QEMU_X86_64',r'C:\Program Files\qemu\qemu-system-x86_64.exe'))

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''): h.update(c)
 return h.hexdigest()
def git(*a): return subprocess.check_output(['git',*a],cwd=ROOT,text=True).strip()
def require_clean_source():
 cp=subprocess.run(['git','status','--porcelain','--','research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER'],cwd=ROOT,text=True,stdout=subprocess.PIPE,check=True)
 if cp.stdout.strip(): raise SystemExit('text-wrapper qualification refuses dirty source:\n'+cp.stdout)

def run_mode(mode:str,run:Path,image:Path):
 rd=run/mode; rd.mkdir(parents=True)
 debug=rd/'debugcon.txt'; out=rd/'qemu.stdout.txt'; err=rd/'qemu.stderr.txt'
 cmd=[str(QEMU),'-machine','pc-q35-11.1,accel=tcg','-cpu','phenom','-smp','2,sockets=1,cores=2,threads=1','-m','4096','-nic','none','-display','none','-no-reboot','-debugcon',f'file:{debug}','-global','isa-debugcon.iobase=0xe9','-device','isa-debug-exit,iobase=0xf4,iosize=0x04']
 if mode=='floppy': cmd += ['-drive',f'file={image},format=raw,if=floppy,readonly=on','-boot','a']
 elif mode=='ide': cmd += ['-drive',f'if=none,id=bootdisk,file={image},format=raw,snapshot=on','-device','ide-hd,drive=bootdisk,bootindex=1']
 else: raise ValueError(mode)
 before=sha(image); start=dt.datetime.now(dt.timezone.utc); t0=time.monotonic()
 with out.open('wb') as fo,err.open('wb') as fe:
  p=subprocess.Popen(cmd,cwd=rd,stdout=fo,stderr=fe); pid=p.pid
  try: rc=p.wait(timeout=20); status='COMPLETED'
  except subprocess.TimeoutExpired: p.kill(); p.wait(); rc=None; status='TIMEOUT'
 end=dt.datetime.now(dt.timezone.utc); text=debug.read_text(encoding='ascii',errors='replace') if debug.exists() else ''
 required=['H1TEXT_BEGIN','H1TEXT_WRAPPER_OK','H1TEXT_CHAIN_PROBE','H1PROBE_BEGIN','CPU_VENDOR=','FW_RSDP=','E820_END','PCI_END','H1PROBE_END']
 required.append('H1TEXT_DISK=CHS' if mode=='floppy' else 'H1TEXT_DISK=EDD')
 markers={x:(x in text) for x in required}; after=sha(image)
 return {'mode':mode,'pid':pid,'status':status,'exit_code':rc,'started_utc':start.isoformat(),'ended_utc':end.isoformat(),'duration_s':round(time.monotonic()-t0,6),'qemu_argv':cmd,'markers':markers,'debug_sha256':sha(debug) if debug.exists() else None,'stdout_sha256':sha(out),'stderr_sha256':sha(err),'backing_image_sha256_before':before,'backing_image_sha256_after':after,'backing_image_unchanged':before==after,'qualified':status=='COMPLETED' and rc==67 and all(markers.values()) and before==after}

def main():
 require_clean_source()
 if not QEMU.is_file(): raise SystemExit('QEMU missing')
 image=H/'build'/'h1_probe_text_qemu.img'
 if not image.is_file(): raise SystemExit('build first')
 ts=dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ'); run=H/'runs'/f'{ts}_h1_text_wrapper_qemu_01'; inp=run/'inputs'; inp.mkdir(parents=True)
 files=['H1_TEXT_WRAPPER_PREREGISTRATION_2026-08-31.md','wrapper_stage1.S','wrapper_stage1.ld','text_loader.S','text_loader.ld','build.py','verify_static.py','run_qemu_qualification.py']
 for n in files: shutil.copy2(H/n,inp/n)
 for n in ['build_manifest.json','static_verification.json','h1_probe_text_qemu.img']: shutil.copy2(H/'build'/n,inp/n)
 image=inp/'h1_probe_text_qemu.img'; results=[run_mode(m,run,image) for m in ('floppy','ide')]
 receipt={'format':'HOSTILE_H1_TEXT_WRAPPER_QEMU_DUAL_MODE_V1','source_head':git('rev-parse','HEAD'),'source_tree':git('rev-parse','HEAD:research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER'),'input_hashes':{p.name:sha(p) for p in inp.iterdir() if p.is_file()},'results':results,'qualified':all(r['qualified'] for r in results)}
 (run/'run_receipt.json').write_text(json.dumps(receipt,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps({'run_dir':str(run.relative_to(ROOT)),'source_head':receipt['source_head'],'qualified':receipt['qualified'],'modes':[{k:r[k] for k in ('mode','pid','status','exit_code','qualified')} for r in results]},indent=2)); return 0 if receipt['qualified'] else 1
if __name__=='__main__': raise SystemExit(main())
