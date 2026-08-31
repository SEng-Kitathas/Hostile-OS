from __future__ import annotations
import hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]; BUILD=HERE/'build'
FLOPPY_BYTES=1474560; PROBE_LBA=9; LOG_BASE_LBA=256; LOG_SECTORS=128; LOG_BYTES=LOG_SECTORS*512

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
def compile_raw(clang,lld,obj,src,lds,outstem,defs=()):
 o=BUILD/(outstem+'.o'); elf=BUILD/(outstem+'.elf'); raw=BUILD/(outstem+'.bin')
 run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c',src,'-o',o,*['-D'+d for d in defs]])
 run([lld,'-m','elf_i386','-T',lds,o,'-o',elf])
 run([obj,'-O','binary',elf,raw])
 return raw

def main():
 BUILD.mkdir(exist_ok=True)
 llvm=Path(os.environ['HOSTILE_LLVM_BIN']) if os.environ.get('HOSTILE_LLVM_BIN') else None
 clang=find('HOSTILE_CLANG',['clang.exe','clang'],llvm); lld=find('HOSTILE_LLD',['ld.lld.exe','ld.lld'],llvm); obj=find('HOSTILE_OBJCOPY',['llvm-objcopy.exe','llvm-objcopy'],llvm)
 s1=compile_raw(clang,lld,obj,'wrapper_stage1.S','wrapper_stage1.ld','wrapper_stage1')
 loader=compile_raw(clang,lld,obj,'text_loader.S','text_loader.ld','text_loader')
 probe_phys=compile_raw(clang,lld,obj,'stage2.S','stage2.ld','stage2')
 probe_qemu=compile_raw(clang,lld,obj,'stage2.S','stage2.ld','stage2_QEMU_EXIT',('QEMU_EXIT',))
 b1=s1.read_bytes(); bl=loader.read_bytes(); bp=probe_phys.read_bytes(); bq=probe_qemu.read_bytes()
 if len(b1)!=512 or b1[510:]!=b'\x55\xaa': raise SystemExit('bad wrapper stage1')
 if len(bl)>4096: raise SystemExit(f'logger loader too large: {len(bl)}')
 if len(bp)>8192 or len(bq)>8192: raise SystemExit(f'logging probe exceeds 8KiB: {len(bp)}/{len(bq)}')
 def compose(probe:bytes,name:str):
  disk=bytearray(FLOPPY_BYTES)
  disk[:512]=b1
  disk[512:512+len(bl)]=bl
  disk[PROBE_LBA*512:PROBE_LBA*512+len(probe)]=probe
  # LOG_BASE_LBA..LOG_BASE_LBA+LOG_SECTORS starts zero by construction.
  p=BUILD/name; p.write_bytes(disk); return p
 phys=compose(bp,'h1_probe_durable_log_physical.img'); qemu=compose(bq,'h1_probe_durable_log_qemu.img')
 sources=['H1_DURABLE_LOG_PREREGISTRATION_2026-08-31.md','wrapper_stage1.S','wrapper_stage1.ld','text_loader.S','text_loader.ld','stage2.S','stage2.ld','build.py','verify_static.py','extract_log.py','run_qemu_qualification.py']
 man={'format':'HOSTILE_H1_DURABLE_LOG_BUILD_V1','wrapper_stage1':{'bytes':len(b1),'sha256':sha(s1)},'logger_loader':{'bytes':len(bl),'envelope':4096,'headroom':4096-len(bl),'sha256':sha(loader)},'probe_physical':{'bytes':len(bp),'envelope':8192,'headroom':8192-len(bp),'sha256':sha(probe_phys)},'probe_qemu':{'bytes':len(bq),'envelope':8192,'headroom':8192-len(bq),'sha256':sha(probe_qemu)},'physical_image':{'bytes':phys.stat().st_size,'sha256':sha(phys)},'qemu_image':{'bytes':qemu.stat().st_size,'sha256':sha(qemu)},'layout':{'stage1_lba':0,'loader_lba_start':1,'loader_lba_count':8,'probe_lba_start':PROBE_LBA,'probe_lba_count':16,'journal_lba_start':LOG_BASE_LBA,'journal_sector_count':LOG_SECTORS,'journal_bytes':LOG_BYTES},'sources':{x:sha(HERE/x) for x in sources},'tool_paths':{'clang':str(clang),'lld':str(lld),'objcopy':str(obj)}}
 (BUILD/'build_manifest.json').write_text(json.dumps(man,indent=2,sort_keys=True)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(man,indent=2,sort_keys=True)); return 0
if __name__=='__main__': raise SystemExit(main())
