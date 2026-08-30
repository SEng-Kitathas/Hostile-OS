from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

VERSION = "D64-STAGE2-8K-LOADER-STATIC-v1"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    if len(sys.argv) != 11:
        print("usage: static_check_8k_loader.py STAGE1_S STAGE1_LD STAGE2_S STAGE2_LD STAGE2_RAW STAGE2_PADDED DISK MANIFEST RECEIPT OUT", file=sys.stderr)
        return 64
    stage1_s, stage1_ld, stage2_s, stage2_ld, stage2_raw, stage2_padded, disk, manifest, receipt, out = map(Path, sys.argv[1:])
    s1 = stage1_s.read_text(encoding="utf-8").replace("\r\n", "\n")
    l1 = stage1_ld.read_text(encoding="utf-8").replace("\r\n", "\n")
    s2 = stage2_s.read_text(encoding="utf-8").replace("\r\n", "\n")
    l2 = stage2_ld.read_text(encoding="utf-8").replace("\r\n", "\n")
    raw = stage2_raw.read_bytes()
    padded = stage2_padded.read_bytes()
    image = disk.read_bytes()
    m = json.loads(manifest.read_text(encoding="utf-8"))
    r = json.loads(receipt.read_text(encoding="utf-8"))
    checks = {}
    checks["stage1_chs_16_sector_contract"] = bool(all(x in s1 for x in ["movb $0x02,%ah", "movb $0x10,%al", "movb $0x00,%ch", "movb $0x02,%cl", "movb $0x00,%dh", "ljmp $0x0000,$0x8000"]))
    checks["stage1_signature_linker"] = bool(".sig 0x7dfe" in l1 and "SHORT(0xaa55)" in l1)
    checks["stage2_tail_linker"] = bool(". = 0x9ff0" in l2 and "ASSERT(. <= 0xa000" in l2)
    checks["stage2_tail_checked_before_success"] = bool("tail_marker:.byte 0xa5" in s2 and "cmpb $0xa5,tail_marker" in s2 and s2.find("cmpb $0xa5,tail_marker") < s2.find("msg_ok"))
    checks["stage2_raw_tail_marker"] = bool(len(raw) > 0x1FF0 and raw[0x1FF0] == 0xA5)
    checks["stage2_padded_exact_8192"] = bool(len(padded) == 8192)
    checks["sector18_untouched_zero"] = bool(len(image) >= 18 * 512 and set(image[17*512:18*512]) <= {0})
    snap_ok = True
    snap_map = {}
    for item in m.get("inputs", []):
        p = manifest.parent / item["snapshot_path"]
        ok = p.exists() and p.stat().st_size == item["bytes"] and sha256(p) == item["sha256"]
        snap_ok = snap_ok and ok
        snap_map[item["key"]] = item["sha256"]
    checks["manifest_receipt_sources_match"] = bool(snap_ok and r.get("input_manifest_sha256") == sha256(manifest) and all(r.get("source_sha256", {}).get(k) == v for k, v in snap_map.items()))
    launcher_text = (manifest.parent / "inputs" / "launch_8k_loader.py").read_text(encoding="utf-8")
    evaluator_text = (manifest.parent / "inputs" / "evaluate_8k_loader.py").read_text(encoding="utf-8")
    checks["host_no_guest_trace_or_memory_synthesis"] = bool(all(x not in launcher_text for x in ["S1_8K_OK", "S2_8K_OK", "debug.write_text", "debug.write_bytes"]) and all(x not in evaluator_text for x in ["debug.write_text", "debug.write_bytes"]))
    result = {
        "checker_version": VERSION,
        "checks": checks,
        "passed": bool(all(checks.values())),
        "stage1_sha256": sha256(stage1_s),
        "stage2_sha256": sha256(stage2_s),
        "input_manifest_sha256": sha256(manifest),
    }
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
