from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P01-reconstruction-evaluator-v1"
EXPECTED = ["R_WC=PASS", "R_CW=PASS", "B_CW=FAIL", "DONE"]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: evaluate_reconstruction.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64
    debugcon = Path(sys.argv[1])
    result_path = Path(sys.argv[2])
    raw = debugcon.read_text(encoding="ascii")
    lines = raw.splitlines()
    passed = lines == EXPECTED
    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "debugcon_path": str(debugcon),
        "debugcon_sha256": sha256(debugcon),
        "expected_lines": EXPECTED,
        "observed_lines": lines,
        "passed": passed,
        "interpretation": (
            "repaired wait->complete and complete->wait both converge; "
            "broken one-shot complete->wait remains discriminated"
            if passed
            else "reconstruction discriminator did not meet its preregistered observation contract"
        ),
        "authority_ceiling": (
            "non-source-equivalent reconstruction probe only; does not complete the "
            "source-grounded C003/P01 Python-host subsidy inventory"
        ),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"debugcon_sha256={result['debugcon_sha256']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
