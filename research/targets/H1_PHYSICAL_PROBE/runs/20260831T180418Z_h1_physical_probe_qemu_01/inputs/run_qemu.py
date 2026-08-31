from __future__ import annotations
import datetime,hashlib,json,os,shutil,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''):h.update(c)
 return h.hexdigest()
def git(*a):return subprocess.check_output(['git',*a],cwd=ROOT,text=True).strip()
def main():
 q=Path(os.environ.get('HOSTILE_QEMU_X86_64',r'C:\Program Files\qemu\qemu-system-x86_64.exe'))
 if not q.is_file():raise SystemExit(f'QEMU missing: {q}')
 image=HERE/'build'/'h1_probe_qemu.img'
 if not image.is_file():raise SystemExit('build first')
 ts=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
 rd=HERE/'runs'/f'{ts}_h1_physical_probe_qemu_01'; inp=rd/'inputs'; inp.mkdir(parents=True)
 names=['H1_PHYSICAL_PROBE_PREREGISTRATION_2026-08-31.md','H1_PHYSICAL_PROBE_AMENDMENT_A_2026-08-31.md','H1_PHYSICAL_PROBE_SCAR_A_2026-08-31.md','stage1.S','stage1.ld','stage2.S','stage2.ld','build.py','run_qemu.py']
 for n in names:shutil.copy2(HERE/n,inp/n)
 shutil.copy2(HERE/'build'/'build_manifest.json',inp/'build_manifest.json')
 shutil.copy2(image,inp/'h1_probe_qemu.img')
 debug=rd/'debugcon.txt'; err=rd/'qemu.stderr.txt'; out=rd/'qemu.stdout.txt'
 cmd=[str(q),'-machine','pc-q35-11.1,accel=tcg','-cpu','phenom','-smp','2,sockets=1,cores=2,threads=1','-m','4096','-nic','none','-display','none','-no-reboot','-drive',f'file={inp / "h1_probe_qemu.img"},format=raw,if=floppy,readonly=on','-boot','a','-debugcon',f'file:{debug}','-global','isa-debugcon.iobase=0xe9','-device','isa-debug-exit,iobase=0xf4,iosize=0x04']
 start=datetime.datetime.now(datetime.timezone.utc); t0=time.monotonic()
 with out.open('wb') as fo,err.open('wb') as fe:
  proc=subprocess.Popen(cmd,cwd=ROOT,stdout=fo,stderr=fe)
  pid=proc.pid
  try: rc=proc.wait(timeout=30)
  except subprocess.TimeoutExpired:
   proc.kill(); proc.wait(); raise
 end=datetime.datetime.now(datetime.timezone.utc)
 text=debug.read_text(encoding='ascii',errors='replace') if debug.exists() else ''
 required=['H1PROBE_BEGIN','CPU_VENDOR=','CPU_L1 ','CPU_DEC ','BOOT_DRIVE=','BOOT_GEOM ','BOOT_EXT=','FW_EBDA=','FW_RSDP=','IRQ_PIC_MASK=','IRQ_CAP ','IRQ_APIC_BASE=','E820_BEGIN','E820_END','PCI_BEGIN','PCI_END','H1PROBE_END']
 checks={x:(x in text) for x in required}
 receipt={'format':'HOSTILE_H1_PHYSICAL_PROBE_QEMU_RUN_V1','source_head':git('rev-parse','HEAD'),'source_tree':git('rev-parse','HEAD:research/targets/H1_PHYSICAL_PROBE'),'start_utc':start.isoformat(),'end_utc':end.isoformat(),'duration_s':round(time.monotonic()-t0,6),'qemu_pid':pid,'qemu_exit_code':rc,'command':cmd,'input_hashes':{p.name:sha(p) for p in inp.iterdir() if p.is_file()},'debug_sha256':sha(debug),'stdout_sha256':sha(out),'stderr_sha256':sha(err),'required_markers':checks,'qualified':rc==67 and all(checks.values())}
 (rd/'run_receipt.json').write_text(json.dumps(receipt,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps({'run_dir':str(rd.relative_to(ROOT)),'exit':rc,'pid':pid,'qualified':receipt['qualified'],'debug_sha256':receipt['debug_sha256'],'source_head':receipt['source_head']},indent=2))
 return 0 if receipt['qualified'] else 1
if __name__=='__main__':raise SystemExit(main())
