from __future__ import annotations
import hashlib
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "infra/reproduction/qemu_transplant/PATCH_003"
OUTPUT = ROOT / "payload_history/lab_tooling/HOSTILE_OS_SMUGGLE_PATCH_003.zip"
FIXED_DATE = (2026, 8, 30, 12, 0, 0)


def main() -> int:
    files = sorted(p for p in SOURCE.rglob("*") if p.is_file())
    with zipfile.ZipFile(OUTPUT, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for path in files:
            rel = path.relative_to(SOURCE).as_posix()
            info = zipfile.ZipInfo(rel, date_time=FIXED_DATE)
            info.compress_type = zipfile.ZIP_DEFLATED
            # Preserve executable bit for shell wrapper; ordinary 0644 otherwise.
            mode = 0o755 if rel.endswith(".sh") else 0o644
            info.external_attr = (mode & 0xFFFF) << 16
            z.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    h = hashlib.sha256(OUTPUT.read_bytes()).hexdigest()
    print(f"{OUTPUT.relative_to(ROOT).as_posix()} bytes={OUTPUT.stat().st_size} sha256={h}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
