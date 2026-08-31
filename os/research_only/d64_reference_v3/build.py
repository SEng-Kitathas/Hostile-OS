from __future__ import annotations
import hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent; BUILD=HERE/'build'
EXPECTED_STATE_BYTES=3467; EXPECTED_IMAGE_BYTES=8089; EXPECTED_RAW_BYTES=4494; EXPECTED_SCRATCH_USED=62; STAGE2_ENVELOPE=8192

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def identity(p:Path)->Path:
 try:return p.resolve(strict=True)
 except (OSError,RuntimeError):return p.absolute()
def find_tool(env,names,llvm=None):
 v=os.environ.get(env)
 if v:
  p=Path(v).expanduser();
  if p.is_file():return p
  raise SystemExit(f'{env} missing: {p}')
 if llvm:
  for n in names:
   p=llvm/n
   if p.is_file():return p
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 raise SystemExit(f'missing {env}: {names}')
def version(path):
 cp=subprocess.run([str(path),'--version'],capture_output=True,text=True,check=False); x=cp.stdout or cp.stderr; return x.splitlines()[0] if x else ''
def run(a):subprocess.run(a,cwd=HERE,check=True)
def syms(nm,elf):
 out=subprocess.check_output([str(nm),'-n',str(elf)],cwd=HERE,text=True); d={}
 for line in out.splitlines():
  q=line.split()
  if len(q)>=3:
   try:d[q[-1]]=int(q[0],16)
   except ValueError:pass
 return out,d
def main():
 BUILD.mkdir(exist_ok=True); llvm=Path(os.environ['HOSTILE_LLVM_BIN']).expanduser() if os.environ.get('HOSTILE_LLVM_BIN') else None
 clang=find_tool('HOSTILE_CLANG',['clang','clang.exe'],llvm); lld=find_tool('HOSTILE_LLD',['ld.lld','ld.lld.exe'],llvm); obj=find_tool('HOSTILE_OBJCOPY',['llvm-objcopy','llvm-objcopy.exe'],llvm); nm=find_tool('HOSTILE_NM',['llvm-nm','llvm-nm.exe'],llvm)
 for n in ('stage1','stage2'):
  run([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c',n+'.S','-o',str(BUILD/(n+'.o'))]); run([str(lld),'-m','elf_i386','-T',n+'.ld','-Map='+str(BUILD/(n+'.map')),str(BUILD/(n+'.o')),'-o',str(BUILD/(n+'.elf'))]); run([str(obj),'-O','binary',str(BUILD/(n+'.elf')),str(BUILD/(n+'.raw.bin'))])
 s1=(BUILD/'stage1.raw.bin').read_bytes(); raw=(BUILD/'stage2.raw.bin').read_bytes(); assert len(s1)==512 and s1[510:]==b'\x55\xaa'; assert len(raw)==EXPECTED_RAW_BYTES,(len(raw),EXPECTED_RAW_BYTES)
 nmtext,s=symbols=syms(nm,BUILD/'stage2.elf'); (BUILD/'stage2.nm.txt').write_text(nmtext,encoding='utf-8',newline='\n')
 needed=['__image_start','__image_end','v2_state_begin','v2_state_end','implementation_scratch','implementation_scratch_used_end']; missing=[x for x in needed if x not in s]; assert not missing,missing
 image=s['__image_end']-s['__image_start']; state=s['v2_state_end']-s['v2_state_begin']; scratch=s['implementation_scratch_used_end']-s['implementation_scratch']
 assert image==EXPECTED_IMAGE_BYTES,(image,EXPECTED_IMAGE_BYTES); assert state==EXPECTED_STATE_BYTES,(state,EXPECTED_STATE_BYTES); assert scratch==EXPECTED_SCRATCH_USED,(scratch,EXPECTED_SCRATCH_USED); assert image<=STAGE2_ENVELOPE
 padded=raw+bytes(STAGE2_ENVELOPE-len(raw)); (BUILD/'stage2.padded.bin').write_bytes(padded); disk=bytearray(1474560); disk[:512]=s1; disk[512:512+8192]=padded; (BUILD/'d64_v3.img').write_bytes(disk)
 tools={}
 for name,p in [('clang',clang),('lld',lld),('objcopy',obj),('nm',nm)]:
  ip=identity(p); tools[name]={'invocation_path':str(p),'identity_path':str(ip),'version':version(p),'sha256':sha(ip)}
 manifest={'format':'HOSTILE_OS_D64_V3_BUILD_V1','body_class':'research-only','sources':{n:{'bytes':(HERE/n).stat().st_size,'sha256':sha(HERE/n)} for n in ['stage1.S','stage1.ld','stage2.S','stage2.ld','build.py','run.py','verify.py']},'stage1':{'bytes':len(s1),'sha256':sha(BUILD/'stage1.raw.bin'),'signature_55aa':s1[510:]==b'\x55\xaa'},'stage2':{'raw_bytes':len(raw),'raw_sha256':sha(BUILD/'stage2.raw.bin'),'padded_bytes':len(padded),'padded_sha256':sha(BUILD/'stage2.padded.bin'),'envelope_bytes':STAGE2_ENVELOPE,'image_memory_bytes':image,'headroom_bytes':STAGE2_ENVELOPE-image},'state':{'expected_bytes':EXPECTED_STATE_BYTES,'actual_bytes':state},'implementation_scratch':{'used_bytes':scratch,'capacity_bytes':128},'disk':{'bytes':len(disk),'sha256':sha(BUILD/'d64_v3.img')},'tools':tools}
 (BUILD/'build_manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(manifest,indent=2)); return 0
if __name__=='__main__':raise SystemExit(main())
