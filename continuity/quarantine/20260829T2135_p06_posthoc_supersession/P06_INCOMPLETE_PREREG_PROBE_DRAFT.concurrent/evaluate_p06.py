from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P06-missing-operation-v1"
EXPECTED = [
    "KNOWN_STATUS=O",
    "UNKNOWN_STATUS=M",
    "BEFORE_UNKNOWN=B",
    "AFTER_UNKNOWN=B",
    "DONE",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: evaluate_p06.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64
    debugcon = Path(sys.argv[1])
    result_path = Path(sys.argv[2])
    observed = debugcon.read_text(encoding="ascii").splitlines()
    passed = observed == EXPECTED
    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "expected_lines": EXPECTED,
        "observed_lines": observed,
        "debugcon_sha256": sha256(debugcon),
        "passed": passed,
        "interpretation": (
            "known operation was accepted and mutated A->B; unknown operation returned explicit missing status and left B unchanged"
            if passed
            else "P06 bounded missing-operation discriminator did not meet its preregistered raw observation contract"
        ),
        "authority_ceiling": (
            "bounded one-byte operation/result relation only; no general syscall namespace, capability system, dynamic linking, service architecture, or architecture claim"
        ),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"debugcon_sha256={result['debugcon_sha256']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
