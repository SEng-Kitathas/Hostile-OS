from __future__ import annotations
import hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=HERE/'build'
PARENT=ROOT/'research'/'targets'/'H1_PHYSICAL_PROBE'
FLOPPY_BYTES=1474560
EXPECTED_PHYSICAL_STAGE2='c12ea44714fd2c4d7dd3590c259e0f196cd38b8a979af8618ddaf79ac31f677d'
EXPECTED_QEMU_STAGE2='2b7c0c2b47f751b716d4340aa7e0764d16a07eb49b8d036311d7d9f8e13234e2'
PROBE_LBA=9

def sha(p:Path)->str:
 h=hashlib.sha256()
 with p.open('rb') as f:
  for c in iter(lambda:f.read(1<<20),b''):h.update(c)
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

def run(a,cwd=HERE,env=None): subprocess.run([str(x) for x in a],cwd=cwd,env=env,check=True)

def compile_raw(clang,lld,obj,src,lds,outstem):
 o=BUILD/(outstem+'.o'); elf=BUILD/(outstem+'.elf'); raw=BUILD/(outstem+'.bin')
 run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c',src,'-o',o])
 run([lld,'-m','elf_i386','-T',lds,o,'-o',elf])
 run([obj,'-O','binary',elf,raw])
 return raw

def main():
 BUILD.mkdir(exist_ok=True)
 llvm=Path(os.environ['HOSTILE_LLVM_BIN']) if os.environ.get('HOSTILE_LLVM_BIN') else None
 clang=find('HOSTILE_CLANG',['clang.exe','clang'],llvm); lld=find('HOSTILE_LLD',['ld.lld.exe','ld.lld'],llvm); obj=find('HOSTILE_OBJCOPY',['llvm-objcopy.exe','llvm-objcopy'],llvm)
 env=os.environ.copy()
 if llvm: env['HOSTILE_LLVM_BIN']=str(llvm)
 run([shutil.which('python') or 'python',PARENT/'build.py'],cwd=PARENT,env=env)
 parent_phys=PARENT/'build'/'stage2.bin'; parent_qemu=PARENT/'build'/'stage2_QEMU_EXIT.bin'
 if sha(parent_phys)!=EXPECTED_PHYSICAL_STAGE2: raise SystemExit('qualified physical probe stage2 hash changed')
 if sha(parent_qemu)!=EXPECTED_QEMU_STAGE2: raise SystemExit('qualified QEMU probe stage2 hash changed')
 s1=compile_raw(clang,lld,obj,'wrapper_stage1.S','wrapper_stage1.ld','wrapper_stage1')
 loader=compile_raw(clang,lld,obj,'text_loader.S','text_loader.ld','text_loader')
 b1=s1.read_bytes(); bl=loader.read_bytes()
 if len(b1)!=512 or b1[510:]!=b'\x55\xaa': raise SystemExit('bad wrapper stage1')
 if len(bl)>4096: raise SystemExit(f'text loader too large: {len(bl)}')
 def compose(probe:bytes,name:str):
  if len(probe)>8192: raise SystemExit('probe stage2 exceeds reserved envelope')
  disk=bytearray(FLOPPY_BYTES)
  disk[:512]=b1
  disk[512:512+len(bl)]=bl
  disk[PROBE_LBA*512:PROBE_LBA*512+len(probe)]=probe
  p=BUILD/name; p.write_bytes(disk); return p
 phys=compose(parent_phys.read_bytes(),'h1_probe_text_physical.img')
 qemu=compose(parent_qemu.read_bytes(),'h1_probe_text_qemu.img')
 sources=['H1_TEXT_WRAPPER_PREREGISTRATION_2026-08-31.md','wrapper_stage1.S','wrapper_stage1.ld','text_loader.S','text_loader.ld','build.py']
 manifest={'format':'HOSTILE_H1_TEXT_WRAPPER_BUILD_V1','parent_probe':{'physical_stage2_sha256':sha(parent_phys),'qemu_stage2_sha256':sha(parent_qemu)},'wrapper_stage1':{'bytes':len(b1),'sha256':sha(s1)},'text_loader':{'bytes':len(bl),'envelope':4096,'headroom':4096-len(bl),'sha256':sha(loader)},'physical_image':{'bytes':phys.stat().st_size,'sha256':sha(phys)},'qemu_image':{'bytes':qemu.stat().st_size,'sha256':sha(qemu)},'layout':{'stage1_lba':0,'loader_lba_start':1,'loader_lba_count':8,'probe_lba_start':PROBE_LBA,'probe_lba_count':16},'sources':{x:sha(HERE/x) for x in sources},'tool_paths':{'clang':str(clang),'lld':str(lld),'objcopy':str(obj)}}
 (BUILD/'build_manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(manifest,indent=2,sort_keys=True)); return 0
if __name__=='__main__': raise SystemExit(main())
