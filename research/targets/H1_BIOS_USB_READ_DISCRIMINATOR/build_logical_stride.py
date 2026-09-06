from pathlib import Path
import os,subprocess,hashlib,json
H=Path(__file__).resolve().parent;B=H/'build_logical_stride';B.mkdir(exist_ok=True)
llvm=Path(os.environ['HOSTILE_LLVM_BIN']); clang=llvm/'clang.exe';lld=llvm/'ld.lld.exe';obj=llvm/'llvm-objcopy.exe'
def run(a):subprocess.run([str(x) for x in a],cwd=H,check=True)
run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c','stage1_logical_stride.S','-o',B/'stage1.o'])
run([lld,'-m','elf_i386','-T','stage1_logical_stride.ld',B/'stage1.o','-o',B/'stage1.elf'])
run([obj,'-O','binary',B/'stage1.elf',B/'stage1.bin'])
s=(B/'stage1.bin').read_bytes()
if len(s)!=512 or s[510:]!=b'\x55\xaa': raise SystemExit(f'bad stage1 {len(s)}')
img=bytearray(1048576); img[:512]=s
for off,tag in [(512,b'H1STRIDE_0512'),(1024,b'H1STRIDE_1024'),(2048,b'H1STRIDE_2048'),(4096,b'H1STRIDE_4096')]:
    img[off:off+len(tag)] = tag
p=B/'h1_bios_usb_read_logical_stride_1MiB.img'; p.write_bytes(img)
print(json.dumps({'image_sha256':hashlib.sha256(img).hexdigest(),'stage1_sha256':hashlib.sha256(s).hexdigest(), 'tags':{str(o):img[o:o+16].hex() for o in [512,1024,2048,4096]}},indent=2))
