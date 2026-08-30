from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

IMAGE_BYTES = 1_474_560
SECTOR_BYTES = 512
STAGE2_EXTENT = 4096
EXPECTED_STAGE1_SHA256 = "bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8"
EXPECTED_STAGE2_SHA256 = "2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be"
EXPECTED_INITIAL_DISK_SHA256 = "b9c79c821d0be352132e940201f23d1e2bcd0456d994a1a142fd01a183bc4218"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def first_line(argv: list[str]) -> str:
    try:
        cp = subprocess.run(argv, text=True, capture_output=True, timeout=10, check=False)
        text = (cp.stdout + cp.stderr).strip().splitlines()
        return text[0] if text else "<no version output>"
    except Exception as exc:
        return f"<version query failed: {exc}>"


def find_tool(env_name: str, names: list[str], llvm_bin: Path | None = None) -> Path:
    explicit = os.environ.get(env_name)
    if explicit:
        p = Path(explicit).expanduser()
        if p.is_file():
            return p.resolve()
        raise SystemExit(f"{env_name} points to missing file: {p}")
    if llvm_bin is not None:
        for name in names:
            p = llvm_bin / name
            if p.is_file():
                return p.resolve()
    for name in names:
        found = shutil.which(name)
        if found:
            return Path(found).resolve()
    raise SystemExit(
        f"missing tool for {env_name}; set {env_name}, set HOSTILE_LLVM_BIN, or put one of {names} on PATH"
    )


def run(argv: list[str], cwd: Path) -> None:
    print("+", " ".join(argv))
    cp = subprocess.run(argv, cwd=cwd, check=False)
    if cp.returncode != 0:
        raise SystemExit(cp.returncode)


def main() -> int:
    ap = argparse.ArgumentParser(description="Build the HOSTILE-OS I001 research-only embodiment")
    ap.add_argument("--out", default="build", help="output directory relative to this file unless absolute")
    args = ap.parse_args()

    here = Path(__file__).resolve().parent
    src = here / "src"
    out = Path(args.out)
    if not out.is_absolute():
        out = here / out
    out.mkdir(parents=True, exist_ok=True)

    llvm_bin_env = os.environ.get("HOSTILE_LLVM_BIN")
    llvm_bin = Path(llvm_bin_env).expanduser().resolve() if llvm_bin_env else None
    clang = find_tool("HOSTILE_CLANG", ["clang", "clang.exe"], llvm_bin)
    lld = find_tool("HOSTILE_LLD", ["ld.lld", "ld.lld.exe"], llvm_bin)
    objcopy = find_tool("HOSTILE_OBJCOPY", ["llvm-objcopy", "llvm-objcopy.exe"], llvm_bin)

    s1o, s1elf, s1bin = out / "stage1.o", out / "stage1.elf", out / "stage1.bin"
    s2o, s2elf, s2raw = out / "stage2.o", out / "stage2.elf", out / "stage2.raw.bin"
    s2pad, disk = out / "stage2.padded.bin", out / "hostile-research-os.img"

    commands = [
        [str(clang), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(src / "stage1.S"), "-o", str(s1o)],
        [str(lld), "-m", "elf_i386", "-T", str(src / "stage1.ld"), str(s1o), "-o", str(s1elf)],
        [str(objcopy), "-O", "binary", str(s1elf), str(s1bin)],
        [str(clang), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(src / "stage2.S"), "-o", str(s2o)],
        [str(lld), "-m", "elf_i386", "-T", str(src / "stage2.ld"), str(s2o), "-o", str(s2elf)],
        [str(objcopy), "-O", "binary", str(s2elf), str(s2raw)],
    ]
    for command in commands:
        run(command, here)

    stage1 = s1bin.read_bytes()
    stage2 = s2raw.read_bytes()
    if len(stage1) != 512 or stage1[510:] != b"\x55\xaa":
        raise SystemExit(f"stage1 contract failed: bytes={len(stage1)} signature={stage1[510:].hex() if len(stage1)>=512 else 'short'}")
    if len(stage2) > STAGE2_EXTENT:
        raise SystemExit(f"stage2 too large: {len(stage2)} > {STAGE2_EXTENT}")

    padded = stage2 + bytes(STAGE2_EXTENT - len(stage2))
    s2pad.write_bytes(padded)
    image = bytearray(IMAGE_BYTES)
    image[:SECTOR_BYTES] = stage1
    image[SECTOR_BYTES:SECTOR_BYTES + STAGE2_EXTENT] = padded
    disk.write_bytes(image)

    manifest = {
        "format": "HOSTILE_OS_RESEARCH_ONLY_BUILD_V1",
        "warning": "RESEARCH PURPOSES ONLY; NOT A RELEASE OR ARCHITECTURE PROMOTION",
        "tools": {
            "clang": {"path": str(clang), "version": first_line([str(clang), "--version"]), "sha256": sha256(clang)},
            "lld": {"path": str(lld), "version": first_line([str(lld), "--version"]), "sha256": sha256(lld)},
            "objcopy": {"path": str(objcopy), "version": first_line([str(objcopy), "--version"]), "sha256": sha256(objcopy)},
            "python": {"path": sys.executable, "version": sys.version.splitlines()[0], "sha256": sha256(Path(sys.executable))},
        },
        "source_sha256": {p.name: sha256(p) for p in sorted(src.iterdir()) if p.is_file()},
        "artifacts": {
            "stage1.bin": {"bytes": len(stage1), "sha256": sha256(s1bin), "matches_i001": sha256(s1bin) == EXPECTED_STAGE1_SHA256},
            "stage2.raw.bin": {"bytes": len(stage2), "sha256": sha256(s2raw), "matches_i001": sha256(s2raw) == EXPECTED_STAGE2_SHA256},
            "stage2.padded.bin": {"bytes": len(padded), "sha256": sha256(s2pad)},
            "hostile-research-os.img": {"bytes": len(image), "sha256": sha256(disk), "matches_i001_initial": sha256(disk) == EXPECTED_INITIAL_DISK_SHA256},
        },
        "commands": commands,
    }
    (out / "build_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(manifest["artifacts"], indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
