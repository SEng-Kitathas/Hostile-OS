from pathlib import Path
import os,subprocess,hashlib,json
H=Path(__file__).resolve().parent; B=H/'build'; B.mkdir(exist_ok=True)
llvm=Path(os.environ['HOSTILE_LLVM_BIN']); clang=llvm/'clang.exe'; lld=llvm/'ld.lld.exe'; obj=llvm/'llvm-objcopy.exe'
def run(a):subprocess.run([str(x) for x in a],cwd=H,check=True)
run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c','stage1.S','-o',B/'stage1.o'])
run([lld,'-m','elf_i386','-T','stage1.ld',B/'stage1.o','-o',B/'stage1.elf'])
run([obj,'-O','binary',B/'stage1.elf',B/'stage1.bin'])
b=(B/'stage1.bin').read_bytes()
if len(b)!=512 or b[510:512]!=b'\x55\xaa':raise SystemExit(f'bad stage1 {len(b)} {b[510:512].hex()}')
img=bytearray(1048576);img[:512]=b
p=B/'h1_bios_usb_write_discriminator_1MiB.img';p.write_bytes(img)
print(json.dumps({'bytes':len(img),'sha256':hashlib.sha256(img).hexdigest(),'stage1_sha256':hashlib.sha256(b).hexdigest()},indent=2))
