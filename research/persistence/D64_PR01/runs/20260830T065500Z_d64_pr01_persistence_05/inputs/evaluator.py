from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

VERSION = "D64-PR01-clean-restart-persistence-v1"

EXPECTED_BOOT1 = [
    "S1_8K_OK", "BOOT=1", "DURABLE_PRESENT=00", "A_ACQ=W",
    "A_SLOT=00", "A_GEN=01", "A_EPOCH=01", "BIND=W",
    "BIND_INDEX=00", "BIND_GEN=01", "RES_SLOT=00", "RES_GEN=01",
    "RES_EPOCH=01", "READ=W", "READ_VAL=7E", "PERSIST1=W",
    "DETACH=W", "LIVE_AFTER_DETACH=0000", "RES_ID_AFTER_DETACH=00",
    "RELEASE=W", "ACT_ID_AFTER_RELEASE=00", "DONE1",
]

EXPECTED_BOOT2 = [
    "S1_8K_OK", "BOOT=2", "DURABLE_PRESENT=01", "DUR_ID=51",
    "DUR_VAL=7E", "DUR_ACT_EPOCH=01", "DUR_RES_EPOCH=01",
    "OLD_BIND_PRE=R", "OLD_RES_PRE=R", "A_ACQ=W", "A_SLOT=00",
    "A_GEN=01", "A_EPOCH=02", "REBIND=W", "BIND_INDEX=00",
    "BIND_GEN=01", "RES_SLOT=00", "RES_GEN=01", "RES_EPOCH=02",
    "OLD_BIND_POST=R", "OLD_RES_POST=R", "FRESH_BIND=W",
    "FRESH_BIND_VAL=7E", "FRESH_RES=W", "FRESH_RES_VAL=7E",
    "BAD_BIND_EPOCHLESS=W", "BAD_BIND_VAL=7E", "BAD_RES_EPOCHLESS=W",
    "BAD_RES_VAL=7E", "PERSIST2=W", "DONE2",
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: evaluate_pr01.py BOOT1_DEBUG BOOT2_DEBUG OUTPUT_JSON", file=sys.stderr)
        return 64
    boot1, boot2, out = map(Path, sys.argv[1:])
    observed1 = boot1.read_text(encoding="ascii").splitlines()
    observed2 = boot2.read_text(encoding="ascii").splitlines()
    pass1 = observed1 == EXPECTED_BOOT1
    pass2 = observed2 == EXPECTED_BOOT2
    result = {
        "evaluator_version": VERSION,
        "boot1_debugcon_sha256": sha256(boot1),
        "boot2_debugcon_sha256": sha256(boot2),
        "boot1_expected_lines": EXPECTED_BOOT1,
        "boot1_observed_lines": observed1,
        "boot1_passed": bool(pass1),
        "boot2_expected_lines": EXPECTED_BOOT2,
        "boot2_observed_lines": observed2,
        "boot2_passed": bool(pass2),
        "passed": bool(pass1 and pass2),
        "authority_ceiling": "two clean QEMU boots over one shared disk; D64 runtime relation rebuilt under fresh activity/resource epochs",
    }
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if result["passed"] else "EVAL_FAIL")
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
