from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P02-membership-history-v1"
EXPECTED = [
    "PRE_ID=C",
    "PRE_IDX=C",
    "POST_ID=C",
    "POST_IDX=B",
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
        print("usage: evaluate_p02.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64

    debugcon = Path(sys.argv[1])
    result_path = Path(sys.argv[2])
    raw = debugcon.read_text(encoding="ascii")
    observed = raw.splitlines()
    passed = observed == EXPECTED

    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "debugcon_path": str(debugcon),
        "debugcon_sha256": sha256(debugcon),
        "expected_lines": EXPECTED,
        "observed_lines": observed,
        "passed": passed,
        "interpretation": (
            "pre-mutation identity/index controls agree; post-mutation identity history preserves C while stale numeric history drifts to B"
            if passed
            else "P02 membership/history discriminator did not meet preregistered observation contract"
        ),
        "authority_ceiling": (
            "bounded fixed-capacity membership/history discriminator only; no exact C002 source-reliance claim, general scheduler/fairness claim, multicore atomicity claim, or architecture promotion"
        ),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"debugcon_sha256={result['debugcon_sha256']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
