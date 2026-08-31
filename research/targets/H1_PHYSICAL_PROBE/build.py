from __future__ import annotations
import hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent; BUILD=HERE/'build'; ENVELOPE=8192

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''): h.update(c)
 return h.hexdigest()

def find(env,names,llvm):
 v=os.environ.get(env)
 if v:
  p=Path(v); assert p.is_file(),p; return p
 if llvm:
  for n in names:
   p=llvm/n
   if p.is_file(): return p
 for n in names:
  q=shutil.which(n)
  if q:return Path(q)
 raise SystemExit(f'missing {env}')

def run(a): subprocess.run([str(x) for x in a],cwd=HERE,check=True)

def build_one(clang,lld,obj,name,defs=()):
 tag=name+(''.join('_'+d for d in defs) if defs else '')
 o=BUILD/(tag+'.o'); elf=BUILD/(tag+'.elf'); raw=BUILD/(tag+'.bin')
 run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c',name+'.S','-o',o,*['-D'+d for d in defs]])
 run([lld,'-m','elf_i386','-T',name+'.ld',o,'-o',elf])
 run([obj,'-O','binary',elf,raw])
 return raw,elf

def main():
 BUILD.mkdir(exist_ok=True)
 llvm=Path(os.environ['HOSTILE_LLVM_BIN']) if os.environ.get('HOSTILE_LLVM_BIN') else None
 clang=find('HOSTILE_CLANG',['clang.exe','clang'],llvm); lld=find('HOSTILE_LLD',['ld.lld.exe','ld.lld'],llvm); obj=find('HOSTILE_OBJCOPY',['llvm-objcopy.exe','llvm-objcopy'],llvm)
 s1,_=build_one(clang,lld,obj,'stage1')
 phys,_=build_one(clang,lld,obj,'stage2')
 qemu,_=build_one(clang,lld,obj,'stage2',('QEMU_EXIT',))
 b1=s1.read_bytes(); bp=phys.read_bytes(); bq=qemu.read_bytes()
 assert len(b1)==512 and b1[510:]==b'\x55\xaa',len(b1)
 assert len(bp)<=ENVELOPE and len(bq)<=ENVELOPE,(len(bp),len(bq))
 def image(stage2:bytes,name:str):
  disk=bytearray(1474560); disk[:512]=b1; disk[512:512+len(stage2)]=stage2
  p=BUILD/name; p.write_bytes(disk); return p
 pi=image(bp,'h1_probe_physical.img'); qi=image(bq,'h1_probe_qemu.img')
 sources=['H1_PHYSICAL_PROBE_PREREGISTRATION_2026-08-31.md','stage1.S','stage1.ld','stage2.S','stage2.ld','build.py']
 m={'format':'HOSTILE_H1_PHYSICAL_PROBE_BUILD_V1','stage1':{'bytes':len(b1),'sha256':sha(s1)},'stage2_physical':{'bytes':len(bp),'headroom':ENVELOPE-len(bp),'sha256':sha(phys)},'stage2_qemu':{'bytes':len(bq),'headroom':ENVELOPE-len(bq),'sha256':sha(qemu)},'physical_image':{'bytes':pi.stat().st_size,'sha256':sha(pi)},'qemu_image':{'bytes':qi.stat().st_size,'sha256':sha(qi)},'sources':{x:sha(HERE/x) for x in sources},'tool_paths':{'clang':str(clang),'lld':str(lld),'objcopy':str(obj)}}
 (BUILD/'build_manifest.json').write_text(json.dumps(m,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n'); print(json.dumps(m,indent=2)); return 0
if __name__=='__main__': raise SystemExit(main())
