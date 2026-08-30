from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

VERSION = "D64-STAGE2-8K-LOADER-EVAL-v1"
EXPECTED = ["S1_8K_OK", "S2_8K_OK"]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: evaluate_8k_loader.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64
    debug = Path(sys.argv[1])
    out = Path(sys.argv[2])
    observed = debug.read_text(encoding="ascii").splitlines()
    passed = observed == EXPECTED
    result = {
        "evaluator_version": VERSION,
        "debugcon_sha256": sha256(debug),
        "expected_lines": EXPECTED,
        "observed_lines": observed,
        "passed": bool(passed),
        "authority_ceiling": "fixed 16-sector/8192-byte first-track stage2 loader qualification only",
    }
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
