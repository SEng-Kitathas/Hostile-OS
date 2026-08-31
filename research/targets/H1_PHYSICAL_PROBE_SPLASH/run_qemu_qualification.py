from __future__ import annotations
import datetime as dt,hashlib,json,os,shutil,socket,subprocess,time
from pathlib import Path
H=Path(__file__).resolve().parent; ROOT=H.parents[2]
QEMU=Path(os.environ.get('HOSTILE_QEMU_X86_64',r'C:\Program Files\qemu\qemu-system-x86_64.exe'))

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''):h.update(c)
 return h.hexdigest()
def git(*a):return subprocess.check_output(['git',*a],cwd=ROOT,text=True).strip()
def require_clean_source():
 cp=subprocess.run(['git','status','--porcelain','--','research/targets/H1_PHYSICAL_PROBE_SPLASH'],cwd=ROOT,text=True,stdout=subprocess.PIPE,check=True)
 if cp.stdout.strip():
  raise SystemExit('splash qualification refuses dirty tracked/untracked source state:\n'+cp.stdout)
def free_port():
 s=socket.socket(); s.bind(('127.0.0.1',0)); p=s.getsockname()[1]; s.close(); return p

def hmp_screendump(port:int,cwd:Path):
 deadline=time.monotonic()+3; last=''
 while time.monotonic()<deadline:
  try:
   with socket.create_connection(('127.0.0.1',port),timeout=.5) as s:
    s.settimeout(.5)
    try:last+=s.recv(4096).decode(errors='replace')
    except Exception:pass
    s.sendall(b'screendump splash.ppm\n')
    time.sleep(.2)
    try:last+=s.recv(4096).decode(errors='replace')
    except Exception:pass
    return last
  except OSError as e:
   last=str(e); time.sleep(.05)
 raise RuntimeError('HMP unavailable: '+last)

def parse_ppm(p:Path):
 b=p.read_bytes(); pos=0; toks=[]
 while len(toks)<4:
  while pos<len(b) and b[pos] in b' \t\r\n':pos+=1
  if b[pos:pos+1]==b'#':
   pos=b.find(b'\n',pos)+1; continue
  end=pos
  while end<len(b) and b[end] not in b' \t\r\n':end+=1
  toks.append(b[pos:end]); pos=end
 while pos<len(b) and b[pos] in b' \t\r\n':pos+=1
 if toks[0]!=b'P6':raise ValueError('not P6')
 w,h,maxv=map(int,toks[1:]); data=b[pos:]
 if maxv!=255 or len(data)!=w*h*3:raise ValueError((w,h,maxv,len(data)))
 return w,h,data

def expected_rgb():
 pal=(H/'splash_palette_32xrgb6.bin').read_bytes(); pix=(H/'splash_pixels_320x200.bin').read_bytes()
 rgb=[]
 for i in range(32):
  trip=[]
  for v in pal[i*3:i*3+3]:trip.append((v<<2)|(3 if (v&1) else 0))
  rgb.append(bytes(trip))
 return b''.join(rgb[x] for x in pix)
def screen_check(ppm:Path):
 w,h,data=parse_ppm(ppm); exp=expected_rgb()
 if (w,h)==(320,200):
  ok=data==exp; mode='320x200-direct'
 elif (w,h)==(640,400):
  out=bytearray(320*200*3)
  for y in range(200):
   for x in range(320):
    src=((y*2)*640+(x*2))*3; dst=(y*320+x)*3
    p=data[src:src+3]
    # Require the full 2x2 doubled block, not merely one sampled point.
    for yy in (0,1):
     for xx in (0,1):
      s=(((y*2)+yy)*640+((x*2)+xx))*3
      if data[s:s+3]!=p:return {'pass':False,'width':w,'height':h,'mode':'640x400-nonuniform-2x2'}
    out[dst:dst+3]=p
  ok=bytes(out)==exp; mode='640x400-2x2'
 else:
  return {'pass':False,'width':w,'height':h,'mode':'unsupported-dimensions','ppm_sha256':sha(ppm)}
 return {'pass':ok,'width':w,'height':h,'mode':mode,'ppm_sha256':sha(ppm),'expected_rgb_sha256':hashlib.sha256(exp).hexdigest(),'observed_normalized_sha256':hashlib.sha256(exp if ok else data).hexdigest()}

def run_mode(mode:str,run:Path,image:Path):
 rd=run/mode; rd.mkdir(parents=True)
 debug=rd/'debugcon.txt'; out=rd/'qemu.stdout.txt'; err=rd/'qemu.stderr.txt'; port=free_port()
 base=[str(QEMU),'-machine','pc-q35-11.1,accel=tcg','-cpu','phenom','-smp','2,sockets=1,cores=2,threads=1','-m','4096','-nic','none','-display','none','-no-reboot','-monitor',f'tcp:127.0.0.1:{port},server,nowait','-debugcon',f'file:{debug}','-global','isa-debugcon.iobase=0xe9','-device','isa-debug-exit,iobase=0xf4,iosize=0x04']
 if mode=='floppy':base += ['-drive',f'file={image},format=raw,if=floppy,readonly=on','-boot','a']
 elif mode=='ide':base += ['-drive',f'if=none,id=bootdisk,file={image},format=raw,snapshot=on','-device','ide-hd,drive=bootdisk,bootindex=1']
 else:raise ValueError(mode)
 image_before=sha(image); started=dt.datetime.now(dt.timezone.utc); t0=time.monotonic(); monitor=''; screenshot_requested=False
 with out.open('wb') as fo,err.open('wb') as fe:
  proc=subprocess.Popen(base,cwd=rd,stdout=fo,stderr=fe); pid=proc.pid
  deadline=time.monotonic()+20
  while time.monotonic()<deadline and proc.poll() is None:
   txt=debug.read_text(encoding='ascii',errors='replace') if debug.exists() else ''
   if not screenshot_requested and 'H1SPLASH_VISIBLE' in txt:
    monitor=hmp_screendump(port,rd); screenshot_requested=True
   time.sleep(.02)
  if proc.poll() is None:
   proc.kill(); proc.wait(); rc=None; status='TIMEOUT'
  else:rc=proc.returncode; status='COMPLETED'
 ended=dt.datetime.now(dt.timezone.utc); text=debug.read_text(encoding='ascii',errors='replace') if debug.exists() else ''
 ppm=rd/'splash.ppm'; screen=screen_check(ppm) if ppm.exists() else {'pass':False,'mode':'missing'}
 required=['H1SPLASH_PALETTE_OK','H1SPLASH_PIXELS_LOADED','H1SPLASH_PROBE_LOADED','H1SPLASH_VISIBLE','H1SPLASH_CHAIN_PROBE','H1PROBE_BEGIN','CPU_VENDOR=','FW_RSDP=','E820_END','PCI_END','H1PROBE_END']
 required.append('H1SPLASH_DISK=CHS' if mode=='floppy' else 'H1SPLASH_DISK=EDD')
 markers={x:(x in text) for x in required}
 image_after=sha(image)
 return {'mode':mode,'pid':pid,'status':status,'exit_code':rc,'started_utc':started.isoformat(),'ended_utc':ended.isoformat(),'duration_s':round(time.monotonic()-t0,6),'qemu_argv':base,'markers':markers,'screenshot':screen,'debug_sha256':sha(debug) if debug.exists() else None,'stdout_sha256':sha(out),'stderr_sha256':sha(err),'monitor_reply':monitor,'backing_image_sha256_before':image_before,'backing_image_sha256_after':image_after,'backing_image_unchanged':image_before==image_after,'qualified':status=='COMPLETED' and rc==67 and all(markers.values()) and screen.get('pass',False) and image_before==image_after}

def main():
 require_clean_source()
 if not QEMU.is_file():raise SystemExit('QEMU missing')
 image=H/'build'/'h1_probe_splash_qemu.img'
 if not image.is_file():raise SystemExit('build first')
 ts=dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ'); run=H/'runs'/f'{ts}_h1_splash_wrapper_qemu_01'; inp=run/'inputs'; inp.mkdir(parents=True)
 files=['H1_SPLASH_WRAPPER_PREREGISTRATION_2026-08-31.md','ASSET_PROVENANCE.md','wrapper_stage1.S','wrapper_stage1.ld','splash_loader.S','splash_loader.ld','build.py','verify_static.py','run_qemu_qualification.py','splash_palette_32xrgb6.bin','splash_pixels_320x200.bin']
 for n in files:shutil.copy2(H/n,inp/n)
 for n in ['build_manifest.json','static_verification.json','h1_probe_splash_qemu.img']:shutil.copy2(H/'build'/n,inp/n)
 image=inp/'h1_probe_splash_qemu.img'
 results=[run_mode(m,run,image) for m in ('floppy','ide')]
 receipt={'format':'HOSTILE_H1_SPLASH_QEMU_DUAL_MODE_V1','source_head':git('rev-parse','HEAD'),'source_tree':git('rev-parse','HEAD:research/targets/H1_PHYSICAL_PROBE_SPLASH'),'input_hashes':{p.name:sha(p) for p in inp.iterdir() if p.is_file()},'results':results,'qualified':all(r['qualified'] for r in results)}
 (run/'run_receipt.json').write_text(json.dumps(receipt,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps({'run_dir':str(run.relative_to(ROOT)),'source_head':receipt['source_head'],'qualified':receipt['qualified'],'modes':[{k:r[k] for k in ('mode','pid','status','exit_code','qualified','screenshot')} for r in results]},indent=2))
 return 0 if receipt['qualified'] else 1
if __name__=='__main__':raise SystemExit(main())
