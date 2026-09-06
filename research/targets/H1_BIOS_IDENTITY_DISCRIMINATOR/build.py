from pathlib import Path
import hashlib, json, os, subprocess

HERE = Path(__file__).resolve().parent
BUILD = HERE / "build"
BUILD.mkdir(exist_ok=True)
LLVM = Path(os.environ.get(
    "HOSTILE_LLVM_BIN",
    r"E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin",
))
CLANG = LLVM / "clang.exe"
LLD = LLVM / "ld.lld.exe"
OBJCOPY = LLVM / "llvm-objcopy.exe"
SRC = HERE / "stage1_smbios_identity.S"
LDS = HERE / "stage1_smbios_identity.ld"


def run(argv):
    subprocess.run([str(x) for x in argv], cwd=HERE, check=True)


def sha256(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def build_variant(name, defines=()):
    obj = BUILD / f"stage1_{name}.o"
    elf = BUILD / f"stage1_{name}.elf"
    raw = BUILD / f"stage1_{name}.bin"
    args = [CLANG, "-target", "i386-unknown-none-elf", "-ffreestanding"]
    for d in defines:
        args.append(f"-D{d}")
    args += ["-c", SRC, "-o", obj]
    run(args)
    run([LLD, "-m", "elf_i386", "-T", LDS, obj, "-o", elf])
    run([OBJCOPY, "-O", "binary", elf, raw])
    b = raw.read_bytes()
    if len(b) != 512 or b[510:512] != b"\x55\xaa":
        raise SystemExit(f"bad boot sector {name}: len={len(b)} sig={b[510:512].hex()}")
    image = bytearray(1024 * 1024)
    image[:512] = b
    image_path = BUILD / f"h1_bios_identity_{name}_1MiB.img"
    image_path.write_bytes(image)
    return {
        "name": name,
        "boot_sector": str(raw.relative_to(HERE)),
        "boot_sector_sha256": sha256(raw),
        "image": str(image_path.relative_to(HERE)),
        "image_bytes": len(image),
        "image_sha256": sha256(image_path),
        "lba257_initial_zero": image[257*512:(258)*512] == bytes(512),
    }


for tool in (CLANG, LLD, OBJCOPY):
    if not tool.is_file():
        raise SystemExit(f"missing tool: {tool}")

manifest = {
    "tool_paths": {"clang": str(CLANG), "lld": str(LLD), "objcopy": str(OBJCOPY)},
    "source_sha256": sha256(SRC),
    "linker_sha256": sha256(LDS),
    "variants": [
        build_variant("physical"),
        build_variant("qemu", ("QEMU_EXIT=1",)),
    ],
}
(BUILD / "build_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(json.dumps(manifest, indent=2))
