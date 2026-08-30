from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P03-mutation-coherence-v1"
EXPECTED = [
    "RAW_CUT=S",
    "RAW_POST=C",
    "GUARD_CUT=R",
    "GUARD_POST=C",
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
        print("usage: evaluate_p03.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64
    debugcon = Path(sys.argv[1])
    result_path = Path(sys.argv[2])
    observed = debugcon.read_text(encoding="ascii").splitlines()
    passed = observed == EXPECTED
    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "debugcon_sha256": sha256(debugcon),
        "expected_lines": EXPECTED,
        "observed_lines": observed,
        "passed": passed,
        "interpretation": (
            "unguarded cut exposes stale history; guarded cut rejects intermediate state and post-commit state is coherent"
            if passed
            else "P03 mutation-coherence discriminator did not meet preregistered observation contract"
        ),
        "authority_ceiling": (
            "single-core bounded explicit-cut model only; no general linearizability, lock-freedom, interrupt, SMP, memory-ordering, or architecture claim"
        ),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"debugcon_sha256={result['debugcon_sha256']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
