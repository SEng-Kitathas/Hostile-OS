from __future__ import annotations
import hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
BUILD=HERE/'build'
EXPECTED_STATE_BYTES=3467
STAGE2_ENVELOPE=8192

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
 return h.hexdigest()
def resolved_identity_path(path:Path)->Path:
 try:return path.resolve(strict=True)
 except (OSError,RuntimeError):return path.absolute()
def find_tool(env,names,llvm=None):
 v=os.environ.get(env)
 if v:
  p=Path(v).expanduser()
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
 cp=subprocess.run([str(path),'--version'],capture_output=True,text=True,check=False);return (cp.stdout or cp.stderr).splitlines()[0] if (cp.stdout or cp.stderr) else ''
def run(argv):subprocess.run(argv,cwd=HERE,check=True)
def symbol_map(nm,elf):
 out=subprocess.check_output([str(nm),'-n',str(elf)],cwd=HERE,text=True); syms={}
 for line in out.splitlines():
  parts=line.split()
  if len(parts)>=3:
   try:syms[parts[-1]]=int(parts[0],16)
   except ValueError:pass
 return out,syms
def main()->int:
 BUILD.mkdir(exist_ok=True)
 llvm_env=os.environ.get('HOSTILE_LLVM_BIN');llvm=Path(llvm_env).expanduser() if llvm_env else None
 clang=find_tool('HOSTILE_CLANG',['clang','clang.exe'],llvm);lld=find_tool('HOSTILE_LLD',['ld.lld','ld.lld.exe'],llvm);obj=find_tool('HOSTILE_OBJCOPY',['llvm-objcopy','llvm-objcopy.exe'],llvm);nm=find_tool('HOSTILE_NM',['llvm-nm','llvm-nm.exe'],llvm)
 run([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c','stage1.S','-o',str(BUILD/'stage1.o')]);run([str(lld),'-m','elf_i386','-T','stage1.ld',str(BUILD/'stage1.o'),'-o',str(BUILD/'stage1.elf')]);run([str(obj),'-O','binary',str(BUILD/'stage1.elf'),str(BUILD/'stage1.bin')])
 run([str(clang),'-target','i386-unknown-none-elf','-ffreestanding','-c','stage2.S','-o',str(BUILD/'stage2.o')]);run([str(lld),'-m','elf_i386','-T','stage2.ld','-Map='+str(BUILD/'stage2.map'),str(BUILD/'stage2.o'),'-o',str(BUILD/'stage2.elf')]);run([str(obj),'-O','binary',str(BUILD/'stage2.elf'),str(BUILD/'stage2.raw.bin')])
 s1=(BUILD/'stage1.bin').read_bytes();raw=(BUILD/'stage2.raw.bin').read_bytes();assert len(s1)==512 and s1[510:]==b'\x55\xaa';assert len(raw)<=STAGE2_ENVELOPE
 padded=raw+bytes(STAGE2_ENVELOPE-len(raw));(BUILD/'stage2.padded.bin').write_bytes(padded);disk=bytearray(1474560);disk[:512]=s1;disk[512:512+STAGE2_ENVELOPE]=padded;(BUILD/'d64_v2.img').write_bytes(disk)
 nm_text,syms=symbol_map(nm,BUILD/'stage2.elf');(BUILD/'stage2.nm.txt').write_text(nm_text,encoding='utf-8',newline='\n')
 needed=['__image_start','__image_end','v2_state_begin','v2_state_end'];missing=[x for x in needed if x not in syms];assert not missing,missing
 state_bytes=syms['v2_state_end']-syms['v2_state_begin'];image_memory_bytes=syms['__image_end']-syms['__image_start'];assert state_bytes==EXPECTED_STATE_BYTES,(state_bytes,EXPECTED_STATE_BYTES);assert image_memory_bytes<=STAGE2_ENVELOPE
 tools={}
 for name,path in [('clang',clang),('lld',lld),('objcopy',obj),('nm',nm)]:
  ident=resolved_identity_path(path);tools[name]={'invocation_path':str(path),'identity_path':str(ident),'version':version(path),'sha256':sha(ident)}
 manifest={'format':'HOSTILE_OS_D64_V2_BUILD_V1','body_status':'CURRENT_RESEARCH_REFERENCE','stage1':{'bytes':len(s1),'sha256':sha(BUILD/'stage1.bin'),'signature_55aa':s1[510:]==b'\x55\xaa'},'stage2':{'raw_bytes':len(raw),'raw_sha256':sha(BUILD/'stage2.raw.bin'),'padded_bytes':len(padded),'padded_sha256':sha(BUILD/'stage2.padded.bin'),'envelope_bytes':STAGE2_ENVELOPE,'image_memory_bytes':image_memory_bytes},'state':{'expected_bytes':EXPECTED_STATE_BYTES,'actual_bytes':state_bytes,'begin':syms['v2_state_begin'],'end':syms['v2_state_end']},'disk':{'bytes':len(disk),'sha256':sha(BUILD/'d64_v2.img')},'tools':tools}
 (BUILD/'build_manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest,indent=2));return 0
if __name__=='__main__':raise SystemExit(main())
