from pathlib import Path
import os,subprocess,hashlib,json
H=Path(__file__).resolve().parent;B=H/'build_chs_single';B.mkdir(exist_ok=True)
llvm=Path(os.environ['HOSTILE_LLVM_BIN']); clang=llvm/'clang.exe';lld=llvm/'ld.lld.exe';obj=llvm/'llvm-objcopy.exe'
def run(a):subprocess.run([str(x) for x in a],cwd=H,check=True)
run([clang,'-target','i386-unknown-none-elf','-ffreestanding','-c','stage1_chs_single.S','-o',B/'stage1.o'])
run([lld,'-m','elf_i386','-T','stage1_chs_single.ld',B/'stage1.o','-o',B/'stage1.elf'])
run([obj,'-O','binary',B/'stage1.elf',B/'stage1.bin'])
s=(B/'stage1.bin').read_bytes()
if len(s)!=512 or s[510:]!=b'\x55\xaa':raise SystemExit(f'bad stage1 {len(s)}')
img=bytearray(1048576);img[:512]=s
ref=(H.parent/'H1_PHYSICAL_PROBE_DURABLE_LOG_EDD_BOOT'/'build'/'h1_probe_durable_log_physical.img').read_bytes()
img[512:1024]=ref[512:1024]
p=B/'h1_bios_usb_read_chs_single_1MiB.img';p.write_bytes(img)
print(json.dumps({'image_sha256':hashlib.sha256(img).hexdigest(),'stage1_sha256':hashlib.sha256(s).hexdigest(),'lba1_sha256':hashlib.sha256(img[512:1024]).hexdigest()},indent=2))
