from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P04-restart-persistence-v1"
BOOT1_EXPECTED = ["BOOT1_INIT=PASS"]
BOOT2_EXPECTED = [
    "BOOT2_DURABLE=PASS",
    "BOOT2_STALE=EXPIRED",
    "BOOT2_REBIND=PASS",
]
PREFIX = b"HOS4R\x5a"
SECTOR_BYTES = 512
SECTOR_INDEX = 1


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) != 6:
        print("usage: evaluate_p04.py BOOT1_DEBUG BOOT2_DEBUG DISK_IMAGE SECTOR_EXTRACT RESULT_JSON", file=sys.stderr)
        return 64

    boot1 = Path(sys.argv[1])
    boot2 = Path(sys.argv[2])
    disk = Path(sys.argv[3])
    sector_extract = Path(sys.argv[4])
    result_path = Path(sys.argv[5])

    boot1_lines = boot1.read_text(encoding="ascii").splitlines()
    boot2_lines = boot2.read_text(encoding="ascii").splitlines()
    disk_bytes = disk.read_bytes()
    start = SECTOR_INDEX * SECTOR_BYTES
    sector = disk_bytes[start:start + SECTOR_BYTES]
    extracted = sector_extract.read_bytes()

    checks = {
        "boot1_exact": boot1_lines == BOOT1_EXPECTED,
        "boot2_exact": boot2_lines == BOOT2_EXPECTED,
        "disk_large_enough": len(disk_bytes) >= start + SECTOR_BYTES,
        "sector_extract_exact": extracted == sector,
        "durable_prefix_exact": len(sector) == SECTOR_BYTES and sector[:6] == PREFIX,
        "durable_tail_zero": len(sector) == SECTOR_BYTES and all(b == 0 for b in sector[6:]),
    }
    passed = all(checks.values())

    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "boot1_expected_lines": BOOT1_EXPECTED,
        "boot1_observed_lines": boot1_lines,
        "boot2_expected_lines": BOOT2_EXPECTED,
        "boot2_observed_lines": boot2_lines,
        "checks": checks,
        "disk_sha256": sha256(disk),
        "sector_extract_sha256": sha256(sector_extract),
        "sector_prefix_hex": sector[:6].hex() if len(sector) >= 6 else "",
        "passed": passed,
        "interpretation": (
            "durable record survived a complete QEMU process restart; volatile runtime access began expired and became current only after explicit fresh rebind"
            if passed
            else "P04 restart-persistence discriminator did not satisfy the preregistered observation contract"
        ),
        "authority_ceiling": "bounded clean-restart QEMU/raw-floppy/BIOS transport only; no crash consistency, filesystem, physical-device timing, storage-subsystem, or architecture claim",
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"disk_sha256={result['disk_sha256']}")
    print(f"sector_prefix_hex={result['sector_prefix_hex']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
